// ####################################################################################################
// # @file general.dart
// # @author Nils Henrich
// # @brief Collection of general functions and algorithms
// # @version 2.0.1+3
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
  // ---------- Home path depends on operating system ----------

  // Linux
  if (Platform.isLinux) {
    String username = Platform.environment["USER"]!;
    return Directory("/home/$username/");
  }

  // Windows
  if (Platform.isWindows) {
    String userhome = Platform.environment["USERPROFILE"]!;
    return Directory("$userhome\\");
  }

  // macOS
  if (Platform.isMacOS) {
    String home = Platform.environment["HOME"]!;
    return Directory("$home/");
  }

  // Unknown OS -> Throw error
  throw UnimplementedError("A home directory is only defined for OS Windows, Linux or MAC, but current OS is ${Platform.operatingSystem}");
}

// ##################################################
// @brief: Get parent path of given file
//         A valid path always end with a slash
//         If no parent path exists, an empty string is returned
// @param: path
// @return: String
// ##################################################
String GetParentPath(String path, {bool trailingSlash = false}) {
  String parent = libpath.dirname(path);

  // Raltive path without directory
  if (parent == ".") return "";

  // Absolute path without directory
  if (parent == "/") return "";
  if (RegExp(r"^[A-Za-z]:\\$").hasMatch(parent)) return "";

  // Add trailing slash
  if (trailingSlash) parent = "$parent/";

  return parent;
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
