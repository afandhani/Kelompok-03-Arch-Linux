-- =====================================================================
-- 03_data_awal.sql: Pengisian data awal (data inti Nexora)
-- =====================================================================

SET search_path TO nexora, public;

-- Satu transaksi: constraint trigger trg_*_total (DEFERRED) baru dicek saat COMMIT,
-- sehingga baris pengguna dan subtipenya boleh dimasukkan berurutan.
BEGIN;

-- Kelompok akses (peran hak akses aplikasi)
INSERT INTO nexora.kelompok_akses
    (id_kelompok_akses, nama_kelompok_akses, deskripsi) OVERRIDING SYSTEM VALUE
VALUES
(1, 'Admin', 'Admin IT / teknisi laboratorium'),
(2, 'Guru', 'Guru pengampu'),
(3, 'Siswa DKV', 'Siswa jurusan Desain Komunikasi Visual'),
(4, 'Siswa RPL', 'Siswa jurusan Rekayasa Perangkat Lunak'),
(9, 'Siswa Animasi', 'Siswa jurusan Animasi dan Multimedia');

-- Aplikasi yang tersedia di lab
INSERT INTO nexora.aplikasi
    (id_aplikasi, nama_aplikasi, kategori) OVERRIDING SYSTEM VALUE
VALUES
(1, 'Blender', 'Desain 3D'),
(2, 'Adobe Photoshop', 'Desain Grafis'),
(3, 'Adobe Illustrator', 'Desain Grafis'),
(4, 'Visual Studio Code', 'Pemrograman'),
(5, 'DBeaver', 'Basis Data'),
(6, 'Web Browser', 'Umum');

-- Lab komputer
INSERT INTO nexora.lab_komputer
    (id_lab, nama_lab, lokasi) OVERRIDING SYSTEM VALUE
VALUES
(1, 'Lab DKV', 'Gedung B Lantai 2'),
(2, 'Lab RPL', 'Gedung A Lantai 1'),
(3, 'Perpustakaan', 'Gedung C Lantai 1'),
(4, 'Lab Multimedia', 'Gedung D Lantai 3');

-- Pengguna (supertipe) - password_hash hanya hash demo, bukan password asli
INSERT INTO nexora.pengguna
    (id_pengguna, nama, email, password_hash, status_aktif, tipe, id_kelompok_akses) OVERRIDING SYSTEM VALUE
VALUES
(1, 'Budi Santoso', 'budi.admin@nexora.test', '$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa1', true, 'admin', 1),
(2, 'Siti Rahma', 'siti.guru@nexora.test', '$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa2', true, 'guru', 2),
(3, 'Agus Wibowo', 'agus.guru@nexora.test', '$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa3', true, 'guru', 2),
(4, 'Rina Lestari', 'rina.dkv@nexora.test', '$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa4', true, 'siswa', 3),
(5, 'Putri Ayu', 'putri.dkv@nexora.test', '$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa5', true, 'siswa', 3),
(6, 'Dimas Pratama', 'dimas.rpl@nexora.test', '$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa6', true, 'siswa', 4),
(7, 'Eko Saputra', 'eko.rpl@nexora.test', '$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa7', true, 'siswa', 4),
(11, 'Fajar Nugraha', 'fajar.animasi@nexora.test', '$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa8', true, 'siswa', 9);

-- Subtipe pengguna: Admin IT
INSERT INTO nexora.admin_it
    (id_pengguna, tipe, hak_akses_perangkat)
VALUES
(1, 'admin', 'Penuh (semua lab)');

-- Subtipe pengguna: Guru
INSERT INTO nexora.guru
    (id_pengguna, tipe, nip, mata_pelajaran)
VALUES
(2, 'guru', '198501012010011001', 'Pemrograman Dasar'),
(3, 'guru', '198702022011012002', 'Desain Grafis');

-- Subtipe pengguna: Siswa
INSERT INTO nexora.siswa
    (id_pengguna, tipe, nis, kelas)
VALUES
(4, 'siswa', '2601001', 'X DKV 1'),
(5, 'siswa', '2601002', 'X DKV 1'),
(6, 'siswa', '2601003', 'X RPL 1'),
(7, 'siswa', '2601004', 'X RPL 1'),
(11, 'siswa', '2601005', 'X Animasi 1');

-- Hak akses: kelompok akses -> aplikasi
INSERT INTO nexora.hak_akses_aplikasi
    (id_kelompok_akses, id_aplikasi)
VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(2, 1),
(2, 2),
(2, 3),
(2, 4),
(2, 5),
(2, 6),
(3, 1),
(3, 2),
(3, 3),
(3, 6),
(4, 4),
(4, 5),
(4, 6);

-- Perangkat (komputer) per lab
INSERT INTO nexora.perangkat
    (id_perangkat, nama_perangkat, sistem_operasi, status, id_lab) OVERRIDING SYSTEM VALUE
VALUES
(1, 'DKV-01', 'Windows', 'online', 1),
(2, 'DKV-02', 'Windows', 'offline', 1),
(3, 'DKV-03', 'Linux', 'online', 1),
(4, 'RPL-01', 'Linux', 'online', 2),
(5, 'RPL-02', 'Linux', 'bermasalah', 2),
(6, 'RPL-03', 'Windows', 'online', 2),
(7, 'RPL-04', 'Windows', 'offline', 2),
(8, 'PERPUS-01', 'Windows', 'online', 3),
(9, 'PERPUS-02', 'Windows', 'bermasalah', 3),
(10, 'MULTI-01', 'Windows', 'bermasalah', 4);

-- Sesi login pengguna pada perangkat
INSERT INTO nexora.sesi_login
    (id_sesi, id_pengguna, id_perangkat, waktu_login, waktu_logout) OVERRIDING SYSTEM VALUE
VALUES
(1, 4, 1, '2026-10-15 08:00:00', '2026-10-15 09:30:00'),
(2, 4, 4, '2026-10-15 10:00:00', NULL),
(3, 6, 3, '2026-10-15 08:10:00', '2026-10-15 09:00:00'),
(4, 6, 6, '2026-10-15 09:15:00', NULL),
(5, 2, 8, '2026-10-15 09:00:00', NULL),
(6, 5, 7, '2026-11-11 19:32:57.605224', NULL),
(7, 11, 10, '2026-11-01 13:00:00', '2026-11-01 15:00:00');

-- Aktivitas aplikasi dalam sesi
INSERT INTO nexora.aktivitas_sesi
    (id_sesi, waktu_akses, aksi, hasil, id_aplikasi)
VALUES
(1, '2026-10-15 08:05:00', 'buka aplikasi', 'diizinkan', 1),
(1, '2026-10-15 08:20:00', 'buka aplikasi', 'ditolak', 4),
(2, '2026-10-15 10:05:00', 'buka aplikasi', 'diizinkan', 2),
(3, '2026-10-15 08:15:00', 'buka aplikasi', 'ditolak', 1),
(4, '2026-10-15 09:20:00', 'buka aplikasi', 'diizinkan', 4);

-- Log aktivitas administrasi
INSERT INTO nexora.log_aktivitas
    (id_log, waktu, aksi, hasil, id_pengguna) OVERRIDING SYSTEM VALUE
VALUES
(1, '2026-10-14 14:55:00', 'login admin', 'berhasil', 1),
(2, '2026-10-14 15:00:00', 'tambah hak akses Siswa RPL -> DBeaver', 'berhasil', 1);

COMMIT;

-- Sesuaikan nilai sequence agar INSERT berikutnya tidak bentrok dengan ID di atas
-- (kolom identity memakai GENERATED ALWAYS, jadi ID di atas diisi dengan OVERRIDING SYSTEM VALUE)
SELECT setval('nexora.aplikasi_id_aplikasi_seq', 6, true);
SELECT setval('nexora.kelompok_akses_id_kelompok_akses_seq', 9, true);
SELECT setval('nexora.lab_komputer_id_lab_seq', 4, true);
SELECT setval('nexora.log_aktivitas_id_log_seq', 3, true);
SELECT setval('nexora.pengguna_id_pengguna_seq', 13, true);
SELECT setval('nexora.perangkat_id_perangkat_seq', 10, true);
SELECT setval('nexora.sesi_login_id_sesi_seq', 8, true);

-- Verifikasi data awal
SELECT 'kelompok_akses'      AS tabel, count(*) FROM nexora.kelompok_akses
UNION ALL SELECT 'aplikasi',           count(*) FROM nexora.aplikasi
UNION ALL SELECT 'lab_komputer',       count(*) FROM nexora.lab_komputer
UNION ALL SELECT 'pengguna',           count(*) FROM nexora.pengguna
UNION ALL SELECT 'admin_it',           count(*) FROM nexora.admin_it
UNION ALL SELECT 'guru',               count(*) FROM nexora.guru
UNION ALL SELECT 'siswa',              count(*) FROM nexora.siswa
UNION ALL SELECT 'hak_akses_aplikasi', count(*) FROM nexora.hak_akses_aplikasi
UNION ALL SELECT 'perangkat',          count(*) FROM nexora.perangkat
UNION ALL SELECT 'sesi_login',         count(*) FROM nexora.sesi_login
UNION ALL SELECT 'aktivitas_sesi',     count(*) FROM nexora.aktivitas_sesi
UNION ALL SELECT 'log_aktivitas',      count(*) FROM nexora.log_aktivitas;
-- Harapan: kelompok_akses 5, aplikasi 6, lab_komputer 4, pengguna 8, admin_it 1, guru 2, siswa 5, hak_akses_aplikasi 19, perangkat 10, sesi_login 7, aktivitas_sesi 5, log_aktivitas 2
