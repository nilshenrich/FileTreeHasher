using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using Windows.Storage;
using Windows.Storage.Pickers;
using Windows.UI.Popups;
using Windows.UI.Xaml.Controls;

// Die Elementvorlage "Leere Seite" wird unter https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x407 dokumentiert.
// TODO: App crashes when starting without debugging
//       -> Issue comes with feature "UseSystemIcons" (4ff13818cf659313522eee5cd5d6cdde3862c725)

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
        private const string SelectedFolderPath_default = "<No folder selected>";
        private ObservableObject<string> SelectedFolderPath = new ObservableObject<string>(SelectedFolderPath_default);

        // Tree view content
        private ObservableCollection<ExplorerItem> LoadedFileTreeItems = new ObservableCollection<ExplorerItem>();

        public MainPage()
        {
            InitializeComponent();
        }

        /// <summary>
        /// Start hash generation and pasting of loaded file in background
        /// </summary>
        /// <param name="file"></param>
        private void startHashGeneration(ExplorerFile file)
        {
            file.markWaiting();
            file.GeneratedHash.Value = "";
            file.StartHashingTask();
        }

        /// <summary>
        /// Bring folder content to UI
        /// </summary>
        /// <param name="rootFolder"></param>
        /// <param name="rootExplorer"></param>
        private void loadFileTree(StorageFolder rootFolder, ObservableCollection<ExplorerItem> rootExplorer)
        {
            // Draw all direct subdirectories
            // Load items of each subdirectory recursively
            IReadOnlyList<StorageFolder> subfolders = rootFolder.GetFoldersAsync().AsTask().Result;
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
            IReadOnlyList<StorageFile> files = rootFolder.GetFilesAsync().AsTask().Result;
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

        /// <summary>
        /// Update all special hash algorithm selectors to have same value as global selector
        /// </summary>
        /// <param name="rootFolder"></param>
        private void updateSpecialHashSelectors(ObservableCollection<ExplorerItem> rootFolder)
        {
            // Update all special hash algorithm selectors
            foreach (ExplorerFolder folder in rootFolder.OfType<ExplorerFolder>())
                updateSpecialHashSelectors(folder.Children);

            foreach (ExplorerFile file in rootFolder.OfType<ExplorerFile>())
                file.SelectedHashAlgIndex.Value = GlobalHashAlgIndex.Value;
        }

        private void clearAllInputs(ObservableCollection<ExplorerItem> rootFolder)
        {
            // Clear all inputs for hash comparison
            foreach (ExplorerFolder folder in rootFolder.OfType<ExplorerFolder>())
                clearAllInputs(folder.Children);

            foreach (ExplorerFile file in rootFolder.OfType<ExplorerFile>())
                file.CheckHash.Value = "";
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
            ExplorerFile.CancelAllHashingTasks();
            LoadedFileTreeItems.Clear();

            // Load file structure to UI
            loadFileTree(folder, LoadedFileTreeItems);
        }

        /// <summary>
        /// Click event: Clear file tree
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Click_ClearFileTree(object sender, Windows.UI.Xaml.RoutedEventArgs e)
        {
            ExplorerFile.CancelAllHashingTasks();
            LoadedFileTreeItems.Clear();
            SelectedFolderPath.Value = SelectedFolderPath_default;
        }

        /// <summary>
        /// Click event: Load files that contain hash strings and paste hashes to inputs
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Click_LoadHashTree(object sender, Windows.UI.Xaml.RoutedEventArgs e)
        {
            var messageDialog = new MessageDialog("Button not implemented!\nClicking this button shall open another folder browsing dialog to select a folder of .md5/.sha1/.sha256/.sha384/.sha512 files that contain belonging check strings and pasting those strings into input fields of loaded files");
            _ = messageDialog.ShowAsync();
        }

        /// <summary>
        /// Click event: Clear all inputs for hash checking
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Click_ClearCheckinputs(object sender, Windows.UI.Xaml.RoutedEventArgs e)
        {
            clearAllInputs(LoadedFileTreeItems);
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
        /// Click event: Set all special hash selectors to current vlue of global
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Click_RefreshAllHashSelectors(object sender, Windows.UI.Xaml.RoutedEventArgs e)
        {
            updateSpecialHashSelectors(LoadedFileTreeItems);
        }

        /// <summary>
        /// Type event: Input for check hash is tyed/canged
        /// -> Compare generated hash with entered string
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Type_CheckHashChanged(object sender, TextChangedEventArgs e)
        {
            // Get loaded file, update check hash and compare
            ExplorerFile file = (sender as TextBox).DataContext as ExplorerFile;
            file.CheckHash.Value = (sender as TextBox).Text;  // Not updated on UI as not observable. Not not needed
            file.compareFileHash();
        }
    }
}
