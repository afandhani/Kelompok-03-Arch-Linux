USE nexora_education;

DROP TRIGGER IF EXISTS trg_perangkat_ai;
DROP TRIGGER IF EXISTS trg_perangkat_au;
DROP TRIGGER IF EXISTS trg_perangkat_ad;
DROP TRIGGER IF EXISTS trg_sesi_ai;
DROP TRIGGER IF EXISTS trg_sesi_au;
DROP TRIGGER IF EXISTS trg_sesi_ad;
DROP TRIGGER IF EXISTS trg_lab_ai;
DROP TRIGGER IF EXISTS trg_lab_au;
DROP PROCEDURE IF EXISTS sp_refresh_rekap;
DROP TABLE IF EXISTS rekap_status_lab;

CREATE TABLE rekap_status_lab (
  id_lab             INT PRIMARY KEY,
  nama_lab           VARCHAR(100) NOT NULL,
  jumlah_perangkat   INT NOT NULL DEFAULT 0,
  jumlah_online      INT NOT NULL DEFAULT 0,
  jumlah_offline     INT NOT NULL DEFAULT 0,
  jumlah_bermasalah  INT NOT NULL DEFAULT 0,
  jumlah_sesi_aktif  INT NOT NULL DEFAULT 0,
  diperbarui_pada    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rekap_lab FOREIGN KEY (id_lab)
    REFERENCES lab_komputer(id_lab) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DELIMITER $$
CREATE PROCEDURE sp_refresh_rekap(IN p_id_lab INT)
BEGIN
  REPLACE INTO rekap_status_lab
    (id_lab, nama_lab, jumlah_perangkat, jumlah_online, jumlah_offline,
     jumlah_bermasalah, jumlah_sesi_aktif, diperbarui_pada)
  SELECT l.id_lab,
         l.nama_lab,
         COUNT(p.id_perangkat),
         SUM(CASE WHEN p.status = 'online'     THEN 1 ELSE 0 END),
         SUM(CASE WHEN p.status = 'offline'    THEN 1 ELSE 0 END),
         SUM(CASE WHEN p.status = 'bermasalah' THEN 1 ELSE 0 END),
         (SELECT COUNT(*) FROM sesi_login s
            JOIN perangkat pp ON pp.id_perangkat = s.id_perangkat
           WHERE pp.id_lab = l.id_lab AND s.waktu_logout IS NULL),
         NOW()
  FROM lab_komputer l
  LEFT JOIN perangkat p ON p.id_lab = l.id_lab
  WHERE p_id_lab IS NULL OR l.id_lab = p_id_lab
  GROUP BY l.id_lab, l.nama_lab;
END$$

CREATE TRIGGER trg_perangkat_ai AFTER INSERT ON perangkat
FOR EACH ROW
BEGIN
  CALL sp_refresh_rekap(NEW.id_lab);
END$$

CREATE TRIGGER trg_perangkat_au AFTER UPDATE ON perangkat
FOR EACH ROW
BEGIN
  CALL sp_refresh_rekap(NEW.id_lab);
  IF OLD.id_lab <> NEW.id_lab THEN
    CALL sp_refresh_rekap(OLD.id_lab);
  END IF;
END$$

CREATE TRIGGER trg_perangkat_ad AFTER DELETE ON perangkat
FOR EACH ROW
BEGIN
  CALL sp_refresh_rekap(OLD.id_lab);
END$$

CREATE TRIGGER trg_sesi_ai AFTER INSERT ON sesi_login
FOR EACH ROW
BEGIN
  DECLARE v_lab INT;
  SELECT id_lab INTO v_lab FROM perangkat WHERE id_perangkat = NEW.id_perangkat;
  CALL sp_refresh_rekap(v_lab);
END$$

CREATE TRIGGER trg_sesi_au AFTER UPDATE ON sesi_login
FOR EACH ROW
BEGIN
  DECLARE v_lab_baru INT;
  DECLARE v_lab_lama INT;
  SELECT id_lab INTO v_lab_baru FROM perangkat WHERE id_perangkat = NEW.id_perangkat;
  SELECT id_lab INTO v_lab_lama FROM perangkat WHERE id_perangkat = OLD.id_perangkat;
  CALL sp_refresh_rekap(v_lab_baru);
  IF v_lab_lama <> v_lab_baru THEN
    CALL sp_refresh_rekap(v_lab_lama);
  END IF;
END$$

CREATE TRIGGER trg_sesi_ad AFTER DELETE ON sesi_login
FOR EACH ROW
BEGIN
  DECLARE v_lab INT;
  SELECT id_lab INTO v_lab FROM perangkat WHERE id_perangkat = OLD.id_perangkat;
  CALL sp_refresh_rekap(v_lab);
END$$

CREATE TRIGGER trg_lab_ai AFTER INSERT ON lab_komputer
FOR EACH ROW
BEGIN
  CALL sp_refresh_rekap(NEW.id_lab);
END$$

CREATE TRIGGER trg_lab_au AFTER UPDATE ON lab_komputer
FOR EACH ROW
BEGIN
  CALL sp_refresh_rekap(NEW.id_lab);
END$$
DELIMITER ;

CALL sp_refresh_rekap(NULL);

DESCRIBE rekap_status_lab;
SHOW CREATE TABLE rekap_status_lab;
SHOW TRIGGERS;
