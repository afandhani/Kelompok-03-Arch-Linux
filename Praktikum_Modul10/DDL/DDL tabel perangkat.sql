-- nexora.perangkat definition

-- Drop table

-- DROP TABLE nexora.perangkat;

CREATE TABLE nexora.perangkat (
	id_perangkat int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	nama_perangkat varchar(100) NOT NULL,
	sistem_operasi nexora.os_perangkat NOT NULL,
	status nexora.status_perangkat DEFAULT 'offline'::status_perangkat NOT NULL,
	id_lab int4 NOT NULL,
	CONSTRAINT perangkat_id_lab_not_null NOT NULL id_lab,
	CONSTRAINT perangkat_id_perangkat_not_null NOT NULL id_perangkat,
	CONSTRAINT perangkat_nama_perangkat_not_null NOT NULL nama_perangkat,
	CONSTRAINT perangkat_pkey PRIMARY KEY (id_perangkat),
	CONSTRAINT perangkat_sistem_operasi_not_null NOT NULL sistem_operasi,
	CONSTRAINT perangkat_status_not_null NOT NULL status
);
CREATE INDEX idx_perangkat_lab ON nexora.perangkat USING btree (id_lab);
CREATE INDEX idx_perangkat_nama ON nexora.perangkat USING btree (nama_perangkat varchar_pattern_ops);
CREATE INDEX idx_perangkat_os ON nexora.perangkat USING btree (sistem_operasi);


-- nexora.perangkat foreign keys

ALTER TABLE nexora.perangkat ADD CONSTRAINT fk_perangkat_lab FOREIGN KEY (id_lab) REFERENCES nexora.lab_komputer(id_lab) ON DELETE RESTRICT ON UPDATE CASCADE;
