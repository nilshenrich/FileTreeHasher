using System;
using System.Collections.ObjectModel;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;

namespace FileTreeHasher
{
    public class ExplorerItem
    {
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
    }

    public class ExplorerFolder : ExplorerItem
    {
        public bool IsExpanded { get; set; } = true;
    }

    public class ExplorerFile : ExplorerItem
    {
        public Uri IconSource { get; set; }
        public string GeneratedHash { get; set; }
        public string CheckHash { get; set; }
        public int SelectedHashAlgIndex = (int)HashAlgirithmNames.SHA256;
        public HashAlgirithmNames SelectedHashAlgName
        {
            get { return (HashAlgirithmNames)SelectedHashAlgIndex; }
            set { SelectedHashAlgIndex = (int)value; }
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
