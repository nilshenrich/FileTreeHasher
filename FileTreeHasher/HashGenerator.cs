using System;
using System.Security.Cryptography;
using Windows.Storage;
using Windows.Storage.Streams;

namespace FileTreeHasher
{
    // Hash algorithms
    public enum HashAlgirithmNames : int
    {
        MD5 = 0,
        SHA1,
        SHA256,
        SHA384,
        SHA512
    }

    internal static class HashGenerator
    {
        public static async void addHashAsync(StorageFile fileOnDisk, ExplorerFile fileInUi)
        {
            // Select hash generator
            HashAlgorithm hasher;
            switch (fileInUi.SelectedHashAlgName)
            {
                case HashAlgirithmNames.MD5:
                    hasher = MD5.Create();
                    break;

                case HashAlgirithmNames.SHA1:
                    hasher = SHA1.Create();
                    break;

                case HashAlgirithmNames.SHA256:
                    hasher = SHA256.Create();
                    break;

                case HashAlgirithmNames.SHA384:
                    hasher = SHA384.Create();
                    break;

                case HashAlgirithmNames.SHA512:
                    hasher = SHA512.Create();
                    break;

                default:
                    fileInUi.GeneratedHash = "";
                    return;
            }

            // Read file content
            var fileBuffer = await FileIO.ReadBufferAsync(fileOnDisk);
            byte[] fileBytes = new byte[fileBuffer.Length];
            DataReader.FromBuffer(fileBuffer).ReadBytes(fileBytes);

            // Generate hash string and update UI
            byte[] hashRaw = hasher.ComputeHash(fileBytes);
            string hash = BitConverter.ToString(hashRaw).Replace("-", "").ToLower();
            fileInUi.GeneratedHash = hash;
        }
    }
}
