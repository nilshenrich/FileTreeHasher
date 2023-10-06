// ####################################################################################################
// # @file defaults
// # @author Nils Henrich
// # @brief All globally defined default values are set here
// # @version 1.0.1+4
// # @date 2023-03-29
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:io';
import 'package:file_tree_hasher/definies/hashalgorithms.dart';

// ---------- Default hash algorithm ----------
// ---------- This algorithm is selected on startup ----------
const E_HashAlgorithms DefaultHashAlgorithm = E_HashAlgorithms.MD5;

// ---------- Currently selected global hash algorithm ----------
String? SelectedGlobalHashAlg = DefaultHashAlgorithm.value;

// ---------- Distinctive text for single files stored in hash file ----------
const String HashfileSingletext = "Single files";

// ---------- Platform dependent line ending character ----------
String get LineendingChar {
  // Linux
  if (Platform.isLinux) return "\n";
  // Windows
  if (Platform.isWindows) return "\r\n";
  // macOS (macOS X only)
  if (Platform.isMacOS) return "\n";
  // Unknown OS -> Throw error
  throw UnimplementedError("A home directory is only defined for OS Windows, Linux or macOS, but current OS is ${Platform.operatingSystem}");
}
