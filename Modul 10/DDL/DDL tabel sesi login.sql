-- nexora.sesi_login definition

-- Drop table

-- DROP TABLE nexora.sesi_login;

CREATE TABLE nexora.sesi_login (
	id_sesi int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	id_pengguna int4 NOT NULL,
	id_perangkat int4 NOT NULL,
	waktu_login timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	waktu_logout timestamp NULL,
	CONSTRAINT ck_sesi_waktu CHECK (((waktu_logout IS NULL) OR (waktu_logout >= waktu_login))),
	CONSTRAINT sesi_login_id_pengguna_not_null NOT NULL id_pengguna,
	CONSTRAINT sesi_login_id_perangkat_not_null NOT NULL id_perangkat,
	CONSTRAINT sesi_login_id_sesi_not_null NOT NULL id_sesi,
	CONSTRAINT sesi_login_pkey PRIMARY KEY (id_sesi),
	CONSTRAINT sesi_login_waktu_login_not_null NOT NULL waktu_login
);
CREATE INDEX idx_sesi_aktif ON nexora.sesi_login USING btree (id_perangkat) WHERE (waktu_logout IS NULL);
CREATE INDEX idx_sesi_pengguna ON nexora.sesi_login USING btree (id_pengguna);
CREATE INDEX idx_sesi_perangkat ON nexora.sesi_login USING btree (id_perangkat);
CREATE INDEX idx_sesi_waktu ON nexora.sesi_login USING btree (waktu_login);


-- nexora.sesi_login foreign keys

ALTER TABLE nexora.sesi_login ADD CONSTRAINT fk_sesi_pengguna FOREIGN KEY (id_pengguna) REFERENCES nexora.pengguna(id_pengguna) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE nexora.sesi_login ADD CONSTRAINT fk_sesi_perangkat FOREIGN KEY (id_perangkat) REFERENCES nexora.perangkat(id_perangkat) ON DELETE RESTRICT ON UPDATE CASCADE;
