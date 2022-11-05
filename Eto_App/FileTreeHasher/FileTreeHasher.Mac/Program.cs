using Eto.Forms;
using System;

namespace FileTreeHasher.Mac
{
    internal class Program
    {
        [STAThread]
        public static void Main(string[] args)
        {
            new Application(Eto.Platforms.Mac64).Run(new MainForm());
        }
    }
}
