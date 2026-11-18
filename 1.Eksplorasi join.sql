SELECT
    l.nama_lab,
    COUNT(s.id_sesi)                                        AS total_sesi,
    COUNT(DISTINCT s.id_pengguna)                           AS pengguna_unik,
    SUM(CASE WHEN s.waktu_logout IS NULL
              AND s.id_sesi IS NOT NULL THEN 1 ELSE 0 END)  AS sesi_aktif
FROM lab_komputer l
LEFT JOIN perangkat  p ON p.id_lab       = l.id_lab
LEFT JOIN sesi_login s ON s.id_perangkat = p.id_perangkat
GROUP BY l.id_lab, l.nama_lab
ORDER BY total_sesi DESC, l.nama_lab;
