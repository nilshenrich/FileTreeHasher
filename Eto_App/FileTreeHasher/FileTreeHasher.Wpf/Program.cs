using Eto.Forms;
using System;

namespace FileTreeHasher.Wpf
{
    internal class Program
    {
        [STAThread]
        public static void Main(string[] args)
        {
            new Application(Eto.Platforms.Wpf).Run(new MainForm());
        }
    }
}
