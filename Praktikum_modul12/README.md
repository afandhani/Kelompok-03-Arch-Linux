# Praktikum Modul 12 — Basis Data Graf (*Graph Database*) dengan Neo4j

Repositori ini berisi hasil pengerjaan **Praktikum Modul 12** mengenai implementasi basis data graf (*Graph Database*) menggunakan **Neo4j** dan bahasa kueri **Cypher**. Praktikum ini mencakup pembuatan skema graf (*node* dan *relationship*), kueri analisis jalur transportasi, pengujian kontrol akses (DCL), serta perancangan migrasi basis data proyek *Project-Based Learning* (PJBL) ke dalam model graf.

---

## 👥 Identitas Kelompok
* **Kelompok:** 03 (Arch Linux)
* **Anggota Kelompok:**
  1. `[AFAN DHANI PRASETYO]` — `[264311003]`
  2. `[DAVA AL MUSTOFFA DACHLAN]` — `[264311010]`
  3. `[JULIAN RAKA NUGRAHA]` — `[264311018]`

---

## 📁 Struktur Direktori

```text
Praktikum_modul12/
├── Diagram/                                  # Diagram rancangan skema graf (Node & Relationship)
├── Dokumentasi/                              # Laporan dan dokumentasi hasil pengujian praktikum
├── scripts/                                  # Kumpulan skrip kueri Cypher (.cypher)
│   ├── 01_migrasi_data_latihan.cypher        # Inisialisasi & migrasi data latihan graf
│   ├── 02_query_transportasi.cypher          # Eksplorasi & pencarian rute pada graf transportasi
│   ├── 03_pengujian_dcl.cypher               # Pengujian manajemen role & hak akses (DCL)
│   └── 04_rancangan_migrasi_pjbl.cypher      # Rancangan skema & migrasi data proyek PJBL ke Neo4j
└── README.md                                 # Dokumentasi utama Praktikum Modul 12
```

---

## 📜 Rincian Skrip Cypher (`scripts/`)

1. **`01_migrasi_data_latihan.cypher`**
   * **Deskripsi:** Skrip inisialisasi awal untuk membangun struktur graf latihan, mencakup pembuatan *node*, penetapan *label*, pemberian properti, serta pembentukan relasi (*relationship*) antar entitas.
2. **`02_query_transportasi.cypher`**
   * **Deskripsi:** Kumpulan kueri Cypher untuk studi kasus jaringan transportasi. Digunakan untuk menelusuri keterhubungan antar titik/stasiun, memfilter properti rute, serta mencari jalur terpendek (*shortest path*).
3. **`03_pengujian_dcl.cypher`**
   * **Deskripsi:** Implementasi dan pengujian *Data Control Language* (DCL) pada Neo4j, meliputi pembuatan pengguna (*user*), pengaturan peran (*role*), serta pemberian maupun pencabutan hak akses (`GRANT`, `DENY`, `REVOKE`) terhadap operasi pembacaan dan penulisan graf.
4. **`04_rancangan_migrasi_pjbl.cypher`**
   * **Deskripsi:** Implementasi rancangan transformasi dan migrasi data proyek PJBL (*Nexora Education* — manajemen laboratorium komputer, perangkat, dan sesi login) dari model relasional ke dalam model *Graph Database* Neo4j.

---

## 🚀 Prasyarat & Cara Menjalankan

### Prasyarat
* **Neo4j Desktop**, **Neo4j AuraDB**, atau **Neo4j Server** (versi 4.x / 5.x ke atas).
* **Neo4j Browser** atau **Cypher Shell** (`cypher-shell`).

### Langkah Eksekusi
1. Pastikan *instance* database Neo4j sudah dalam keadaan aktif (*Running*).
2. Buka **Neo4j Browser** (biasanya berjalan di `http://localhost:7474`).
3. Jalankan skrip secara berurutan mulai dari `01_migrasi_data_latihan.cypher` hingga `04_rancangan_migrasi_pjbl.cypher` dengan menyalin isi skrip ke editor kueri, atau jalankan melalui terminal menggunakan `cypher-shell`:

```bash
cypher-shell -u neo4j -p <password_anda> -f scripts/01_migrasi_data_latihan.cypher
```

> **Catatan:** Untuk pengujian pada `03_pengujian_dcl.cypher`, pastikan menggunakan akun dengan hak akses administrator dan menggunakan edisi Neo4j yang mendukung manajemen multi-user/RBAC (seperti Neo4j Enterprise atau Neo4j Desktop).

---

## 📊 Diagram & Dokumentasi
* Seluruh visualisasi model graf (*Node-Relationship Diagram*) tersimpan di dalam direktori [`Diagram/`](./Diagram/).
* Laporan lengkap beserta tangkapan layar (*screenshot*) hasil eksekusi kueri tersimpan di dalam direktori [`Dokumentasi/`](./Dokumentasi/).