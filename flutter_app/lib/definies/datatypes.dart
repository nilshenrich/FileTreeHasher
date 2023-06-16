// ####################################################################################################
// # @file datatypes.dart
// # @author Nils Henrich
// # @brief Definition of useful datatypes usable in entire project
// # @version 0.0.0+1
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
  none, // No comparison
  equal, // Generated hash and comparison hash match
  notEqual, // Generated hash and comparison hash differ
}

// ##################################################
// # Chosen storage paths for hash files
// ##################################################
class C_HashfileStoragepaths {
  // Attributes
  List<String> _fileTreePaths = []; // Storage paths for all loaded file trees
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
