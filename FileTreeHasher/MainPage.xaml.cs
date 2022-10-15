using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;
using Windows.ApplicationModel.Core;
using Windows.Storage;
using Windows.Storage.Pickers;
using Windows.UI.Core;
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
        private ObservableObject<int> GlobalHashAlgIndex = new ObservableObject<int>((int)HashAlgirithmNames.SHA256);

        // Path of currentliy selected folder
        private ObservableObject<string> SelectedFolderPath = new ObservableObject<string>("<No folder selected>");

        // Tree view content
        private ObservableCollection<ExplorerItem> LoadedFileTreeItems = new ObservableCollection<ExplorerItem>();

        public MainPage()
        {
            InitializeComponent();
        }

        /// <summary>
        /// Mark loaded file as waiting for hash string calculation
        /// </summary>
        /// <param name="file"></param>
        private void markFileWaiting(ExplorerFile file)
        {
            file.IconSource.Value = new Uri(BaseUri, "/Icons/Wait.png");
        }

        /// <summary>
        /// Mark loaded file as ready for hash comparison (hash string calculated)
        /// </summary>
        /// <param name="file"></param>
        private void markFileReady(ExplorerFile file)
        {
            file.IconSource.Value = new Uri(BaseUri, "/Icons/Hashed.png");
        }

        /// <summary>
        /// Marks loaded file as passed for hash checking
        /// </summary>
        /// <param name="file"></param>
        private void markAsPassed(ExplorerFile file)
        {
            file.IconSource.Value = new Uri(BaseUri, "/Icons/Check.png");
        }

        /// <summary>
        /// Marks loaded file as failed for hash checking
        /// </summary>
        /// <param name="file"></param>
        private void markAsFailed(ExplorerFile file)
        {
            file.IconSource.Value = new Uri(BaseUri, "/Icons/Fail.png");
        }

        /// <summary>
        /// Compare generated hash with string and mark file item acordingly
        /// </summary>
        /// <param name="file"></param>
        /// <param name="hash"></param>
        private void compareFileHash(ExplorerFile file, string hash)
        {
            // For empty comparison string, don't compare
            if (string.IsNullOrEmpty(hash))
            {
                markFileReady(file);
                return;
            }

            // Check string
            if (file.GeneratedHash.Value == hash.ToLower())
                markAsPassed(file);
            else
                markAsFailed(file);
        }

        /// <summary>
        /// Start hash generation and pasting of loaded file in background
        /// </summary>
        /// <param name="file"></param>
        private void startHashGeneration(ExplorerFile file)
        {
            markFileWaiting(file);
            file.GeneratedHash.Value = "";
            Task.Run(() =>
            {
                string hash = HashGenerator.generateHashAsync(file.FileOnDisk, file.SelectedHashAlgName).Result;
                file.GeneratedHash.Value = hash;
                _ = CoreApplication.MainView.CoreWindow.Dispatcher.RunAsync(CoreDispatcherPriority.Normal, () =>
                compareFileHash(file, file.CheckHash));
            });
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
                ExplorerFile explorerFile = new ExplorerFile()
                {
                    FileOnDisk = file,
                    Name = file.Name,
                    SelectedHashAlgIndex = new ObservableObject<int>(GlobalHashAlgIndex.Value),
                    OldSelectedHashAlgIndex = GlobalHashAlgIndex.Value
                };

                // Add file to UI
                rootExplorer.Add(explorerFile);

                // Generate hash in task
                startHashGeneration(explorerFile);
            }
        }

        private void updateSpecialHashSelectors(ObservableCollection<ExplorerItem> rootFolder)
        {
            // Update all special hash algorithm selectors
            foreach (ExplorerFolder folder in rootFolder.OfType<ExplorerFolder>())
                updateSpecialHashSelectors(folder.Children);

            foreach (ExplorerFile file in rootFolder.OfType<ExplorerFile>())
                file.SelectedHashAlgIndex.Value = GlobalHashAlgIndex.Value;
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

            // Set selected folder path
            SelectedFolderPath.Value = folder.Path;

            // Clear all old lodaded elements
            LoadedFileTreeItems.Clear();

            // Load file structure to UI
            loadFileTree(folder, LoadedFileTreeItems);
        }

        /// <summary>
        /// Change event: Selected global hash algorithm changed
        /// -> Set all special hash algorithm selectors to new value
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Change_GlobalHashChanged(object sender, SelectionChangedEventArgs e)
        {
            updateSpecialHashSelectors(LoadedFileTreeItems);
        }

        /// <summary>
        /// Change event: Selected special hash algorithm changed
        /// -> Regenerate and show hash if algorithm changed
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Change_SpecialHashChanged(object sender, SelectionChangedEventArgs e)
        {
            ExplorerFile file = (sender as ComboBox).DataContext as ExplorerFile;
            if (file.SelectedHashAlgIndex.Value != file.OldSelectedHashAlgIndex)
            {
                file.OldSelectedHashAlgIndex = file.SelectedHashAlgIndex.Value;
                startHashGeneration(file);
            }
        }

        /// <summary>
        /// Type event: Input for check hash is tyed/canged
        /// -> Compare generated hash with entered string
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Type_CheckHashChanged(object sender, TextChangedEventArgs e)
        {
            // Get loaded file
            ExplorerFile file = (sender as TextBox).DataContext as ExplorerFile;
            string hash = (sender as TextBox).Text;
            compareFileHash(file, hash);
        }
    }
}
