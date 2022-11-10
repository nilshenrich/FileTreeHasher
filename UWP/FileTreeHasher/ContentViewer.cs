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
                if (!Equals(value, m_value))
                {
                    m_value = value;
                    OnPropertyChanged();
                }
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
        public ObservableObject<double> HashingProgress = new ObservableObject<double>();
        public ObservableObject<string> HashingProgress_str = new ObservableObject<string>();
        public ObservableObject<Visibility> HashingProgress_visibility = new ObservableObject<Visibility>();
        public ObservableObject<string> GeneratedHash = new ObservableObject<string>();
        public ObservableObject<string> CheckHash = new ObservableObject<string>();
        public ObservableObject<int> SelectedHashAlgIndex = new ObservableObject<int>();
        public int OldSelectedHashAlgIndex;

        // Collection of Image source uris
        public static Uri IconSourceWait;
        public static Uri IconSourceCalc;
        public static Uri IconSourceHashed;
        public static Uri IconSourceCheck;
        public static Uri IconSourceFail;

        // Hash generation task
        private Task m_hashGenerationTask = Task.CompletedTask;
        private static SemaphoreSlim concurrencySemaphore = new SemaphoreSlim(Math.Max(Environment.ProcessorCount / 4, 1));
        private CancellationTokenSource m_taskCancellationTokenSource = new CancellationTokenSource();

        /// <summary>
        /// Hashing process which is executed in task
        /// </summary>
        /// <param name="cancellation"></param>
        private void HashGenerationProcess()
        {
            // Break if the correct hash is already displayed
            m_taskCancellationTokenSource.Token.ThrowIfCancellationRequested();

            // Init progress calculation
            Action<double> proc = new Action<double>(i =>
            {
                HashingProgress.Value = i;
                HashingProgress_str.Value = string.Format("{0:0} %", i * 100);
            });

            // Generate hash and update UI
            markPending();
            string hash = HashGenerator.generateHash(FileOnDisk, (HashAlgorithmNames)SelectedHashAlgIndex.Value, proc, m_taskCancellationTokenSource.Token);

            // Break if the task queue is cancelled
            m_taskCancellationTokenSource.Token.ThrowIfCancellationRequested();

            // Generation done
            GeneratedHash.Value = hash;
            compareFileHash();
        }

        /// <summary>
        /// Cancel pending task and restart with given action
        /// </summary>
        public async void StartHashingTask()
        {
            markWaiting();
            GeneratedHash.Value = "";

            // Before starting new task, wait for currently running task to finish
            CancelHashingTask();

            // Run hash generation in task
            m_hashGenerationTask = Task.Run(() =>
            {
                concurrencySemaphore.Wait(m_taskCancellationTokenSource.Token);
                try
                {
                    HashGenerationProcess();
                }
                finally
                {
                    concurrencySemaphore.Release();
                }
            }, m_taskCancellationTokenSource.Token);

            try
            {
                await m_hashGenerationTask;
            }
            catch (OperationCanceledException)
            {
                // Do nothing, just catch
            }
        }

        /// <summary>
        /// Cancel pending hash calculation task
        /// </summary>
        public void CancelHashingTask()
        {
            m_taskCancellationTokenSource.Cancel();

            // Wait for task to finish or cancel by token source
            try
            {
                m_hashGenerationTask.Wait(m_taskCancellationTokenSource.Token);
            }
            catch (OperationCanceledException)
            {
                // Do nothing, just catch
            }

            // Recreate cancellation token source as it is requested now
            m_taskCancellationTokenSource = new CancellationTokenSource();
        }

        /// <summary>
        /// Mark file as waiting for hash string calculation
        /// </summary>
        private void markWaiting()
        {
            IconSource.Value = IconSourceWait;
            HashingProgress_visibility.Value = Visibility.Collapsed;
            HashingProgress.Value = 0.0;
            HashingProgress_str.Value = "";
        }

        /// <summary>
        /// Mark file as pending hash calculation
        /// </summary>
        private void markPending()
        {
            IconSource.Value = IconSourceCalc;
            HashingProgress_visibility.Value = Visibility.Visible;
            HashingProgress.Value = 0.0;
            HashingProgress_str.Value = "";
        }

        /// <summary>
        /// Mark file as ready for hash comparison (hash string calculated)
        /// </summary>
        private void markReady()
        {
            IconSource.Value = IconSourceHashed;
            HashingProgress_visibility.Value = Visibility.Collapsed;
            HashingProgress.Value = 0.0;
            HashingProgress_str.Value = "";
        }

        /// <summary>
        /// Marks file as passed for hash checking
        /// </summary>
        private void markPassed()
        {
            IconSource.Value = IconSourceCheck;
            HashingProgress_visibility.Value = Visibility.Collapsed;
            HashingProgress.Value = 0.0;
            HashingProgress_str.Value = "";
        }

        /// <summary>
        /// Marks file as failed for hash checking
        /// </summary>
        private void markFailed()
        {
            IconSource.Value = IconSourceFail;
            HashingProgress_visibility.Value = Visibility.Collapsed;
            HashingProgress.Value = 0.0;
            HashingProgress_str.Value = "";
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
