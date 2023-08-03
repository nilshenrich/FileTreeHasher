// ####################################################################################################
// # @file main.dart
// # @author Nils Henrich
// # @brief App entry point
// # @version 0.0.0+2
// # @date 2023-03-19
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

import 'package:flutter/material.dart';
import 'package:file_tree_hasher/templates/contentarea.dart';

void main() {
  runApp(const FileTreeHasher());
}

// ##################################################
// # Actual entry point to app
// ##################################################
class FileTreeHasher extends StatelessWidget {
  const FileTreeHasher({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'File Tree Hasher',
      home: ControlHeader(),
    );
  }
}

// ##################################################
// # App bar
// # A header bar with global controls:
// #  1. Load/clear file tree
// #  2. Select global hash algorithm
// #  3. Compare generated hashes, create/load checksum file
// ##################################################
class ControlHeader extends StatelessWidget {
  const ControlHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const T_HeaderBar(), body: SingleChildScrollView(child: T_BodyContent(key: BodyContent)));
  }
}
