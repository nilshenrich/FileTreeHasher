using Eto.Drawing;
using Eto.Forms;

namespace FileTreeHasher
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            // ===============================================
            // ========== General Elements / Styles ==========
            // ===============================================
            Title = "File Tree Hasher";
            MinimumSize = new Size(500, 200);

            // ===============================================
            // ================== Menu bar ===================
            // ===============================================

            // ===============================================
            // =================== Content ===================
            // ===============================================
            var fileTree = new TreeGridView()
            {
                // Help:
                // - http://pages.picoe.ca/docs/api/html/T_Eto_Forms_TreeGridView.htm
                // - https://stackoverflow.com/questions/49348488/how-to-use-eto-forms-treegridview
                // - https://10tec.com/articles/treegridview-c-sharp-vb-net.aspx

                BackgroundColor = Colors.Transparent,

                // 3 columns
                Columns =
                {
                    new GridColumn(){HeaderText="Left column",DataCell=new TextBoxCell(0)},
                    new GridColumn(){HeaderText="Middle column",DataCell=new TextBoxCell(1)},
                    new GridColumn(){HeaderText="Right column",DataCell=new TextBoxCell(2)}
                },
                DataStore = new TreeGridItemCollection()
            };

            // Sample folder
            var sampleFolder = new TreeGridItem()
            {
                Values = new string[] { "Sample folder", "Hash algorithm", "Check" },
                Tag = "SampleFolder_tag",
                Expanded = true
            };

            // Sample file
            var sampleFile = new TreeGridItem()
            {
                Values = new string[] { "Sample file", "Hash algorithm", "Check" },
                Tag = "SampleFile"
            };

            // Sample nested file
            var sampleNestedFile = new TreeGridItem()
            {
                Values = new string[] { "Sample nested file", "Hash algorithm", "Check" },
                Tag = "SampleNestedFile"
            };

            // Stack tree
            TreeGridItemCollection mainFolder = new();
            sampleFolder.Children.Add(sampleNestedFile);
            mainFolder.Add(sampleFolder);
            mainFolder.Add(sampleFile);
            fileTree.DataStore = mainFolder;

            // Show content
            Content = fileTree;
        }
    }
}
