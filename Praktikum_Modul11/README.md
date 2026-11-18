# Praktikum Modul 11 — Perkembangan DBMS dan Lingkup Penerapan Basis Data

Kelompok : _isi nama anggota, NIM, kelas_
Proyek   : Nexora (manajemen lab komputer sekolah) — PostgreSQL, schema `nexora`

## Struktur

```
praktikum_modul11/
├── sql/
│   ├── 01_database.sql          # A. buat database + struktur tabel  |  B. eksplorasi DBMS
│   ├── 02_tabel.sql             # kolom JSONB, constraint, index GIN
│   ├── 03_data_awal.sql         # pengisian data awal (INSERT, dari backup_modul10)
│   └── 04_pengujian_json.sql    # 0. isi data JSONB  |  A. pengujian JSONB  |  B. pemodelan objek
├── dokumentasi/   # perbandingan_dbms.pdf, analisis_objek.pdf, lingkup_penerapan.pdf
├── diagram/       # pemodelan_objek.png
└── README.md
```

## Urutan menjalankan (PostgreSQL / Nexora)

`01 → 02 → 03 → 04`

```
psql -U postgres -f sql/01_database.sql                    # buat database + struktur tabel
psql -U nexora -d nexora_modul11 -f sql/02_tabel.sql
psql -U nexora -d nexora_modul11 -f sql/03_data_awal.sql   # data awal (INSERT)
psql -U nexora -d nexora_modul11 -f sql/04_pengujian_json.sql   # isi data JSONB + pengujian
```

## Pemetaan file → tugas modul

| Tugas (skor) | Berkas |
|---|---|
| 1. Eksplorasi & perbandingan DBMS (25) | `01_database.sql` (Bagian B), `dokumentasi/perbandingan_dbms.pdf` |
| 2. Implementasi fitur JSON (30) | `02_tabel.sql`, `03_data_awal.sql`, `04_pengujian_json.sql` (Bagian 0 & A) |
| 3. Analisis berorientasi objek (25) | `04_pengujian_json.sql` (Bagian B), `dokumentasi/analisis_objek.pdf`, `diagram/pemodelan_objek.png` |
| 4. Lingkup penerapan & dokumentasi (20) | `dokumentasi/lingkup_penerapan.pdf` |

## Keamanan
Jangan commit password, kredensial, atau data pribadi nyata. Script hanya memakai
placeholder (`<ISI_PASSWORD_SENDIRI>`) atau role `NOLOGIN`.

## Git
```
git init
git add .
git commit -m "Praktikum modul 11 basis data"
git remote add origin URL_REPOSITORY
git branch -M main
git push -u origin main
```
