CREATE TABLE rekap_pemakaian_lab (
  id_lab           INT PRIMARY KEY,
  total_sesi       INT NOT NULL DEFAULT 0,
  pengguna_unik    INT NOT NULL DEFAULT 0,
  sesi_aktif       INT NOT NULL DEFAULT 0,
  diperbarui_pada  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rekap_pemakaian_lab FOREIGN KEY (id_lab)
    REFERENCES lab_komputer(id_lab) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

INSERT INTO rekap_pemakaian_lab (id_lab, total_sesi, pengguna_unik, sesi_aktif)
SELECT l.id_lab,
       COUNT(s.id_sesi),
       COUNT(DISTINCT s.id_pengguna),
       SUM(CASE WHEN s.id_sesi IS NOT NULL AND s.waktu_logout IS NULL THEN 1 ELSE 0 END)
FROM lab_komputer l
LEFT JOIN perangkat  p ON p.id_lab       = l.id_lab
LEFT JOIN sesi_login s ON s.id_perangkat = p.id_perangkat
GROUP BY l.id_lab;
