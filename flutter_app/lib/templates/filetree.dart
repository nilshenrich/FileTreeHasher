// ####################################################################################################
// # @file filetree.dart
// # @author Nils Henrich
// # @brief Build file tree from system path and provide hash generating and checking
// # @version 1.0.1+4
// # @date 2023-12-07
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:file_tree_hasher/definies/styles.dart';
import 'package:file_tree_hasher/functions/general.dart';
import 'package:file_tree_hasher/templates/hashselector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

// ##################################################
// # TEMPLATE
// # File tree item to be shown in file tree
// ##################################################
abstract class T_FileTree_Item extends StatefulWidget {
  // Parameter
  final String name; // Elements name (to be shown in GUI)
  final String path; // Elements absolute system path (used for hash generation and shown in tree header)
  final String parent; // Elements parents absolute system path

  // Constructor
  T_FileTree_Item({super.key, required this.path, required showFullPath})
      : name = GetFileName(path),
        parent = showFullPath ? GetParentPath(path) : "";
}

// ##################################################
// # ITEM
// # Folder item
// ##################################################
// TODO: Make InheritedWidget, so all children can be updated on change
class I_FileTree_Folder extends T_FileTree_Item {
  // Constructor
  I_FileTree_Folder({super.key, required super.path, super.showFullPath = false});

  // Style parameter
  final bool _param_showIcon = true;
  final TextStyle _param_textStyle_parent = Style_FileTree_Item_Text_Parent;
  final TextStyle _param_textStyle_name = Style_FileTree_Item_Text_Name;
  final Color _param_color_header = Style_FileTree_Item_Color;
  final EdgeInsets _param_padding = Style_FileTree_Item_Padding;

  @override
  State<StatefulWidget> createState() => I_FileTree_Folder_state();
}

// ##################################################
// # STATE
// # Folder item
// ##################################################
class I_FileTree_Folder_state extends State<I_FileTree_Folder> with SingleTickerProviderStateMixin {
  // State parameter
  bool expanded = true; // Is folder expanded
  List<T_FileTree_Item> children = []; // Direct child items to be shown in tree
  StreamController<T_FileTree_Item> s_children = StreamController(); // Stream to add a child item with live update

  // Toggle animation
  Duration _duration = Duration(milliseconds: 250);
  Icon _iconToggle = Icon(Icons.expand_more);
  late AnimationController _animationcontroller;
  late Animation<double> _animation_expand;
  late Animation<double> _animation_iconturn;

  @override
  Widget build(BuildContext context) {
    // ---------- Header row ----------
    Widget areaHeader_clickable = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          expanded ? _animationcontroller.reverse() : _animationcontroller.forward();
          setState(() {
            expanded = !expanded;
          });
        },
        child: Row(
          children: [
            RotationTransition(
              turns: _animation_iconturn,
              child: _iconToggle,
            ),
            widget._param_showIcon ? Icon(Icons.folder) : SizedBox.shrink(),
            Text(widget.parent, style: widget._param_textStyle_parent),
            Text(widget.name, style: widget._param_textStyle_name),
          ],
        ),
      ),
    );
    Widget areaHeader_unclickable = Container(
      child: Row(
        children: [
          T_FileHashSelector(),
          SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
          SizedBox(width: Style_FileTree_ComparisonInput_Width_px),
        ],
      ),
    );
    Widget areaHeader = Container(
      padding: widget._param_padding,
      color: widget._param_color_header,
      child: Row(
        children: [Expanded(child: areaHeader_clickable), areaHeader_unclickable],
      ),
    );

    // ---------- Content column ----------
    Padding areaContent = Padding(
      padding: EdgeInsets.fromLTRB(Style_FileTree_SubItem_ShiftRight_px, 0, 0, 0),
      child: Column(children: children),
    );

    // ---------- Expandable ----------
    return Column(
      children: [
        areaHeader,
        SizeTransition(
          sizeFactor: _animation_expand,
          axisAlignment: -1,
          child: areaContent,
        )
      ],
    );
  }

  @override
  void initState() {
    // ---------- Add event listener to be triggered when adding a new child item ----------
    s_children.stream.listen((item) {
      setState(() {
        children.add(item);
      });
    });

    // ---------- Call base method as usual ----------
    super.initState();

    // ---------- Initialize toggle animation ----------
    _animationcontroller = AnimationController(vsync: this, duration: _duration);
    _animation_expand = _animationcontroller.drive(CurveTween(curve: Curves.easeIn));
    _animation_iconturn = _animationcontroller.drive(Tween<double>(begin: 0, end: -0.25).chain(CurveTween(curve: Curves.easeIn)));
    if (expanded) _animationcontroller.value = 1;

    // ---------- Load all direct children items from system ----------
    loadChildren();
  }

  // ##################################################
  // @brief: Load child items from system path
  // ##################################################
  void loadChildren() async {
    Directory systemDir = Directory(widget.path);
    Stream<FileSystemEntity> systemItems = systemDir.list();
    await for (FileSystemEntity sysItem in systemItems) {
      T_FileTree_Item item;

      // ---------- Item is a file ----------
      if (sysItem is File) {
        item = I_FileTree_File(
          path: sysItem.path,
          showFullPath: false,
        );
      }

      // ---------- Item is a folder ----------
      else if (sysItem is Directory) {
        item = I_FileTree_Folder(path: sysItem.path);
      }

      // ---------- Item is none of these ----------
      else {
        continue;
      }

      // ---------- Trigger stram listener to add new item as sub-item ----------
      if (!s_children.isClosed) s_children.sink.addStream(Stream.value(item));
      // await Future.delayed(Duration(seconds: 1)); // DEV: To simulate calculation time
      await Future.delayed(Duration.zero); // Use await to work consecutively on items
    }
  }
}

// ##################################################
// # ITEM
// # File tree head (differently designed folder under the hood)
// ##################################################
class I_FileTree_Head extends I_FileTree_Folder {
  // Constructor
  I_FileTree_Head({super.key, required super.path, super.showFullPath = true});

  // Style parameter
  @override
  bool get _param_showIcon => false;
  @override
  TextStyle get _param_textStyle_parent => Style_FileTree_Header_Text_Parent;
  @override
  TextStyle get _param_textStyle_name => Style_FileTree_Header_Text_Name;
  @override
  Color get _param_color_header => Style_FileTree_Header_Color;
  @override
  EdgeInsets get _param_padding => Style_FileTree_Header_Padding;
}

// ##################################################
// # ITEM
// # File item
// ##################################################
class I_FileTree_File extends T_FileTree_Item {
  // Constructor
  I_FileTree_File({super.key, required super.path, required super.showFullPath});

  @override
  State<StatefulWidget> createState() => I_FileTree_File_state();
}

// ##################################################
// # STATE
// # File item
// ##################################################
class I_FileTree_File_state extends State<I_FileTree_File> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.description),
        Text(widget.parent, style: Style_FileTree_Item_Text_Parent),
        Text(widget.name, style: Style_FileTree_Item_Text_Name),
        SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        Expanded(child: _buildHashGenerationView()),
        SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        T_FileHashSelector(),
        SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        _buildHashComparisonView()
      ],
    );
  }

  // ##################################################
  // @brief: Build hash generation view
  // @return: Widget
  // ##################################################
  Widget _buildHashGenerationView() {
    return Text("# TODO: Build hash generation view");
  }

  // ##################################################
  // @brief: Build hash comparison view
  // @return: Widget
  // ##################################################
  Widget _buildHashComparisonView() {
    return Text("# TODO: Build hash comparison view");
  }
}
