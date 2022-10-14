using System;
using System.Collections.ObjectModel;
using Windows.UI.Xaml.Controls;

// Die Elementvorlage "Leere Seite" wird unter https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x407 dokumentiert.

namespace FileTreeHasher
{
    /// <summary>
    /// Eine leere Seite, die eigenständig verwendet oder zu der innerhalb eines Rahmens navigiert werden kann.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        private ObservableCollection<ExplorerItem> DataSource;
        public MainPage()
        {
            this.InitializeComponent();
            DataSource = GetData();
        }

        // Debugging
        private ObservableCollection<ExplorerItem> GetData()
        {
            ObservableCollection<ExplorerItem> data = new ObservableCollection<ExplorerItem>();
            ExplorerFolder SampleTopLevelFolder = new ExplorerFolder()
            {
                Name = "Sample top level folder",
                IsExpanded = true
            };
            ExplorerFile SampleNestedFile = new ExplorerFile()
            {
                Name = "Sample nested file",
                IconSource = new Uri(BaseUri, "/Icons/Wait.png")
            };
            SampleTopLevelFolder.Children.Add(SampleNestedFile);
            data.Add(SampleTopLevelFolder);

            return data;
        }
    }
}
