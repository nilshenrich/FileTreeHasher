// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class _DividerPart extends StatelessWidget {
  // Constructor
  const _DividerPart();

  @override
  Widget build(BuildContext context) {
    return const Expanded(child: Divider(color: Colors.black));
  }
}

class _TextPart extends StatelessWidget {
  final String text;

  // Constructor
  const _TextPart({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text);
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
        const _DividerPart(),
        _TextPart(text: text),
        const _DividerPart()
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
