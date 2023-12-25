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
import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:file_tree_hasher/definies/defaults.dart';
import 'package:file_tree_hasher/definies/hashalgorithms.dart';
import 'package:file_tree_hasher/definies/styles.dart';
import 'package:file_tree_hasher/functions/general.dart';
import 'package:file_tree_hasher/templates/contentarea.dart';
import 'package:file_tree_hasher/templates/hashselector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:percent_indicator/percent_indicator.dart';

// ##################################################
// # TEMPLATE
// # File tree item to be shown in file tree
// ##################################################
abstract class T_FileTree_Item extends StatefulWidget {
  // Parameter
  final String name; // Elements name (to be shown in GUI)
  final String path; // Elements absolute system path (used for hash generation and shown in tree header)
  final String parent; // Elements parents absolute system path

  // Status change: Parent stream
  Stream<C_HashAlg> s_hashAlg_stream; // Selected hash algorithm

  // Constructor
  T_FileTree_Item({super.key, required this.path, required Stream<C_HashAlg> stream_hashAlg, required showFullPath})
      : name = GetFileName(path),
        s_hashAlg_stream = stream_hashAlg,
        parent = showFullPath ? GetParentPath(path) : "";
}

// ##################################################
// # ITEM
// # Folder item
// ##################################################
class I_FileTree_Folder extends T_FileTree_Item {
  // Constructor
  I_FileTree_Folder({super.key, required super.path, required super.stream_hashAlg, super.showFullPath = false});

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
  List<S_FileTree_StreamControlled_Item> children = []; // Direct child items to be shown in tree
  StreamController<FileSystemEntity> s_children = StreamController(); // Stream to add a child item with live update

  // Hash algorithm selector key
  GlobalKey<T_HashSelector_state> globalkey_hashAlgSel = GlobalKey();

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
            SizedBox(
              width: Style_FileTree_Item_Expander_Width_px,
              child: RotationTransition(
                turns: _animation_iconturn,
                child: _iconToggle,
              ),
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
          T_FileHashSelector(
            key: globalkey_hashAlgSel,
            onChanged: (selected) {
              children.forEach((item) {
                item.send(C_HashAlg(selected));
              });
            },
          ),
          SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
          SizedBox(width: Style_FileTree_ComparisonInput_Width_px - widget._param_padding.right),
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
      child: Column(children: children.map((c) => c.item).toList()),
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
    s_children.stream.listen((sysItem) {
      T_FileTree_Item item;
      StreamController<C_HashAlg> controller = StreamController();

      // ---------- Item is a file ----------
      if (sysItem is File) {
        item = I_FileTree_File(path: sysItem.path, stream_hashAlg: controller.stream, showFullPath: false);
      }

      // ---------- Item is a folder ----------
      else if (sysItem is Directory) {
        item = I_FileTree_Folder(path: sysItem.path, stream_hashAlg: controller.stream);
      }

      // ---------- Item is none of these ----------
      else {
        return;
      }

      setState(() {
        children.add(S_FileTree_StreamControlled_Item(item: item, controllers: [controller]));
      });
    });
    widget.s_hashAlg_stream?.listen((hash) {
      globalkey_hashAlgSel.currentState!.set(hash.value);
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
    // await for (FileSystemEntity sysItem in systemItems) {
    systemItems.forEach((sysItem) {
      s_children.add(sysItem);
    });
  }
}

// ##################################################
// # ITEM
// # File tree head (differently designed folder under the hood)
// ##################################################
class I_FileTree_Head extends I_FileTree_Folder {
  // Constructor
  I_FileTree_Head({super.key, required super.path, required super.stream_hashAlg, super.showFullPath = true});

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
  I_FileTree_File({super.key, required super.path, required super.stream_hashAlg, required super.showFullPath});

  @override
  State<StatefulWidget> createState() => I_FileTree_File_state();
}

// ##################################################
// # STATE
// # File item
// ##################################################
class I_FileTree_File_state extends State<I_FileTree_File> {
  // State parameter
  String _hashComp = "";
  String? _hashGen; // Generated hash
  double _hashGenProgress = 0; // Hash generation progress (0-1)
  StreamController<double> _s_hashGenProgress = StreamController(); // Stream to update live progress
  bool _hashOngoing = false; // Hash generation ongoing? (Used for abortion)

  // Hash algorithm selector key
  GlobalKey<T_HashSelector_state> globalkey_hashAlgSel = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: Style_FileTree_Item_Expander_Width_px),
        const Icon(Icons.description),
        Text(widget.parent, style: Style_FileTree_Item_Text_Parent),
        Text(widget.name, style: Style_FileTree_Item_Text_Name),
        SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        Expanded(child: _buildHashGenerationView(context)),
        SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        T_FileHashSelector(key: globalkey_hashAlgSel),
        SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        _buildHashComparisonView()
      ],
    );
  }

  // ##################################################
  // @brief: Build hash generation view
  // @param: context
  // @return: Widget
  // ##################################################
  Widget _buildHashGenerationView(BuildContext context) {
    if (_hashGen == null) {
      return LinearPercentIndicator(
        percent: _hashGenProgress,
        lineHeight: Style_FileTree_HashGen_Prg_Height_px,
        center: Text("${(_hashGenProgress * 100).toStringAsFixed(1)}%", style: Style_FileTree_HashGen_Prg_Text),
        progressColor: Style_FileTree_HashGen_Prg_Color,
      );
    }
    return Row(
      children: [
        Flexible(
            child: Container(
          child: Text(_hashGen!, style: Style_FileTree_HashGen_Text),
        )),
        SizedBox(
            height: Style_FileTree_HashSelector_FontSize_px,
            child: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _hashGen!));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
                },
                iconSize: Style_FileTree_HashSelector_FontSize_px,
                padding: EdgeInsets.zero,
                color: Style_FileTree_HashGen_Text.color,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: const Icon(Icons.copy))),
      ],
    );
  }

  // ##################################################
  // @brief: Build hash comparison view
  // @return: Widget
  // ##################################################
  Widget _buildHashComparisonView() {
    return SizedBox(
      width: Style_FileTree_ComparisonInput_Width_px,
      height: Style_FileTree_ComparisonInput_Height_px,
      child: TextField(
        style: Style_FileTree_ComparisonInput_Text,
        decoration: Style_FileTree_ComparisonInput_Decoration,
        controller: TextEditingController(text: _hashComp),
      ),
    );
  }

  @override
  void initState() {
    // ---------- Add event listener to be triggered when updating progress ----------
    _s_hashGenProgress.stream.listen((prog) {
      setState(() {
        _hashGenProgress = prog;
      });
    });
    widget.s_hashAlg_stream?.listen((hash) {
      globalkey_hashAlgSel.currentState!.set(hash.value);
    });
    Controller_ComparisonInput.stream.listen((input) {
      if (input.itempath == null || input.itempath == widget.path) {
        if (input.hashAlg != null) globalkey_hashAlgSel.currentState!.set(input.hashAlg);
        setState(() {
          if (input.compInput != null) _hashComp = input.compInput!;
        });
      }
    });

    // ---------- Call base method as usual ----------
    super.initState();

    // ---------- Start generating hash ----------
    generateHash(SelectedGlobalHashAlg);
  }

  // ##################################################
  // @brief: Generate hash and update progress bar
  // @param: alg
  // ##################################################
  void generateHash(String? alg) async {
    // -------------------- Open file read stream --------------------

    // Check if file exists
    File file = File(widget.path);
    if (!file.existsSync()) {
      setState(() {
        _hashGen = "<Can't find file in file system>";
        _hashGenProgress = 0;
      });
      return;
    }

    // Reset any old status
    // TODO: Reset _hashGen as well
    _s_hashGenProgress.add(0);

    // File size and processed size for progress calculation
    int totalBytes = file.lengthSync();
    int bytesRead = 0;

    // -------------------- Choose hash generator --------------------

    // Select hash algorithm
    var hashOut = AccumulatorSink<Digest>();
    ByteConversionSink hasher;
    if (alg == E_HashAlgorithms.MD5.value) {
      hasher = md5.startChunkedConversion(hashOut);
    } else if (alg == E_HashAlgorithms.SHA1.value) {
      hasher = sha1.startChunkedConversion(hashOut);
    } else if (alg == E_HashAlgorithms.SHA256.value) {
      hasher = sha256.startChunkedConversion(hashOut);
    } else if (alg == E_HashAlgorithms.SHA384.value) {
      hasher = sha384.startChunkedConversion(hashOut);
    } else if (alg == E_HashAlgorithms.SHA512.value) {
      hasher = sha512.startChunkedConversion(hashOut);
    } else if (alg == E_HashAlgorithms.NONE.value) {
      setState(() {
        _hashGen = "<No hash to create>";
      });
      return;
    } else {
      setState(() {
        _hashGen = "<Can't use hash algorithm '$alg'>";
      });
      return;
    }

    // -------------------- Generate hash block wise --------------------
    _hashOngoing = true;

    // Read file step by step and generate hash
    await for (var chunk in file.openRead()) {
      // Abort process here if flag is unset
      if (!_hashOngoing) {
        return;
      }

      // Generate hash for next file part
      bytesRead += chunk.length;
      hasher.add(chunk);

      // Update progress bar
      _s_hashGenProgress.add(bytesRead / totalBytes);
    }

    _hashOngoing = false;

    // -------------------- Done --------------------

    // Extract hash string
    hasher.close();
    String hashString = hashOut.events.single.toString();

    setState(() {
      _hashGen = hashString;
    });
  }

  // ##################################################
  // @brief: Abort current hash generation
  // ##################################################
  void abortHashGeneration() {
    // Unset flag to mark abortion
    _hashOngoing = false;

    // Reset hash generation view
    setState(() {
      _hashGen = "<aborted>";
    });
  }
}

// ##################################################
// # STRUCT
// # Stream controlled item
// ##################################################
class S_FileTree_StreamControlled_Item {
  // Private attributes
  final T_FileTree_Item _item;
  final List<StreamController> _controllers;

  // Constructor
  S_FileTree_StreamControlled_Item({required T_FileTree_Item item, required List<StreamController> controllers})
      : _item = item,
        _controllers = controllers;

  // Getter
  T_FileTree_Item get item => _item;
  // StreamController get controller => _controller;
  // Stream get stream => _controller.stream;

  // Stream setter
  void send<T>(T e) {
    for (StreamController controller in _controllers) {
      if (controller is StreamController<T>) {
        controller.add(e);
      }
    }
  }
}

// ##################################################
// # TYPE
// # Explicit types to be used in stream controllers to identify
// ##################################################
class C_HashAlg {
  String? _value;
  C_HashAlg(String? value) : _value = value;
  String? get value => _value;
}
