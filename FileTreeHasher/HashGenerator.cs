using System;
using System.IO;
using System.Security.Cryptography;
using Windows.Storage;

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
        public static string generateHash(StorageFile file, HashAlgirithmNames hashAlgirithm)
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

            // Open file stream to generate hash from
            Stream fileStream = file.OpenStreamForReadAsync().Result;

            // Generate hash block wise
            //byte[] hashRaw = hasher.ComputeHash(fileStream);

            // Get file size in bytes
            long fileSize = fileStream.Length;

            // Define step size for hash generation (1MB)
            int blockSize = 1024 * 1024;

            // Read and hash file block wise while a whole block fits
            int offset = 0;
            byte[] buffer = new byte[blockSize];
            while (offset + blockSize <= fileSize)
            {
                // Read next block and do partial hash
                fileStream.Read(buffer, 0, blockSize);
                offset += hasher.TransformBlock(buffer, 0, blockSize, buffer, 0);
            }

            // Read and hash rest of file
            fileStream.Read(buffer, 0, (int)(fileSize - offset));
            hasher.TransformFinalBlock(buffer, 0, (int)(fileSize - offset));

            // Get generated hash from buffer
            byte[] hashRaw = hasher.Hash;

            // Return hash as readeble string with lower case letters
            return BitConverter.ToString(hashRaw).Replace("-", "").ToLower();
        }
    }
}
