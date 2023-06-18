// ####################################################################################################
// # @file hashfile.dart
// # @author Nils Henrich
// # @brief Algorithms for hash file: creating, loading
//          Hash file format:
//          <some general header lines>
//
//          <absolute view path (or distinctive text for single files)>
//          abcde,md5,"top-file"
//          abcde,sha1,"top-folder/sub-file"
// # @version 0.0.0+1
// # @date 2023-06-16
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

import 'dart:io';
import 'package:file_tree_hasher/definies/datatypes.dart';
import 'package:file_tree_hasher/definies/info.dart';
import 'package:file_tree_hasher/functions/general.dart';

// ##################################################
// @brief: Generate hash file from given file paths and hashes
// @param: fileviewhashes
// @param: storagepath
// @param: override
// ##################################################
void generateHashfile(C_FileViewHashes fileviewhashes, String storagepath, {bool override = true, int level = 0}) {
  // Get file socket
  File filesocket = File(storagepath);

  // If file shall be overridded, just recreate it with information header
  if (override) {
    filesocket.writeAsStringSync("$hashFileHeader\n\n");
  }

  // Loop over all view elements
  // - For a file, add entry to hash file
  // - For a folder, recurse on folder
  for (C_FileViewHashes folder in fileviewhashes.folders) {
    generateHashfile(folder, storagepath, override: false, level: level + 1);
  }
  for (C_FileHashPair file in fileviewhashes.files) {
    String newLine = "";
    newLine += file.hash ?? "<no hash>";
    newLine += ",";
    newLine += file.algorithm.name;
    newLine += ",\"";
    newLine += getRawString(file.file);
    newLine += "\"\n";
    filesocket.writeAsStringSync(newLine, mode: FileMode.append);
  }
}
