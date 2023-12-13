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
// # @version 1.0.1+4
// # @date 2023-06-16
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_tree_hasher/definies/datatypes.dart';
import 'package:file_tree_hasher/definies/defaults.dart';
import 'package:file_tree_hasher/definies/hashalgorithms.dart';
import 'package:file_tree_hasher/definies/info.dart';
import 'package:file_tree_hasher/functions/general.dart';
import 'package:file_tree_hasher/templates/filetree.dart';
import 'package:path/path.dart' as libpath;

// ##################################################
// @brief: Generate hash file from given file paths and hashes
// @param: fileviewhashes
// @param: storagepath
// @param: [override]
// @param: [level]
// ##################################################
void GenerateHashfile(C_FileViewHashes fileviewhashes, String storagepath, {bool override = true, int level = 0}) {
  // Get file socket
  File filesocket = File(storagepath);

  // If file shall be overridded, just recreate it with information header
  if (override) {
    filesocket.writeAsStringSync("$HashFileHeader\n\n${fileviewhashes.name}\n", mode: FileMode.writeOnly);
  }

  // Loop over all view elements
  // - For a file, add entry to hash file
  // - For a folder, recurse on folder
  for (C_FileViewHashes folder in fileviewhashes.folders) {
    GenerateHashfile(folder, storagepath, override: false, level: level + 1);
  }
  for (C_FileHashPair file in fileviewhashes.files) {
    // If no hash algorithm is selected, skip this file
    if (file.algorithm == E_HashAlgorithms.NONE.value) continue;

    String newLine = "";
    newLine += file.hash ?? "<no hash>";
    newLine += ",";
    newLine += file.algorithm;
    newLine += ",\"";
    newLine += GetRawString(file.file);
    newLine += "\"$LineendingChar";
    filesocket.writeAsStringSync(newLine, mode: FileMode.writeOnlyAppend);
  }
}

// ##################################################
// @brief: Transform a given list of file tree items into a C_FileViewHashes
// @param: items
// @param: name
// @return: C_FileViewHashes
// ##################################################
C_FileViewHashes FileTreeItems_to_FileViewHashes(List<T_FileTree_Item> items, String name, String rootpath) {
  List<C_FileViewHashes> folders = [];
  List<C_FileHashPair> files = [];
  // TODO: Obsolete for new structure
  // for (T_TreeItem item in items) {
  //   String relpath = libpath.relative(item.path, from: rootpath);
  //   if (item is T_FolderItem) {
  //     folders.add(FileTreeItems_to_FileViewHashes(item.children, item.path, rootpath));
  //   } else if (item is T_FileItem) {
  //     files.add(C_FileHashPair(relpath, item.globKey_HashGenerationView.currentState!.HashGen, item.globKey_HashAlgorithm.currentState!.get()!));
  //   }
  // }
  return C_FileViewHashes(name, files, folders);
}

// ##################################################
// @brief: Transform a given list of single files into a C_FileViewHashes
// @param: files
// @param: name
// @return: C_FileViewHashes
// ##################################################
C_FileViewHashes SingleFiles_to_FileViewHashes(List<T_FileTree_Item> fileViews, String name) {
  List<C_FileHashPair> files = [];
  // TODO: Obsolete for new structure
  // for (T_FileItem file in fileViews) {
  //   files.add(C_FileHashPair(file.path, file.globKey_HashGenerationView.currentState!.HashGen, file.globKey_HashAlgorithm.currentState!.get()!));
  // }
  return C_FileViewHashes(name, files, []);
}
