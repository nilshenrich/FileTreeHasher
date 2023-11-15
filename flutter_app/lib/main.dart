// ####################################################################################################
// # @file main.dart
// # @author Nils Henrich
// # @brief App entry point
// # @version 1.0.1+4
// # @date 2023-03-19
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

import 'package:file_tree_hasher/templates/filetree.dart';
import 'package:flutter/material.dart';
import 'package:file_tree_hasher/templates/contentarea.dart';
import 'package:provider/provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => P_FileTrees()),
        ChangeNotifierProvider(create: (context) => P_SingleFiles()),
      ],
      child: const MaterialApp(
        restorationScopeId: 'app',
        title: 'File Tree Hasher',
        home: ControlHeader(),
      ),
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
