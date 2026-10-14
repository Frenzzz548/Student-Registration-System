# Student Registration System

Aplikasi desktop **WPF + C# (.NET 8)** yang terhubung ke **SQL Server** memakai **ADO.NET**
(`Microsoft.Data.SqlClient`). Project ini menggabungkan dua Hands-On Lab mata kuliah
**.NET Programming with C#** dalam **satu solution Visual Studio**:

| Hands-On Lab | Topik | Hasil di project ini |
| --- | --- | --- |
| **HOL 1** | Membangun Database Student Registration dengan SQL Server | `Database/StudentRegistrationDB.sql`, `Database/Query-Challenges.sql` |
| **HOL 2** | Membuat Aplikasi WPF + C# Terhubung SQL Server dengan ADO.NET | Project `StudentRegistration/` |

> **Identitas** — Nama: ____________________  NRP: ____________________  Kelas: ____________

---

## Daftar Isi

1. [Teknologi](#1-teknologi)
2. [Struktur Project](#2-struktur-project)
3. [Arsitektur](#3-arsitektur)
4. [Desain Database (HOL 1)](#4-desain-database-hol-1)
5. [Cara Menjalankan](#5-cara-menjalankan)
6. [Penjelasan Kode (HOL 2)](#6-penjelasan-kode-hol-2)
7. [Alur Data: Database sampai DataGrid](#7-alur-data-database-sampai-datagrid)
8. [Fitur Aplikasi](#8-fitur-aplikasi)
9. [Pemetaan Materi Lab ke Project](#9-pemetaan-materi-lab-ke-project)
10. [Troubleshooting](#10-troubleshooting)
11. [Catatan Perbaikan dari Modul](#11-catatan-perbaikan-dari-modul)
12. [Dokumentasi Screenshot](#12-dokumentasi-screenshot)
13. [Checkpoint](#13-checkpoint)
14. [Roadmap](#14-roadmap)

---

## 1. Teknologi

| Komponen | Keterangan |
| --- | --- |
| IDE | **Visual Studio 2022 (17.8+)** atau lebih baru, workload *.NET desktop development* |
| Bahasa / Framework | C# 12, **.NET 8** (`net8.0-windows`), WPF |
| Akses data | ADO.NET: `SqlConnection`, `SqlCommand`, `SqlDataReader` |
| NuGet | `Microsoft.Data.SqlClient` 5.2.2 |
| Database | SQL Server Developer / Express + SQL Server Management Studio (SSMS) |
| Autentikasi | Windows Authentication (`Trusted_Connection`) |

## 2. Struktur Project

```
Student-Registration-System/
├── StudentRegistration.sln              # Solution Visual Studio
├── README.md                            # Dokumen ini
├── .gitignore
├── Database/
│   ├── StudentRegistrationDB.sql        # HOL 1: DB, tabel, data, uji FK/UNIQUE, mini assignment
│   └── Query-Challenges.sql             # HOL 1: Query Challenge 1-4 + inspeksi struktur
├── docs/
│   └── screenshots/                     # Tempat menaruh screenshot (lihat bagian 12)
└── StudentRegistration/
    ├── StudentRegistration.csproj
    ├── App.xaml / App.xaml.cs           # Entry point WPF
    ├── MainWindow.xaml / .xaml.cs       # UI + event handler
    ├── Data/
    │   └── DatabaseSettings.cs          # Connection string
    ├── Models/
    │   ├── Student.cs                   # Model tabel Students
    │   └── Program.cs                   # Model tabel Programs (bukan entry point!)
    └── Repositories/
        └── StudentRepository.cs         # Data access ADO.NET
```

Folder `Database` dan file `README.md` juga muncul sebagai *Solution Folder* di Solution Explorer
sehingga script SQL bisa dibuka langsung dari Visual Studio.

## 3. Arsitektur

```
WPF UI (MainWindow)
        │
        ▼
StudentRepository  ──uses──▶  DatabaseSettings (connection string)
        │
        ▼
ADO.NET (SqlConnection → SqlCommand → SqlDataReader)
        │
        ▼
SQL Server  ──▶  StudentRegistrationDB  ──▶  Programs (1) ─── (N) Students
```

| Class / File | Tanggung jawab |
| --- | --- |
| `Student.cs` | Model data mahasiswa |
| `Program.cs` | Model program studi |
| `DatabaseSettings.cs` | Menyediakan connection string |
| `StudentRepository.cs` | Data access ke SQL Server |
| `MainWindow.xaml` | User interface WPF |
| `MainWindow.xaml.cs` | Event dan UI logic tahap awal |

## 4. Desain Database (HOL 1)

### Relasi 1:N

```
Programs (1) ───────< (N) Students
ProgramId (PK)          ProgramId (FK)
```

Satu program studi memiliki banyak mahasiswa; satu mahasiswa hanya punya satu `ProgramId`.

### Tabel `Programs`

| Kolom | Tipe | Constraint |
| --- | --- | --- |
| `ProgramId` | INT IDENTITY(1,1) | **PRIMARY KEY** (`PK_Programs`) |
| `ProgramCode` | VARCHAR(20) | NOT NULL, **UNIQUE** (`UQ_Programs_ProgramCode`) |
| `ProgramName` | VARCHAR(100) | NOT NULL |
| `IsActive` | BIT | NOT NULL, DEFAULT 1 |
| `CreatedAt` | DATETIME2 | NOT NULL, DEFAULT `SYSDATETIME()` |

Data awal: `TI`, `SI`, `MNJ`, `TE`, `DKV`.

### Tabel `Students`

| Kolom | Tipe | Constraint |
| --- | --- | --- |
| `StudentId` | INT IDENTITY(1,1) | **PRIMARY KEY** (`PK_Students`) |
| `NIM` | VARCHAR(20) | NOT NULL, **UNIQUE** (`UQ_Students_NIM`) |
| `Name` | VARCHAR(100) | NOT NULL |
| `ProgramId` | INT | NOT NULL, **FOREIGN KEY** → `Programs(ProgramId)` (`FK_Students_Programs`) |
| `BirthDate` | DATE | NULL |
| `Address` | VARCHAR(250) | NULL |
| `PhoneNumber` | VARCHAR(20) | NULL |
| `CreatedAt` | DATETIME2 | NOT NULL, DEFAULT `SYSDATETIME()` |
| `UpdatedAt` | DATETIME2 | NULL |

### Isi script `StudentRegistrationDB.sql`

1. Membuat database (jika belum ada) dan `USE StudentRegistrationDB`.
2. Reset tabel agar script bisa dijalankan berulang (`Students` di-drop dulu karena ber-FK).
3. Membuat `Programs`, mengisi 5 program studi.
4. Membuat `Students`, mengisi 5 mahasiswa.
5. Menjalankan `SELECT` dan `INNER JOIN`.
6. **Uji Foreign Key** (ProgramId 99) dan **uji UNIQUE NIM** (NIM duplikat) dengan `TRY/CATCH`,
   sehingga pesan penolakan tampil di tab *Messages* tanpa menghentikan script.
7. **Mini Assignment**: menambah 3 mahasiswa baru (1 TI, 1 SI, 1 TE) lalu menampilkan JOIN terurut nama.

Total data setelah script: **5 program studi, 8 mahasiswa**.

### Isi script `Query-Challenges.sql`

Challenge 1 (`SELECT *`), 2 (`WHERE` program TI), 3 (`COUNT`), 4 (`LEFT JOIN` + `GROUP BY`),
query JOIN yang sama persis dengan yang dipakai aplikasi, serta query inspeksi struktur
(daftar tabel, kolom, foreign key, constraint) untuk LAB 21-23.

## 5. Cara Menjalankan

### Langkah 1: Siapkan SQL Server dan SSMS (LAB 01-08 HOL 1)

1. Install **SQL Server Developer** atau **Express**, pada *Feature Selection* centang **Database Engine Services**.
2. *Instance Configuration*: named instance `SQLEXPRESS`; *Authentication*: Windows Authentication.
3. Install **SSMS**, lalu connect dengan:

   | Field | Nilai |
   | --- | --- |
   | Server type | Database Engine |
   | Server name | `.\SQLEXPRESS` |
   | Authentication | Windows Authentication |

4. Jika folder **Databases** terlihat di Object Explorer, koneksi berhasil.

### Langkah 2: Jalankan script database

1. Di SSMS: **File → Open → File** → `Database/StudentRegistrationDB.sql`.
2. Klik **Execute** (F5).
3. Cek tab **Results** dan **Messages**, lalu jalankan `Database/Query-Challenges.sql` bila ingin mencoba challenge.

### Langkah 3: Buka project di Visual Studio

1. Double-click `StudentRegistration.sln` (atau **File → Open → Project/Solution**).
2. Tunggu NuGet restore otomatis (paket `Microsoft.Data.SqlClient`). Jika tidak jalan:
   **Tools → NuGet Package Manager → Manage NuGet Packages for Solution → Restore**.
3. Pastikan **StudentRegistration** menjadi *Startup Project* (klik kanan → *Set as Startup Project*).
4. Tekan **F5**. Data mahasiswa akan tampil di DataGrid.

### Menyesuaikan nama server

Nama server default adalah `.\SQLEXPRESS`. Jika instance berbeda, ubah salah satu:

- **Ubah kode** di `Data/DatabaseSettings.cs`:

  ```csharp
  public const string DefaultServer = @".\SQLEXPRESS";   // contoh lain: "." atau @"(localdb)\MSSQLLocalDB"
  ```

- **Atau** set environment variable `STUDENTREG_SERVER` (lalu restart Visual Studio).

Connection string yang dihasilkan setara dengan versi di modul:

```text
Server=.\SQLEXPRESS;
Database=StudentRegistrationDB;
Trusted_Connection=True;
TrustServerCertificate=True;
```

> Jika memakai **.NET 10** / SDK lain, ubah `<TargetFramework>` di `StudentRegistration.csproj`
> (mis. `net10.0-windows`).

## 6. Penjelasan Kode (HOL 2)

### `Models/Student.cs`

Model satu baris tabel `Students`. Properti nullable (`DateTime? BirthDate`, `DateTime? UpdatedAt`)
sesuai kolom `NULL` di database. `ProgramName` bukan kolom `Students`; ia menampung hasil JOIN dengan `Programs`.

### `Models/Program.cs`

Model program studi (`ProgramId`, `ProgramCode`, `ProgramName`, `IsActive`).
Ini **bukan** entry point aplikasi. Properti tambahan `StudentCount` menampung hasil `COUNT` untuk ringkasan per program.

### `Data/DatabaseSettings.cs`

| Member | Fungsi |
| --- | --- |
| `DefaultServer`, `DatabaseName` | Konstanta nama server dan database |
| `ServerName` | Membaca environment variable `STUDENTREG_SERVER`, jika kosong memakai `DefaultServer` |
| `ConnectionString` | Membangun connection string via `SqlConnectionStringBuilder` (Windows Auth + `TrustServerCertificate`) |

### `Repositories/StudentRepository.cs`

| Method | Fungsi |
| --- | --- |
| `GetAll()` | `SELECT` JOIN `Students` + `Programs`, urut `StudentId`, mengembalikan `List<Student>` |
| `GetByProgram(int programId)` | Sama seperti `GetAll()` dengan `WHERE s.ProgramId = @ProgramId` (query berparameter, aman dari SQL injection) |
| `GetTotalCount()` | `SELECT COUNT(*) FROM Students` via `ExecuteScalar()` |
| `GetProgramsWithStudentCount()` | `LEFT JOIN` + `GROUP BY`, mengembalikan `List<Program>` beserta `StudentCount` |
| `ReadStudents(sql, parameterize)` *(private)* | Helper: buka koneksi, jalankan query, loop `reader.Read()` |
| `MapStudent(reader)` *(private)* | Memetakan baris reader ke `Student`, kolom NULL dicek dengan `IsDBNull` |

Tiga class ADO.NET yang dipakai:

```csharp
using var connection = new SqlConnection(_connectionString); // membuka koneksi ke SQL Server
using var command    = new SqlCommand(sql, connection);       // menjalankan perintah SQL
connection.Open();
using var reader     = command.ExecuteReader();               // membaca hasil query
```

`using var` memastikan koneksi, command, dan reader otomatis ditutup walau terjadi exception.

### `MainWindow.xaml`

Layout `Grid` 5 baris: judul + info server, toolbar (tombol **Refresh**, ComboBox **filter program studi**, label **Total Mahasiswa**),
**DataGrid**, ringkasan per program (`ItemsControl`), dan status bar. DataGrid memakai `AutoGenerateColumns="False"`,
`IsReadOnly="True"`, `CanUserAddRows="False"`, dengan kolom ID, NIM, Nama, Program Studi, Tanggal Lahir, No. Telepon,
**Alamat** (Mini Challenge 1), dan **Dibuat** (Mini Challenge 2).

### `MainWindow.xaml.cs`

| Method | Fungsi |
| --- | --- |
| `MainWindow()` | `InitializeComponent()`, membuat `StudentRepository`, menampilkan info server, memanggil `LoadAll()` |
| `LoadAll()` | Mengisi ComboBox filter (opsi "Semua Program Studi" + program dari DB), ringkasan per program, lalu `LoadStudents()` |
| `LoadStudents()` | Mengambil `List<Student>` (semua atau terfilter), memasang ke `StudentDataGrid.ItemsSource`, memperbarui total dan status bar |
| `RefreshButton_Click` | Memuat ulang semua data dari database |
| `ProgramFilterComboBox_SelectionChanged` | Memuat ulang mahasiswa sesuai program terpilih (diabaikan saat ComboBox diisi ulang via flag `_isLoading`) |
| `ShowDatabaseError(ex)` | Menampilkan `MessageBox` error beserta nama server |

### Data binding

`Binding` menghubungkan properti objek dengan kolom DataGrid, misalnya `Student.NIM = "20231001"` tampil di kolom **NIM**.
Format tanggal memakai `StringFormat=dd/MM/yyyy`.

## 7. Alur Data: Database sampai DataGrid

```
1. User menjalankan aplikasi WPF
2. MainWindow membuat StudentRepository
3. Repository membuat SqlConnection (connection string dari DatabaseSettings)
4. SqlCommand menjalankan SELECT
5. SqlDataReader membaca hasil dari SQL Server
6. Baris dipetakan menjadi object Student
7. Object dimasukkan ke List<Student>
8. List<Student> dipasang sebagai ItemsSource
9. DataGrid menampilkan data
```

## 8. Fitur Aplikasi

- Menampilkan data mahasiswa dari SQL Server pada **DataGrid** (JOIN dengan program studi).
- Tombol **Refresh** untuk mengambil ulang data dari database.
- **Filter program studi** (Challenge 2: mahasiswa per program).
- Label **Total Mahasiswa** (Challenge 3: `COUNT(*)`).
- Ringkasan **jumlah mahasiswa per program studi** (Challenge 4: `GROUP BY`); program tanpa mahasiswa tetap tampil dengan nilai 0.
- Kolom **Alamat** dan **Dibuat** (Mini Challenge 1 dan 2).
- Penanganan error koneksi dengan `MessageBox` yang informatif.

## 9. Pemetaan Materi Lab ke Project

### HOL 1: SQL Server

| Materi | Lokasi |
| --- | --- |
| Install SQL Server, SSMS, koneksi (LAB 01-08) | Bagian 5 langkah 1 + screenshot |
| CREATE DATABASE, USE (LAB 09-10) | `StudentRegistrationDB.sql` |
| Tabel `Programs`: PK, UNIQUE, DEFAULT (LAB 11) | `StudentRegistrationDB.sql` |
| INSERT / SELECT Programs (LAB 12-13) | `StudentRegistrationDB.sql` |
| Tabel `Students`: PK, UNIQUE, FK (LAB 14) | `StudentRegistrationDB.sql` |
| Relasi 1:N (LAB 15) | Bagian 4 + `FK_Students_Programs` |
| INSERT / SELECT Students (LAB 16-17) | `StudentRegistrationDB.sql` |
| INNER JOIN (LAB 18) | `StudentRegistrationDB.sql`, `Query-Challenges.sql` |
| Uji Foreign Key, uji UNIQUE NIM (LAB 19-20) | `StudentRegistrationDB.sql` (TRY/CATCH) |
| Struktur DB, kolom, relationship (LAB 21-23) | `Query-Challenges.sql` + screenshot |
| Query Challenge 1-4 (LAB 24) | `Query-Challenges.sql`, `StudentRepository` |
| Persiapan integrasi C#, connection string (LAB 25-26) | `DatabaseSettings.cs` |
| Mini Assignment (3 mahasiswa baru + JOIN) | `StudentRegistrationDB.sql` bagian akhir |

### HOL 2: WPF + ADO.NET

| Materi | Lokasi |
| --- | --- |
| Project WPF `StudentRegistration` (LAB 01-02) | `StudentRegistration.csproj` |
| Folder Models, `Student.cs`, `Program.cs` (LAB 03-05) | `Models/` |
| `Microsoft.Data.SqlClient` (LAB 06) | `StudentRegistration.csproj` |
| Folder Repositories, `StudentRepository.cs` (LAB 07-08, 10) | `Repositories/` |
| Connection string (LAB 09) | `Data/DatabaseSettings.cs` |
| SqlConnection, SqlCommand, SqlDataReader (LAB 11) | `StudentRepository.cs` |
| Desain `MainWindow` + DataGrid (LAB 12) | `MainWindow.xaml` |
| Hubungkan repository ke WPF (LAB 13) | `MainWindow.xaml.cs` |
| Jalankan aplikasi, tombol Refresh (LAB 14) | F5 + `RefreshButton_Click` |
| Troubleshooting, uji query terpisah (LAB 15) | Bagian 10 + `Query-Challenges.sql` |
| Data binding, ItemsSource (LAB 16-17) | `MainWindow.xaml(.cs)` |
| Tanggung jawab class (LAB 18) | Bagian 3 |
| Mini Challenge 1-3 (LAB 19) | Kolom Alamat, kolom Dibuat, label Total Mahasiswa |
| Assignment minimal (LAB 20) | Seluruh project |

## 10. Troubleshooting

Jika DataGrid kosong atau muncul **Database Error**, periksa berurutan:

1. Di SSMS, `SELECT * FROM Students;` harus menghasilkan data (jalankan `StudentRegistrationDB.sql` jika belum).
2. Nama server di `DatabaseSettings.cs` harus sama dengan instance di SSMS (`.\SQLEXPRESS`, `.`, atau `(localdb)\MSSQLLocalDB`).
3. Nama database harus `StudentRegistrationDB`.
4. Paket `Microsoft.Data.SqlClient` sudah ter-restore.
5. Query JOIN di `Query-Challenges.sql` berjalan di SSMS dan menghasilkan jumlah baris yang sama. Jika ya, masalahnya ada pada koneksi atau kode C#.

| Pesan error | Penyebab umum |
| --- | --- |
| *A network-related or instance-specific error ...* | Nama instance salah, atau service SQL Server belum berjalan (cek *SQL Server Configuration Manager* / `services.msc`) |
| *Cannot open database "StudentRegistrationDB"* | Script SQL belum dijalankan |
| *certificate chain was issued by an authority that is not trusted* | `TrustServerCertificate=True` hilang dari connection string |
| *Invalid object name 'Students'* | Tabel belum dibuat atau database yang dipilih salah |

## 11. Catatan Perbaikan dari Modul

Beberapa potongan kode di modul mengandung typo hasil konversi dokumen. Pada project ini sudah dikoreksi:

| Di modul | Di project ini |
| --- | --- |
| `namespace StudentRegistration Repositories;` | `namespace StudentRegistration.Repositories;` |
| `reader.getInt32(...)` | `reader.GetInt32(...)` |
| `MessageBoxButtons.OK`, `MessageBoxIcon.Error` (Windows Forms) | `MessageBoxButton.OK`, `MessageBoxImage.Error` (WPF) |
| `_studentRepository"".GetAll()` | `_studentRepository.GetAll()` |
| `CREATE TABLE Students` dengan `DEFAULT SYSDATETIME)` dan tanpa penutup | `DEFAULT SYSDATETIME(),` dan tanda kurung penutup yang benar |
| Connection string literal di dalam repository | Dipusatkan di `DatabaseSettings.cs` |

## 12. Dokumentasi Screenshot

Simpan gambar di folder `docs/screenshots/` dengan nama file seperti pada setiap bagian
(daftar lengkap ada di `docs/screenshots/README.md`). Gambar akan otomatis tampil di sini.

### 12.1 Hands-On Lab 1: SQL Server

**a. SQL Server berhasil terkoneksi**

![SQL Server terkoneksi](docs/screenshots/01-sql-server-connected.png)

*Keterangan: ........................................*

**b. Database `StudentRegistrationDB`**

![Database dibuat](docs/screenshots/02-database-created.png)

*Keterangan: ........................................*

**c. Tabel `Programs`**

![Tabel Programs](docs/screenshots/03-tabel-programs.png)

*Keterangan: ........................................*

**d. Tabel `Students`**

![Tabel Students](docs/screenshots/04-tabel-students.png)

*Keterangan: ........................................*

**e. Hasil JOIN (Mini Assignment)**

![Hasil JOIN](docs/screenshots/05-hasil-join.png)

*Keterangan: ........................................*

**f. Uji Foreign Key**

![Uji FK](docs/screenshots/06-uji-foreign-key.png)

*Keterangan: ........................................*

**g. Uji UNIQUE NIM**

![Uji UNIQUE](docs/screenshots/07-uji-unique-nim.png)

*Keterangan: ........................................*

**h. Database Diagram (relasi 1:N)**

![Database diagram](docs/screenshots/08-database-diagram.png)

*Keterangan: ........................................*

### 12.2 Hands-On Lab 2: Aplikasi WPF

**a. Solution Explorer di Visual Studio**

![Solution Explorer](docs/screenshots/09-vs-solution-explorer.png)

*Keterangan: ........................................*

**b. Tampilan utama: DataGrid mahasiswa**

![DataGrid](docs/screenshots/10-app-datagrid.png)

*Keterangan: ........................................*

**c. Filter program studi**

![Filter program](docs/screenshots/11-app-filter-program.png)

*Keterangan: ........................................*

**d. Setelah klik Refresh**

![Refresh](docs/screenshots/12-app-refresh.png)

*Keterangan: ........................................*

**e. (Opsional) Pesan Database Error**

![Error](docs/screenshots/13-app-error.png)

*Keterangan: ........................................*

## 13. Checkpoint

**HOL 1**

- [ ] SQL Server dan SSMS terinstal dan terkoneksi
- [ ] `StudentRegistrationDB` dibuat
- [ ] Tabel `Programs` dan `Students` dibuat
- [ ] PRIMARY KEY, UNIQUE, FOREIGN KEY diterapkan
- [ ] Data program studi dan mahasiswa dimasukkan
- [ ] Query SELECT, JOIN, COUNT, WHERE, GROUP BY berjalan
- [ ] Relasi 1:N dipahami

**HOL 2**

- [ ] `Student.cs`, `Program.cs`, `StudentRepository.cs`
- [ ] `Microsoft.Data.SqlClient`, `SqlConnection`, `SqlCommand`, `SqlDataReader`
- [ ] `MainWindow.xaml` dengan DataGrid dan tombol Refresh
- [ ] Data berhasil ditampilkan

**Output yang dikumpulkan (HOL 1)**

- [ ] Screenshot SQL Server terkoneksi (12.1a)
- [ ] Screenshot database (12.1b)
- [ ] Screenshot tabel Programs (12.1c)
- [ ] Screenshot tabel Students (12.1d)
- [ ] Screenshot hasil JOIN (12.1e)
- [ ] File `.sql` berisi seluruh script (`Database/StudentRegistrationDB.sql`)

## 14. Roadmap

```
LAB 1  SQL Server          -> Database, Tables, PK/FK            (selesai)
LAB 2  WPF + ADO.NET       -> Repository, DataGrid               (selesai)
LAB 3  CRUD                -> Tambah, Edit, Hapus, Search
LAB 4  MVVM                -> Data Binding, ICommand
LAB 5  Rich UI             -> Dashboard, Chart, Navigation
LAB 6  Professional UI     -> MVVM + Repository, Validation, Async/Await, REST API
```
