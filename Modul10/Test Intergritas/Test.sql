DO $$
BEGIN
  -- 1. Uji Disjoint: Coba masukkan Siti (id 2, Guru) ke tabel Siswa (Harus GAGAL)
  BEGIN
    INSERT INTO siswa (id_pengguna, nis, kelas) VALUES (2, '9999001', 'X RPL 1');
    RAISE NOTICE 'GAGAL: Guru berhasil dimasukkan ke siswa';
  EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'BERHASIL (Disjoint Bekerja): %', SQLERRM;
  END;

  -- 2. Uji Total Specialization: Buat pengguna tanpa mendaftarkannya ke subtipe (Harus GAGAL)
  BEGIN
    INSERT INTO pengguna (nama, email, password_hash, tipe, id_kelompok_akses)
    VALUES ('Tanpa Subtipe', 'x@nexora.test',
            '$2b$12$DemoSaltDemoSaltDemoSaDemoHashDemoHashDemoHashDemoHa9', 'siswa', 3);
    SET CONSTRAINTS ALL IMMEDIATE; -- Paksa pengecekan sekarang
    RAISE NOTICE 'GAGAL: Pengguna tanpa subtipe lolos';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'BERHASIL (Total Specialization Bekerja): %', SQLERRM;
  END;

  -- 3. Uji Hash Password: Coba masukkan password polos (Harus GAGAL)
  BEGIN
    INSERT INTO pengguna (nama, email, password_hash, tipe, id_kelompok_akses)
    VALUES ('Password Polos', 'y@nexora.test', 'rahasia123', 'siswa', 3);
    RAISE NOTICE 'GAGAL: Password polos lolos';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'BERHASIL (Check Hash Bekerja): %', SQLERRM;
  END;
END;
$$;
