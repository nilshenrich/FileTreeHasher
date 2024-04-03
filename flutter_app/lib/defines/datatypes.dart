// ####################################################################################################
// # @file datatypes.dart
// # @author Nils Henrich
// # @brief Definition of useful datatypes usable in entire project
// # @version 2.0.0+2
// # @date 2023-05-15
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: camel_case_types

// ##################################################
// # Hash comparison result
// ##################################################
enum E_HashComparisonResult {
  none, // Hash generation completed: No comparison
  queued, // Hash to be generated but not started
  busy, // Hash being generated
  equal, // Hash generation completed: hash match
  notEqual, // Hash generation completed: hash differ
}

// ##################################################
// # Assignment file and hash string
// ##################################################
class C_FileHashPair {
  final String _file; // File name or path
  final String? _hash; // Generated hash
  final String _algorithm; // Hash algorithm

  // Constructor
  C_FileHashPair(String file, String? hash, String algorithm)
      : _file = file,
        _hash = hash,
        _algorithm = algorithm;

  // Getter for file and hash
  String get file {
    return _file;
  }

  String? get hash {
    return _hash;
  }

  String get algorithm {
    return _algorithm;
  }
}

// ##################################################
// # Chosen storage paths for hash files
// ##################################################
class C_HashfileStoragepaths {
  // Attributes
  final List<String> _fileTreePaths = []; // Storage paths for all loaded file trees
  String _singleFilesPath = ""; // Storage path for single files

  // Constructor
  C_HashfileStoragepaths();

  // ##################################################
  // @brief: Getters/Setters
  // @return: Map/String
  // ##################################################
  List<String> getTrees() {
    return _fileTreePaths;
  }

  String getSingle() {
    return _singleFilesPath;
  }

  // ##################################################
  // @brief: Add or set items
  // @param: fileTreePath/singleFilesPath
  // ##################################################
  void addTree(String fileTreePath) {
    _fileTreePaths.add(fileTreePath);
  }

  void setSingle(String singleFilesPath) {
    _singleFilesPath = singleFilesPath;
  }
}

// ##################################################
// # Files and hashes for a view section
// ##################################################
class C_FileViewHashes {
  final String _name; // Name of this view
  final List<C_FileHashPair> _files; //Top level files with corresponding hashes
  final List<C_FileViewHashes> _folders; // Subfolders that can contain files and subfolders

  // Constructor
  C_FileViewHashes(String name, List<C_FileHashPair>? files, List<C_FileViewHashes>? folders)
      : _name = name,
        _files = files ?? [],
        _folders = folders ?? [];

  // Getter for files and folders
  String get name {
    return _name;
  }

  List<C_FileHashPair> get files {
    return _files;
  }

  List<C_FileViewHashes> get folders {
    return _folders;
  }
}
