// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class _DividerPart extends StatelessWidget {
  // Constructor
  const _DividerPart();

  @override
  Widget build(BuildContext context) {
    return const Expanded(child: Divider(color: Colors.black, thickness: 1));
  }
}

class _TextPart extends StatelessWidget {
  final String text;

  // Constructor
  const _TextPart({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 18));
  }
}

abstract class _ContentDivider extends StatelessWidget {
  final String text;

  // Constructor
  const _ContentDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 10),
      Row(children: [
        const SizedBox(width: 10), // Space to the left
        const _DividerPart(), // Left divider line part
        const SizedBox(width: 10), // Text space to the left
        _TextPart(text: text), // Divider text
        const SizedBox(width: 10), // Text space to the right
        const _DividerPart(), // Right divider line part
        const SizedBox(width: 10) // Space to the right
      ]),
      const SizedBox(height: 5)
    ]);
  }
}

class ContentDivider_folders extends _ContentDivider {
  // Constructor
  const ContentDivider_folders({super.key}) : super(text: "Loaded folders");
}

class ContentDivider_files extends _ContentDivider {
  // Constructor
  const ContentDivider_files({super.key}) : super(text: "Loaded single files");
}
