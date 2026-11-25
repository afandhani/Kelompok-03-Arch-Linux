BEGIN;

INSERT INTO kelompok_akses (nama_kelompok_akses, deskripsi) VALUES
 ('Siswa Animasi', 'Siswa jurusan Animasi dan Multimedia');

WITH inserted_user AS (
    INSERT INTO pengguna (nama, email, password_hash, status_aktif, tipe, id_kelompok_akses)
    VALUES (
        'Fajar Nugraha',
        'fajar.animasi@nexora.test',
        '$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa8',
        TRUE,
        'siswa',
        (SELECT id_kelompok_akses FROM kelompok_akses WHERE nama_kelompok_akses = 'Siswa Animasi')
    )
    RETURNING id_pengguna
)
-- 3. Masukkan ke subtipe siswa menggunakan ID yang baru saja digenerate secara otomatis
INSERT INTO siswa (id_pengguna, nis, kelas)
SELECT id_pengguna, '2601005', 'X Animasi 1'
FROM inserted_user;

-- 4. Tambah lab dan perangkat baru
INSERT INTO lab_komputer (nama_lab, lokasi) VALUES ('Lab Multimedia', 'Gedung D Lantai 3');
INSERT INTO perangkat (nama_perangkat, sistem_operasi, status, id_lab)
VALUES ('MULTI-01', 'Windows', 'online', (SELECT MAX(id_lab) FROM lab_komputer));

-- 5. Tambah riwayat sesi login menggunakan relasi otomatis
INSERT INTO sesi_login (id_pengguna, id_perangkat, waktu_login, waktu_logout)
SELECT
    (SELECT id_pengguna FROM pengguna WHERE email = 'fajar.animasi@nexora.test'),
    (SELECT id_perangkat FROM perangkat WHERE nama_perangkat = 'MULTI-01'),
    '2026-11-01 13:00:00',
    '2026-11-01 15:00:00';

COMMIT;
