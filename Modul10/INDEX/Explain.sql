SET enable_seqscan = off;
EXPLAIN SELECT * FROM perangkat WHERE nama_perangkat LIKE 'RPL%';
EXPLAIN SELECT * FROM perangkat WHERE sistem_operasi = 'Linux';
RESET enable_seqscan;
