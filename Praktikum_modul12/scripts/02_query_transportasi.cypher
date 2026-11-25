// =====================================================================
// Modul 12 | Konsep Pemrosesan Query Basis Data
// DBMS     : Neo4j 5.26 Enterprise (Graph Database)
// File     : 02_query_transportasi.cypher
//
// Kebutuhan informasi:
//   Tampilkan trip_id, started_at, dan route_name untuk perjalanan
//   pada route_id = 12 sejak 1 November 2026.
//
// Ekspresi aljabar relasional:
//   pi(trip_id, started_at, route_name)(
//     sigma(route_id = 12 AND started_at >= '2026-11-01')(
//       TRIPS join ROUTES
//     )
//   )
//
// Hasil yang diharapkan: 3 baris -> T001, T003, T005
// =====================================================================


// ---------------------------------------------------------------------
// Q1. QUERY UTAMA (padanan seleksi + join + proyeksi)
//     sigma -> pola dan WHERE, join -> relasi ON_ROUTE, pi -> RETURN
// ---------------------------------------------------------------------
MATCH (t:Trip)-[:ON_ROUTE]->(r:Route {route_id: 12})
WHERE t.started_at >= datetime('2026-11-01T00:00:00')
RETURN t.trip_id     AS trip_id,
       t.started_at  AS started_at,
       r.route_name  AS route_name
ORDER BY t.started_at;


// ---------------------------------------------------------------------
// Q2. RENCANA 1 DIPAKSA (planner hint USING SCAN)
// ---------------------------------------------------------------------
PROFILE MATCH (t:Trip)-[:ON_ROUTE]->(r:Route) USING SCAN t:Trip
WHERE r.route_id = 12
  AND t.started_at >= datetime('2026-11-01T00:00:00')
RETURN t.trip_id     AS trip_id,
       t.started_at  AS started_at,
       r.route_name  AS route_name
ORDER BY trip_id;


// ---------------------------------------------------------------------
// Q3. RENCANA 2 DIPAKSA (planner hint USING INDEX)
// ---------------------------------------------------------------------
PROFILE MATCH (r:Route) USING INDEX r:Route(route_id)
WHERE r.route_id = 12
MATCH (t:Trip)-[:ON_ROUTE]->(r)
WHERE t.started_at >= datetime('2026-11-01T00:00:00')
RETURN t.trip_id     AS trip_id,
       t.started_at  AS started_at,
       r.route_name  AS route_name
ORDER BY trip_id;
