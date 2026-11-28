// =====================================================================
// Modul 12 | Konsep Pemrosesan Query Basis Data
// DBMS lama : PostgreSQL 18 (proyek Nexora) -> DBMS target : Neo4j 5.26
// File      : 04_rancangan_migrasi_pjbl.cypher
//
// Proyek PjBL : Nexora Education
//               Sistem Informasi Manajemen Laboratorium Komputer
//
// Fitur yang dimigrasikan (satu fitur):
//   Laporan utilisasi laboratorium, yaitu jumlah sesi dan total durasi
//   pemakaian per lab per kelompok akses pada satu periode.
//
// ---------------------------------------------------------------------
// RANCANGAN SKEMA
//
// Relasional (lama)                     Graf (baru)
// -------------------------------       ------------------------------
// lab_komputer                      ->  (:Lab {nama, lokasi})
// perangkat                         ->  (:Perangkat {kode, os, gpu,
//                                            status})
// sesi_login                        ->  (:Sesi {sesi_id, mulai,
//                                            selesai, durasi_menit})
// pengguna                          ->  (:Pengguna {user_id, nama,
//                                            tipe})
// kelompok_akses                    ->  (:KelompokAkses {nama})
//
// Relasi penghubung (menggantikan kunci asing):
//   (:Perangkat)-[:BERADA_DI]->(:Lab)
//   (:Sesi)-[:DI_PERANGKAT]->(:Perangkat)
//   (:Sesi)-[:DILAKUKAN_OLEH]->(:Pengguna)
//   (:Pengguna)-[:TERGABUNG]->(:KelompokAkses)
//
// Kueri relasional setara memerlukan 4 JOIN (sesi_login, perangkat,
// lab_komputer, pengguna, kelompok_akses). Pada graf, kebutuhan itu
// dijawab satu pola penelusuran lima simpul karena hubungan sudah
// menjadi bagian dari struktur penyimpanan.
//
// =====================================================================


// ---------------------------------------------------------------------
// 1. CONSTRAINT DAN INDEX
// ---------------------------------------------------------------------
CREATE CONSTRAINT lab_nama_unique IF NOT EXISTS
FOR (l:Lab) REQUIRE l.nama IS UNIQUE;

CREATE CONSTRAINT perangkat_kode_unique IF NOT EXISTS
FOR (p:Perangkat) REQUIRE p.kode IS UNIQUE;

CREATE CONSTRAINT pengguna_id_unique IF NOT EXISTS
FOR (u:Pengguna) REQUIRE u.user_id IS UNIQUE;

CREATE CONSTRAINT kelompok_nama_unique IF NOT EXISTS
FOR (k:KelompokAkses) REQUIRE k.nama IS UNIQUE;

CREATE CONSTRAINT sesi_id_unique IF NOT EXISTS
FOR (s:Sesi) REQUIRE s.sesi_id IS UNIQUE;

// Index untuk seleksi berbasis rentang waktu. Index inilah yang menjadi
// titik masuk utama query fitur, karena periode laporan selalu berupa
// rentang tanggal.
CREATE INDEX sesi_mulai IF NOT EXISTS
FOR (s:Sesi) ON (s.mulai);


// ---------------------------------------------------------------------
// 2. DATA CONTOH (subset sintetis yang mengikuti data Nexora)
// ---------------------------------------------------------------------
UNWIND [
  {nama:'Lab DKV',        lokasi:'Gedung B Lantai 2'},
  {nama:'Lab RPL',        lokasi:'Gedung A Lantai 1'},
  {nama:'Lab Multimedia', lokasi:'Gedung D Lantai 3'},
  {nama:'Perpustakaan',   lokasi:'Gedung C Lantai 1'}
] AS row
MERGE (l:Lab {nama: row.nama})
SET   l.lokasi = row.lokasi;

UNWIND [
  {nama:'Admin',          deskripsi:'Admin IT / teknisi laboratorium'},
  {nama:'Guru',           deskripsi:'Guru pengampu'},
  {nama:'Siswa DKV',      deskripsi:'Siswa jurusan Desain Komunikasi Visual'},
  {nama:'Siswa RPL',      deskripsi:'Siswa jurusan Rekayasa Perangkat Lunak'},
  {nama:'Siswa Animasi',  deskripsi:'Siswa jurusan Animasi dan Multimedia'}
] AS row
MERGE (k:KelompokAkses {nama: row.nama})
SET   k.deskripsi = row.deskripsi;

UNWIND [
  {user_id:'U02', nama:'Siti Rahma',    tipe:'guru',  kelompok:'Guru'},
  {user_id:'U04', nama:'Rina Lestari',  tipe:'siswa', kelompok:'Siswa DKV'},
  {user_id:'U05', nama:'Putri Ayu',     tipe:'siswa', kelompok:'Siswa DKV'},
  {user_id:'U06', nama:'Dimas Pratama', tipe:'siswa', kelompok:'Siswa RPL'},
  {user_id:'U07', nama:'Eko Saputra',   tipe:'siswa', kelompok:'Siswa RPL'},
  {user_id:'U11', nama:'Fajar Nugraha', tipe:'siswa', kelompok:'Siswa Animasi'}
] AS row
MATCH (k:KelompokAkses {nama: row.kelompok})
MERGE (u:Pengguna {user_id: row.user_id})
SET   u.nama = row.nama,
      u.tipe = row.tipe
MERGE (u)-[:TERGABUNG]->(k);

UNWIND [
  {kode:'DKV-01',   lab:'Lab DKV',        os:'Windows', gpu:'NVIDIA RTX 3060 12GB', status:'online'},
  {kode:'DKV-02',   lab:'Lab DKV',        os:'Windows', gpu:'NVIDIA RTX 3060 12GB', status:'offline'},
  {kode:'DKV-03',   lab:'Lab DKV',        os:'Linux',   gpu:'NVIDIA RTX 3060 12GB', status:'online'},
  {kode:'RPL-01',   lab:'Lab RPL',        os:'Linux',   gpu:null, status:'online'},
  {kode:'RPL-03',   lab:'Lab RPL',        os:'Windows', gpu:null, status:'online'},
  {kode:'MULTI-01', lab:'Lab Multimedia', os:'Windows', gpu:'NVIDIA RTX 4070 12GB', status:'bermasalah'},
  {kode:'PERPUS-01',lab:'Perpustakaan',   os:'Windows', gpu:null, status:'online'}
] AS row
MATCH (l:Lab {nama: row.lab})
MERGE (p:Perangkat {kode: row.kode})
SET   p.os = row.os, p.gpu = row.gpu, p.status = row.status
MERGE (p)-[:BERADA_DI]->(l);

UNWIND [
  {sesi_id:'S01', pengguna:'U04', perangkat:'DKV-01',   mulai:'2026-11-02T08:00:00', selesai:'2026-11-02T09:30:00', durasi_menit:90},
  {sesi_id:'S02', pengguna:'U04', perangkat:'DKV-01',   mulai:'2026-11-09T08:00:00', selesai:'2026-11-09T09:30:00', durasi_menit:90},
  {sesi_id:'S03', pengguna:'U05', perangkat:'DKV-02',   mulai:'2026-11-02T10:00:00', selesai:'2026-11-02T11:30:00', durasi_menit:90},
  {sesi_id:'S04', pengguna:'U06', perangkat:'RPL-01',   mulai:'2026-11-03T13:00:00', selesai:'2026-11-03T15:00:00', durasi_menit:120},
  {sesi_id:'S05', pengguna:'U07', perangkat:'RPL-03',   mulai:'2026-11-04T08:00:00', selesai:'2026-11-04T09:00:00', durasi_menit:60},
  {sesi_id:'S06', pengguna:'U11', perangkat:'MULTI-01', mulai:'2026-11-05T13:00:00', selesai:'2026-11-05T15:00:00', durasi_menit:120},
  {sesi_id:'S07', pengguna:'U02', perangkat:'PERPUS-01',mulai:'2026-11-06T09:00:00', selesai:'2026-11-06T10:00:00', durasi_menit:60},
  {sesi_id:'S08', pengguna:'U06', perangkat:'RPL-01',   mulai:'2026-11-10T13:00:00', selesai:'2026-11-10T14:30:00', durasi_menit:90},
  {sesi_id:'S09', pengguna:'U04', perangkat:'DKV-01',   mulai:'2026-10-15T08:00:00', selesai:'2026-10-15T09:30:00', durasi_menit:90}
] AS row
MATCH (u:Pengguna {user_id: row.pengguna})
MATCH (p:Perangkat {kode: row.perangkat})
MERGE (s:Sesi {sesi_id: row.sesi_id})
SET   s.mulai        = datetime(row.mulai),
      s.selesai      = datetime(row.selesai),
      s.durasi_menit = row.durasi_menit
MERGE (s)-[:DILAKUKAN_OLEH]->(u)
MERGE (s)-[:DI_PERANGKAT]->(p);


// ---------------------------------------------------------------------
// 3. QUERY FITUR UTAMA
//    Ekspresi aljabar relasional:
//      gamma(lab, kelompok; COUNT(sesi), SUM(durasi)) (
//        sigma(mulai in Nov 2026 AND selesai not null) (
//          Sesi join Perangkat join Lab join Pengguna join KelompokAkses
//        )
//      )
//
//    Bandingkan dengan baseline SQL yang memerlukan 4 JOIN:
//      SELECT l.nama_lab, ka.nama_kelompok_akses,
//             count(*) AS jumlah_sesi,
//             sum(s.durasi_menit) AS total_menit
//      FROM sesi_login s
//      JOIN perangkat      p  ON p.id_perangkat = s.id_perangkat
//      JOIN lab_komputer   l  ON l.id_lab = p.id_lab
//      JOIN pengguna       u  ON u.id_pengguna = s.id_pengguna
//      JOIN kelompok_akses ka ON ka.id_kelompok_akses = u.id_kelompok_akses
//      WHERE s.waktu_login >= '2026-11-01'
//        AND s.waktu_login <  '2026-12-01'
//        AND s.waktu_logout IS NOT NULL
//      GROUP BY l.nama_lab, ka.nama_kelompok_akses
//      ORDER BY total_menit DESC;
// ---------------------------------------------------------------------
MATCH (ka:KelompokAkses)<-[:TERGABUNG]-(u:Pengguna)
      <-[:DILAKUKAN_OLEH]-(s:Sesi)-[:DI_PERANGKAT]->(:Perangkat)
      -[:BERADA_DI]->(l:Lab)
WHERE s.mulai >= datetime('2026-11-01T00:00:00')
  AND s.mulai <  datetime('2026-12-01T00:00:00')
RETURN l.nama              AS lab,
       ka.nama             AS kelompok_akses,
       count(s)            AS jumlah_sesi,
       sum(s.durasi_menit) AS total_menit
ORDER BY total_menit DESC, lab;

// Hasil terukur (4 baris):
//   Lab DKV        | Siswa DKV      | 3 | 270
//   Lab RPL        | Siswa RPL      | 3 | 270
//   Lab Multimedia | Siswa Animasi  | 1 | 120
//   Perpustakaan   | Guru           | 1 |  60
//
// Sesi S09 (15 Oktober 2026) tidak ikut karena berada di luar rentang.
// Rencana yang dipilih planner: NodeIndexSeekByRange pada index
// :Sesi(mulai), total 169 db hits.


// ---------------------------------------------------------------------
// 4. QUERY PENDUKUNG
// ---------------------------------------------------------------------

// 4a. Riwayat sesi seorang pengguna (dua hop: Pengguna - Sesi - Perangkat)
MATCH (u:Pengguna {nama:'Rina Lestari'})-[:TERGABUNG]->(ka:KelompokAkses)
MATCH (s:Sesi)-[:DILAKUKAN_OLEH]->(u)
MATCH (s)-[:DI_PERANGKAT]->(p:Perangkat)-[:BERADA_DI]->(l:Lab)
RETURN ka.nama       AS kelompok_akses,
       s.sesi_id     AS sesi_id,
       s.mulai       AS mulai,
       p.kode        AS perangkat,
       l.nama        AS lab,
       s.durasi_menit AS durasi_menit
ORDER BY s.mulai;
// Hasil terukur: 3 baris (S09, S01, S02).

// 4b. Perangkat yang paling sering dipakai
MATCH (s:Sesi)-[:DI_PERANGKAT]->(p:Perangkat)
RETURN p.kode              AS perangkat,
       count(s)            AS jumlah_sesi,
       sum(s.durasi_menit) AS total_menit
ORDER BY total_menit DESC, perangkat;
// Hasil terukur: DKV-01 (3 sesi, 270 menit) di urutan pertama.

// 4c. Lab yang belum pernah dipakai pada periode laporan
MATCH (l:Lab)
OPTIONAL MATCH (l)<-[:BERADA_DI]-(:Perangkat)<-[:DI_PERANGKAT]-(s:Sesi)
WHERE s.mulai >= datetime('2026-11-01T00:00:00')
  AND s.mulai <  datetime('2026-12-01T00:00:00')
WITH l, count(s) AS jumlah_sesi
WHERE jumlah_sesi = 0
RETURN l.nama AS lab, jumlah_sesi;
// Hasil terukur: 0 baris, karena keempat lab terpakai pada November 2026.


// ---------------------------------------------------------------------
// 5. OPTIMISASI: PERBANDINGAN RENCANA (diukur dengan PROFILE)
//
//    Catatan: data latihan hanya berisi 9 sesi, sehingga selisih db hits
//    tampak kecil. Pada skala penuh selisihnya jauh lebih besar karena
//    biaya pemindaian tumbuh sebanding jumlah baris.
// ---------------------------------------------------------------------

// ---------------------------------------------------------------------
// 5a. Tanpa index waktu: pemindaian seluruh label Sesi
//     Hasil terukur: NodeByLabelScan -> 188 db hits
//     Jalankan sekali saja, lalu buat ulang index pada 5b.
// ---------------------------------------------------------------------
// DROP INDEX sesi_mulai IF EXISTS;

// PROFILE MATCH (ka:KelompokAkses)<-[:TERGABUNG]-(u:Pengguna)
//               <-[:DILAKUKAN_OLEH]-(s:Sesi)-[:DI_PERANGKAT]->(:Perangkat)
//               -[:BERADA_DI]->(l:Lab)
// WHERE s.mulai >= datetime('2026-11-01T00:00:00')
//   AND s.mulai <  datetime('2026-12-01T00:00:00')
// RETURN l.nama AS lab, ka.nama AS kelompok_akses,
//        count(s) AS jumlah_sesi, sum(s.durasi_menit) AS total_menit
// ORDER BY total_menit DESC, lab;

// CREATE INDEX sesi_mulai IF NOT EXISTS FOR (s:Sesi) ON (s.mulai);

// ---------------------------------------------------------------------
// 5b. Dengan index rentang pada :Sesi(mulai) - rencana yang dipilih planner
//     Hasil terukur: NodeIndexSeekByRange -> 169 db hits
// ---------------------------------------------------------------------
PROFILE MATCH (ka:KelompokAkses)<-[:TERGABUNG]-(u:Pengguna)
              <-[:DILAKUKAN_OLEH]-(s:Sesi)-[:DI_PERANGKAT]->(:Perangkat)
              -[:BERADA_DI]->(l:Lab)
WHERE s.mulai >= datetime('2026-11-01T00:00:00')
  AND s.mulai <  datetime('2026-12-01T00:00:00')
RETURN l.nama AS lab, ka.nama AS kelompok_akses,
       count(s) AS jumlah_sesi, sum(s.durasi_menit) AS total_menit
ORDER BY total_menit DESC, lab;

// ---------------------------------------------------------------------
// 5c. Query tiga hop: jangkar waktu vs jangkar lab
//     Keduanya menjawab pertanyaan berbeda, jadi dibandingkan pada
//     titik masuknya, bukan pada jumlah baris keluaran.
// ---------------------------------------------------------------------

// 5c-1. Jangkar waktu memakai index rentang
//       Hasil terukur: NodeIndexSeekByRange -> 97 db hits (4 baris)
PROFILE MATCH (s:Sesi)
WHERE s.mulai >= datetime('2026-11-01T00:00:00')
  AND s.mulai <  datetime('2026-12-01T00:00:00')
MATCH (s)-[:DI_PERANGKAT]->(:Perangkat)-[:BERADA_DI]->(l:Lab)
RETURN l.nama AS lab, count(s) AS jumlah_sesi, sum(s.durasi_menit) AS total_menit
ORDER BY total_menit DESC;

// 5c-2. Jangkar lab memakai constraint unik :Lab(nama)
//       Hasil terukur: NodeUniqueIndexSeek -> 39 db hits (1 baris)
//
//       Hint diperlukan. Tanpa hint, planner tetap memakai index waktu
//       walaupun :Lab ditulis lebih dahulu, karena Cypher bersifat
//       deklaratif dan urutan penulisan tidak mengikat planner.
PROFILE MATCH (l:Lab) USING INDEX l:Lab(nama)
WHERE l.nama = 'Lab DKV'
MATCH (l)<-[:BERADA_DI]-(:Perangkat)<-[:DI_PERANGKAT]-(s:Sesi)
WHERE s.mulai >= datetime('2026-11-01T00:00:00')
  AND s.mulai <  datetime('2026-12-01T00:00:00')
RETURN l.nama AS lab, count(s) AS jumlah_sesi, sum(s.durasi_menit) AS total_menit;

// 5c-3. Pembanding terburuk: paksa pemindaian label tanpa index
//       Hasil terukur: NodeByLabelScan -> 108 db hits (4 baris)
PROFILE MATCH (s:Sesi) USING SCAN s:Sesi
WHERE s.mulai >= datetime('2026-11-01T00:00:00')
  AND s.mulai <  datetime('2026-12-01T00:00:00')
MATCH (s)-[:DI_PERANGKAT]->(p:Perangkat)-[:BERADA_DI]->(l:Lab)
RETURN l.nama AS lab, count(s) AS jumlah_sesi
ORDER BY jumlah_sesi DESC;


// ---------------------------------------------------------------------
// 6. RANCANGAN DCL UNTUK PROYEK
//    Hak disesuaikan dengan tugas masing-masing peran, dan hak tulis
//    dibatasi per label agar tidak melebar ke seluruh basis data.
// ---------------------------------------------------------------------

// 6a. Peran pelaporan: hanya membaca
CREATE ROLE pjbl_reporter IF NOT EXISTS;
GRANT ACCESS ON DATABASE neo4j TO pjbl_reporter;
GRANT TRAVERSE ON GRAPH neo4j NODES         * TO pjbl_reporter;
GRANT TRAVERSE ON GRAPH neo4j RELATIONSHIPS * TO pjbl_reporter;
GRANT MATCH {*} ON GRAPH neo4j NODES         * TO pjbl_reporter;
GRANT MATCH {*} ON GRAPH neo4j RELATIONSHIPS * TO pjbl_reporter;

// 6b. Peran operator: membaca, dan hanya boleh menulis data sesi
//     (pencatatan login/logout). Simpul Lab, Perangkat, Pengguna, dan
//     KelompokAkses tidak boleh diubah oleh peran ini.
CREATE ROLE pjbl_operator IF NOT EXISTS;
GRANT ACCESS ON DATABASE neo4j TO pjbl_operator;
GRANT TRAVERSE ON GRAPH neo4j NODES         * TO pjbl_operator;
GRANT TRAVERSE ON GRAPH neo4j RELATIONSHIPS * TO pjbl_operator;
GRANT MATCH {*} ON GRAPH neo4j NODES         * TO pjbl_operator;
GRANT MATCH {*} ON GRAPH neo4j RELATIONSHIPS * TO pjbl_operator;

GRANT CREATE ON GRAPH neo4j NODES Sesi TO pjbl_operator;
GRANT DELETE ON GRAPH neo4j NODES Sesi TO pjbl_operator;
GRANT SET PROPERTY {*} ON GRAPH neo4j NODES Sesi TO pjbl_operator;
GRANT CREATE ON GRAPH neo4j RELATIONSHIPS DI_PERANGKAT   TO pjbl_operator;
GRANT CREATE ON GRAPH neo4j RELATIONSHIPS DILAKUKAN_OLEH TO pjbl_operator;

// 6c. Verifikasi konfigurasi
SHOW ROLE pjbl_reporter PRIVILEGES;
SHOW ROLE pjbl_operator PRIVILEGES;


// ---------------------------------------------------------------------
// 8. PEMBERSIHAN (opsional, jalankan setelah praktikum selesai)
// ---------------------------------------------------------------------
MATCH (n) WHERE n:Lab OR n:Perangkat OR n:Pengguna OR n:KelompokAkses OR n:Sesi
DETACH DELETE n;
DROP ROLE pjbl_reporter;
DROP ROLE pjbl_operator;
