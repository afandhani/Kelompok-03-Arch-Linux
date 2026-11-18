-- =====================================================================
-- 01_database.sql: Membuat database, struktur tabel Nexora, dan eksplorasi DBMS
-- =====================================================================

-- =====================================================================
-- BAGIAN A - Menyiapkan database dan struktur tabel
-- =====================================================================

DROP DATABASE IF EXISTS nexora_modul11;
CREATE DATABASE nexora_modul11 OWNER nexora ENCODING 'UTF8';

\c nexora_modul11

-- Objek di bawah dibuat atas nama role nexora (pemilik sama seperti di backup)
SET ROLE nexora;
SET search_path TO nexora, public;

--
-- Name: nexora; Type: SCHEMA; Schema: -
--

CREATE SCHEMA nexora;

--
-- Name: hasil_akses; Type: TYPE; Schema: nexora
--

CREATE TYPE nexora.hasil_akses AS ENUM (
    'diizinkan',
    'ditolak'
);

--
-- Name: hasil_log; Type: TYPE; Schema: nexora
--

CREATE TYPE nexora.hasil_log AS ENUM (
    'berhasil',
    'gagal'
);

--
-- Name: os_perangkat; Type: TYPE; Schema: nexora
--

CREATE TYPE nexora.os_perangkat AS ENUM (
    'Linux',
    'Windows'
);

--
-- Name: status_perangkat; Type: TYPE; Schema: nexora
--

CREATE TYPE nexora.status_perangkat AS ENUM (
    'online',
    'offline',
    'bermasalah'
);

--
-- Name: tipe_pengguna; Type: TYPE; Schema: nexora
--

CREATE TYPE nexora.tipe_pengguna AS ENUM (
    'admin',
    'guru',
    'siswa'
);

--
-- Name: fn_validasi_subtipe(); Type: FUNCTION; Schema: nexora
--

CREATE FUNCTION nexora.fn_validasi_subtipe() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_id INT;
BEGIN
  IF TG_OP = 'INSERT' THEN v_id := NEW.id_pengguna; ELSE v_id := OLD.id_pengguna; END IF;

  -- Pengguna sudah dihapus (mis. cascade) -> tidak ada yang perlu dicek
  IF NOT EXISTS (SELECT 1 FROM nexora.pengguna WHERE id_pengguna = v_id) THEN
    RETURN NULL;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM nexora.admin_it WHERE id_pengguna = v_id)
 AND NOT EXISTS (SELECT 1 FROM nexora.guru     WHERE id_pengguna = v_id)
 AND NOT EXISTS (SELECT 1 FROM nexora.siswa    WHERE id_pengguna = v_id) THEN
    RAISE EXCEPTION 'Pengguna % harus memiliki satu subtipe (admin_it / guru / siswa)', v_id
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NULL;
END;
$$;

--
-- Name: admin_it; Type: TABLE; Schema: nexora
--

CREATE TABLE nexora.admin_it (
    id_pengguna integer NOT NULL,
    tipe nexora.tipe_pengguna DEFAULT 'admin'::nexora.tipe_pengguna NOT NULL,
    hak_akses_perangkat character varying(100) NOT NULL,
    CONSTRAINT admin_it_tipe_check CHECK ((tipe = 'admin'::nexora.tipe_pengguna))
);

--
-- Name: aktivitas_sesi; Type: TABLE; Schema: nexora
--

CREATE TABLE nexora.aktivitas_sesi (
    id_sesi bigint NOT NULL,
    waktu_akses timestamp without time zone NOT NULL,
    aksi character varying(150) NOT NULL,
    hasil nexora.hasil_akses NOT NULL,
    id_aplikasi integer
);

--
-- Name: aplikasi; Type: TABLE; Schema: nexora
--

CREATE TABLE nexora.aplikasi (
    id_aplikasi integer NOT NULL,
    nama_aplikasi character varying(100) NOT NULL,
    kategori character varying(50)
);

--
-- Name: aplikasi_id_aplikasi_seq; Type: SEQUENCE; Schema: nexora
--

ALTER TABLE nexora.aplikasi ALTER COLUMN id_aplikasi ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME nexora.aplikasi_id_aplikasi_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: guru; Type: TABLE; Schema: nexora
--

CREATE TABLE nexora.guru (
    id_pengguna integer NOT NULL,
    tipe nexora.tipe_pengguna DEFAULT 'guru'::nexora.tipe_pengguna NOT NULL,
    nip character varying(20) NOT NULL,
    mata_pelajaran character varying(100),
    CONSTRAINT guru_tipe_check CHECK ((tipe = 'guru'::nexora.tipe_pengguna))
);

--
-- Name: hak_akses_aplikasi; Type: TABLE; Schema: nexora
--

CREATE TABLE nexora.hak_akses_aplikasi (
    id_kelompok_akses integer NOT NULL,
    id_aplikasi integer NOT NULL
);

--
-- Name: kelompok_akses; Type: TABLE; Schema: nexora
--

CREATE TABLE nexora.kelompok_akses (
    id_kelompok_akses integer NOT NULL,
    nama_kelompok_akses character varying(100) NOT NULL,
    deskripsi character varying(255)
);

--
-- Name: kelompok_akses_id_kelompok_akses_seq; Type: SEQUENCE; Schema: nexora
--

ALTER TABLE nexora.kelompok_akses ALTER COLUMN id_kelompok_akses ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME nexora.kelompok_akses_id_kelompok_akses_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: lab_komputer; Type: TABLE; Schema: nexora
--

CREATE TABLE nexora.lab_komputer (
    id_lab integer NOT NULL,
    nama_lab character varying(100) NOT NULL,
    lokasi character varying(100)
);

--
-- Name: lab_komputer_id_lab_seq; Type: SEQUENCE; Schema: nexora
--

ALTER TABLE nexora.lab_komputer ALTER COLUMN id_lab ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME nexora.lab_komputer_id_lab_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: log_aktivitas; Type: TABLE; Schema: nexora
--

CREATE TABLE nexora.log_aktivitas (
    id_log bigint NOT NULL,
    waktu timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    aksi character varying(150) NOT NULL,
    hasil nexora.hasil_log NOT NULL,
    id_pengguna integer NOT NULL
);

--
-- Name: log_aktivitas_id_log_seq; Type: SEQUENCE; Schema: nexora
--

ALTER TABLE nexora.log_aktivitas ALTER COLUMN id_log ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME nexora.log_aktivitas_id_log_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: pengguna; Type: TABLE; Schema: nexora
--

CREATE TABLE nexora.pengguna (
    id_pengguna integer NOT NULL,
    nama character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    status_aktif boolean DEFAULT true NOT NULL,
    tipe nexora.tipe_pengguna NOT NULL,
    id_kelompok_akses integer NOT NULL,
    CONSTRAINT ck_pengguna_hash CHECK (((password_hash)::text ~ '^\$(2[aby]\$[0-9]{2}|argon2id)\$'::text))
);

--
-- Name: COLUMN pengguna.password_hash; Type: COMMENT; Schema: nexora
--

COMMENT ON COLUMN nexora.pengguna.password_hash IS 'Hash dari aplikasi (bcrypt/argon2id). Jangan pernah menyimpan password polos.';

--
-- Name: pengguna_id_pengguna_seq; Type: SEQUENCE; Schema: nexora
--

ALTER TABLE nexora.pengguna ALTER COLUMN id_pengguna ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME nexora.pengguna_id_pengguna_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: perangkat; Type: TABLE; Schema: nexora
--

CREATE TABLE nexora.perangkat (
    id_perangkat integer NOT NULL,
    nama_perangkat character varying(100) NOT NULL,
    sistem_operasi nexora.os_perangkat NOT NULL,
    status nexora.status_perangkat DEFAULT 'offline'::nexora.status_perangkat NOT NULL,
    id_lab integer NOT NULL
);

--
-- Name: perangkat_id_perangkat_seq; Type: SEQUENCE; Schema: nexora
--

ALTER TABLE nexora.perangkat ALTER COLUMN id_perangkat ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME nexora.perangkat_id_perangkat_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: sesi_login; Type: TABLE; Schema: nexora
--

CREATE TABLE nexora.sesi_login (
    id_sesi bigint NOT NULL,
    id_pengguna integer NOT NULL,
    id_perangkat integer NOT NULL,
    waktu_login timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    waktu_logout timestamp without time zone,
    CONSTRAINT ck_sesi_waktu CHECK (((waktu_logout IS NULL) OR (waktu_logout >= waktu_login)))
);

--
-- Name: sesi_login_id_sesi_seq; Type: SEQUENCE; Schema: nexora
--

ALTER TABLE nexora.sesi_login ALTER COLUMN id_sesi ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME nexora.sesi_login_id_sesi_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: siswa; Type: TABLE; Schema: nexora
--

CREATE TABLE nexora.siswa (
    id_pengguna integer NOT NULL,
    tipe nexora.tipe_pengguna DEFAULT 'siswa'::nexora.tipe_pengguna NOT NULL,
    nis character varying(20) NOT NULL,
    kelas character varying(20) NOT NULL,
    CONSTRAINT siswa_tipe_check CHECK ((tipe = 'siswa'::nexora.tipe_pengguna))
);

--
-- Name: v_akses_pengguna; Type: VIEW; Schema: nexora
--

CREATE VIEW nexora.v_akses_pengguna AS
 SELECT p.id_pengguna,
    p.nama,
    ka.nama_kelompok_akses,
    a.nama_aplikasi
   FROM (((nexora.pengguna p
     JOIN nexora.kelompok_akses ka ON ((ka.id_kelompok_akses = p.id_kelompok_akses)))
     JOIN nexora.hak_akses_aplikasi ha ON ((ha.id_kelompok_akses = ka.id_kelompok_akses)))
     JOIN nexora.aplikasi a ON ((a.id_aplikasi = ha.id_aplikasi)));

--
-- Name: v_rekap_status_lab; Type: VIEW; Schema: nexora
--

CREATE VIEW nexora.v_rekap_status_lab AS
 SELECT l.id_lab,
    l.nama_lab,
    count(p.id_perangkat) AS jumlah_perangkat,
    count(*) FILTER (WHERE (p.status = 'online'::nexora.status_perangkat)) AS jumlah_online,
    count(*) FILTER (WHERE (p.status = 'offline'::nexora.status_perangkat)) AS jumlah_offline,
    count(*) FILTER (WHERE (p.status = 'bermasalah'::nexora.status_perangkat)) AS jumlah_bermasalah,
    COALESCE(sa.jumlah_sesi_aktif, (0)::bigint) AS jumlah_sesi_aktif
   FROM ((nexora.lab_komputer l
     LEFT JOIN nexora.perangkat p ON ((p.id_lab = l.id_lab)))
     LEFT JOIN ( SELECT pr.id_lab,
            count(*) AS jumlah_sesi_aktif
           FROM (nexora.sesi_login s
             JOIN nexora.perangkat pr ON ((pr.id_perangkat = s.id_perangkat)))
          WHERE (s.waktu_logout IS NULL)
          GROUP BY pr.id_lab) sa ON ((sa.id_lab = l.id_lab)))
  GROUP BY l.id_lab, l.nama_lab, sa.jumlah_sesi_aktif;

--
-- Name: admin_it admin_it_pkey; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.admin_it
    ADD CONSTRAINT admin_it_pkey PRIMARY KEY (id_pengguna);

--
-- Name: aktivitas_sesi aktivitas_sesi_pkey; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.aktivitas_sesi
    ADD CONSTRAINT aktivitas_sesi_pkey PRIMARY KEY (id_sesi, waktu_akses);

--
-- Name: aplikasi aplikasi_nama_aplikasi_key; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.aplikasi
    ADD CONSTRAINT aplikasi_nama_aplikasi_key UNIQUE (nama_aplikasi);

--
-- Name: aplikasi aplikasi_pkey; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.aplikasi
    ADD CONSTRAINT aplikasi_pkey PRIMARY KEY (id_aplikasi);

--
-- Name: guru guru_nip_key; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.guru
    ADD CONSTRAINT guru_nip_key UNIQUE (nip);

--
-- Name: guru guru_pkey; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.guru
    ADD CONSTRAINT guru_pkey PRIMARY KEY (id_pengguna);

--
-- Name: hak_akses_aplikasi hak_akses_aplikasi_pkey; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.hak_akses_aplikasi
    ADD CONSTRAINT hak_akses_aplikasi_pkey PRIMARY KEY (id_kelompok_akses, id_aplikasi);

--
-- Name: kelompok_akses kelompok_akses_nama_kelompok_akses_key; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.kelompok_akses
    ADD CONSTRAINT kelompok_akses_nama_kelompok_akses_key UNIQUE (nama_kelompok_akses);

--
-- Name: kelompok_akses kelompok_akses_pkey; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.kelompok_akses
    ADD CONSTRAINT kelompok_akses_pkey PRIMARY KEY (id_kelompok_akses);

--
-- Name: lab_komputer lab_komputer_nama_lab_key; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.lab_komputer
    ADD CONSTRAINT lab_komputer_nama_lab_key UNIQUE (nama_lab);

--
-- Name: lab_komputer lab_komputer_pkey; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.lab_komputer
    ADD CONSTRAINT lab_komputer_pkey PRIMARY KEY (id_lab);

--
-- Name: log_aktivitas log_aktivitas_pkey; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.log_aktivitas
    ADD CONSTRAINT log_aktivitas_pkey PRIMARY KEY (id_log);

--
-- Name: pengguna pengguna_email_key; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.pengguna
    ADD CONSTRAINT pengguna_email_key UNIQUE (email);

--
-- Name: pengguna pengguna_pkey; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.pengguna
    ADD CONSTRAINT pengguna_pkey PRIMARY KEY (id_pengguna);

--
-- Name: perangkat perangkat_pkey; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.perangkat
    ADD CONSTRAINT perangkat_pkey PRIMARY KEY (id_perangkat);

--
-- Name: sesi_login sesi_login_pkey; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.sesi_login
    ADD CONSTRAINT sesi_login_pkey PRIMARY KEY (id_sesi);

--
-- Name: siswa siswa_nis_key; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.siswa
    ADD CONSTRAINT siswa_nis_key UNIQUE (nis);

--
-- Name: siswa siswa_pkey; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.siswa
    ADD CONSTRAINT siswa_pkey PRIMARY KEY (id_pengguna);

--
-- Name: pengguna uq_pengguna_tipe; Type: CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.pengguna
    ADD CONSTRAINT uq_pengguna_tipe UNIQUE (id_pengguna, tipe);

--
-- Name: idx_aktivitas_aplikasi; Type: INDEX; Schema: nexora
--

CREATE INDEX idx_aktivitas_aplikasi ON nexora.aktivitas_sesi USING btree (id_aplikasi);

--
-- Name: idx_ha_aplikasi; Type: INDEX; Schema: nexora
--

CREATE INDEX idx_ha_aplikasi ON nexora.hak_akses_aplikasi USING btree (id_aplikasi);

--
-- Name: idx_log_pengguna; Type: INDEX; Schema: nexora
--

CREATE INDEX idx_log_pengguna ON nexora.log_aktivitas USING btree (id_pengguna);

--
-- Name: idx_pengguna_kelompok; Type: INDEX; Schema: nexora
--

CREATE INDEX idx_pengguna_kelompok ON nexora.pengguna USING btree (id_kelompok_akses);

--
-- Name: idx_perangkat_lab; Type: INDEX; Schema: nexora
--

CREATE INDEX idx_perangkat_lab ON nexora.perangkat USING btree (id_lab);

--
-- Name: idx_perangkat_nama; Type: INDEX; Schema: nexora
--

CREATE INDEX idx_perangkat_nama ON nexora.perangkat USING btree (nama_perangkat varchar_pattern_ops);

--
-- Name: idx_perangkat_os; Type: INDEX; Schema: nexora
--

CREATE INDEX idx_perangkat_os ON nexora.perangkat USING btree (sistem_operasi);

--
-- Name: idx_sesi_aktif; Type: INDEX; Schema: nexora
--

CREATE INDEX idx_sesi_aktif ON nexora.sesi_login USING btree (id_perangkat) WHERE (waktu_logout IS NULL);

--
-- Name: idx_sesi_pengguna; Type: INDEX; Schema: nexora
--

CREATE INDEX idx_sesi_pengguna ON nexora.sesi_login USING btree (id_pengguna);

--
-- Name: idx_sesi_perangkat; Type: INDEX; Schema: nexora
--

CREATE INDEX idx_sesi_perangkat ON nexora.sesi_login USING btree (id_perangkat);

--
-- Name: idx_sesi_waktu; Type: INDEX; Schema: nexora
--

CREATE INDEX idx_sesi_waktu ON nexora.sesi_login USING btree (waktu_login);

--
-- Name: admin_it trg_admin_total; Type: TRIGGER; Schema: nexora
--

CREATE CONSTRAINT TRIGGER trg_admin_total AFTER DELETE OR UPDATE ON nexora.admin_it DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION nexora.fn_validasi_subtipe();

--
-- Name: guru trg_guru_total; Type: TRIGGER; Schema: nexora
--

CREATE CONSTRAINT TRIGGER trg_guru_total AFTER DELETE OR UPDATE ON nexora.guru DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION nexora.fn_validasi_subtipe();

--
-- Name: pengguna trg_pengguna_total; Type: TRIGGER; Schema: nexora
--

CREATE CONSTRAINT TRIGGER trg_pengguna_total AFTER INSERT ON nexora.pengguna DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION nexora.fn_validasi_subtipe();

--
-- Name: siswa trg_siswa_total; Type: TRIGGER; Schema: nexora
--

CREATE CONSTRAINT TRIGGER trg_siswa_total AFTER DELETE OR UPDATE ON nexora.siswa DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION nexora.fn_validasi_subtipe();

--
-- Name: admin_it fk_admin_pengguna; Type: FK CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.admin_it
    ADD CONSTRAINT fk_admin_pengguna FOREIGN KEY (id_pengguna, tipe) REFERENCES nexora.pengguna(id_pengguna, tipe) ON DELETE CASCADE;

--
-- Name: aktivitas_sesi fk_aktivitas_aplikasi; Type: FK CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.aktivitas_sesi
    ADD CONSTRAINT fk_aktivitas_aplikasi FOREIGN KEY (id_aplikasi) REFERENCES nexora.aplikasi(id_aplikasi) ON UPDATE CASCADE ON DELETE SET NULL;

--
-- Name: aktivitas_sesi fk_aktivitas_sesi; Type: FK CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.aktivitas_sesi
    ADD CONSTRAINT fk_aktivitas_sesi FOREIGN KEY (id_sesi) REFERENCES nexora.sesi_login(id_sesi) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- Name: guru fk_guru_pengguna; Type: FK CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.guru
    ADD CONSTRAINT fk_guru_pengguna FOREIGN KEY (id_pengguna, tipe) REFERENCES nexora.pengguna(id_pengguna, tipe) ON DELETE CASCADE;

--
-- Name: hak_akses_aplikasi fk_ha_aplikasi; Type: FK CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.hak_akses_aplikasi
    ADD CONSTRAINT fk_ha_aplikasi FOREIGN KEY (id_aplikasi) REFERENCES nexora.aplikasi(id_aplikasi) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- Name: hak_akses_aplikasi fk_ha_kelompok; Type: FK CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.hak_akses_aplikasi
    ADD CONSTRAINT fk_ha_kelompok FOREIGN KEY (id_kelompok_akses) REFERENCES nexora.kelompok_akses(id_kelompok_akses) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- Name: log_aktivitas fk_log_pengguna; Type: FK CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.log_aktivitas
    ADD CONSTRAINT fk_log_pengguna FOREIGN KEY (id_pengguna) REFERENCES nexora.pengguna(id_pengguna) ON UPDATE CASCADE ON DELETE RESTRICT;

--
-- Name: pengguna fk_pengguna_kelompok; Type: FK CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.pengguna
    ADD CONSTRAINT fk_pengguna_kelompok FOREIGN KEY (id_kelompok_akses) REFERENCES nexora.kelompok_akses(id_kelompok_akses) ON UPDATE CASCADE ON DELETE RESTRICT;

--
-- Name: perangkat fk_perangkat_lab; Type: FK CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.perangkat
    ADD CONSTRAINT fk_perangkat_lab FOREIGN KEY (id_lab) REFERENCES nexora.lab_komputer(id_lab) ON UPDATE CASCADE ON DELETE RESTRICT;

--
-- Name: sesi_login fk_sesi_pengguna; Type: FK CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.sesi_login
    ADD CONSTRAINT fk_sesi_pengguna FOREIGN KEY (id_pengguna) REFERENCES nexora.pengguna(id_pengguna) ON UPDATE CASCADE ON DELETE RESTRICT;

--
-- Name: sesi_login fk_sesi_perangkat; Type: FK CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.sesi_login
    ADD CONSTRAINT fk_sesi_perangkat FOREIGN KEY (id_perangkat) REFERENCES nexora.perangkat(id_perangkat) ON UPDATE CASCADE ON DELETE RESTRICT;

--
-- Name: siswa fk_siswa_pengguna; Type: FK CONSTRAINT; Schema: nexora
--

ALTER TABLE ONLY nexora.siswa
    ADD CONSTRAINT fk_siswa_pengguna FOREIGN KEY (id_pengguna, tipe) REFERENCES nexora.pengguna(id_pengguna, tipe) ON DELETE CASCADE;

RESET ROLE;

-- Verifikasi struktur (data diisi di 03_data_awal.sql)
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'nexora'
ORDER BY table_type, table_name;

-- =====================================================================
-- BAGIAN B - Eksplorasi DBMS
-- (asal: 00_eksplorasi_dbms.sql)
-- =====================================================================

-- 1. Nama dan versi DBMS            (padanan: SELECT VERSION())
SELECT version();

-- 2. Database, user, schema aktif   (padanan: SHOW DATABASES, SELECT DATABASE())
SELECT current_database() AS database_aktif,
       current_user       AS user_aktif,
       current_schema()   AS schema_aktif,
       now()              AS waktu_server;

SELECT datname FROM pg_database WHERE NOT datistemplate ORDER BY datname;

-- 3. Karakteristik server           (padanan: character_set_server, collation_server)
SHOW server_encoding;
SELECT datname,
       pg_encoding_to_char(encoding) AS encoding,
       datcollate,
       datctype
FROM pg_database
WHERE datname = current_database();

-- 4. Access method / jenis index    (padanan kasar: SHOW ENGINES)
--    PostgreSQL punya satu mesin penyimpanan tabel (heap) dengan banyak jenis index.
SELECT amname,
       CASE amtype WHEN 't' THEN 'tabel' WHEN 'i' THEN 'index' END AS untuk
FROM pg_am
ORDER BY amtype, amname;

-- 5. Fasilitas pengelolaan transaksi
SHOW transaction_isolation;
SHOW default_transaction_isolation;


-- 6. Dukungan JSON
SELECT pg_typeof('{}'::json)  AS tipe_json,
       pg_typeof('{}'::jsonb) AS tipe_jsonb;

SELECT '{"nama":"Budi"}'::text IS JSON               AS json_valid,
       '{"nama":"Budi"}'::jsonb ->> 'nama'           AS nama;

-- 7. Ekstensi yang tersedia (contoh perluasan fitur: IoT, pencarian teks, GIS)
SELECT name, default_version, installed_version
FROM pg_available_extensions
WHERE name IN ('pgcrypto', 'pg_trgm', 'btree_gin', 'postgis', 'timescaledb')
ORDER BY name;

-- 8. Replikasi (prasyarat)
SHOW wal_level;
SHOW max_wal_senders;

-- 9. Keamanan: daftar role
SELECT rolname, rolsuper, rolcreaterole, rolcanlogin
FROM pg_roles
WHERE rolname !~ '^pg_'
ORDER BY rolname;
