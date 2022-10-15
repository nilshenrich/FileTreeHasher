using System;
using System.Security.Cryptography;
using System.Threading.Tasks;
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
        /// <summary>
        /// Generate hash string for a file
        /// </summary>
        /// <param name="file"></param>
        public static async Task<string> generateHashAsync(StorageFile file, HashAlgirithmNames hashAlgirithm)
        {
            // Select hash generator
            HashAlgorithm hasher;
            switch (hashAlgirithm)
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
                    return "";
            }

            // Read file content
            var fileBuffer = await FileIO.ReadBufferAsync(file);
            byte[] fileBytes = new byte[fileBuffer.Length];
            DataReader.FromBuffer(fileBuffer).ReadBytes(fileBytes);

            // Generate hash string and update UI
            byte[] hashRaw = hasher.ComputeHash(fileBytes);
            string hash = BitConverter.ToString(hashRaw).Replace("-", "").ToLower();
            return hash;
        }
    }
}
