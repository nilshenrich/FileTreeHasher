﻿using System;
using System.IO;
using System.Security.Cryptography;
using System.Threading;
using Windows.Storage;

namespace FileTreeHasher
{
    // Hash algorithms
    public enum HashAlgorithmNames : int
    {
        MD5 = 0,
        SHA1,
        SHA256,
        SHA384,
        SHA512
    }

    // Length (bytes) of hash algorithms
    public enum HashAlgorithmBytecounts : int
    {
        MD5 = 16,
        SHA1 = 20,
        SHA256 = 32,
        SHA384 = 48,
        SHA512 = 64
    }

    internal static class HashGenerator
    {
        /// <summary>
        /// Generate hash string for a file
        /// </summary>
        /// <param name="file"></param>
        /// <param name="hashAlgirithm"></param>
        /// <param name="progress"></param>
        /// <param name="cancellation"></param>
        public static string generateHash(StorageFile file, HashAlgorithmNames hashAlgirithm, Action<double> progress, CancellationToken cancellation)
        {
            // Cancel if requested
            cancellation.ThrowIfCancellationRequested();

            // Select hash generator
            HashAlgorithm hasher;
            switch (hashAlgirithm)
            {
                case HashAlgorithmNames.MD5:
                    hasher = MD5.Create();
                    break;

                case HashAlgorithmNames.SHA1:
                    hasher = SHA1.Create();
                    break;

                case HashAlgorithmNames.SHA256:
                    hasher = SHA256.Create();
                    break;

                case HashAlgorithmNames.SHA384:
                    hasher = SHA384.Create();
                    break;

                case HashAlgorithmNames.SHA512:
                    hasher = SHA512.Create();
                    break;

                default:
                    return "";
            }
            progress(0);

            // Open file stream to generate hash from
            Stream fileStream = file.OpenStreamForReadAsync().Result;

            // Get file size in bytes
            long fileSize = fileStream.Length;

            // Define step size for hash generation (1MB)
            int blockSize = 1024 * 1024;

            // Read and hash file block wise while a whole block fits
            long processed = 0;
            byte[] buffer = new byte[blockSize];
            while (processed + blockSize <= fileSize)
            {
                // Cancel if requested
                cancellation.ThrowIfCancellationRequested();

                // Read next block and do partial hash
                fileStream.Read(buffer, 0, blockSize);
                processed += hasher.TransformBlock(buffer, 0, blockSize, buffer, 0);
                progress((double)processed / fileSize);
            }

            // Cancel if requested
            cancellation.ThrowIfCancellationRequested();

            // Read and hash rest of file
            fileStream.Read(buffer, 0, (int)(fileSize - processed));
            hasher.TransformFinalBlock(buffer, 0, (int)(fileSize - processed));
            progress(1);

            // Return hash as readeble string with lower case letters
            return BitConverter.ToString(hasher.Hash).Replace("-", "").ToLower();
        }
    }
}
