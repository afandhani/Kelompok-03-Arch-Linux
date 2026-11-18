-- =====================================================================
-- 04_pengujian_json.sql: Pengisian data JSONB, pengujian JSONB, dan pemodelan objek
-- Modul 11 | PostgreSQL (proyek Nexora)
-- Bagian 0: mengisi data JSONB (spesifikasi perangkat & metadata aplikasi)
-- Bagian A: pengujian JSONB (baca/ubah/tambah/hapus/cari/fungsi)
-- Bagian B: pemodelan objek (pemetaan kelas, view, function, INHERITS)
-- Jalankan setelah 03_data_awal.sql
-- =====================================================================

-- =====================================================================
-- BAGIAN 0 - Mengisi data dengan JSONB
-- (kolom spesifikasi/metadata dibuat di 02_tabel.sql; baris perangkat dan
--  aplikasi berasal dari 03_data_awal.sql)
-- =====================================================================

SET search_path TO nexora, public;

BEGIN;

-- Lab DKV: perangkat desain (GPU, monitor terkalibrasi, periferal)
UPDATE nexora.perangkat
SET spesifikasi = '{
    "cpu": "Intel Core i7-12700",
    "ram_gb": 32,
    "storage": {"tipe": "NVMe SSD", "kapasitas_gb": 1000},
    "gpu": "NVIDIA RTX 3060 12GB",
    "monitor": {"ukuran_inch": 27, "resolusi": "2560x1440", "kalibrasi_warna": true},
    "periferal": ["Pen Tablet", "Colorimeter"]
}'::jsonb
WHERE nama_perangkat IN ('DKV-01', 'DKV-02', 'DKV-03');

-- Lab RPL: perangkat pemrograman (virtualisasi, docker, jaringan)
UPDATE nexora.perangkat
SET spesifikasi = '{
    "cpu": "Intel Core i5-12400",
    "ram_gb": 16,
    "storage": {"tipe": "SSD SATA", "kapasitas_gb": 512},
    "virtualisasi": true,
    "docker_terpasang": true,
    "jaringan": {"kecepatan_mbps": 1000, "ip_statis": true}
}'::jsonb
WHERE nama_perangkat IN ('RPL-01', 'RPL-02', 'RPL-03', 'RPL-04');

-- Perpustakaan: perangkat umum (kiosk, tanpa GPU)
UPDATE nexora.perangkat
SET spesifikasi = '{
    "cpu": "Intel Core i3-10100",
    "ram_gb": 8,
    "storage": {"tipe": "HDD", "kapasitas_gb": 500},
    "mode_kiosk": true,
    "terhubung_katalog_perpustakaan": true
}'::jsonb
WHERE nama_perangkat IN ('PERPUS-01', 'PERPUS-02');

-- Lab Multimedia: perangkat produksi (render, capture)
UPDATE nexora.perangkat
SET spesifikasi = '{
    "cpu": "Intel Core i9-13900K",
    "ram_gb": 64,
    "storage": {"tipe": "NVMe SSD", "kapasitas_gb": 2000},
    "gpu": "NVIDIA RTX 4070 12GB",
    "monitor": {"ukuran_inch": 32, "resolusi": "3840x2160", "kalibrasi_warna": true},
    "periferal": ["Capture Card", "Audio Interface"]
}'::jsonb
WHERE nama_perangkat = 'MULTI-01';

-- Metadata aplikasi (atribut berbeda-beda per aplikasi)
UPDATE nexora.aplikasi SET metadata = '{
    "model_lisensi": "open source", "butuh_gpu": true,
    "os_didukung": ["Windows", "Linux"], "min_ram_gb": 16
}'::jsonb WHERE nama_aplikasi = 'Blender';

UPDATE nexora.aplikasi SET metadata = '{
    "model_lisensi": "langganan", "butuh_gpu": true,
    "os_didukung": ["Windows"], "min_ram_gb": 16
}'::jsonb WHERE nama_aplikasi = 'Adobe Photoshop';

UPDATE nexora.aplikasi SET metadata = '{
    "model_lisensi": "langganan", "butuh_gpu": false,
    "os_didukung": ["Windows"], "min_ram_gb": 8
}'::jsonb WHERE nama_aplikasi = 'Adobe Illustrator';

UPDATE nexora.aplikasi SET metadata = '{
    "model_lisensi": "gratis", "butuh_gpu": false,
    "os_didukung": ["Windows", "Linux"], "min_ram_gb": 4,
    "ekstensi_rekomendasi": ["PostgreSQL", "Python", "GitLens"]
}'::jsonb WHERE nama_aplikasi = 'Visual Studio Code';

UPDATE nexora.aplikasi SET metadata = '{
    "model_lisensi": "gratis", "butuh_gpu": false,
    "os_didukung": ["Windows", "Linux"], "min_ram_gb": 4,
    "driver": ["PostgreSQL", "MySQL", "MariaDB"]
}'::jsonb WHERE nama_aplikasi = 'DBeaver';

UPDATE nexora.aplikasi SET metadata = '{
    "model_lisensi": "gratis", "butuh_gpu": false,
    "os_didukung": ["Windows", "Linux"], "min_ram_gb": 4
}'::jsonb WHERE nama_aplikasi = 'Web Browser';

COMMIT;

-- Periksa hasil
SELECT nama_perangkat, sistem_operasi, status, spesifikasi
FROM nexora.perangkat
ORDER BY id_perangkat;

SELECT nama_aplikasi, kategori, metadata
FROM nexora.aplikasi
ORDER BY id_aplikasi;

-- =====================================================================
-- BAGIAN A - Pengujian fitur JSONB
-- (asal: 04_pengujian_json.sql)
-- =====================================================================

SET search_path TO nexora, public;

-- ---------------------------------------------------------------------
-- 0. Validasi
-- ---------------------------------------------------------------------
SELECT '{"nama":"Budi","umur":21}'::text IS JSON AS json_valid;
SELECT '{"nama":"Budi"'::text           IS JSON AS json_valid_salah;     -- false

SELECT jsonb_typeof(spesifikasi) AS tipe_json, count(*) AS jumlah
FROM nexora.perangkat
GROUP BY 1;

-- ---------------------------------------------------------------------
-- 1. MEMBACA atribut JSON  (C.6)
-- ---------------------------------------------------------------------
SELECT nama_perangkat,
       spesifikasi -> 'ram_gb'          AS ram_json,
       spesifikasi ->> 'ram_gb'         AS ram_teks,
       (spesifikasi ->> 'ram_gb')::int  AS ram_gb
FROM nexora.perangkat
ORDER BY id_perangkat;

-- Atribut bersarang: -> berantai, atau #>> dengan path
SELECT nama_perangkat,
       spesifikasi #>> '{storage,kapasitas_gb}'          AS kapasitas_gb,
       spesifikasi -> 'monitor' ->> 'resolusi'           AS resolusi,
       spesifikasi #>> '{periferal,0}'                   AS periferal_pertama
FROM nexora.perangkat
ORDER BY id_perangkat;

-- Perangkat tanpa atribut tertentu menghasilkan NULL (bukan error)
SELECT nama_perangkat, spesifikasi ->> 'gpu' AS gpu
FROM nexora.perangkat
ORDER BY id_perangkat;

-- Jumlah atribut (padanan JSON_LENGTH) dan jumlah elemen array
SELECT nama_perangkat,
       (SELECT count(*) FROM jsonb_object_keys(spesifikasi)) AS jumlah_atribut,
       CASE WHEN jsonb_typeof(spesifikasi -> 'periferal') = 'array'
            THEN jsonb_array_length(spesifikasi -> 'periferal') END AS jumlah_periferal
FROM nexora.perangkat
ORDER BY id_perangkat;

-- Daftar kunci tiap perangkat (padanan JSON_KEYS)
SELECT nama_perangkat, array_agg(k ORDER BY k) AS daftar_atribut
FROM nexora.perangkat p, jsonb_object_keys(p.spesifikasi) AS k
GROUP BY nama_perangkat, id_perangkat
ORDER BY id_perangkat;

-- Tampilan rapi
SELECT nama_perangkat, jsonb_pretty(spesifikasi) AS spesifikasi_rapi
FROM nexora.perangkat
WHERE nama_perangkat = 'DKV-01';

-- ---------------------------------------------------------------------
-- 2. MENGUBAH atribut JSON  (C.7)  -> upgrade RAM RPL-02 menjadi 32 GB
-- ---------------------------------------------------------------------
UPDATE nexora.perangkat
SET spesifikasi = jsonb_set(spesifikasi, '{ram_gb}', '32')
WHERE nama_perangkat = 'RPL-02';

SELECT nama_perangkat, spesifikasi ->> 'ram_gb' AS ram_gb
FROM nexora.perangkat
WHERE nama_perangkat = 'RPL-02';

-- ---------------------------------------------------------------------
-- 3. MENAMBAH atribut JSON  (C.8)  -> catatan_servis
-- ---------------------------------------------------------------------
UPDATE nexora.perangkat
SET spesifikasi = spesifikasi || jsonb_build_object('catatan_servis', 'RAM diupgrade ke 32GB')
WHERE nama_perangkat = 'RPL-02';

SELECT nama_perangkat, spesifikasi
FROM nexora.perangkat
WHERE nama_perangkat = 'RPL-02';

-- Menambah elemen array (dijaga agar tidak dobel bila script diulang)
UPDATE nexora.perangkat
SET spesifikasi = jsonb_set(
        spesifikasi, '{periferal}',
        (spesifikasi -> 'periferal') || '"Webcam"'::jsonb)
WHERE nama_perangkat = 'MULTI-01'
  AND NOT (spesifikasi @> '{"periferal": ["Webcam"]}');

SELECT nama_perangkat, spesifikasi -> 'periferal' AS periferal
FROM nexora.perangkat
WHERE nama_perangkat = 'MULTI-01';

-- ---------------------------------------------------------------------
-- 4. MENGHAPUS atribut JSON  (C.9)  -> hapus catatan_servis
-- ---------------------------------------------------------------------
UPDATE nexora.perangkat
SET spesifikasi = spesifikasi - 'catatan_servis'
WHERE nama_perangkat = 'RPL-02';

SELECT nama_perangkat, spesifikasi
FROM nexora.perangkat
WHERE nama_perangkat = 'RPL-02';

-- Pratinjau hapus atribut bersarang (hanya SELECT, data tidak berubah)
SELECT nama_perangkat,
       spesifikasi #- '{monitor,kalibrasi_warna}' AS tanpa_kalibrasi
FROM nexora.perangkat
WHERE nama_perangkat = 'DKV-01';

-- ---------------------------------------------------------------------
-- 5. MENCARI berdasarkan atribut JSON  (C.10)
-- ---------------------------------------------------------------------
-- RAM >= 16 GB (konversi numerik)
SELECT nama_perangkat, status, (spesifikasi ->> 'ram_gb')::int AS ram_gb
FROM nexora.perangkat
WHERE (spesifikasi ->> 'ram_gb')::int >= 16
ORDER BY ram_gb DESC, nama_perangkat;

-- Kecocokan nilai persis dengan containment @> (memanfaatkan index GIN)
SELECT nama_perangkat
FROM nexora.perangkat
WHERE spesifikasi @> '{"gpu": "NVIDIA RTX 3060 12GB"}';

-- Nilai di dalam array
SELECT nama_perangkat
FROM nexora.perangkat
WHERE spesifikasi @> '{"periferal": ["Pen Tablet"]}';

-- Atribut bersarang
SELECT nama_perangkat
FROM nexora.perangkat
WHERE spesifikasi -> 'storage' ->> 'tipe' = 'HDD';

SELECT nama_perangkat
FROM nexora.perangkat
WHERE spesifikasi @> '{"monitor": {"kalibrasi_warna": true}}';

-- Perangkat yang MEMILIKI atribut gpu (padanan JSON_CONTAINS_PATH)
SELECT nama_perangkat
FROM nexora.perangkat
WHERE jsonb_path_exists(spesifikasi, '$.gpu');

-- JSONPath dengan filter: storage >= 1000 GB
SELECT nama_perangkat
FROM nexora.perangkat
WHERE jsonb_path_exists(spesifikasi, '$.storage.kapasitas_gb ? (@ >= 1000)');

-- Aplikasi yang butuh GPU
SELECT nama_aplikasi, metadata ->> 'model_lisensi' AS model_lisensi
FROM nexora.aplikasi
WHERE metadata @> '{"butuh_gpu": true}';

-- Gabungan JSON + relasional: perangkat ONLINE bermonitor terkalibrasi, per lab
SELECT l.nama_lab, p.nama_perangkat, p.status, p.spesifikasi ->> 'gpu' AS gpu
FROM nexora.perangkat p
JOIN nexora.lab_komputer l ON l.id_lab = p.id_lab
WHERE p.status = 'online'
  AND p.spesifikasi @> '{"monitor": {"kalibrasi_warna": true}}';

-- Studi kasus: aplikasi yang diizinkan untuk Siswa DKV tetapi TIDAK mendukung
-- sistem operasi perangkat di Lab DKV (kompatibilitas = data JSON + relasi)
SELECT DISTINCT a.nama_aplikasi, pr.nama_perangkat, pr.sistem_operasi
FROM nexora.kelompok_akses ka
JOIN nexora.hak_akses_aplikasi ha ON ha.id_kelompok_akses = ka.id_kelompok_akses
JOIN nexora.aplikasi a            ON a.id_aplikasi = ha.id_aplikasi
JOIN nexora.lab_komputer l        ON l.nama_lab = 'Lab DKV'
JOIN nexora.perangkat pr          ON pr.id_lab = l.id_lab
WHERE ka.nama_kelompok_akses = 'Siswa DKV'
  AND NOT ((a.metadata -> 'os_didukung') @> to_jsonb(pr.sistem_operasi::text))
ORDER BY a.nama_aplikasi, pr.nama_perangkat;

-- ---------------------------------------------------------------------
-- 6. Fungsi JSON lainnya  (C.11)
-- ---------------------------------------------------------------------
SELECT jsonb_build_object('nama', 'Budi', 'umur', 21, 'status', 'Mahasiswa') AS data_mahasiswa;
SELECT jsonb_build_array('MySQL', 'MariaDB', 'PostgreSQL')                   AS daftar_dbms;

-- Data relasional -> dokumen JSON (satu dokumen per lab)
SELECT l.nama_lab,
       jsonb_agg(jsonb_build_object(
           'nama',   p.nama_perangkat,
           'os',     p.sistem_operasi,
           'status', p.status
       ) ORDER BY p.nama_perangkat) AS daftar_perangkat
FROM nexora.lab_komputer l
JOIN nexora.perangkat p ON p.id_lab = l.id_lab
GROUP BY l.id_lab, l.nama_lab
ORDER BY l.id_lab;

-- Dokumen JSON -> baris (unpivot atribut)
SELECT p.nama_perangkat, kv.key AS atribut, kv.value AS nilai
FROM nexora.perangkat p, jsonb_each_text(p.spesifikasi) AS kv
WHERE p.nama_perangkat = 'RPL-01'
ORDER BY kv.key;

-- =====================================================================
-- BAGIAN B - Pemodelan data berorientasi objek
-- (asal: 05_pemodelan_objek.sql)
-- =====================================================================

SET search_path TO nexora, public;

-- =====================================================================
-- A. Pemetaan kelas -> tabel pada Nexora
-- ---------------------------------------------------------------------
-- Class Pengguna            -> nexora.pengguna
-- Subclass Admin/Guru/Siswa -> nexora.admin_it / guru / siswa
-- Object Identity           -> PK id_pengguna (anak: PK = FK ke induk)
-- Diskriminator tipe        -> kolom tipe + CHECK + FK komposit (id_pengguna, tipe)
-- Keharusan punya subtipe   -> constraint trigger fn_validasi_subtipe (total)
-- =====================================================================
SELECT p.id_pengguna, p.nama, p.tipe,
       COALESCE(g.nip, s.nis)                                   AS nomor_induk,
       COALESCE(g.mata_pelajaran, s.kelas, a.hak_akses_perangkat) AS atribut_khusus
FROM nexora.pengguna p
LEFT JOIN nexora.admin_it a ON a.id_pengguna = p.id_pengguna
LEFT JOIN nexora.guru     g ON g.id_pengguna = p.id_pengguna
LEFT JOIN nexora.siswa    s ON s.id_pengguna = p.id_pengguna
ORDER BY p.id_pengguna;

-- =====================================================================
-- B. Merekonstruksi "objek" lengkap sebagai dokumen JSON
--    (password_hash sengaja tidak ikut = encapsulation)
-- =====================================================================
CREATE OR REPLACE VIEW nexora.v_pengguna_objek AS
SELECT
    p.id_pengguna,
    p.nama,
    p.tipe,
    jsonb_build_object(
        'id',     p.id_pengguna,
        'nama',   p.nama,
        'email',  p.email,
        'tipe',   p.tipe,
        'aktif',  p.status_aktif,
        'atribut_khusus', CASE p.tipe
            WHEN 'admin' THEN jsonb_build_object('hak_akses_perangkat', a.hak_akses_perangkat)
            WHEN 'guru'  THEN jsonb_build_object('nip', g.nip, 'mata_pelajaran', g.mata_pelajaran)
            WHEN 'siswa' THEN jsonb_build_object('nis', s.nis, 'kelas', s.kelas)
        END
    ) AS objek
FROM nexora.pengguna p
LEFT JOIN nexora.admin_it a ON a.id_pengguna = p.id_pengguna
LEFT JOIN nexora.guru     g ON g.id_pengguna = p.id_pengguna
LEFT JOIN nexora.siswa    s ON s.id_pengguna = p.id_pengguna;

SELECT * FROM nexora.v_pengguna_objek ORDER BY id_pengguna;
SELECT jsonb_pretty(objek) FROM nexora.v_pengguna_objek WHERE tipe = 'siswa' LIMIT 1;

-- =====================================================================
-- C. METHOD -> function
--    tampilkanInformasi() : perilaku berbeda tiap subclass (polymorphism)
--    infoPerangkat()      : objek Perangkat + spesifikasi JSONB
-- =====================================================================
CREATE OR REPLACE FUNCTION nexora.fn_tampilkan_informasi(p_id_pengguna integer)
RETURNS text
LANGUAGE sql STABLE
AS $$
    SELECT CASE p.tipe
        WHEN 'admin' THEN format('Admin IT %s - hak akses: %s', p.nama, a.hak_akses_perangkat)
        WHEN 'guru'  THEN format('Guru %s - mapel: %s (NIP %s)', p.nama, COALESCE(g.mata_pelajaran, '-'), g.nip)
        WHEN 'siswa' THEN format('Siswa %s - kelas %s (NIS %s)', p.nama, s.kelas, s.nis)
    END
    FROM nexora.pengguna p
    LEFT JOIN nexora.admin_it a ON a.id_pengguna = p.id_pengguna
    LEFT JOIN nexora.guru     g ON g.id_pengguna = p.id_pengguna
    LEFT JOIN nexora.siswa    s ON s.id_pengguna = p.id_pengguna
    WHERE p.id_pengguna = p_id_pengguna
$$;

CREATE OR REPLACE FUNCTION nexora.fn_info_perangkat(p_id_perangkat integer)
RETURNS jsonb
LANGUAGE sql STABLE
AS $$
    SELECT jsonb_build_object(
        'id',          p.id_perangkat,
        'nama',        p.nama_perangkat,
        'lab',         l.nama_lab,
        'os',          p.sistem_operasi,
        'status',      p.status,
        'spesifikasi', p.spesifikasi
    )
    FROM nexora.perangkat p
    JOIN nexora.lab_komputer l ON l.id_lab = p.id_lab
    WHERE p.id_perangkat = p_id_perangkat
$$;

SELECT id_pengguna, nexora.fn_tampilkan_informasi(id_pengguna) AS informasi
FROM nexora.pengguna
ORDER BY id_pengguna;

SELECT jsonb_pretty(nexora.fn_info_perangkat(1));

-- =====================================================================
-- D. Fitur object-relational PostgreSQL: pewarisan tabel (INHERITS)
--    Dibuat di schema terpisah agar skema Nexora tidak berubah.
--    PostgreSQL = DBMS relasional dengan fitur objek, BUKAN OODBMS murni.
-- =====================================================================
DROP SCHEMA IF EXISTS modul11_oop CASCADE;
CREATE SCHEMA modul11_oop;

CREATE SEQUENCE modul11_oop.seq_pengguna;

-- Kelas induk
CREATE TABLE modul11_oop.pengguna (
    id_pengguna integer PRIMARY KEY DEFAULT nextval('modul11_oop.seq_pengguna'),
    nama        varchar(100) NOT NULL,
    email       varchar(100) NOT NULL UNIQUE
);

-- Kelas turunan (mewarisi id_pengguna, nama, email + default-nya)
CREATE TABLE modul11_oop.guru (
    nip            varchar(20) NOT NULL UNIQUE,
    mata_pelajaran varchar(100),
    PRIMARY KEY (id_pengguna)
) INHERITS (modul11_oop.pengguna);

CREATE TABLE modul11_oop.siswa (
    nis   varchar(20) NOT NULL UNIQUE,
    kelas varchar(20) NOT NULL,
    PRIMARY KEY (id_pengguna)
) INHERITS (modul11_oop.pengguna);

INSERT INTO modul11_oop.guru  (nama, email, nip, mata_pelajaran)
VALUES ('Siti Rahma', 'siti@contoh.test', '198501012010011001', 'Pemrograman Dasar');
INSERT INTO modul11_oop.siswa (nama, email, nis, kelas)
VALUES ('Dimas Pratama', 'dimas@contoh.test', '2601003', 'X RPL 1');

-- Polymorphic query: SELECT pada induk ikut membaca semua anak
SELECT tableoid::regclass AS kelas, id_pengguna, nama, email
FROM modul11_oop.pengguna
ORDER BY id_pengguna;

-- Hanya baris induk murni (kosong) vs hanya subclass
SELECT * FROM ONLY modul11_oop.pengguna;
SELECT * FROM modul11_oop.guru;

-- Method pada tipe baris induk
CREATE FUNCTION modul11_oop.tampilkan_informasi(p modul11_oop.pengguna)
RETURNS text
LANGUAGE sql STABLE
AS $$ SELECT format('%s <%s>', p.nama, p.email) $$;

SELECT tableoid::regclass AS kelas,
       modul11_oop.tampilkan_informasi(p) AS informasi
FROM modul11_oop.pengguna p;

-- KETERBATASAN INHERITS (bahan analisis perbedaan dengan OODBMS murni):
-- UNIQUE/PK pada induk tidak berlaku lintas anak -> email yang sama bisa
-- masuk di guru DAN siswa, padahal induknya UNIQUE.
INSERT INTO modul11_oop.siswa (nama, email, nis, kelas)
VALUES ('Eko Saputra', 'siti@contoh.test', '2601004', 'X RPL 1');   -- tidak ditolak!

SELECT email, count(*) AS jumlah
FROM modul11_oop.pengguna
GROUP BY email
HAVING count(*) > 1;
