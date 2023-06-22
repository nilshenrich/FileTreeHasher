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

// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:file_tree_hasher/definies/datatypes.dart';
import 'package:file_tree_hasher/definies/info.dart';
import 'package:file_tree_hasher/functions/general.dart';
import 'package:file_tree_hasher/templates/filetree.dart';

// ##################################################
// @brief: Generate hash file from given file paths and hashes
// @param: fileviewhashes
// @param: storagepath
// @param: override
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
    String newLine = "";
    newLine += file.hash ?? "<no hash>";
    newLine += ",";
    newLine += file.algorithm;
    newLine += ",\"";
    newLine += GetRawString(file.file);
    newLine += "\"\n";
    filesocket.writeAsStringSync(newLine, mode: FileMode.writeOnlyAppend);
  }
}

// ##################################################
// @brief: Transform a given list of file tree items into a C_FileViewHashes
// @param: items
// @param: name
// @return: C_FileViewHashes
// ##################################################
// TODO: Implement
C_FileViewHashes FileTreeItems_to_FileViewHashes(List<T_FileTreeItem> items, String name) {
  List<C_FileViewHashes> folders = [];
  List<C_FileHashPair> files = [];
  for (T_FileTreeItem item in items) {
    if (item is T_FolderView) {
      folders.add(FileTreeItems_to_FileViewHashes(item.subitems, item.path));
    } else if (item is T_FileView) {
      files.add(C_FileHashPair(item.path, item.globKey_HashGenerationView.currentState!.HashGen, item.globKey_HashAlgorithm.currentState!.get()!));
    }
  }
  return C_FileViewHashes(name, files, folders);
}

// ##################################################
// @brief: Transform a given list of single files into a C_FileViewHashes
// @param: files
// @param: name
// @return: C_FileViewHashes
// ##################################################
C_FileViewHashes SingleFiles_to_FileViewHashes(List<T_FileView> fileViews, String name) {
  List<C_FileHashPair> files = [];
  for (T_FileView file in fileViews) {
    files.add(C_FileHashPair(file.path, file.globKey_HashGenerationView.currentState!.HashGen, file.globKey_HashAlgorithm.currentState!.get()!));
  }
  return C_FileViewHashes(name, files, []);
}
