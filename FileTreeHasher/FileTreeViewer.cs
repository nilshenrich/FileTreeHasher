using System;
using System.Collections.ObjectModel;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;

namespace FileTreeHasher
{
    public enum ExplorerItemType { Folder, File };

    public class ExplorerItem //: INotifyPropertyChanged
    {
        //public event PropertyChangedEventHandler PropertyChanged;
        public string Name { get; set; }
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

        // Event triggers only needed if handlers available
        //private bool m_isExpanded;
        //public bool IsExpanded
        //{
        //    get { return m_isExpanded; }
        //    set
        //    {
        //        if (m_isExpanded != value)
        //        {
        //            m_isExpanded = value;
        //            NotifyPropertyChanged("IsExpanded");
        //        }
        //    }
        //}

        //private bool m_isSelected;
        //public bool IsSelected
        //{
        //    get { return m_isSelected; }

        //    set
        //    {
        //        if (m_isSelected != value)
        //        {
        //            m_isSelected = value;
        //            NotifyPropertyChanged("IsSelected");
        //        }
        //    }

        //}

        //private void NotifyPropertyChanged(String propertyName)
        //{
        //    if (PropertyChanged != null)
        //    {
        //        PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
        //    }
        //}
    }

    public class ExplorerFolder : ExplorerItem { }

    public class ExplorerFile : ExplorerItem
    {
        public Uri IconSource { get; set; }
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
