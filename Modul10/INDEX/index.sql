CREATE INDEX idx_pengguna_kelompok ON pengguna (id_kelompok_akses);
CREATE INDEX idx_perangkat_lab ON perangkat (id_lab);
CREATE INDEX idx_sesi_pengguna ON sesi_login (id_pengguna);
CREATE INDEX idx_perangkat_nama ON perangkat (nama_perangkat varchar_pattern_ops);
CREATE INDEX idx_perangkat_os ON perangkat (sistem_operasi);
