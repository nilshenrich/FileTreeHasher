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
        private static Task m_hashGenerationTask = Task.CompletedTask;
        private static CancellationTokenSource m_taskCancellationTokenSource = new CancellationTokenSource();

        /// <summary>
        /// Cancel pending task and restart with given action
        /// </summary>
        public void QueueNewHashingTask()
        {
            markWaiting();
            GeneratedHash.Value = "";
            GeneratedHashAlgIndex = null;

            // Queue new process to run consecutively
            m_hashGenerationTask = m_hashGenerationTask.ContinueWith((m_hashGenerationTask) =>
            {
                // TODO: Also cancel pending hashing process
                // TODO: If hashing can be cancelled, tasks could be started in parallel again

                // Break if the task queue is cancelled
                m_taskCancellationTokenSource.Token.ThrowIfCancellationRequested();

                // Break if the correct hash is already displayed
                if (SelectedHashAlgIndex.Value == GeneratedHashAlgIndex)
                    return;

                // Generate hash and update UI
                markPending();
                GeneratedHashAlgIndex = null;
                int hashId = SelectedHashAlgIndex.Value;
                string hash = HashGenerator.generateHash(FileOnDisk, (HashAlgirithmNames)hashId);

                // Generation done if hash selector didn't change
                if (SelectedHashAlgIndex.Value == hashId)
                {
                    GeneratedHash.Value = hash;
                    GeneratedHashAlgIndex = hashId;
                    compareFileHash();
                }
                else
                    QueueNewHashingTask();
            }, m_taskCancellationTokenSource.Token);
        }

        /// <summary>
        /// Cancel pending hash calculation task if running
        /// </summary>
        public static void CancelAllHashingTasks()
        {
            if (!m_hashGenerationTask.IsCompleted)
            {
                m_taskCancellationTokenSource.Cancel();
                m_taskCancellationTokenSource = new CancellationTokenSource();
            }
        }

        /// <summary>
        /// Mark file as waiting for hash string calculation
        /// </summary>
        private void markWaiting()
        {
            IconSource.Value = IconSourceWait;
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
        }

        /// <summary>
        /// Marks file as passed for hash checking
        /// </summary>
        private void markPassed()
        {
            IconSource.Value = IconSourceCheck;
        }

        /// <summary>
        /// Marks file as failed for hash checking
        /// </summary>
        private void markFailed()
        {
            IconSource.Value = IconSourceFail;
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
