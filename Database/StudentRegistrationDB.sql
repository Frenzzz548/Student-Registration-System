/* =====================================================================
   HANDS-ON LAB 1 - Membangun Database Student Registration (SQL Server)
   Mata Kuliah : .NET Programming with C#
   Database    : StudentRegistrationDB
   Cara pakai  : Buka di SSMS, koneksi ke .\SQLEXPRESS, lalu Execute (F5).
   Script ini aman dijalankan berulang: tabel lama akan di-reset.
   ===================================================================== */

/* ---------------------------------------------------------------------
   LAB 09 - Membuat Database
   --------------------------------------------------------------------- */
IF DB_ID(N'StudentRegistrationDB') IS NULL
BEGIN
    CREATE DATABASE StudentRegistrationDB;
END
GO

/* ---------------------------------------------------------------------
   LAB 10 - Menggunakan Database
   --------------------------------------------------------------------- */
USE StudentRegistrationDB;
GO

SELECT DB_NAME() AS CurrentDatabase;   -- Hasil: StudentRegistrationDB
GO

/* ---------------------------------------------------------------------
   Reset (agar script bisa dijalankan ulang).
   Students harus di-drop lebih dulu karena memiliki FK ke Programs.
   --------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.Students', N'U') IS NOT NULL DROP TABLE dbo.Students;
IF OBJECT_ID(N'dbo.Programs', N'U') IS NOT NULL DROP TABLE dbo.Programs;
GO

/* ---------------------------------------------------------------------
   LAB 11 - Membuat Tabel Programs (PRIMARY KEY + UNIQUE + DEFAULT)
   --------------------------------------------------------------------- */
CREATE TABLE Programs
(
    ProgramId INT IDENTITY(1,1)
        CONSTRAINT PK_Programs PRIMARY KEY,

    ProgramCode VARCHAR(20) NOT NULL
        CONSTRAINT UQ_Programs_ProgramCode UNIQUE,

    ProgramName VARCHAR(100) NOT NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_Programs_IsActive DEFAULT 1,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Programs_CreatedAt
        DEFAULT SYSDATETIME()
);
GO

/* ---------------------------------------------------------------------
   LAB 12 - Memasukkan Data Program Studi
   --------------------------------------------------------------------- */
INSERT INTO Programs
(
    ProgramCode,
    ProgramName
)
VALUES
('TI',  'Teknik Informatika'),
('SI',  'Sistem Informasi'),
('MNJ', 'Manajemen'),
('TE',  'Teknik Elektro'),
('DKV', 'Desain Komunikasi Visual');
GO

/* ---------------------------------------------------------------------
   LAB 13 - Melihat Data Programs
   --------------------------------------------------------------------- */
SELECT * FROM Programs;
GO

/* ---------------------------------------------------------------------
   LAB 14 - Membuat Tabel Students (PK, UNIQUE NIM, FK ke Programs)
   --------------------------------------------------------------------- */
CREATE TABLE Students
(
    StudentId INT IDENTITY(1,1)
        CONSTRAINT PK_Students PRIMARY KEY,

    NIM VARCHAR(20) NOT NULL
        CONSTRAINT UQ_Students_NIM UNIQUE,

    Name VARCHAR(100) NOT NULL,

    ProgramId INT NOT NULL,

    BirthDate DATE NULL,

    Address VARCHAR(250) NULL,

    PhoneNumber VARCHAR(20) NULL,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Students_CreatedAt
        DEFAULT SYSDATETIME(),

    UpdatedAt DATETIME2 NULL,

    CONSTRAINT FK_Students_Programs
        FOREIGN KEY (ProgramId)
        REFERENCES Programs(ProgramId)
);
GO

/* ---------------------------------------------------------------------
   LAB 15 - Relasi 1:N
   Satu Program dapat memiliki banyak Students;
   satu Student hanya memiliki satu ProgramId.
   --------------------------------------------------------------------- */

/* ---------------------------------------------------------------------
   LAB 16 - Memasukkan Data Mahasiswa
   --------------------------------------------------------------------- */
INSERT INTO Students
(
    NIM,
    Name,
    ProgramId,
    BirthDate,
    Address,
    PhoneNumber
)
VALUES
('20231001', 'Ahmad Rizki',   1, '2003-03-12', 'Jl. Merdeka No. 123, Surabaya',   '081234567890'),
('20231002', 'Siti Aisyah',   2, '2004-07-21', 'Jl. Diponegoro No. 45, Surabaya', '082233445566'),
('20231003', 'Budi Santoso',  1, '2003-11-05', 'Jl. Ahmad Yani No. 10, Surabaya', '081355667788'),
('20231004', 'Citra Lestari', 3, '2004-01-18', 'Jl. Darmo No. 20, Surabaya',      '089900112233'),
('20231005', 'Dimas Prayoga', 4, '2003-09-27', 'Jl. Raya ITS, Surabaya',          '081288776655');
GO

/* ---------------------------------------------------------------------
   LAB 17 - Menampilkan Data Students
   --------------------------------------------------------------------- */
SELECT * FROM Students;
GO

/* ---------------------------------------------------------------------
   LAB 18 - Menggabungkan Dua Tabel (INNER JOIN)
   --------------------------------------------------------------------- */
SELECT
    s.StudentId,
    s.NIM,
    s.Name,
    p.ProgramCode,
    p.ProgramName,
    s.BirthDate,
    s.PhoneNumber
FROM Students s
INNER JOIN Programs p
    ON s.ProgramId = p.ProgramId;
GO

/* ---------------------------------------------------------------------
   LAB 19 - Pengujian Foreign Key
   ProgramId 99 tidak ada -> SQL Server HARUS menolak (error 547).
   Dibungkus TRY/CATCH supaya script tetap lanjut dan pesannya tampil.
   --------------------------------------------------------------------- */
BEGIN TRY
    INSERT INTO Students (NIM, Name, ProgramId)
    VALUES ('20231099', 'Test Student', 99);

    PRINT 'PERINGATAN: data seharusnya ditolak oleh Foreign Key!';
END TRY
BEGIN CATCH
    PRINT 'LAB 19 OK - Ditolak Foreign Key. Error '
        + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

/* ---------------------------------------------------------------------
   LAB 20 - Pengujian UNIQUE NIM
   NIM 20231001 sudah ada -> HARUS ditolak (error 2627).
   --------------------------------------------------------------------- */
BEGIN TRY
    INSERT INTO Students (NIM, Name, ProgramId)
    VALUES ('20231001', 'Mahasiswa Duplikat', 1);

    PRINT 'PERINGATAN: data seharusnya ditolak oleh UNIQUE constraint!';
END TRY
BEGIN CATCH
    PRINT 'LAB 20 OK - Ditolak UNIQUE NIM. Error '
        + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

/* ---------------------------------------------------------------------
   MINI ASSIGNMENT - Tambah 3 mahasiswa baru:
   1 Teknik Informatika, 1 Sistem Informasi, 1 Teknik Elektro
   --------------------------------------------------------------------- */
INSERT INTO Students
(
    NIM,
    Name,
    ProgramId,
    BirthDate,
    Address,
    PhoneNumber
)
VALUES
('20231006', 'Eka Putri Ananda',  1, '2003-05-30', 'Jl. Keputih Tegal No. 7, Surabaya',  '081311223344'),
('20231007', 'Fajar Nugroho',     2, '2004-02-14', 'Jl. Mulyorejo No. 88, Surabaya',     '082144556677'),
('20231008', 'Gita Maharani',     4, '2003-12-09', 'Jl. Gubeng Kertajaya No. 3, Surabaya', '085712345678');
GO

SELECT
    s.NIM,
    s.Name,
    p.ProgramName,
    s.BirthDate,
    s.PhoneNumber
FROM Students s
INNER JOIN Programs p
    ON s.ProgramId = p.ProgramId
ORDER BY s.Name;
GO
