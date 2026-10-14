/* =====================================================================
   Query Challenges & Utilitas - Student Registration
   Jalankan SETELAH StudentRegistrationDB.sql
   Mencakup: LAB 21-24 (HOL 1), troubleshooting & Mini Challenge (HOL 2)
   ===================================================================== */
USE StudentRegistrationDB;
GO

/* ---------------------------------------------------------------------
   LAB 24 - Challenge 1: Tampilkan seluruh mahasiswa
   --------------------------------------------------------------------- */
SELECT * FROM Students;
GO

/* ---------------------------------------------------------------------
   Challenge 2: Mahasiswa Teknik Informatika (WHERE)
   --------------------------------------------------------------------- */
SELECT
    s.NIM,
    s.Name,
    p.ProgramName
FROM Students s
INNER JOIN Programs p
    ON s.ProgramId = p.ProgramId
WHERE p.ProgramCode = 'TI';
GO

/* ---------------------------------------------------------------------
   Challenge 3: Hitung jumlah mahasiswa (COUNT)
   (juga dipakai aplikasi WPF: label "Total Mahasiswa")
   --------------------------------------------------------------------- */
SELECT COUNT(*) AS TotalMahasiswa
FROM Students;
GO

/* ---------------------------------------------------------------------
   Challenge 4: Hitung mahasiswa per program studi (LEFT JOIN + GROUP BY)
   Program tanpa mahasiswa (mis. DKV) tetap tampil dengan nilai 0.
   --------------------------------------------------------------------- */
SELECT
    p.ProgramName,
    COUNT(s.StudentId) AS JumlahMahasiswa
FROM Programs p
LEFT JOIN Students s
    ON p.ProgramId = s.ProgramId
GROUP BY
    p.ProgramId,
    p.ProgramName;
GO

/* ---------------------------------------------------------------------
   Query JOIN lengkap yang dipakai StudentRepository.GetAll()
   (LAB 15 HOL 2 - uji query terpisah di SSMS; harus menghasilkan
   jumlah baris yang sama dengan DataGrid)
   --------------------------------------------------------------------- */
SELECT
    s.StudentId,
    s.NIM,
    s.Name,
    s.ProgramId,
    p.ProgramName,
    s.BirthDate,
    s.Address,
    s.PhoneNumber,
    s.CreatedAt,
    s.UpdatedAt
FROM Students s
INNER JOIN Programs p
    ON s.ProgramId = p.ProgramId
ORDER BY s.StudentId;
GO

/* ---------------------------------------------------------------------
   LAB 21 - Melihat struktur database (daftar tabel)
   --------------------------------------------------------------------- */
SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_NAME;
GO

/* ---------------------------------------------------------------------
   LAB 22 - Melihat kolom tabel Students
   --------------------------------------------------------------------- */
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Students'
ORDER BY ORDINAL_POSITION;
GO

/* ---------------------------------------------------------------------
   LAB 23 - Melihat relationship (Foreign Key)
   --------------------------------------------------------------------- */
SELECT
    fk.name                                   AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id)          AS ChildTable,
    COL_NAME(fkc.parent_object_id,
             fkc.parent_column_id)            AS ChildColumn,
    OBJECT_NAME(fk.referenced_object_id)      AS ParentTable,
    COL_NAME(fkc.referenced_object_id,
             fkc.referenced_column_id)        AS ParentColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id;
GO

/* ---------------------------------------------------------------------
   Daftar constraint (PK, UNIQUE, FK, DEFAULT) pada kedua tabel
   --------------------------------------------------------------------- */
SELECT
    OBJECT_NAME(parent_object_id) AS TableName,
    name                          AS ConstraintName,
    type_desc                     AS ConstraintType
FROM sys.objects
WHERE type IN ('PK', 'UQ', 'F', 'D')
  AND OBJECT_NAME(parent_object_id) IN ('Programs', 'Students')
ORDER BY TableName, ConstraintType;
GO
