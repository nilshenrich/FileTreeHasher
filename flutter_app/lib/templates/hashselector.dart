// ####################################################################################################
// # @file hashselector.dart
// # @author Nils Henrich
// # @brief Template for hash selection drop-down menu.
// #        Globally in header bar or special in file tree
// # @version 1.0.1+4
// # @date 2023-04-03
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: camel_case_types

// ##################################################
// # TEMPLATE
// # Overall hash selector
// ##################################################
import 'package:file_tree_hasher/defines/defaults.dart';
import 'package:file_tree_hasher/defines/hashalgorithms.dart';
import 'package:file_tree_hasher/defines/styles.dart';
import 'package:flutter/material.dart';

abstract class T_HashSelector extends StatefulWidget {
  // Sizing
  final double height;
  final double fontSize;

  // Function call on changed
  final Function(String?)? onChanged;

  // Constructor
  const T_HashSelector({super.key, required this.height, required this.fontSize, this.onChanged});

  @override
  State<StatefulWidget> createState() => T_HashSelector_state();
}

// ##################################################
// # STATE
// # Overall hash selector state
// ##################################################
class T_HashSelector_state extends State<T_HashSelector> {
  // Currently selected hash algorithm
  String? _selected = SelectedGlobalHashAlg;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.height,
        child: DropdownButton(
            value: _selected,
            style: TextStyle(fontSize: widget.fontSize, color: Colors.black),
            items: GetAllHashAlgorithmNames().map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: set));
  }

  // ##################################################
  // @brief: Getter/Setter
  // ##################################################
  String? get() {
    return _selected;
  }

  void set(String? selected) {
    if (selected == _selected) return;
    setState(() {
      _selected = selected;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(selected);
    }
  }
}

// ##################################################
// # TEMPLATE
// # Global hash selector
// ##################################################
class T_GlobalHashSelector extends T_HashSelector {
  const T_GlobalHashSelector({super.key, super.onChanged}) : super(height: 48, fontSize: 16);
}

// ##################################################
// # TEMPLATE
// # File tree item hash selector
// ##################################################
class T_FileHashSelector extends T_HashSelector {
  const T_FileHashSelector({super.key, super.onChanged})
      : super(height: Style_FileTree_HashSelector_Height_px, fontSize: Style_FileTree_HashSelector_FontSize_px);
}
