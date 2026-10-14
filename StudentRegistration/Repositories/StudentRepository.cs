using System.Data;
using Microsoft.Data.SqlClient;
using StudentRegistration.Data;
using StudentRegistration.Models;

namespace StudentRegistration.Repositories;

/// <summary>
/// Data access layer ke SQL Server memakai ADO.NET.
/// Alur: SQL -> SqlConnection -> SqlCommand -> ExecuteReader()
///       -> SqlDataReader -> Student -> List&lt;Student&gt;.
/// </summary>
public class StudentRepository
{
    private readonly string _connectionString = DatabaseSettings.ConnectionString;

    // Query dasar JOIN Students + Programs (LAB 18 HOL 1 / LAB 10 HOL 2).
    private const string SelectStudentsSql = """
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
        """;

    /// <summary>Mengambil seluruh mahasiswa (urut StudentId).</summary>
    public List<Student> GetAll()
    {
        const string sql = SelectStudentsSql + "\nORDER BY s.StudentId;";
        return ReadStudents(sql, parameterize: null);
    }

    /// <summary>
    /// Mengambil mahasiswa pada satu program studi (Challenge 2 HOL 1).
    /// Memakai parameter @ProgramId agar aman dari SQL injection.
    /// </summary>
    public List<Student> GetByProgram(int programId)
    {
        const string sql = SelectStudentsSql
            + "\nWHERE s.ProgramId = @ProgramId\nORDER BY s.StudentId;";

        return ReadStudents(sql, command =>
            command.Parameters.Add("@ProgramId", SqlDbType.Int).Value = programId);
    }

    /// <summary>Menghitung total mahasiswa: SELECT COUNT(*) FROM Students (Challenge 3).</summary>
    public int GetTotalCount()
    {
        const string sql = "SELECT COUNT(*) FROM Students;";

        using var connection = new SqlConnection(_connectionString);
        using var command = new SqlCommand(sql, connection);

        connection.Open();

        return Convert.ToInt32(command.ExecuteScalar());
    }

    /// <summary>
    /// Mengambil semua program studi beserta jumlah mahasiswanya
    /// (LEFT JOIN + GROUP BY, Challenge 4 HOL 1).
    /// </summary>
    public List<Program> GetProgramsWithStudentCount()
    {
        var programs = new List<Program>();

        const string sql = """
            SELECT
                p.ProgramId,
                p.ProgramCode,
                p.ProgramName,
                p.IsActive,
                COUNT(s.StudentId) AS JumlahMahasiswa
            FROM Programs p
            LEFT JOIN Students s
                ON p.ProgramId = s.ProgramId
            GROUP BY
                p.ProgramId,
                p.ProgramCode,
                p.ProgramName,
                p.IsActive
            ORDER BY p.ProgramId;
            """;

        using var connection = new SqlConnection(_connectionString);
        using var command = new SqlCommand(sql, connection);

        connection.Open();

        using var reader = command.ExecuteReader();

        while (reader.Read())
        {
            programs.Add(new Program
            {
                ProgramId = reader.GetInt32(reader.GetOrdinal("ProgramId")),
                ProgramCode = reader.GetString(reader.GetOrdinal("ProgramCode")),
                ProgramName = reader.GetString(reader.GetOrdinal("ProgramName")),
                IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                StudentCount = reader.GetInt32(reader.GetOrdinal("JumlahMahasiswa"))
            });
        }

        return programs;
    }

    /// <summary>
    /// Helper bersama: membuka koneksi, menjalankan query, lalu memetakan
    /// setiap baris SqlDataReader menjadi object Student.
    /// </summary>
    private List<Student> ReadStudents(string sql, Action<SqlCommand>? parameterize)
    {
        var students = new List<Student>();

        using var connection = new SqlConnection(_connectionString);
        using var command = new SqlCommand(sql, connection);

        parameterize?.Invoke(command);

        connection.Open();

        using var reader = command.ExecuteReader();

        while (reader.Read())
        {
            students.Add(MapStudent(reader));
        }

        return students;
    }

    /// <summary>
    /// Memetakan satu baris reader ke Student. Kolom yang NULL di database
    /// (BirthDate, Address, PhoneNumber, UpdatedAt) dicek dengan IsDBNull.
    /// </summary>
    private static Student MapStudent(SqlDataReader reader)
    {
        int birthDate = reader.GetOrdinal("BirthDate");
        int address = reader.GetOrdinal("Address");
        int phoneNumber = reader.GetOrdinal("PhoneNumber");
        int updatedAt = reader.GetOrdinal("UpdatedAt");

        return new Student
        {
            StudentId = reader.GetInt32(reader.GetOrdinal("StudentId")),
            NIM = reader.GetString(reader.GetOrdinal("NIM")),
            Name = reader.GetString(reader.GetOrdinal("Name")),
            ProgramId = reader.GetInt32(reader.GetOrdinal("ProgramId")),
            ProgramName = reader.GetString(reader.GetOrdinal("ProgramName")),
            BirthDate = reader.IsDBNull(birthDate) ? null : reader.GetDateTime(birthDate),
            Address = reader.IsDBNull(address) ? string.Empty : reader.GetString(address),
            PhoneNumber = reader.IsDBNull(phoneNumber) ? string.Empty : reader.GetString(phoneNumber),
            CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
            UpdatedAt = reader.IsDBNull(updatedAt) ? null : reader.GetDateTime(updatedAt)
        };
    }
}
