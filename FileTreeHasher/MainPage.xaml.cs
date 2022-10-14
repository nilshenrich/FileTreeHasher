using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Threading;
using Windows.Storage;
using Windows.Storage.Pickers;
using Windows.UI.Xaml.Controls;

// Die Elementvorlage "Leere Seite" wird unter https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x407 dokumentiert.

namespace FileTreeHasher
{
    /// <summary>
    /// Eine leere Seite, die eigenständig verwendet oder zu der innerhalb eines Rahmens navigiert werden kann.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        // Globally selected hash algorithm
        private int GlobalHashAlgIndex = (int)HashAlgirithmNames.SHA256;

        // Tree view content
        private ObservableCollection<ExplorerItem> LoadedFileTreeItems = new ObservableCollection<ExplorerItem>();

        public MainPage()
        {
            InitializeComponent();
        }

        private async void loadFileTree(StorageFolder rootFolder, ObservableCollection<ExplorerItem> rootExplorer)
        {
            // Draw all direct subdirectories
            // Load items of each subdirectory recursively
            IReadOnlyList<StorageFolder> subfolders = await rootFolder.GetFoldersAsync();
            foreach (StorageFolder subfolder in subfolders)
            {
                // Create new item for folder
                ExplorerFolder explorerFolder = new ExplorerFolder() { Name = subfolder.Name };

                // Add folder to UI
                rootExplorer.Add(explorerFolder);

                // Load all items of folder
                loadFileTree(subfolder, explorerFolder.Children);
            }

            // Draw all files
            IReadOnlyList<StorageFile> files = await rootFolder.GetFilesAsync();
            foreach (StorageFile file in files)
            {
                // Create item for file
                ExplorerFile explorerFile = new ExplorerFile()
                {
                    Name = file.Name,
                    IconSource = new Uri(BaseUri, "/Icons/Wait.png"),
                    SelectedHashAlgIndex = GlobalHashAlgIndex
                };

                // Add file to UI
                rootExplorer.Add(explorerFile);

                // Start has generation asynchronously
                // TODO: Hash is written but not updated on UI for all items
                explorerFile.GeneratedHash = await HashGenerator.generateHashAsync(file, (HashAlgirithmNames)GlobalHashAlgIndex);
            }
        }

        /// <summary>
        /// Click event: Load file tree to hash
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void Click_LoadFileTree(object sender, Windows.UI.Xaml.RoutedEventArgs e)
        {
            // Open file explorer to select a folder
            FolderPicker folderPicker = new FolderPicker();
            folderPicker.FileTypeFilter.Add("*");
            StorageFolder folder = await folderPicker.PickSingleFolderAsync();

            // Cancel if no folder was selected
            if (folder == null)
                return;

            // Load file structure to UI
            loadFileTree(folder, LoadedFileTreeItems);
        }
    }
}
