// ####################################################################################################
// # @file hashselector.dart
// # @author Nils Henrich
// # @brief Template for hash selection drop-down menu.
// #        Globally in header bar or special in file tree
// # @version 0.0.0+1
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
import 'package:file_tree_hasher/definies/defaults.dart';
import 'package:file_tree_hasher/definies/hashalgorithms.dart';
import 'package:flutter/material.dart';

abstract class T_HashSelector extends StatefulWidget {
  // Sizing
  final double height;
  final double fontSize;

  // Function call on changed
  final Function(String?)? onChanged;

  // Global key to access state
  final GlobalKey<T_HashSelector_state> key;

  // Constructor
  const T_HashSelector(
      {required this.key, this.height = 48, this.fontSize = 16, this.onChanged})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => T_HashSelector_state();
}

// ##################################################
// # STATE
// # Overall hash selector state
// ##################################################
class T_HashSelector_state extends State<T_HashSelector> {
  // Currently selected hash algorithm
  String? _selected = DefaultHashAlgorithm.name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.height,
        child: DropdownButton(
            value: _selected,
            style: TextStyle(fontSize: widget.fontSize, color: Colors.black),
            items: getAllHashAlgorithmNames()
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: updateSelected));
  }

  void updateSelected(String? selected) {
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
  const T_GlobalHashSelector(
      {required super.key, super.height, super.fontSize, super.onChanged});
}

// ##################################################
// # TEMPLATE
// # File tree item hash selector
// ##################################################
class T_FileHashSelector extends T_HashSelector {
  const T_FileHashSelector(
      {required super.key, super.height, super.fontSize, super.onChanged});
}
