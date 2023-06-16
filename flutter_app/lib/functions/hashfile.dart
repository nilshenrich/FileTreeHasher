// ####################################################################################################
// # @file hashfile.dart
// # @author Nils Henrich
// # @brief Algorithms for hash file: creating, loading
//          Hash file format:
//          <folder1>
//          +---<file11> <hash>
//          +---<folder11>
//          |   +---<file111> <hash>
//          |   +---<folder<111>
//          |       +---<file1111> <hash>
//          +---<folder12>
//          <file1> <hash>
// # @version 0.0.0+1
// # @date 2023-06-16
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

import 'dart:io';
import 'package:file_tree_hasher/definies/datatypes.dart';

// ##################################################
// @brief: Generate hash file from given file paths and hashes
// @param: fileviewhashes
// @param: storagepath
// @param: override
// ##################################################
void generateHashfile(C_FileViewHashes fileviewhashes, String storagepath, {bool override = true, int level = 0}) {
  // Get file socket
  File filesocket = File(storagepath);

  // If file shall be overridded, just recreate it
  if (override) {
    filesocket.createSync();
  }

  // Loop over all view elements
  // - For a file, add entry to hash file
  // - For a folder, recurse on folder
  for (C_FileViewHashes folder in fileviewhashes.folders) {
    generateHashfile(folder, storagepath, override: false, level: level + 1);
  }
  for (C_FileHashPair file in fileviewhashes.files) {
    String newLine;
    switch (level) {
      case 0:
        newLine = "";
        break;
      case 1:
        newLine = "+---";
        break;
      default:
        {
          newLine = "|   ";
          for (int i = 2; i <= level; i += 1) {
            newLine += "    ";
          }
        }
        break;
    }
    newLine += file.file;
    newLine += " ";
    newLine += file.hash ?? "<no hash>";
    newLine += "\n";
    filesocket.writeAsStringSync(newLine, mode: FileMode.append);
  }
}
