-- nexora.lab_komputer definition

-- Drop table

-- DROP TABLE nexora.lab_komputer;

CREATE TABLE nexora.lab_komputer (
	id_lab int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	nama_lab varchar(100) NOT NULL,
	lokasi varchar(100) NULL,
	CONSTRAINT lab_komputer_id_lab_not_null NOT NULL id_lab,
	CONSTRAINT lab_komputer_nama_lab_key UNIQUE (nama_lab),
	CONSTRAINT lab_komputer_nama_lab_not_null NOT NULL nama_lab,
	CONSTRAINT lab_komputer_pkey PRIMARY KEY (id_lab)
);
