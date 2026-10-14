namespace StudentRegistration.Models;

/// <summary>
/// Model Program Studi (tabel Programs). Ini BUKAN file entry point aplikasi.
/// StudentCount adalah properti tambahan (bukan kolom tabel) untuk menampung
/// hasil COUNT pada query GROUP BY (Challenge 4 - HOL 1).
/// </summary>
public class Program
{
    public int ProgramId { get; set; }

    public string ProgramCode { get; set; } = string.Empty;

    public string ProgramName { get; set; } = string.Empty;

    public bool IsActive { get; set; }

    public int StudentCount { get; set; }
}
