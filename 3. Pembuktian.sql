USE nexora_education;

SELECT id_lab, nama_lab, jumlah_perangkat, jumlah_online, jumlah_offline,
       jumlah_bermasalah, jumlah_sesi_aktif, diperbarui_pada
FROM rekap_status_lab;

EXPLAIN SELECT id_lab, nama_lab, jumlah_perangkat, jumlah_online, jumlah_offline,
               jumlah_bermasalah, jumlah_sesi_aktif
        FROM rekap_status_lab;

SELECT r.id_lab, r.nama_lab
FROM rekap_status_lab r
JOIN (
  SELECT l.id_lab,
         COUNT(p.id_perangkat) AS jml,
         SUM(CASE WHEN p.status = 'online'     THEN 1 ELSE 0 END) AS onl,
         SUM(CASE WHEN p.status = 'offline'    THEN 1 ELSE 0 END) AS off_,
         SUM(CASE WHEN p.status = 'bermasalah' THEN 1 ELSE 0 END) AS bml,
         (SELECT COUNT(*) FROM sesi_login s
            JOIN perangkat pp ON pp.id_perangkat = s.id_perangkat
           WHERE pp.id_lab = l.id_lab AND s.waktu_logout IS NULL) AS ses
  FROM lab_komputer l
  LEFT JOIN perangkat p ON p.id_lab = l.id_lab
  GROUP BY l.id_lab
) x ON x.id_lab = r.id_lab
WHERE x.jml <> r.jumlah_perangkat OR x.onl <> r.jumlah_online
   OR x.off_ <> r.jumlah_offline  OR x.bml <> r.jumlah_bermasalah
   OR x.ses <> r.jumlah_sesi_aktif;

INSERT INTO sesi_login (id_pengguna, id_perangkat) VALUES (5, 7);
SET @id_sesi_uji = LAST_INSERT_ID();
SELECT id_lab, nama_lab, jumlah_sesi_aktif FROM rekap_status_lab WHERE id_lab = 2;

UPDATE sesi_login SET waktu_logout = NOW() WHERE id_sesi = @id_sesi_uji;
SELECT id_lab, nama_lab, jumlah_sesi_aktif FROM rekap_status_lab WHERE id_lab = 2;

UPDATE perangkat SET status = 'online' WHERE nama_perangkat = 'DKV-02';
SELECT id_lab, nama_lab, jumlah_online, jumlah_offline FROM rekap_status_lab WHERE id_lab = 1;

UPDATE lab_komputer SET nama_lab = 'Lab DKV (Baru)' WHERE id_lab = 1;
SELECT id_lab, nama_lab FROM rekap_status_lab WHERE id_lab = 1;

UPDATE rekap_status_lab SET jumlah_online = 99 WHERE id_lab = 1;
SELECT id_lab, nama_lab, jumlah_online FROM rekap_status_lab WHERE id_lab = 1;

CALL sp_refresh_rekap(NULL);
SELECT id_lab, nama_lab, jumlah_online FROM rekap_status_lab WHERE id_lab = 1; 

UPDATE lab_komputer SET nama_lab = 'Lab DKV' WHERE id_lab = 1;
UPDATE perangkat SET status = 'offline' WHERE nama_perangkat = 'DKV-02';
DELETE FROM sesi_login WHERE id_sesi = @id_sesi_uji;
SELECT * FROM rekap_status_lab;
