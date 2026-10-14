using Microsoft.Data.SqlClient;

namespace StudentRegistration.Data;

/// <summary>
/// Pusat konfigurasi koneksi ke SQL Server (LAB 09 / LAB 26).
/// Ubah <see cref="DefaultServer"/> bila instance SQL Server berbeda, misalnya:
///   .\SQLEXPRESS           -> SQL Server Express (default lab)
///   .                      -> SQL Server Developer (default instance)
///   (localdb)\MSSQLLocalDB -> LocalDB bawaan Visual Studio
/// Alternatif tanpa mengubah kode: set environment variable STUDENTREG_SERVER.
/// </summary>
public static class DatabaseSettings
{
    public const string DefaultServer = @".\SQLEXPRESS";

    public const string DatabaseName = "StudentRegistrationDB";

    public const string ServerEnvironmentVariable = "STUDENTREG_SERVER";

    /// <summary>Nama server yang dipakai (environment variable jika ada, selain itu default).</summary>
    public static string ServerName
    {
        get
        {
            var fromEnvironment = Environment.GetEnvironmentVariable(ServerEnvironmentVariable);
            return string.IsNullOrWhiteSpace(fromEnvironment) ? DefaultServer : fromEnvironment;
        }
    }

    /// <summary>
    /// Setara dengan:
    /// Server=.\SQLEXPRESS; Database=StudentRegistrationDB;
    /// Trusted_Connection=True; TrustServerCertificate=True;
    /// </summary>
    public static string ConnectionString =>
        new SqlConnectionStringBuilder
        {
            DataSource = ServerName,
            InitialCatalog = DatabaseName,
            IntegratedSecurity = true,        // Windows Authentication
            TrustServerCertificate = true     // sertifikat lokal self-signed
        }.ConnectionString;
}
