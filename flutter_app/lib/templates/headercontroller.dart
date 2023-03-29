// ####################################################################################################
// # @file headercontroller.dart
// # @author Nils Henrich
// # @brief Template for general control section sitting in the header bar
// # @version 0.0.0+1
// # @date 2023-03-29
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

import 'package:flutter/material.dart';
import 'package:file_tree_hasher/definies/hashalgorithms.dart';
import 'package:file_tree_hasher/definies/defaults.dart';

// ##################################################
// # TEMPLATE
// # Control section in header bar
// # This section is made of an overall heading and some items aranged horizontally
// ##################################################
class T_HeaderControlSection extends StatelessWidget {
  final String headingText;
  final List<Widget> items;

  const T_HeaderControlSection({
    Key? key,
    required this.headingText,
    this.items = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // ---------- Section heading ----------
          Text(headingText),
          const Divider(
              thickness: 1.0,
              color: Colors.black,
              indent: 10.0,
              endIndent: 10.0),
          // ---------- Section buttons ----------
          Row(
            children: items,
          ),
        ],
      ),
    );
  }
}

// ##################################################
// # Global hash algorithm selector
// # This widget is defined seperately as it requires a state
// ##################################################
class GlobalHashSelector extends StatefulWidget {
  const GlobalHashSelector({super.key});

  @override
  State<StatefulWidget> createState() => _GlobalHashSelector();
}

// State for hash selector dropdown
class _GlobalHashSelector extends State<GlobalHashSelector> {
  // Currently selected hash algorithm
  String? _selected = DefaultHashAlgorithm.name;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        value: _selected,
        items: getAllHashAlgorithmNames()
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (selected) {
          setState(() {
            _selected = selected;
          });
        });
  }
}
