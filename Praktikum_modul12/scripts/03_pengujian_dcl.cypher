// =====================================================================
// Modul 12 | Konsep Pemrosesan Query Basis Data
// DBMS     : Neo4j 5.26 Enterprise (Graph Database)
// File     : 03_pengujian_dcl.cypher
//
// Tujuan   : Menerapkan prinsip least privilege melalui RBAC Neo4j, lalu
//            membuktikan bahwa hak tersebut benar-benar berlaku.
//
// CATATAN :
//   1. Bagian B, D, dan F WAJIB dijalankan pada sesi login report_user,
//      bukan sebagai admin. Jika dijalankan sebagai admin, semua
//      pengujian akan lolos dan tidak membuktikan apa pun.
//   2. Cara paling praktis: buka DUA terminal cypher-shell.
//        Terminal 1 (admin)       : -u neo4j
//        Terminal 2 (report_user) : -u report_user
//      Bagian A, C, E, G dijalankan di terminal 1;
//      Bagian B, D, F dijalankan di terminal 2.
// =====================================================================


// =====================================================================
// BAGIAN A - DIJALANKAN SEBAGAI ADMIN (user: neo4j)
// =====================================================================

// ---------------------------------------------------------------------
// A1. Membuat peran pelaporan
//
//     Peran ini hanya memperoleh dua hak pada simpul dan relasi:
//       TRAVERSE -> boleh menelusuri simpul dan relasi
//       MATCH    -> boleh membaca seluruh properti
// ---------------------------------------------------------------------
CREATE ROLE reporter IF NOT EXISTS;

GRANT ACCESS ON DATABASE neo4j TO reporter;
GRANT TRAVERSE ON GRAPH neo4j NODES         * TO reporter;
GRANT TRAVERSE ON GRAPH neo4j RELATIONSHIPS * TO reporter;
GRANT MATCH {*} ON GRAPH neo4j NODES         * TO reporter;
GRANT MATCH {*} ON GRAPH neo4j RELATIONSHIPS * TO reporter;

// ---------------------------------------------------------------------
// A2. Membuat akun pengguna pelaporan
//
//     IF NOT EXISTS membuat perintah ini aman dijalankan berulang.
//     Perhatikan: jika pengguna sudah ada, password TIDAK diubah.
//     Untuk menyetel ulang password, jalankan baris ALTER USER di bawah.
//
// ---------------------------------------------------------------------
CREATE USER report_user
  IF NOT EXISTS
  SET PASSWORD 'GantiDenganPasswordKuat!'
  CHANGE NOT REQUIRED;

// ALTER USER report_user SET PASSWORD 'GantiDenganPasswordKuat!' CHANGE NOT REQUIRED;

GRANT ROLE reporter TO report_user;

// ---------------------------------------------------------------------
// A3. Inspeksi konfigurasi hak akses
//     Ketiga perintah ini menjadi bukti bahwa peran dan pengguna benar
//     terbentuk sebelum pengujian dilakukan.
// ---------------------------------------------------------------------
SHOW ROLES;
SHOW USERS;

SHOW ROLE reporter PRIVILEGES;


// =====================================================================
// BAGIAN B - SESI report_user: UJI IZIN BACA DAN TULIS
//
//   Salin satu per satu ke terminal 2 (report_user).
//   Perintah di bawah sengaja DIKOMENTARI agar tidak ikut berjalan
//   sebagai admin ketika berkas ini dieksekusi sekaligus.
// ---------------------------------------------------------------------

// [B0] Bukti sesi - memastikan perintah berikut benar-benar dijalankan
//      sebagai report_user, bukan sebagai admin
// SHOW CURRENT USER;
//
//   Hasil terukur: "report_user", ["reporter", "PUBLIC"]

// [B1] SELECT - HARUS BERHASIL (hak baca diberikan)
// MATCH (t:Trip)-[:ON_ROUTE]->(r:Route {route_id: 12})
// WHERE t.started_at >= datetime('2026-11-01T00:00:00')
// RETURN t.trip_id AS trip_id, r.route_name AS route_name
// ORDER BY trip_id;
//
//   Hasil terukur: 3 baris -> T001, T003, T005

// [B2] DELETE - HARUS DITOLAK
// MATCH (t:Trip {trip_id: 'T006'}) DELETE t;
//
//   Pesan terukur:
//   Delete node with labels 'Trip' on database 'neo4j' is not allowed
//   for user 'report_user' with roles [PUBLIC, reporter].

// [B3] CREATE - HARUS DITOLAK
// CREATE (:Trip {trip_id: 'T999', status: 'completed'});
//
//   Pesan terukur:
//   Create node with labels 'Trip' on database 'neo4j' is not allowed
//   for user 'report_user' with roles [PUBLIC, reporter].

// [B4] SET - HARUS DITOLAK
// MATCH (t:Trip {trip_id: 'T001'}) SET t.status = 'cancelled';
//
//   Pesan terukur:
//   Set property for property 'status' on database 'neo4j' is not
//   allowed for user 'report_user' with roles [PUBLIC, reporter].
//


// =====================================================================
// BAGIAN C - KEMBALI SEBAGAI ADMIN: PENCABUTAN HAK BACA PROPERTI
// =====================================================================

// ---------------------------------------------------------------------
// C1. Cabut MATCH pada simpul
//     Hak TRAVERSE sengaja DIBIARKAN pada langkah ini, agar pengaruh
//     kedua hak dapat dipisahkan dan diamati satu per satu.
// ---------------------------------------------------------------------
REVOKE MATCH {*} ON GRAPH neo4j NODES * FROM reporter;

// C2. Periksa konfigurasi setelah pencabutan
//     Baris "match | all_properties | NODE(*)" harus hilang, sedangkan
//     "traverse | graph | NODE(*)" masih ada.
SHOW ROLE reporter PRIVILEGES;


// =====================================================================
// BAGIAN D - SESI report_user: UJI BACA SETELAH MATCH DICABUT
//   Jalankan di terminal 2.
// ---------------------------------------------------------------------

// [D0] Bukti sesi
// SHOW CURRENT USER;

// [D1] Membaca properti - TIDAK GAGAL, tetapi properti menjadi NULL
// MATCH (t:Trip) RETURN t.trip_id AS trip_id LIMIT 5;
//
//   Hasil terukur: 5 baris, seluruh kolom trip_id bernilai NULL.
//
// [D2] Menghitung simpul - masih dapat menemukan simpulnya
// MATCH (t:Trip) RETURN count(t) AS jumlah;
//
//   Hasil terukur: 6
//


// =====================================================================
// BAGIAN E - KEMBALI SEBAGAI ADMIN: PENCABUTAN HAK TELUSUR
// =====================================================================

// E1. Cabut TRAVERSE pada simpul, sehingga tidak ada lagi hak NODE(*)
REVOKE TRAVERSE ON GRAPH neo4j NODES * FROM reporter;

// E2. Periksa konfigurasi setelah pencabutan
//     Kini tidak ada satu pun baris dengan segment NODE(*).
SHOW ROLE reporter PRIVILEGES;


// =====================================================================
// BAGIAN F - SESI report_user: UJI BACA SETELAH SEMUA HAK DICABUT
//   Jalankan di terminal 2.
// ---------------------------------------------------------------------

// [F0] Bukti sesi
// SHOW CURRENT USER;

// [F1] Menghitung simpul - simpul tidak lagi terlihat
// MATCH (t:Trip) RETURN count(t) AS jumlah;
//
//   Hasil terukur: 0

// [F2] Membaca properti - tidak ada baris yang dikembalikan
// MATCH (t:Trip) RETURN t.trip_id AS trip_id LIMIT 5;
//
//   Hasil terukur: tidak ada baris keluaran (0 baris).
//
// Catatan: tanpa TRAVERSE, pemindaian label tidak menghasilkan simpul
// apa pun. Kueri tetap berakhir normal, tetapi basis data tampak kosong
// bagi pengguna tersebut. Inilah bentuk penerapan least privilege pada
// jalur baca: data tidak sekadar disamarkan, melainkan tidak terjangkau.


// =====================================================================
// BAGIAN G - PEMULIHAN DAN PEMBERSIHAN (DIJALANKAN SEBAGAI ADMIN)
// =====================================================================

// G1. Pulihkan hak baca bila pengujian ingin diulang dari Bagian B
// GRANT MATCH {*} ON GRAPH neo4j NODES         * TO reporter;
// GRANT TRAVERSE ON GRAPH neo4j NODES         * TO reporter;
// GRANT MATCH {*} ON GRAPH neo4j RELATIONSHIPS * TO reporter;
// GRANT TRAVERSE ON GRAPH neo4j RELATIONSHIPS * TO reporter;
// SHOW ROLE reporter PRIVILEGES;

// G2. Hapus akun dan peran setelah praktikum selesai
//     Urutan penting: pengguna dihapus lebih dahulu, baru perannya.
// DROP USER report_user;
// DROP ROLE reporter;
// SHOW ROLES;
