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
                }
            };

            // Sample folder
            var sampleFolder = new TreeGridItem()
            {
                Values = new string[] { "Left item", "Middle item", "Right item" },
                Tag = "SampleFolder_tag"
            };

            // Sample file
            var sampleNestedFile = new TreeGridItem()
            {
                Values = new string[] { "Left item", "Middle item", "Right item" },
                Tag = "SampleNestedFile"
            };

            // Show content
            sampleFolder.Children.Add(sampleNestedFile);
            fileTree.DataStore = new TreeGridItemCollection() { sampleFolder };
            Content = fileTree;
        }
    }
}
