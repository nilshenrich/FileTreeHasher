using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
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

        /// <summary>
        /// Bring folder content to UI
        /// </summary>
        /// <param name="rootFolder"></param>
        /// <param name="rootExplorer"></param>
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
                // TODO: Adding hash here stucks file tree loading
                ExplorerFile explorerFile = new ExplorerFile()
                {
                    Name = file.Name,
                    IconSource = new Uri(BaseUri, "/Icons/Wait.png"),
                    SelectedHashAlgIndex = GlobalHashAlgIndex
                };

                // Add file to UI
                // !! Important to do at the end !!
                // !! Items modified after insersion won't be updated on UI !!
                // -> Solution: https://www.syncfusion.com/forums/142654/sftree-does-not-refresh-when-items-are-added?reply=NSgzwQ
                rootExplorer.Add(explorerFile);

                // Generate hash in task
                _ = Task.Run(() => HashGenerator.addHashAsync(file, explorerFile));
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

            // Clear all old lodaded elements
            LoadedFileTreeItems.Clear();

            // Load file structure to UI
            loadFileTree(folder, LoadedFileTreeItems);
        }
    }
}
