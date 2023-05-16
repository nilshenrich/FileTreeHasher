import 'dart:io';

import 'package:file_tree_hasher/templates/contentarea.dart';

// ##################################################
// @brief: Get home directory depending on plattform
// @return: Directory
// ##################################################
Directory getHomeDir() {
  Map<String, String> keywords = {
    "linux": "HOME",
    "macos": "HOME",
    "windows": "USERPROFILE",
    "android": "HOME"
  };

  return Directory(
      Platform.environment[keywords[Platform.operatingSystem]] ?? "");
}

String? getGlobalHashAlg() {
  return GlobalHashSelector.currentState!.get();
}
