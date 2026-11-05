USE nexora_education;

SELECT l.id_lab,
       l.nama_lab,
       COUNT(p.id_perangkat) AS jumlah_perangkat,
       SUM(CASE WHEN p.status = 'online'     THEN 1 ELSE 0 END) AS jumlah_online,
       SUM(CASE WHEN p.status = 'offline'    THEN 1 ELSE 0 END) AS jumlah_offline,
       SUM(CASE WHEN p.status = 'bermasalah' THEN 1 ELSE 0 END) AS jumlah_bermasalah,
       (SELECT COUNT(*)
          FROM sesi_login s
          JOIN perangkat pp ON pp.id_perangkat = s.id_perangkat
         WHERE pp.id_lab = l.id_lab AND s.waktu_logout IS NULL) AS jumlah_sesi_aktif
FROM lab_komputer l
LEFT JOIN perangkat p ON p.id_lab = l.id_lab
GROUP BY l.id_lab, l.nama_lab;

SELECT l.id_lab,
       l.nama_lab,
       COUNT(p.id_perangkat) AS jumlah_perangkat,
       SUM(CASE WHEN p.status = 'online'     THEN 1 ELSE 0 END) AS jumlah_online,
       SUM(CASE WHEN p.status = 'offline'    THEN 1 ELSE 0 END) AS jumlah_offline,
       SUM(CASE WHEN p.status = 'bermasalah' THEN 1 ELSE 0 END) AS jumlah_bermasalah,
       (SELECT COUNT(*)
          FROM sesi_login s
          JOIN perangkat pp ON pp.id_perangkat = s.id_perangkat
         WHERE pp.id_lab = l.id_lab AND s.waktu_logout IS NULL) AS jumlah_sesi_aktif
FROM lab_komputer l
LEFT JOIN perangkat p ON p.id_lab = l.id_lab
GROUP BY l.id_lab, l.nama_lab;
