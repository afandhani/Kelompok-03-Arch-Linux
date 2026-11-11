--
-- PostgreSQL database dump
--

\restrict CQlZOMfT5QVjQ9NsEiIDOt3WjFmtZeusWtLXUi80TrF4oZcgNoOoiIaRmGKoZOF

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: nexora; Type: SCHEMA; Schema: -; Owner: nexora
--

CREATE SCHEMA nexora;


ALTER SCHEMA nexora OWNER TO nexora;

--
-- Name: hasil_akses; Type: TYPE; Schema: nexora; Owner: nexora
--

CREATE TYPE nexora.hasil_akses AS ENUM (
    'diizinkan',
    'ditolak'
);


ALTER TYPE nexora.hasil_akses OWNER TO nexora;

--
-- Name: hasil_log; Type: TYPE; Schema: nexora; Owner: nexora
--

CREATE TYPE nexora.hasil_log AS ENUM (
    'berhasil',
    'gagal'
);


ALTER TYPE nexora.hasil_log OWNER TO nexora;

--
-- Name: os_perangkat; Type: TYPE; Schema: nexora; Owner: nexora
--

CREATE TYPE nexora.os_perangkat AS ENUM (
    'Linux',
    'Windows'
);


ALTER TYPE nexora.os_perangkat OWNER TO nexora;

--
-- Name: status_perangkat; Type: TYPE; Schema: nexora; Owner: nexora
--

CREATE TYPE nexora.status_perangkat AS ENUM (
    'online',
    'offline',
    'bermasalah'
);


ALTER TYPE nexora.status_perangkat OWNER TO nexora;

--
-- Name: tipe_pengguna; Type: TYPE; Schema: nexora; Owner: nexora
--

CREATE TYPE nexora.tipe_pengguna AS ENUM (
    'admin',
    'guru',
    'siswa'
);


ALTER TYPE nexora.tipe_pengguna OWNER TO nexora;

--
-- Name: fn_validasi_subtipe(); Type: FUNCTION; Schema: nexora; Owner: nexora
--

CREATE FUNCTION nexora.fn_validasi_subtipe() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_id INT;
BEGIN
  IF TG_OP = 'INSERT' THEN v_id := NEW.id_pengguna; ELSE v_id := OLD.id_pengguna; END IF;

  -- Pengguna sudah dihapus (mis. cascade) -> tidak ada yang perlu dicek
  IF NOT EXISTS (SELECT 1 FROM pengguna WHERE id_pengguna = v_id) THEN
    RETURN NULL;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM admin_it WHERE id_pengguna = v_id)
 AND NOT EXISTS (SELECT 1 FROM guru     WHERE id_pengguna = v_id)
 AND NOT EXISTS (SELECT 1 FROM siswa    WHERE id_pengguna = v_id) THEN
    RAISE EXCEPTION 'Pengguna % harus memiliki satu subtipe (admin_it / guru / siswa)', v_id
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION nexora.fn_validasi_subtipe() OWNER TO nexora;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_it; Type: TABLE; Schema: nexora; Owner: nexora
--

CREATE TABLE nexora.admin_it (
    id_pengguna integer NOT NULL,
    tipe nexora.tipe_pengguna DEFAULT 'admin'::nexora.tipe_pengguna NOT NULL,
    hak_akses_perangkat character varying(100) NOT NULL,
    CONSTRAINT admin_it_tipe_check CHECK ((tipe = 'admin'::nexora.tipe_pengguna))
);


ALTER TABLE nexora.admin_it OWNER TO nexora;

--
-- Name: aktivitas_sesi; Type: TABLE; Schema: nexora; Owner: nexora
--

CREATE TABLE nexora.aktivitas_sesi (
    id_sesi bigint NOT NULL,
    waktu_akses timestamp without time zone NOT NULL,
    aksi character varying(150) NOT NULL,
    hasil nexora.hasil_akses NOT NULL,
    id_aplikasi integer
);


ALTER TABLE nexora.aktivitas_sesi OWNER TO nexora;

--
-- Name: aplikasi; Type: TABLE; Schema: nexora; Owner: nexora
--

CREATE TABLE nexora.aplikasi (
    id_aplikasi integer NOT NULL,
    nama_aplikasi character varying(100) NOT NULL,
    kategori character varying(50)
);


ALTER TABLE nexora.aplikasi OWNER TO nexora;

--
-- Name: aplikasi_id_aplikasi_seq; Type: SEQUENCE; Schema: nexora; Owner: nexora
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
-- Name: guru; Type: TABLE; Schema: nexora; Owner: nexora
--

CREATE TABLE nexora.guru (
    id_pengguna integer NOT NULL,
    tipe nexora.tipe_pengguna DEFAULT 'guru'::nexora.tipe_pengguna NOT NULL,
    nip character varying(20) NOT NULL,
    mata_pelajaran character varying(100),
    CONSTRAINT guru_tipe_check CHECK ((tipe = 'guru'::nexora.tipe_pengguna))
);


ALTER TABLE nexora.guru OWNER TO nexora;

--
-- Name: hak_akses_aplikasi; Type: TABLE; Schema: nexora; Owner: nexora
--

CREATE TABLE nexora.hak_akses_aplikasi (
    id_kelompok_akses integer NOT NULL,
    id_aplikasi integer NOT NULL
);


ALTER TABLE nexora.hak_akses_aplikasi OWNER TO nexora;

--
-- Name: kelompok_akses; Type: TABLE; Schema: nexora; Owner: nexora
--

CREATE TABLE nexora.kelompok_akses (
    id_kelompok_akses integer NOT NULL,
    nama_kelompok_akses character varying(100) NOT NULL,
    deskripsi character varying(255)
);


ALTER TABLE nexora.kelompok_akses OWNER TO nexora;

--
-- Name: kelompok_akses_id_kelompok_akses_seq; Type: SEQUENCE; Schema: nexora; Owner: nexora
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
-- Name: lab_komputer; Type: TABLE; Schema: nexora; Owner: nexora
--

CREATE TABLE nexora.lab_komputer (
    id_lab integer NOT NULL,
    nama_lab character varying(100) NOT NULL,
    lokasi character varying(100)
);


ALTER TABLE nexora.lab_komputer OWNER TO nexora;

--
-- Name: lab_komputer_id_lab_seq; Type: SEQUENCE; Schema: nexora; Owner: nexora
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
-- Name: log_aktivitas; Type: TABLE; Schema: nexora; Owner: nexora
--

CREATE TABLE nexora.log_aktivitas (
    id_log bigint NOT NULL,
    waktu timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    aksi character varying(150) NOT NULL,
    hasil nexora.hasil_log NOT NULL,
    id_pengguna integer NOT NULL
);


ALTER TABLE nexora.log_aktivitas OWNER TO nexora;

--
-- Name: log_aktivitas_id_log_seq; Type: SEQUENCE; Schema: nexora; Owner: nexora
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
-- Name: pengguna; Type: TABLE; Schema: nexora; Owner: nexora
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


ALTER TABLE nexora.pengguna OWNER TO nexora;

--
-- Name: COLUMN pengguna.password_hash; Type: COMMENT; Schema: nexora; Owner: nexora
--

COMMENT ON COLUMN nexora.pengguna.password_hash IS 'Hash dari aplikasi (bcrypt/argon2id). Jangan pernah menyimpan password polos.';


--
-- Name: pengguna_id_pengguna_seq; Type: SEQUENCE; Schema: nexora; Owner: nexora
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
-- Name: perangkat; Type: TABLE; Schema: nexora; Owner: nexora
--

CREATE TABLE nexora.perangkat (
    id_perangkat integer NOT NULL,
    nama_perangkat character varying(100) NOT NULL,
    sistem_operasi nexora.os_perangkat NOT NULL,
    status nexora.status_perangkat DEFAULT 'offline'::nexora.status_perangkat NOT NULL,
    id_lab integer NOT NULL
);


ALTER TABLE nexora.perangkat OWNER TO nexora;

--
-- Name: perangkat_id_perangkat_seq; Type: SEQUENCE; Schema: nexora; Owner: nexora
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
-- Name: sesi_login; Type: TABLE; Schema: nexora; Owner: nexora
--

CREATE TABLE nexora.sesi_login (
    id_sesi bigint NOT NULL,
    id_pengguna integer NOT NULL,
    id_perangkat integer NOT NULL,
    waktu_login timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    waktu_logout timestamp without time zone,
    CONSTRAINT ck_sesi_waktu CHECK (((waktu_logout IS NULL) OR (waktu_logout >= waktu_login)))
);


ALTER TABLE nexora.sesi_login OWNER TO nexora;

--
-- Name: sesi_login_id_sesi_seq; Type: SEQUENCE; Schema: nexora; Owner: nexora
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
-- Name: siswa; Type: TABLE; Schema: nexora; Owner: nexora
--

CREATE TABLE nexora.siswa (
    id_pengguna integer NOT NULL,
    tipe nexora.tipe_pengguna DEFAULT 'siswa'::nexora.tipe_pengguna NOT NULL,
    nis character varying(20) NOT NULL,
    kelas character varying(20) NOT NULL,
    CONSTRAINT siswa_tipe_check CHECK ((tipe = 'siswa'::nexora.tipe_pengguna))
);


ALTER TABLE nexora.siswa OWNER TO nexora;

--
-- Name: v_akses_pengguna; Type: VIEW; Schema: nexora; Owner: nexora
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


ALTER VIEW nexora.v_akses_pengguna OWNER TO nexora;

--
-- Name: v_rekap_status_lab; Type: VIEW; Schema: nexora; Owner: nexora
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


ALTER VIEW nexora.v_rekap_status_lab OWNER TO nexora;

--
-- Data for Name: admin_it; Type: TABLE DATA; Schema: nexora; Owner: nexora
--

COPY nexora.admin_it (id_pengguna, tipe, hak_akses_perangkat) FROM stdin;
1	admin	Penuh (semua lab)
\.


--
-- Data for Name: aktivitas_sesi; Type: TABLE DATA; Schema: nexora; Owner: nexora
--

COPY nexora.aktivitas_sesi (id_sesi, waktu_akses, aksi, hasil, id_aplikasi) FROM stdin;
1	2026-10-15 08:05:00	buka aplikasi	diizinkan	1
1	2026-10-15 08:20:00	buka aplikasi	ditolak	4
2	2026-10-15 10:05:00	buka aplikasi	diizinkan	2
3	2026-10-15 08:15:00	buka aplikasi	ditolak	1
4	2026-10-15 09:20:00	buka aplikasi	diizinkan	4
\.


--
-- Data for Name: aplikasi; Type: TABLE DATA; Schema: nexora; Owner: nexora
--

COPY nexora.aplikasi (id_aplikasi, nama_aplikasi, kategori) FROM stdin;
1	Blender	Desain 3D
2	Adobe Photoshop	Desain Grafis
3	Adobe Illustrator	Desain Grafis
4	Visual Studio Code	Pemrograman
5	DBeaver	Basis Data
6	Web Browser	Umum
\.


--
-- Data for Name: guru; Type: TABLE DATA; Schema: nexora; Owner: nexora
--

COPY nexora.guru (id_pengguna, tipe, nip, mata_pelajaran) FROM stdin;
2	guru	198501012010011001	Pemrograman Dasar
3	guru	198702022011012002	Desain Grafis
\.


--
-- Data for Name: hak_akses_aplikasi; Type: TABLE DATA; Schema: nexora; Owner: nexora
--

COPY nexora.hak_akses_aplikasi (id_kelompok_akses, id_aplikasi) FROM stdin;
1	1
1	2
1	3
1	4
1	5
1	6
2	1
2	2
2	3
2	4
2	5
2	6
3	1
3	2
3	3
3	6
4	4
4	5
4	6
\.


--
-- Data for Name: kelompok_akses; Type: TABLE DATA; Schema: nexora; Owner: nexora
--

COPY nexora.kelompok_akses (id_kelompok_akses, nama_kelompok_akses, deskripsi) FROM stdin;
1	Admin	Admin IT / teknisi laboratorium
2	Guru	Guru pengampu
3	Siswa DKV	Siswa jurusan Desain Komunikasi Visual
4	Siswa RPL	Siswa jurusan Rekayasa Perangkat Lunak
9	Siswa Animasi	Siswa jurusan Animasi dan Multimedia
\.


--
-- Data for Name: lab_komputer; Type: TABLE DATA; Schema: nexora; Owner: nexora
--

COPY nexora.lab_komputer (id_lab, nama_lab, lokasi) FROM stdin;
1	Lab DKV	Gedung B Lantai 2
2	Lab RPL	Gedung A Lantai 1
3	Perpustakaan	Gedung C Lantai 1
4	Lab Multimedia	Gedung D Lantai 3
\.


--
-- Data for Name: log_aktivitas; Type: TABLE DATA; Schema: nexora; Owner: nexora
--

COPY nexora.log_aktivitas (id_log, waktu, aksi, hasil, id_pengguna) FROM stdin;
1	2026-10-14 14:55:00	login admin	berhasil	1
2	2026-10-14 15:00:00	tambah hak akses Siswa RPL -> DBeaver	berhasil	1
\.


--
-- Data for Name: pengguna; Type: TABLE DATA; Schema: nexora; Owner: nexora
--

COPY nexora.pengguna (id_pengguna, nama, email, password_hash, status_aktif, tipe, id_kelompok_akses) FROM stdin;
1	Budi Santoso	budi.admin@nexora.test	$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa1	t	admin	1
2	Siti Rahma	siti.guru@nexora.test	$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa2	t	guru	2
3	Agus Wibowo	agus.guru@nexora.test	$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa3	t	guru	2
4	Rina Lestari	rina.dkv@nexora.test	$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa4	t	siswa	3
5	Putri Ayu	putri.dkv@nexora.test	$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa5	t	siswa	3
6	Dimas Pratama	dimas.rpl@nexora.test	$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa6	t	siswa	4
7	Eko Saputra	eko.rpl@nexora.test	$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa7	t	siswa	4
11	Fajar Nugraha	fajar.animasi@nexora.test	$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa8	t	siswa	9
\.


--
-- Data for Name: perangkat; Type: TABLE DATA; Schema: nexora; Owner: nexora
--

COPY nexora.perangkat (id_perangkat, nama_perangkat, sistem_operasi, status, id_lab) FROM stdin;
1	DKV-01	Windows	online	1
2	DKV-02	Windows	offline	1
3	DKV-03	Linux	online	1
4	RPL-01	Linux	online	2
5	RPL-02	Linux	bermasalah	2
6	RPL-03	Windows	online	2
7	RPL-04	Windows	offline	2
8	PERPUS-01	Windows	online	3
9	PERPUS-02	Windows	bermasalah	3
10	MULTI-01	Windows	bermasalah	4
\.


--
-- Data for Name: sesi_login; Type: TABLE DATA; Schema: nexora; Owner: nexora
--

COPY nexora.sesi_login (id_sesi, id_pengguna, id_perangkat, waktu_login, waktu_logout) FROM stdin;
1	4	1	2026-10-15 08:00:00	2026-10-15 09:30:00
2	4	4	2026-10-15 10:00:00	\N
3	6	3	2026-10-15 08:10:00	2026-10-15 09:00:00
4	6	6	2026-10-15 09:15:00	\N
5	2	8	2026-10-15 09:00:00	\N
6	5	7	2026-11-11 19:32:57.605224	\N
7	11	10	2026-11-01 13:00:00	2026-11-01 15:00:00
\.


--
-- Data for Name: siswa; Type: TABLE DATA; Schema: nexora; Owner: nexora
--

COPY nexora.siswa (id_pengguna, tipe, nis, kelas) FROM stdin;
4	siswa	2601001	X DKV 1
5	siswa	2601002	X DKV 1
6	siswa	2601003	X RPL 1
7	siswa	2601004	X RPL 1
11	siswa	2601005	X Animasi 1
\.


--
-- Name: aplikasi_id_aplikasi_seq; Type: SEQUENCE SET; Schema: nexora; Owner: nexora
--

SELECT pg_catalog.setval('nexora.aplikasi_id_aplikasi_seq', 6, true);


--
-- Name: kelompok_akses_id_kelompok_akses_seq; Type: SEQUENCE SET; Schema: nexora; Owner: nexora
--

SELECT pg_catalog.setval('nexora.kelompok_akses_id_kelompok_akses_seq', 9, true);


--
-- Name: lab_komputer_id_lab_seq; Type: SEQUENCE SET; Schema: nexora; Owner: nexora
--

SELECT pg_catalog.setval('nexora.lab_komputer_id_lab_seq', 4, true);


--
-- Name: log_aktivitas_id_log_seq; Type: SEQUENCE SET; Schema: nexora; Owner: nexora
--

SELECT pg_catalog.setval('nexora.log_aktivitas_id_log_seq', 3, true);


--
-- Name: pengguna_id_pengguna_seq; Type: SEQUENCE SET; Schema: nexora; Owner: nexora
--

SELECT pg_catalog.setval('nexora.pengguna_id_pengguna_seq', 13, true);


--
-- Name: perangkat_id_perangkat_seq; Type: SEQUENCE SET; Schema: nexora; Owner: nexora
--

SELECT pg_catalog.setval('nexora.perangkat_id_perangkat_seq', 10, true);


--
-- Name: sesi_login_id_sesi_seq; Type: SEQUENCE SET; Schema: nexora; Owner: nexora
--

SELECT pg_catalog.setval('nexora.sesi_login_id_sesi_seq', 8, true);


--
-- Name: admin_it admin_it_pkey; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.admin_it
    ADD CONSTRAINT admin_it_pkey PRIMARY KEY (id_pengguna);


--
-- Name: aktivitas_sesi aktivitas_sesi_pkey; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.aktivitas_sesi
    ADD CONSTRAINT aktivitas_sesi_pkey PRIMARY KEY (id_sesi, waktu_akses);


--
-- Name: aplikasi aplikasi_nama_aplikasi_key; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.aplikasi
    ADD CONSTRAINT aplikasi_nama_aplikasi_key UNIQUE (nama_aplikasi);


--
-- Name: aplikasi aplikasi_pkey; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.aplikasi
    ADD CONSTRAINT aplikasi_pkey PRIMARY KEY (id_aplikasi);


--
-- Name: guru guru_nip_key; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.guru
    ADD CONSTRAINT guru_nip_key UNIQUE (nip);


--
-- Name: guru guru_pkey; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.guru
    ADD CONSTRAINT guru_pkey PRIMARY KEY (id_pengguna);


--
-- Name: hak_akses_aplikasi hak_akses_aplikasi_pkey; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.hak_akses_aplikasi
    ADD CONSTRAINT hak_akses_aplikasi_pkey PRIMARY KEY (id_kelompok_akses, id_aplikasi);


--
-- Name: kelompok_akses kelompok_akses_nama_kelompok_akses_key; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.kelompok_akses
    ADD CONSTRAINT kelompok_akses_nama_kelompok_akses_key UNIQUE (nama_kelompok_akses);


--
-- Name: kelompok_akses kelompok_akses_pkey; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.kelompok_akses
    ADD CONSTRAINT kelompok_akses_pkey PRIMARY KEY (id_kelompok_akses);


--
-- Name: lab_komputer lab_komputer_nama_lab_key; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.lab_komputer
    ADD CONSTRAINT lab_komputer_nama_lab_key UNIQUE (nama_lab);


--
-- Name: lab_komputer lab_komputer_pkey; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.lab_komputer
    ADD CONSTRAINT lab_komputer_pkey PRIMARY KEY (id_lab);


--
-- Name: log_aktivitas log_aktivitas_pkey; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.log_aktivitas
    ADD CONSTRAINT log_aktivitas_pkey PRIMARY KEY (id_log);


--
-- Name: pengguna pengguna_email_key; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.pengguna
    ADD CONSTRAINT pengguna_email_key UNIQUE (email);


--
-- Name: pengguna pengguna_pkey; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.pengguna
    ADD CONSTRAINT pengguna_pkey PRIMARY KEY (id_pengguna);


--
-- Name: perangkat perangkat_pkey; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.perangkat
    ADD CONSTRAINT perangkat_pkey PRIMARY KEY (id_perangkat);


--
-- Name: sesi_login sesi_login_pkey; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.sesi_login
    ADD CONSTRAINT sesi_login_pkey PRIMARY KEY (id_sesi);


--
-- Name: siswa siswa_nis_key; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.siswa
    ADD CONSTRAINT siswa_nis_key UNIQUE (nis);


--
-- Name: siswa siswa_pkey; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.siswa
    ADD CONSTRAINT siswa_pkey PRIMARY KEY (id_pengguna);


--
-- Name: pengguna uq_pengguna_tipe; Type: CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.pengguna
    ADD CONSTRAINT uq_pengguna_tipe UNIQUE (id_pengguna, tipe);


--
-- Name: idx_aktivitas_aplikasi; Type: INDEX; Schema: nexora; Owner: nexora
--

CREATE INDEX idx_aktivitas_aplikasi ON nexora.aktivitas_sesi USING btree (id_aplikasi);


--
-- Name: idx_ha_aplikasi; Type: INDEX; Schema: nexora; Owner: nexora
--

CREATE INDEX idx_ha_aplikasi ON nexora.hak_akses_aplikasi USING btree (id_aplikasi);


--
-- Name: idx_log_pengguna; Type: INDEX; Schema: nexora; Owner: nexora
--

CREATE INDEX idx_log_pengguna ON nexora.log_aktivitas USING btree (id_pengguna);


--
-- Name: idx_pengguna_kelompok; Type: INDEX; Schema: nexora; Owner: nexora
--

CREATE INDEX idx_pengguna_kelompok ON nexora.pengguna USING btree (id_kelompok_akses);


--
-- Name: idx_perangkat_lab; Type: INDEX; Schema: nexora; Owner: nexora
--

CREATE INDEX idx_perangkat_lab ON nexora.perangkat USING btree (id_lab);


--
-- Name: idx_perangkat_nama; Type: INDEX; Schema: nexora; Owner: nexora
--

CREATE INDEX idx_perangkat_nama ON nexora.perangkat USING btree (nama_perangkat varchar_pattern_ops);


--
-- Name: idx_perangkat_os; Type: INDEX; Schema: nexora; Owner: nexora
--

CREATE INDEX idx_perangkat_os ON nexora.perangkat USING btree (sistem_operasi);


--
-- Name: idx_sesi_aktif; Type: INDEX; Schema: nexora; Owner: nexora
--

CREATE INDEX idx_sesi_aktif ON nexora.sesi_login USING btree (id_perangkat) WHERE (waktu_logout IS NULL);


--
-- Name: idx_sesi_pengguna; Type: INDEX; Schema: nexora; Owner: nexora
--

CREATE INDEX idx_sesi_pengguna ON nexora.sesi_login USING btree (id_pengguna);


--
-- Name: idx_sesi_perangkat; Type: INDEX; Schema: nexora; Owner: nexora
--

CREATE INDEX idx_sesi_perangkat ON nexora.sesi_login USING btree (id_perangkat);


--
-- Name: idx_sesi_waktu; Type: INDEX; Schema: nexora; Owner: nexora
--

CREATE INDEX idx_sesi_waktu ON nexora.sesi_login USING btree (waktu_login);


--
-- Name: admin_it trg_admin_total; Type: TRIGGER; Schema: nexora; Owner: nexora
--

CREATE CONSTRAINT TRIGGER trg_admin_total AFTER DELETE OR UPDATE ON nexora.admin_it DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION nexora.fn_validasi_subtipe();


--
-- Name: guru trg_guru_total; Type: TRIGGER; Schema: nexora; Owner: nexora
--

CREATE CONSTRAINT TRIGGER trg_guru_total AFTER DELETE OR UPDATE ON nexora.guru DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION nexora.fn_validasi_subtipe();


--
-- Name: pengguna trg_pengguna_total; Type: TRIGGER; Schema: nexora; Owner: nexora
--

CREATE CONSTRAINT TRIGGER trg_pengguna_total AFTER INSERT ON nexora.pengguna DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION nexora.fn_validasi_subtipe();


--
-- Name: siswa trg_siswa_total; Type: TRIGGER; Schema: nexora; Owner: nexora
--

CREATE CONSTRAINT TRIGGER trg_siswa_total AFTER DELETE OR UPDATE ON nexora.siswa DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION nexora.fn_validasi_subtipe();


--
-- Name: admin_it fk_admin_pengguna; Type: FK CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.admin_it
    ADD CONSTRAINT fk_admin_pengguna FOREIGN KEY (id_pengguna, tipe) REFERENCES nexora.pengguna(id_pengguna, tipe) ON DELETE CASCADE;


--
-- Name: aktivitas_sesi fk_aktivitas_aplikasi; Type: FK CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.aktivitas_sesi
    ADD CONSTRAINT fk_aktivitas_aplikasi FOREIGN KEY (id_aplikasi) REFERENCES nexora.aplikasi(id_aplikasi) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: aktivitas_sesi fk_aktivitas_sesi; Type: FK CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.aktivitas_sesi
    ADD CONSTRAINT fk_aktivitas_sesi FOREIGN KEY (id_sesi) REFERENCES nexora.sesi_login(id_sesi) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: guru fk_guru_pengguna; Type: FK CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.guru
    ADD CONSTRAINT fk_guru_pengguna FOREIGN KEY (id_pengguna, tipe) REFERENCES nexora.pengguna(id_pengguna, tipe) ON DELETE CASCADE;


--
-- Name: hak_akses_aplikasi fk_ha_aplikasi; Type: FK CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.hak_akses_aplikasi
    ADD CONSTRAINT fk_ha_aplikasi FOREIGN KEY (id_aplikasi) REFERENCES nexora.aplikasi(id_aplikasi) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hak_akses_aplikasi fk_ha_kelompok; Type: FK CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.hak_akses_aplikasi
    ADD CONSTRAINT fk_ha_kelompok FOREIGN KEY (id_kelompok_akses) REFERENCES nexora.kelompok_akses(id_kelompok_akses) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: log_aktivitas fk_log_pengguna; Type: FK CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.log_aktivitas
    ADD CONSTRAINT fk_log_pengguna FOREIGN KEY (id_pengguna) REFERENCES nexora.pengguna(id_pengguna) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pengguna fk_pengguna_kelompok; Type: FK CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.pengguna
    ADD CONSTRAINT fk_pengguna_kelompok FOREIGN KEY (id_kelompok_akses) REFERENCES nexora.kelompok_akses(id_kelompok_akses) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: perangkat fk_perangkat_lab; Type: FK CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.perangkat
    ADD CONSTRAINT fk_perangkat_lab FOREIGN KEY (id_lab) REFERENCES nexora.lab_komputer(id_lab) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sesi_login fk_sesi_pengguna; Type: FK CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.sesi_login
    ADD CONSTRAINT fk_sesi_pengguna FOREIGN KEY (id_pengguna) REFERENCES nexora.pengguna(id_pengguna) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sesi_login fk_sesi_perangkat; Type: FK CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.sesi_login
    ADD CONSTRAINT fk_sesi_perangkat FOREIGN KEY (id_perangkat) REFERENCES nexora.perangkat(id_perangkat) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: siswa fk_siswa_pengguna; Type: FK CONSTRAINT; Schema: nexora; Owner: nexora
--

ALTER TABLE ONLY nexora.siswa
    ADD CONSTRAINT fk_siswa_pengguna FOREIGN KEY (id_pengguna, tipe) REFERENCES nexora.pengguna(id_pengguna, tipe) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict CQlZOMfT5QVjQ9NsEiIDOt3WjFmtZeusWtLXUi80TrF4oZcgNoOoiIaRmGKoZOF

