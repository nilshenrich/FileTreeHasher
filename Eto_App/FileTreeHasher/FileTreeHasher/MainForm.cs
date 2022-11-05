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
            MinimumSize = new Eto.Drawing.Size(500, 200);

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

                BackgroundColor = Colors.Transparent,
            };

            // Show content
            Content = fileTree;
        }
    }
}
