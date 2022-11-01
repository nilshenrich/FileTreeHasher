using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using Windows.Storage;
using Windows.Storage.Pickers;
using Windows.UI.Popups;
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
        private const string SelectedFolderPath_default = "<No folder selected>";
        private ObservableObject<string> SelectedFolderPath = new ObservableObject<string>(SelectedFolderPath_default);

        // Tree view content
        private ObservableCollection<ExplorerItem> LoadedFileTreeItems = new ObservableCollection<ExplorerItem>();

        public MainPage()
        {
            InitializeComponent();

            // Set icon sources
            ExplorerFile.IconSourceWait = new Uri(BaseUri, "/Icons/Wait.png");
            ExplorerFile.IconSourceCalc = new Uri(BaseUri, "/Icons/Calc.png");
            ExplorerFile.IconSourceHashed = new Uri(BaseUri, "/Icons/Hashed.png");
            ExplorerFile.IconSourceCheck = new Uri(BaseUri, "/Icons/Check.png");
            ExplorerFile.IconSourceFail = new Uri(BaseUri, "/Icons/Fail.png");
        }

        /// <summary>
        /// Cancel hashing process for all loaded files
        /// </summary>
        /// <param name="rootFolder"></param>
        private void cancelAllHashingTasks(ObservableCollection<ExplorerItem> rootFolder)
        {
            foreach (ExplorerFolder folder in rootFolder.OfType<ExplorerFolder>())
                cancelAllHashingTasks(folder.Children);

            foreach (ExplorerFile file in rootFolder.OfType<ExplorerFile>())
                file.CancelHashingTask();
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
                explorerFile.StartHashingTask();
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
            cancelAllHashingTasks(LoadedFileTreeItems);
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
            cancelAllHashingTasks(LoadedFileTreeItems);
            LoadedFileTreeItems.Clear();
            SelectedFolderPath.Value = SelectedFolderPath_default;
        }

        /// <summary>
        /// Click event: Load checkfile that contains hash strings and paste hashes to inputs
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Click_LoadCheckfile(object sender, Windows.UI.Xaml.RoutedEventArgs e)
        {
            var messageDialog = new MessageDialog("Button not implemented!\nClicking this button shall open a file browsing dialog to select a checkfile that contains belonging check strings and pasting those strings into input fields of loaded files");
            _ = messageDialog.ShowAsync();
        }

        /// <summary>
        /// Click event: Save all generated hashes to checkfile that contains hash strings
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Click_SaveCheckfile(object sender, Windows.UI.Xaml.RoutedEventArgs e)
        {
            var messageDialog = new MessageDialog("Button not implemented!\nClicking this button shall save all generated hashes to a checkfile");
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
                file.StartHashingTask();
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
