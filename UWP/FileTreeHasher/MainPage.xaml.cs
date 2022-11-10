using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text.RegularExpressions;
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
        // Global selections
        private ObservableObject<int> GlobalHashAlgIndex = new ObservableObject<int>((int)HashAlgorithmNames.SHA256);
        private ObservableObject<string> GlobalFileFilter = new ObservableObject<string>();

        // Path of currentliy selected folder
        private const string SelectedFolderPath_default = "<no folder selected>";
        private ObservableObject<string> SelectedFolderPath = new ObservableObject<string>(SelectedFolderPath_default);
        private StorageFolder PickedFolder;

        // Placeholder for "not generated hash"
        private const string HashNotGenerated_placeholder = "<hash not generated>";

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
                // Apply filter
                if (!Regex.IsMatch(file.Name, GlobalFileFilter.Value))
                    continue;

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

        /// <summary>
        /// Loop over loaded files and find belonging check hash from checkfile and insert it into input
        /// </summary>
        /// <param name="checkfile"></param>
        /// <param name="rootFolder"></param>
        /// <param name="dirPath"></param>
        private void assignFilesToCheckfile(string checkfile, ObservableCollection<ExplorerItem> rootFolder, string dirPath)
        {
            // Recurse for all sub-folders
            foreach (ExplorerFolder folder in rootFolder.OfType<ExplorerFolder>())
                assignFilesToCheckfile(checkfile, folder.Children, dirPath + folder.Name + "/");

            // Update hash check inputs
            foreach (ExplorerFile file in rootFolder.OfType<ExplorerFile>())
            {
                // Get path of current loaded file
                string path = dirPath + file.Name;

                // If file exists in checkfile, update check hash and hash algorithm
                foreach (string checkline in checkfile.Split(Environment.NewLine))
                {
                    // Get hash, algorithm, file from checkfile line
                    string[] items = checkline.Split("\t");
                    if (items.Length != 3)
                        continue;

                    // Trim hash sting
                    items[0] = items[0].Trim();

                    // Only update UI if check hash matches format
                    if (!Regex.IsMatch(items[0], string.Format("\\A[0-9a-f]{{{0}}}\\Z", 2 * (int)Enum.Parse(typeof(HashAlgorithmBytecounts), items[1]))))
                        continue;

                    // If current file matches, update UI
                    if (items[2] == path)
                    {
                        file.CheckHash.Value = items[0];
                        file.SelectedHashAlgIndex.Value = (int)Enum.Parse(typeof(HashAlgorithmNames), items[1]);
                        break;
                    }
                }
            }
        }

        /// <summary>
        /// Recursively add all files with generated hashes to string to be stored to checkfile
        /// </summary>
        /// <param name="checkfile"></param>
        /// <param name="rootFolder"></param>
        /// <param name="dirPath"></param>
        private void appendHashesToCheckfile(ref string checkfile, ObservableCollection<ExplorerItem> rootFolder, string dirPath)
        {
            // Recurse for all sub-folders
            foreach (ExplorerFolder folder in rootFolder.OfType<ExplorerFolder>())
                appendHashesToCheckfile(ref checkfile, folder.Children, dirPath + folder.Name + "/");

            // Append all files in current directory
            foreach (ExplorerFile file in rootFolder.OfType<ExplorerFile>())
            {
                checkfile += string.Format("{0}\t{1}\t{2}{3}",
                    string.IsNullOrEmpty(file.GeneratedHash.Value) ? HashNotGenerated_placeholder : file.GeneratedHash.Value,
                    Enum.GetName(typeof(HashAlgorithmNames), file.SelectedHashAlgIndex.Value),
                    dirPath + file.Name,
                    Environment.NewLine);
            }
        }

        /// <summary>
        /// Recursively clear all text inputs for hash checking
        /// </summary>
        /// <param name="rootFolder"></param>
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
            PickedFolder = await folderPicker.PickSingleFolderAsync();

            // Cancel if no folder was selected
            if (PickedFolder == null)
                return;

            // Set selected folder path
            SelectedFolderPath.Value = PickedFolder.Path;

            // Clear all old lodaded elements
            cancelAllHashingTasks(LoadedFileTreeItems);
            LoadedFileTreeItems.Clear();

            // Load file structure to UI
            loadFileTree(PickedFolder, LoadedFileTreeItems);
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
            PickedFolder = null;
            SelectedFolderPath.Value = SelectedFolderPath_default;
        }

        /// <summary>
        /// Change event: Selected global file filter changed
        /// -> Reload all file tree
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Change_FileLoadFilter(object sender, SelectionChangedEventArgs e)
        {
            // Reload current folder if loaded
            if (PickedFolder == null)
                return;

            // Clear all old lodaded elements
            cancelAllHashingTasks(LoadedFileTreeItems);
            LoadedFileTreeItems.Clear();

            // Load file structure to UI
            loadFileTree(PickedFolder, LoadedFileTreeItems);
        }

        /// <summary>
        /// Click event: Load checkfile that contains hash strings and paste hashes to inputs
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void Click_LoadCheckfile(object sender, Windows.UI.Xaml.RoutedEventArgs e)
        {
            // Open file browsing dialog to select checkfile to load from
            // Manual: https://learn.microsoft.com/en-us/uwp/api/windows.storage.pickers.fileopenpicker?view=winrt-22621
            FileOpenPicker filePicker = new FileOpenPicker();
            filePicker.ViewMode = PickerViewMode.List;
            filePicker.FileTypeFilter.Add(".sha");
            StorageFile file = await filePicker.PickSingleFileAsync();

            // Caancel if no proper file is selected
            if (file == null)
                return;

            // Loop over loaded files and update from checkfile
            string checkfile = await FileIO.ReadTextAsync(file);
            assignFilesToCheckfile(checkfile, LoadedFileTreeItems, "");
        }

        /// <summary>
        /// Click event: Save all generated hashes to checkfile that contains hash strings
        /// 
        /// File format:
        /// ; Checkfile created by File Tree Hasher
        /// ; Get latest release from https://github.com/nilshenrich/FileTreeHasher/releases
        /// ; Creation time stamp: 01.11.2022 16:06:01
        /// 
        /// CA56950A5FEAC0166994AF9225714B8DF1481AE6B32DAE538B6C21F5C5291DE2	SHA1	folder/file.txt
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void Click_SaveCheckfile(object sender, Windows.UI.Xaml.RoutedEventArgs e)
        {
            // Open file browsing dialog to select checkfile to save hashes to
            // Manual: https://learn.microsoft.com/en-us/uwp/api/Windows.Storage.Pickers.FileSavePicker?view=winrt-22621
            FileSavePicker filePicker = new FileSavePicker();
            filePicker.FileTypeChoices.Add("Checkfile", new List<string>() { ".sha" });
            filePicker.SuggestedFileName = "Checkfile";
            StorageFile file = await filePicker.PickSaveFileAsync();

            // Caancel if no proper file is selected
            if (file == null)
                return;

            // Checkfile header
            string checkfile = string.Format("; Checkfile created by File Tree Hasher\r\n; Get latest release from https://github.com/nilshenrich/FileTreeHasher/releases\r\n; Creation time stamp: {0}\r\n\r\n", DateTime.Now);

            // Loop over loaded files with generated hash
            appendHashesToCheckfile(ref checkfile, LoadedFileTreeItems, "");

            // Save checkfile
            CachedFileManager.DeferUpdates(file);
            await FileIO.WriteTextAsync(file, checkfile);
            await CachedFileManager.CompleteUpdatesAsync(file);
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
            file.CheckHash.Value = (sender as TextBox).Text;
            file.compareFileHash();
        }
    }
}
