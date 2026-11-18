-- =====================================================================
-- 02_tabel.sql: Menambah kolom JSONB, constraint, dan index GIN
-- Modul 11 | PostgreSQL (proyek Nexora)
-- Jalankan setelah 01_database.sql: psql -U nexora -d nexora_modul11 -f 02_tabel.sql
-- =====================================================================

SET search_path TO nexora, public;

BEGIN;

-- Perangkat
ALTER TABLE nexora.perangkat
    ADD COLUMN IF NOT EXISTS spesifikasi jsonb NOT NULL DEFAULT '{}'::jsonb;

ALTER TABLE nexora.perangkat
    DROP CONSTRAINT IF EXISTS ck_perangkat_spesifikasi_objek;
ALTER TABLE nexora.perangkat
    ADD CONSTRAINT ck_perangkat_spesifikasi_objek
    CHECK (jsonb_typeof(spesifikasi) = 'object');

COMMENT ON COLUMN nexora.perangkat.spesifikasi IS
    'Atribut perangkat yang bervariasi (cpu, ram_gb, gpu, monitor, dst) dalam JSONB.';

-- Aplikasi
ALTER TABLE nexora.aplikasi
    ADD COLUMN IF NOT EXISTS metadata jsonb NOT NULL DEFAULT '{}'::jsonb;

ALTER TABLE nexora.aplikasi
    DROP CONSTRAINT IF EXISTS ck_aplikasi_metadata_objek;
ALTER TABLE nexora.aplikasi
    ADD CONSTRAINT ck_aplikasi_metadata_objek
    CHECK (jsonb_typeof(metadata) = 'object');

COMMENT ON COLUMN nexora.aplikasi.metadata IS
    'Atribut aplikasi yang bervariasi (model_lisensi, butuh_gpu, os_didukung, dst) dalam JSONB.';

-- Index GIN: mempercepat pencarian @> pada JSONB
CREATE INDEX IF NOT EXISTS idx_perangkat_spesifikasi_gin
    ON nexora.perangkat USING gin (spesifikasi jsonb_path_ops);
CREATE INDEX IF NOT EXISTS idx_aplikasi_metadata_gin
    ON nexora.aplikasi USING gin (metadata jsonb_path_ops);

COMMIT;

-- Verifikasi
SELECT table_name, column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'nexora'
  AND ((table_name = 'perangkat' AND column_name = 'spesifikasi')
    OR (table_name = 'aplikasi'  AND column_name = 'metadata'));
