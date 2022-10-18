using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Threading.Tasks;
using Windows.ApplicationModel.Core;
using Windows.Storage;
using Windows.UI.Core;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;

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
        public ObservableObject<Uri> IconSource = new ObservableObject<Uri>();
        public ObservableObject<string> HashingProgress = new ObservableObject<string>();
        public ObservableObject<string> GeneratedHash = new ObservableObject<string>();
        public ObservableObject<string> CheckHash = new ObservableObject<string>();
        public ObservableObject<int> SelectedHashAlgIndex = new ObservableObject<int>();
        private int? GeneratedHashAlgIndex = null;
        public int OldSelectedHashAlgIndex;

        // Collection of Image source uris
        public static Uri IconSourceWait;
        public static Uri IconSourceCalc;
        public static Uri IconSourceHashed;
        public static Uri IconSourceCheck;
        public static Uri IconSourceFail;

        // Hash generation task
        private Task m_hashGenerationTask = Task.CompletedTask;
        private CancellationTokenSource m_taskCancellationTokenSource = new CancellationTokenSource();

        /// <summary>
        /// Cancel pending task and restart with given action
        /// </summary>
        public void StartHashingTask()
        {
            markWaiting();
            GeneratedHash.Value = "";
            GeneratedHashAlgIndex = null;

            // Before starting new task, wait for currently running task to finish
            CancelHashingTask();

            // Run hash generation in task
            m_hashGenerationTask = Task.Run(() =>
            {
                // Break if the task queue is cancelled
                if (m_taskCancellationTokenSource.Token.IsCancellationRequested)
                    return;

                // Break if the correct hash is already displayed
                m_taskCancellationTokenSource.Token.ThrowIfCancellationRequested();

                // Init progress calculation
                // TODO: Doesn't stop updating UI
                //       just setting to null won't work
                Progress<double> proc = new Progress<double>(i => HashingProgress.Value = string.Format("{0:0.00} %", i * 100));

                // Generate hash and update UI
                markPending();
                GeneratedHashAlgIndex = null;
                int hashId = SelectedHashAlgIndex.Value;
                string hash = HashGenerator.generateHash(FileOnDisk, (HashAlgirithmNames)hashId, proc, m_taskCancellationTokenSource.Token);

                // Break if the task queue is cancelled
                m_taskCancellationTokenSource.Token.ThrowIfCancellationRequested();

                // Generation done if hash selector didn't change
                if (SelectedHashAlgIndex.Value == hashId)
                {
                    GeneratedHash.Value = hash;
                    GeneratedHashAlgIndex = hashId;
                    compareFileHash();
                }
                else
                    StartHashingTask();
            }, m_taskCancellationTokenSource.Token);
        }

        /// <summary>
        /// Cancel pending hash calculation task
        /// </summary>
        public void CancelHashingTask()
        {
            m_taskCancellationTokenSource.Cancel();

            // TODO: Wait for task to finish (.Wait causes exception)
            // TODO: Without wait, this overrides token before task is cancelled
            m_taskCancellationTokenSource = new CancellationTokenSource();
        }

        /// <summary>
        /// Mark file as waiting for hash string calculation
        /// </summary>
        private void markWaiting()
        {
            IconSource.Value = IconSourceWait;
            HashingProgress.Value = "";
        }

        /// <summary>
        /// Mark file as pending hash calculation
        /// </summary>
        private void markPending()
        {
            IconSource.Value = IconSourceCalc;
        }

        /// <summary>
        /// Mark file as ready for hash comparison (hash string calculated)
        /// </summary>
        private void markReady()
        {
            IconSource.Value = IconSourceHashed;
            HashingProgress.Value = "";
        }

        /// <summary>
        /// Marks file as passed for hash checking
        /// </summary>
        private void markPassed()
        {
            IconSource.Value = IconSourceCheck;
            HashingProgress.Value = "";
        }

        /// <summary>
        /// Marks file as failed for hash checking
        /// </summary>
        private void markFailed()
        {
            IconSource.Value = IconSourceFail;
            HashingProgress.Value = "";
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
