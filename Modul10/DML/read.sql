SELECT p.nama, ka.nama_kelompok_akses, l.nama_lab, pr.nama_perangkat, s.waktu_login, s.waktu_logout
FROM sesi_login s
JOIN pengguna p        ON p.id_pengguna = s.id_pengguna
JOIN kelompok_akses ka ON ka.id_kelompok_akses = p.id_kelompok_akses
JOIN perangkat pr      ON pr.id_perangkat = s.id_perangkat
JOIN lab_komputer l    ON l.id_lab = pr.id_lab
WHERE p.email = 'fajar.animasi@nexora.test';
