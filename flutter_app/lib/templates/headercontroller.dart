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

// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

// ##################################################
// # TEMPLATE
// # Control section in header bar
// # This section is made of an overall heading and some items aranged horizontally
// ##################################################
class T_HeaderControlSection extends StatelessWidget {
  final String headingText;
  final List<Widget> items;

  const T_HeaderControlSection({
    super.key,
    required this.headingText,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // ---------- Section heading ----------
          Text(headingText, style: const TextStyle(fontSize: 22)),
          const Divider(
              thickness: 1.0,
              color: Colors.black,
              indent: 10.0,
              endIndent: 10.0),
          // ---------- Section buttons ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items,
          ),
        ],
      ),
    );
  }
}
