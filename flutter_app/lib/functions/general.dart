// ####################################################################################################
// # @file general.dart
// # @author Nils Henrich
// # @brief Collection of general functions and algorithms
// # @version 0.0.0+1
// # @date 2023-04-22
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:path/path.dart' as libpath;

// ##################################################
// @brief: Get home directory depending on plattform
// @return: Directory
// ##################################################
Directory GetHomeDir() {
  Map<String, String> keywords = {"linux": "HOME", "macos": "HOME", "windows": "USERPROFILE", "android": "HOME"};

  return Directory(Platform.environment[keywords[Platform.operatingSystem]] ?? "");
}

// ##################################################
// @brief: Get parent path of given file
//         A valid path always end with a slash
//         If no parent path exists, an empty string is returned
// @param: path
// @return: String
// ##################################################
String GetParentPath(String path) {
  String parent = libpath.dirname(path);

  // Raltive path without directory
  if (parent == ".") return "";

  // Absolute path without directory
  if (parent == "/") return "";
  if (RegExp(r"^[A-Za-z]:\\$").hasMatch(parent)) return "";

  // Add trailing slash
  return "$parent/";
}

// ##################################################
// @brief: Get file name from file path
// @param: path
// @return: String
// ##################################################
String GetFileName(String path) {
  return libpath.basename(path);
}

// ##################################################
// @brief: Convert string to raw string
//         All escape sequences will be replaced by their ASCII code
// @param: in
// @return: String
// ##################################################
String GetRawString(String s) {
  return s.replaceAll('"', '\\"').replaceAll("'", "\\'").replaceAll("\\", "\\\\").replaceAll("\n", "\\n");
}
