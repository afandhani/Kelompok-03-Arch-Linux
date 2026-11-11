CREATE DATABASE IF NOT EXISTS nexora_education
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE nexora_education;

CREATE TABLE kelompok_akses (
  id_kelompok_akses    INT AUTO_INCREMENT PRIMARY KEY,
  nama_kelompok_akses  VARCHAR(100) NOT NULL UNIQUE,
  deskripsi            VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE pengguna (
  id_pengguna        INT AUTO_INCREMENT PRIMARY KEY,
  nama               VARCHAR(100) NOT NULL,
  email              VARCHAR(100) NOT NULL UNIQUE,
  password_hash      VARCHAR(255) NOT NULL,
  status_aktif       TINYINT(1)   NOT NULL DEFAULT 1,
  id_kelompok_akses  INT NOT NULL,
  CONSTRAINT fk_pengguna_kelompok FOREIGN KEY (id_kelompok_akses)
    REFERENCES kelompok_akses(id_kelompok_akses) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE admin_it (
  id_pengguna          INT PRIMARY KEY,
  hak_akses_perangkat  VARCHAR(100) NOT NULL,
  CONSTRAINT fk_admin_pengguna FOREIGN KEY (id_pengguna)
    REFERENCES pengguna(id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE guru (
  id_pengguna     INT PRIMARY KEY,
  nip             VARCHAR(20) NOT NULL UNIQUE,
  mata_pelajaran  VARCHAR(100),
  CONSTRAINT fk_guru_pengguna FOREIGN KEY (id_pengguna)
    REFERENCES pengguna(id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE siswa (
  id_pengguna  INT PRIMARY KEY,
  nis          VARCHAR(20) NOT NULL UNIQUE,
  kelas        VARCHAR(20) NOT NULL,
  CONSTRAINT fk_siswa_pengguna FOREIGN KEY (id_pengguna)
    REFERENCES pengguna(id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE aplikasi (
  id_aplikasi    INT AUTO_INCREMENT PRIMARY KEY,
  nama_aplikasi  VARCHAR(100) NOT NULL UNIQUE,
  kategori       VARCHAR(50)
) ENGINE=InnoDB;

CREATE TABLE hak_akses_aplikasi (
  id_kelompok_akses  INT NOT NULL,
  id_aplikasi        INT NOT NULL,
  PRIMARY KEY (id_kelompok_akses, id_aplikasi),
  CONSTRAINT fk_ha_kelompok FOREIGN KEY (id_kelompok_akses)
    REFERENCES kelompok_akses(id_kelompok_akses) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ha_aplikasi FOREIGN KEY (id_aplikasi)
    REFERENCES aplikasi(id_aplikasi) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE lab_komputer (
  id_lab    INT AUTO_INCREMENT PRIMARY KEY,
  nama_lab  VARCHAR(100) NOT NULL UNIQUE,
  lokasi    VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE perangkat (
  id_perangkat    INT AUTO_INCREMENT PRIMARY KEY,
  nama_perangkat  VARCHAR(100) NOT NULL,
  sistem_operasi  ENUM('Linux','Windows') NOT NULL,
  status          ENUM('online','offline','bermasalah') NOT NULL DEFAULT 'offline',
  id_lab          INT NOT NULL,
  CONSTRAINT fk_perangkat_lab FOREIGN KEY (id_lab)
    REFERENCES lab_komputer(id_lab) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE sesi_login (
  id_sesi       BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_pengguna   INT NOT NULL,
  id_perangkat  INT NOT NULL,
  waktu_login   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  waktu_logout  DATETIME NULL,
  CONSTRAINT fk_sesi_pengguna  FOREIGN KEY (id_pengguna)  REFERENCES pengguna(id_pengguna)   ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_sesi_perangkat FOREIGN KEY (id_perangkat) REFERENCES perangkat(id_perangkat) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE aktivitas_sesi (
  id_sesi      BIGINT NOT NULL,
  waktu_akses  DATETIME NOT NULL,
  aksi         VARCHAR(150) NOT NULL,
  hasil        ENUM('diizinkan','ditolak') NOT NULL,
  id_aplikasi  INT NULL,
  PRIMARY KEY (id_sesi, waktu_akses),
  CONSTRAINT fk_aktivitas_sesi FOREIGN KEY (id_sesi)
    REFERENCES sesi_login(id_sesi) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_aktivitas_aplikasi FOREIGN KEY (id_aplikasi)
    REFERENCES aplikasi(id_aplikasi) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE log_aktivitas (
  id_log       BIGINT AUTO_INCREMENT PRIMARY KEY,
  waktu        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aksi         VARCHAR(150) NOT NULL,
  hasil        ENUM('berhasil','gagal') NOT NULL,
  id_pengguna  INT NOT NULL,
  CONSTRAINT fk_log_pengguna FOREIGN KEY (id_pengguna)
    REFERENCES pengguna(id_pengguna) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_perangkat_nama ON perangkat (nama_perangkat);
CREATE INDEX idx_perangkat_os   ON perangkat (sistem_operasi);
CREATE INDEX idx_sesi_waktu     ON sesi_login (waktu_login);

INSERT INTO kelompok_akses (nama_kelompok_akses, deskripsi) VALUES
 ('Admin',     'Admin IT / teknisi laboratorium'),
 ('Guru',      'Guru pengampu'),
 ('Siswa DKV', 'Siswa jurusan Desain Komunikasi Visual'),
 ('Siswa RPL', 'Siswa jurusan Rekayasa Perangkat Lunak');

INSERT INTO pengguna (nama, email, password_hash, status_aktif, id_kelompok_akses) VALUES
 ('Budi Santoso',  'budi.admin@nexora.test',  'placeholder_hash_01', 1, 1),
 ('Siti Rahma',    'siti.guru@nexora.test',   'placeholder_hash_02', 1, 2),
 ('Agus Wibowo',   'agus.guru@nexora.test',   'placeholder_hash_03', 1, 2),
 ('Rina Lestari',  'rina.dkv@nexora.test',    'placeholder_hash_04', 1, 3),
 ('Putri Ayu',     'putri.dkv@nexora.test',   'placeholder_hash_05', 1, 3),
 ('Dimas Pratama', 'dimas.rpl@nexora.test',   'placeholder_hash_06', 1, 4),
 ('Eko Saputra',   'eko.rpl@nexora.test',     'placeholder_hash_07', 1, 4);

INSERT INTO admin_it (id_pengguna, hak_akses_perangkat) VALUES (1, 'Penuh (semua lab)');
INSERT INTO guru  (id_pengguna, nip, mata_pelajaran) VALUES
 (2, '198501012010011001', 'Pemrograman Dasar'),
 (3, '198702022011012002', 'Desain Grafis');
INSERT INTO siswa (id_pengguna, nis, kelas) VALUES
 (4, '2601001', 'X DKV 1'), (5, '2601002', 'X DKV 1'),
 (6, '2601003', 'X RPL 1'), (7, '2601004', 'X RPL 1');

INSERT INTO aplikasi (nama_aplikasi, kategori) VALUES
 ('Blender',            'Desain 3D'),
 ('Adobe Photoshop',    'Desain Grafis'),
 ('Adobe Illustrator',  'Desain Grafis'),
 ('Visual Studio Code', 'Pemrograman'),
 ('DBeaver',            'Basis Data'),
 ('Web Browser',        'Umum');

INSERT INTO hak_akses_aplikasi (id_kelompok_akses, id_aplikasi) VALUES
 (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),
 (2,1),(2,2),(2,3),(2,4),(2,5),(2,6),
 (3,1),(3,2),(3,3),(3,6),
 (4,4),(4,5),(4,6);

INSERT INTO lab_komputer (nama_lab, lokasi) VALUES
 ('Lab DKV','Gedung B Lantai 2'), ('Lab RPL','Gedung A Lantai 1'), ('Perpustakaan','Gedung C Lantai 1');

INSERT INTO perangkat (nama_perangkat, sistem_operasi, status, id_lab) VALUES
 ('DKV-01','Windows','online',1),    ('DKV-02','Windows','offline',1),    ('DKV-03','Linux','online',1),
 ('RPL-01','Linux','online',2),      ('RPL-02','Linux','bermasalah',2),   ('RPL-03','Windows','online',2),
 ('RPL-04','Windows','offline',2),
 ('PERPUS-01','Windows','online',3), ('PERPUS-02','Windows','bermasalah',3);

INSERT INTO sesi_login (id_pengguna, id_perangkat, waktu_login, waktu_logout) VALUES
 (4, 1, '2026-10-15 08:00:00', '2026-10-15 09:30:00'),
 (4, 4, '2026-10-15 10:00:00', NULL),
 (6, 3, '2026-10-15 08:10:00', '2026-10-15 09:00:00'),
 (6, 6, '2026-10-15 09:15:00', NULL),
 (2, 8, '2026-10-15 09:00:00', NULL);

INSERT INTO aktivitas_sesi (id_sesi, waktu_akses, aksi, hasil, id_aplikasi) VALUES
 (1, '2026-10-15 08:05:00', 'buka aplikasi', 'diizinkan', 1),
 (1, '2026-10-15 08:20:00', 'buka aplikasi', 'ditolak',   4),
 (2, '2026-10-15 10:05:00', 'buka aplikasi', 'diizinkan', 2),
 (3, '2026-10-15 08:15:00', 'buka aplikasi', 'ditolak',   1),
 (4, '2026-10-15 09:20:00', 'buka aplikasi', 'diizinkan', 4);

INSERT INTO log_aktivitas (waktu, aksi, hasil, id_pengguna) VALUES
 ('2026-10-14 14:55:00', 'login admin', 'berhasil', 1),
 ('2026-10-14 15:00:00', 'tambah hak akses Siswa RPL -> DBeaver', 'berhasil', 1),
 ('2026-10-14 15:10:00', 'tambah perangkat RPL-04 ke Lab RPL', 'berhasil', 1);
