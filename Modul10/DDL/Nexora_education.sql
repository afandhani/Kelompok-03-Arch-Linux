CREATE SCHEMA IF NOT EXISTS nexora;
SET search_path TO nexora, public;

CREATE TYPE os_perangkat AS ENUM ('Linux','Windows');
CREATE TYPE status_perangkat AS ENUM ('online','offline','bermasalah');
CREATE TYPE hasil_akses AS ENUM ('diizinkan','ditolak');
CREATE TYPE hasil_log AS ENUM ('berhasil','gagal');
CREATE TYPE tipe_pengguna AS ENUM ('admin','guru','siswa');

CREATE TABLE kelompok_akses (
  id_kelompok_akses INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nama_kelompok_akses VARCHAR(100) NOT NULL UNIQUE,
  deskripsi VARCHAR(255)
);

CREATE TABLE pengguna (
  id_pengguna INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  status_aktif BOOLEAN NOT NULL DEFAULT TRUE,
  tipe tipe_pengguna NOT NULL,
  id_kelompok_akses INT NOT NULL,
  CONSTRAINT uq_pengguna_tipe UNIQUE (id_pengguna, tipe),
  CONSTRAINT ck_pengguna_hash CHECK (password_hash ~ '^\$(2[aby]\$[0-9]{2}|argon2id)\$'),
  CONSTRAINT fk_pengguna_kelompok FOREIGN KEY (id_kelompok_akses)
    REFERENCES kelompok_akses(id_kelompok_akses) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE admin_it (
  id_pengguna INT PRIMARY KEY,
  tipe tipe_pengguna NOT NULL DEFAULT 'admin' CHECK (tipe = 'admin'),
  hak_akses_perangkat VARCHAR(100) NOT NULL,
  CONSTRAINT fk_admin_pengguna FOREIGN KEY (id_pengguna, tipe)
    REFERENCES pengguna(id_pengguna, tipe) ON DELETE CASCADE
);

CREATE TABLE guru (
  id_pengguna INT PRIMARY KEY,
  tipe tipe_pengguna NOT NULL DEFAULT 'guru' CHECK (tipe = 'guru'),
  nip VARCHAR(20) NOT NULL UNIQUE,
  mata_pelajaran VARCHAR(100),
  CONSTRAINT fk_guru_pengguna FOREIGN KEY (id_pengguna, tipe)
    REFERENCES pengguna(id_pengguna, tipe) ON DELETE CASCADE
);

CREATE TABLE siswa (
  id_pengguna INT PRIMARY KEY,
  tipe tipe_pengguna NOT NULL DEFAULT 'siswa' CHECK (tipe = 'siswa'),
  nis VARCHAR(20) NOT NULL UNIQUE,
  kelas VARCHAR(20) NOT NULL,
  CONSTRAINT fk_siswa_pengguna FOREIGN KEY (id_pengguna, tipe)
    REFERENCES pengguna(id_pengguna, tipe) ON DELETE CASCADE
);

CREATE TABLE aplikasi (
  id_aplikasi INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nama_aplikasi VARCHAR(100) NOT NULL UNIQUE,
  kategori VARCHAR(50)
);

CREATE TABLE hak_akses_aplikasi (
  id_kelompok_akses INT NOT NULL,
  id_aplikasi INT NOT NULL,
  PRIMARY KEY (id_kelompok_akses, id_aplikasi),
  CONSTRAINT fk_ha_kelompok FOREIGN KEY (id_kelompok_akses)
    REFERENCES kelompok_akses(id_kelompok_akses) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ha_aplikasi FOREIGN KEY (id_aplikasi)
    REFERENCES aplikasi(id_aplikasi) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE lab_komputer (
  id_lab INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nama_lab VARCHAR(100) NOT NULL UNIQUE,
  lokasi VARCHAR(100)
);

CREATE TABLE perangkat (
  id_perangkat INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nama_perangkat VARCHAR(100) NOT NULL,
  sistem_operasi os_perangkat NOT NULL,
  status status_perangkat NOT NULL DEFAULT 'offline',
  id_lab INT NOT NULL,
  CONSTRAINT fk_perangkat_lab FOREIGN KEY (id_lab)
    REFERENCES lab_komputer(id_lab) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE sesi_login (
  id_sesi BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_pengguna INT NOT NULL,
  id_perangkat INT NOT NULL,
  waktu_login TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  waktu_logout TIMESTAMP NULL,
  CONSTRAINT ck_sesi_waktu CHECK (waktu_logout IS NULL OR waktu_logout >= waktu_login),
  CONSTRAINT fk_sesi_pengguna FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_sesi_perangkat FOREIGN KEY (id_perangkat) REFERENCES perangkat(id_perangkat) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE aktivitas_sesi (
  id_sesi BIGINT NOT NULL,
  waktu_akses TIMESTAMP NOT NULL,
  aksi VARCHAR(150) NOT NULL,
  hasil hasil_akses NOT NULL,
  id_aplikasi INT NULL,
  PRIMARY KEY (id_sesi, waktu_akses),
  CONSTRAINT fk_aktivitas_sesi FOREIGN KEY (id_sesi)
    REFERENCES sesi_login(id_sesi) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_aktivitas_aplikasi FOREIGN KEY (id_aplikasi)
    REFERENCES aplikasi(id_aplikasi) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE log_aktivitas (
  id_log BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  waktu TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aksi VARCHAR(150) NOT NULL,
  hasil hasil_log NOT NULL,
  id_pengguna INT NOT NULL,
  CONSTRAINT fk_log_pengguna FOREIGN KEY (id_pengguna)
    REFERENCES pengguna(id_pengguna) ON DELETE RESTRICT ON UPDATE CASCADE
);
