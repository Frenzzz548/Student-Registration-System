using System.Windows;
using System.Windows.Controls;
using StudentRegistration.Data;
using StudentRegistration.Models;
using StudentRegistration.Repositories;

namespace StudentRegistration;

/// <summary>
/// UI logic tahap awal (LAB 13): membuat StudentRepository, mengambil data,
/// lalu memasangnya ke DataGrid lewat ItemsSource.
/// </summary>
public partial class MainWindow : Window
{
    private const int AllProgramsId = 0;

    private readonly StudentRepository _studentRepository;

    // Mencegah SelectionChanged berjalan saat ComboBox sedang diisi ulang oleh kode.
    private bool _isLoading;

    public MainWindow()
    {
        InitializeComponent();

        _studentRepository = new StudentRepository();

        ServerTextBlock.Text =
            $"Server: {DatabaseSettings.ServerName}  |  Database: {DatabaseSettings.DatabaseName}";

        LoadAll();
    }

    /// <summary>Memuat ulang filter program studi, ringkasan, dan data mahasiswa.</summary>
    private void LoadAll()
    {
        try
        {
            _isLoading = true;

            int selectedProgramId = ProgramFilterComboBox.SelectedValue is int id
                ? id
                : AllProgramsId;

            var programs = _studentRepository.GetProgramsWithStudentCount();

            var filterItems = new List<Program>
            {
                new Program { ProgramId = AllProgramsId, ProgramName = "Semua Program Studi" }
            };
            filterItems.AddRange(programs);

            ProgramFilterComboBox.ItemsSource = filterItems;
            ProgramFilterComboBox.SelectedValue = selectedProgramId;

            if (ProgramFilterComboBox.SelectedItem is null)
            {
                ProgramFilterComboBox.SelectedIndex = 0;
            }

            ProgramSummaryItemsControl.ItemsSource = programs;
        }
        catch (Exception ex)
        {
            ShowDatabaseError(ex);
            return;
        }
        finally
        {
            _isLoading = false;
        }

        LoadStudents();
    }

    /// <summary>
    /// Alur LAB 17: SELECT -> SqlDataReader -> Student -> List&lt;Student&gt;
    /// -> ItemsSource -> DataGrid.
    /// </summary>
    private void LoadStudents()
    {
        try
        {
            int selectedProgramId = ProgramFilterComboBox.SelectedValue is int id
                ? id
                : AllProgramsId;

            var students = selectedProgramId == AllProgramsId
                ? _studentRepository.GetAll()
                : _studentRepository.GetByProgram(selectedProgramId);

            StudentDataGrid.ItemsSource = students;

            // Challenge 3: total mahasiswa (SELECT COUNT(*) FROM Students).
            int total = _studentRepository.GetTotalCount();
            TotalTextBlock.Text = $"Total Mahasiswa: {total}";

            StatusTextBlock.Text =
                $"Menampilkan {students.Count} data  |  Diperbarui {DateTime.Now:dd/MM/yyyy HH:mm:ss}";
        }
        catch (Exception ex)
        {
            ShowDatabaseError(ex);
        }
    }

    private void RefreshButton_Click(object sender, RoutedEventArgs e)
    {
        LoadAll();
    }

    private void ProgramFilterComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (_isLoading)
        {
            return;
        }

        LoadStudents();
    }

    private void ShowDatabaseError(Exception ex)
    {
        StatusTextBlock.Text = "Gagal terhubung ke database.";

        // Catatan: pada WPF yang benar adalah MessageBoxButton / MessageBoxImage
        // (MessageBoxButtons / MessageBoxIcon milik Windows Forms).
        MessageBox.Show(
            ex.Message + Environment.NewLine + Environment.NewLine +
            $"Server: {DatabaseSettings.ServerName}" + Environment.NewLine +
            "Periksa instance SQL Server dan pastikan StudentRegistrationDB.sql sudah dijalankan.",
            "Database Error",
            MessageBoxButton.OK,
            MessageBoxImage.Error);
    }
}
