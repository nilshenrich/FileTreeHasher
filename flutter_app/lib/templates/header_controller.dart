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
