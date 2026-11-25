// =====================================================================
// Modul 12 | Konsep Pemrosesan Query Basis Data
// DBMS     : Neo4j 5.26 Enterprise (Graph Database)
//
// Tujuan   : Memindahkan kasus latihan layanan transportasi dari model
//            relasional (ROUTES, TRIPS) ke model graf (simpul + relasi).
//
// Pemetaan :
//   Tabel  ROUTES                  -> simpul (:Route)
//   Tabel  TRIPS                   -> simpul (:Trip)
//   Kolom  TRIPS.route_id (FK)     -> relasi -[:ON_ROUTE]->
//   Kolom  route_id, route_name    -> sifat (property) simpul
//
// =====================================================================


// ---------------------------------------------------------------------
// 1. CONSTRAINT DAN INDEX
// ---------------------------------------------------------------------
CREATE CONSTRAINT route_id_unique IF NOT EXISTS
FOR (r:Route) REQUIRE r.route_id IS UNIQUE;

CREATE CONSTRAINT trip_id_unique IF NOT EXISTS
FOR (t:Trip) REQUIRE t.trip_id IS UNIQUE;

// Index untuk mempercepat seleksi berbasis tanggal.
CREATE INDEX trip_started_at IF NOT EXISTS
FOR (t:Trip) ON (t.started_at);


// ---------------------------------------------------------------------
// 2. MIGRASI DATA ROUTES  (3 baris)
// ---------------------------------------------------------------------
UNWIND [
  {route_id: 12, route_name: 'Koridor Pusat–Terminal'},
  {route_id: 15, route_name: 'Koridor Kampus–Stasiun'},
  {route_id: 18, route_name: 'Koridor Pasar–Kota'}
] AS row
MERGE (r:Route {route_id: row.route_id})
SET   r.route_name = row.route_name;


// ---------------------------------------------------------------------
// 3. MIGRASI DATA TRIPS  (6 baris)
//    Kunci asing route_id TIDAK disimpan sebagai sifat, melainkan
//    diubah menjadi relasi ON_ROUTE. Inilah inti migrasi ke graph DB:
//    hubungan menjadi bagian dari struktur penyimpanan.
// ---------------------------------------------------------------------
UNWIND [
  {trip_id:'T001', route_id:12, started_at:'2026-11-02T07:10:00', status:'completed'},
  {trip_id:'T002', route_id:15, started_at:'2026-11-02T07:25:00', status:'completed'},
  {trip_id:'T003', route_id:12, started_at:'2026-11-03T08:05:00', status:'delayed'},
  {trip_id:'T004', route_id:18, started_at:'2026-10-29T06:50:00', status:'completed'},
  {trip_id:'T005', route_id:12, started_at:'2026-11-05T17:20:00', status:'completed'},
  {trip_id:'T006', route_id:15, started_at:'2026-11-06T09:15:00', status:'cancelled'}
] AS row
MATCH (r:Route {route_id: row.route_id})
MERGE (t:Trip {trip_id: row.trip_id})
SET   t.started_at = datetime(row.started_at),
      t.status     = row.status
MERGE (t)-[:ON_ROUTE]->(r);


// ---------------------------------------------------------------------
// 4. VERIFIKASI HASIL MIGRASI
//    Harapan: Route = 3, Trip = 6, ON_ROUTE = 6.
// ---------------------------------------------------------------------
MATCH (n)
RETURN labels(n) AS label, count(*) AS jumlah
ORDER BY label;

MATCH ()-[r]->()
RETURN type(r) AS relasi, count(*) AS jumlah;

// Seluruh trip beserta nama rutenya (setara JOIN tanpa JOIN)
MATCH (t:Trip)-[:ON_ROUTE]->(r:Route)
RETURN t.trip_id     AS trip_id,
       t.started_at  AS started_at,
       t.status      AS status,
       r.route_name  AS route_name
ORDER BY t.trip_id;
