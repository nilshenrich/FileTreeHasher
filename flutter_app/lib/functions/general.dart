import 'dart:io';

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
