using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Threading.Tasks;
using Windows.ApplicationModel.Core;
using Windows.Storage;
using Windows.UI;
using Windows.UI.Core;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Media;

namespace FileTreeHasher
{
    public class ObservableObject<T> : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged = delegate { };
        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            // Raise the PropertyChanged event, passing the name of the property whose value has changed.
            var args = new PropertyChangedEventArgs(propertyName);
            _ = CoreApplication.MainView.CoreWindow.Dispatcher.RunAsync(CoreDispatcherPriority.Normal, () =>
            PropertyChanged?.Invoke(this, args));
        }

        public ObservableObject() { }
        public ObservableObject(T value) { m_value = value; }

        private T m_value;
        public T Value
        {
            get { return m_value; }
            set
            {
                bool equal = value.Equals(m_value);
                m_value = value;
                if (!equal)
                    OnPropertyChanged();
            }
        }
    }

    public class ExplorerItem
    {
        public string Name;
    }

    public class ExplorerFolder : ExplorerItem
    {
        public bool IsExpanded = true;
        private ObservableCollection<ExplorerItem> m_children;
        public ObservableCollection<ExplorerItem> Children
        {
            get
            {
                if (m_children == null)
                {
                    m_children = new ObservableCollection<ExplorerItem>();
                }
                return m_children;
            }
            set
            {
                m_children = value;
            }
        }
    }

    public class ExplorerFile : ExplorerItem
    {
        // Visible UI outputs
        public StorageFile FileOnDisk;
        public ObservableObject<Symbol> IconSymbol = new ObservableObject<Symbol>();
        public ObservableObject<Brush> IconColor = new ObservableObject<Brush>();
        public ObservableObject<string> GeneratedHash = new ObservableObject<string>();
        public ObservableObject<string> CheckHash = new ObservableObject<string>();
        public ObservableObject<int> SelectedHashAlgIndex = new ObservableObject<int>();
        public int OldSelectedHashAlgIndex;
        public HashAlgirithmNames SelectedHashAlgName
        {
            get { return (HashAlgirithmNames)SelectedHashAlgIndex.Value; }
            set { SelectedHashAlgIndex.Value = (int)value; }
        }

        // Hash generation task
        private static Task m_hashGenerationTask = Task.CompletedTask;
        private static CancellationTokenSource m_taskCancellationTokenSource = new CancellationTokenSource();

        /// <summary>
        /// Cancel pending task and restart with given action
        /// </summary>
        public void StartHashingTask()
        {
            // Queue new process to run consecutively
            m_hashGenerationTask = m_hashGenerationTask.ContinueWith((m_hashGenerationTask) =>
            {
                // TODO: Also cancel pending hashing process
                // TODO: If hashing can be cancelled, tasks could be started in parallel again
                // TODO: Same file could have multiple hash calculations in pipeline after changing algorithm
                // TODO: Files don't starthashing when reloading new file tree cancelled earlier process
                m_taskCancellationTokenSource.Token.ThrowIfCancellationRequested();
                _ = CoreApplication.MainView.CoreWindow.Dispatcher.RunAsync(CoreDispatcherPriority.Normal, () =>
                    markPending());
                string hash = HashGenerator.generateHash(FileOnDisk, SelectedHashAlgName);
                GeneratedHash.Value = hash;
                _ = CoreApplication.MainView.CoreWindow.Dispatcher.RunAsync(CoreDispatcherPriority.Normal, () =>
                    compareFileHash());
            }, m_taskCancellationTokenSource.Token);
        }

        /// <summary>
        /// Cancel pending hash calculation task if running
        /// </summary>
        public static void CancelAllHashingTasks()
        {
            if (!m_hashGenerationTask.IsCompleted)
                m_taskCancellationTokenSource.Cancel();
        }

        /// <summary>
        /// Mark file as waiting for hash string calculation
        /// </summary>
        public void markWaiting()
        {
            IconSymbol.Value = Symbol.Clock;
            IconColor.Value = new SolidColorBrush(Colors.Orange);
        }

        /// <summary>
        /// Mark file as pending hash calculation
        /// </summary>
        public void markPending()
        {
            IconSymbol.Value = Symbol.Forward;
            IconColor.Value = new SolidColorBrush(Colors.Purple);
        }

        /// <summary>
        /// Mark file as ready for hash comparison (hash string calculated)
        /// </summary>
        public void markReady()
        {
            IconSymbol.Value = Symbol.Accept;
            IconColor.Value = new SolidColorBrush(Colors.Blue);
        }

        /// <summary>
        /// Marks file as passed for hash checking
        /// </summary>
        public void markPassed()
        {
            IconSymbol.Value = Symbol.Accept;
            IconColor.Value = new SolidColorBrush(Colors.Green);
        }

        /// <summary>
        /// Marks file as failed for hash checking
        /// </summary>
        public void markFailed()
        {
            IconSymbol.Value = Symbol.Cancel;
            IconColor.Value = new SolidColorBrush(Colors.Red);
        }

        /// <summary>
        /// Compare generated hash with check string and mark file item acordingly
        /// </summary>
        public void compareFileHash()
        {
            // For empty generated string, do nothing
            if (string.IsNullOrEmpty(GeneratedHash.Value))
                return;

            // For empty comparison string, don't compare
            if (string.IsNullOrEmpty(CheckHash.Value))
            {
                markReady();
                return;
            }

            // Check string
            if (GeneratedHash.Value == CheckHash.Value.ToLower())
                markPassed();
            else
                markFailed();
        }
    }

    public class ExplorerItemTemplateSelector : DataTemplateSelector
    {
        public DataTemplate FolderTemplate { get; set; }
        public DataTemplate FileTemplate { get; set; }

        protected override DataTemplate SelectTemplateCore(object item)
        {
            return item is ExplorerFile ? FileTemplate : FolderTemplate;
        }
    }
}
