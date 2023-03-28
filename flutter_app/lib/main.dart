import 'package:flutter/material.dart';

void main() {
  runApp(const FileTreeHasher());
}

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

class ControlHeader extends StatelessWidget {
  const ControlHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: Row(children: <Widget>[
      // -------------------- Row: File tree --------------------
      Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            // ---------- Section heading ----------
            Row(children: []),
            // ---------- Section buttons ----------
            Row(children: <Widget>[
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.drive_folder_upload),
                tooltip: "Load file tree",
              )
            ])
          ])),
      // -------------------- Row: Hash algorithm --------------------
      Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            // ---------- Section heading ----------
            Row(children: []),
            // ---------- Section buttons ----------
            Row(children: <Widget>[])
          ])),
      // -------------------- Row: Comparison --------------------
      Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            // ---------- Section heading ----------
            Row(children: []),
            // ---------- Section buttons ----------
            Row(children: <Widget>[])
          ]))
    ])));
  }
}
