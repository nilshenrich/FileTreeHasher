// ####################################################################################################
// # @file filetree.dart
// # @author Nils Henrich
// # @brief Build file tree from system path and provide hash generating and checking
// # @version 2.0.0+2
// # @date 2023-12-07
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_tree_hasher/defines/datatypes.dart';
import 'package:path/path.dart' as libpath;

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:file_tree_hasher/defines/defaults.dart';
import 'package:file_tree_hasher/defines/hashalgorithms.dart';
import 'package:file_tree_hasher/defines/styles.dart';
import 'package:file_tree_hasher/functions/general.dart';
import 'package:file_tree_hasher/templates/contentarea.dart';
import 'package:file_tree_hasher/templates/hashselector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';

// ##################################################
// # TEMPLATE
// # File tree item to be shown in file tree
// ##################################################
abstract class T_FileTree_Item extends StatefulWidget {
  // Parameter
  final String name; // Elements name (to be shown in GUI)
  final String path; // Elements absolute system path (used for hash generation and shown in tree header)
  final String parent; // Elements parents absolute system path (With trailing slash)

  // Status change: Parent stream
  final Stream<C_HashAlg> s_hashAlg_stream; // Selected hash algorithm
  final Stream<C_HashFile_SavePath> s_hashFile_savePath_stream; // File path to save hash file to

  // Constructor
  T_FileTree_Item(
      {super.key,
      required this.path,
      required Stream<C_HashAlg> stream_hashAlg,
      required Stream<C_HashFile_SavePath> stream_hashFile_savePath,
      required showFullPath})
      : name = GetFileName(path),
        s_hashAlg_stream = stream_hashAlg,
        s_hashFile_savePath_stream = stream_hashFile_savePath,
        parent = showFullPath ? GetParentPath(path, trailingSlash: true) : "";
}

// ##################################################
// # ITEM
// # Folder item
// ##################################################
class I_FileTree_Folder extends T_FileTree_Item {
  // Constructor
  I_FileTree_Folder(
      {super.key, required super.path, required super.stream_hashAlg, required super.stream_hashFile_savePath, super.showFullPath = false});

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
  final Duration _duration = const Duration(milliseconds: 250);
  final Icon _iconToggle = const Icon(Icons.expand_more);
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
            widget._param_showIcon ? const Icon(Icons.folder) : const SizedBox.shrink(),
            Text(widget.parent, style: widget._param_textStyle_parent),
            Text(widget.name, style: widget._param_textStyle_name),
          ],
        ),
      ),
    );
    Widget areaHeader_unclickable = Row(
      children: [
        T_FileHashSelector(
          key: globalkey_hashAlgSel,
          onChanged: (selected) {
            for (var item in children) {
              item.send(C_HashAlg(selected));
            }
          },
        ),
        const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        SizedBox(width: Style_FileTree_ComparisonInput_Width_px - widget._param_padding.right),
      ],
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
      padding: const EdgeInsets.fromLTRB(Style_FileTree_SubItem_ShiftRight_px, 0, 0, 0),
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
      StreamController<C_HashAlg> controller_hashAlg = StreamController();
      StreamController<C_HashFile_SavePath> controller_hashFile_savePath = StreamController();

      // ---------- Item is a file ----------
      if (sysItem is File) {
        item = I_FileTree_File(
            path: sysItem.path,
            stream_hashAlg: controller_hashAlg.stream,
            stream_hashFile_savePath: controller_hashFile_savePath.stream,
            showFullPath: false);
      }

      // ---------- Item is a folder ----------
      else if (sysItem is Directory) {
        item = I_FileTree_Folder(
            path: sysItem.path, stream_hashAlg: controller_hashAlg.stream, stream_hashFile_savePath: controller_hashFile_savePath.stream);
      }

      // ---------- Item is none of these ----------
      else {
        return;
      }

      setState(() {
        children.add(S_FileTree_StreamControlled_Item(item: item, controllers: [controller_hashAlg, controller_hashFile_savePath]));
      });
    });
    widget.s_hashAlg_stream.listen((hash) {
      globalkey_hashAlgSel.currentState!.set(hash.value);
    });
    widget.s_hashFile_savePath_stream.listen((path) {
      for (S_FileTree_StreamControlled_Item child in children) {
        child.send(path);
      }
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
  I_FileTree_Head(
      {super.key, required super.path, required super.stream_hashAlg, required super.stream_hashFile_savePath, super.showFullPath = true});

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
  I_FileTree_File(
      {super.key, required super.path, required super.stream_hashAlg, required super.stream_hashFile_savePath, required super.showFullPath});

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
  int _hashComp_cursorPos = 0;
  E_HashComparisonResult _hashComparisonResult = E_HashComparisonResult.none;
  String? _hashGen; // Generated hash
  double _hashGenProgress = 0; // Hash generation progress (0-1)
  final StreamController<double> _s_hashGenProgress = StreamController(); // Stream to update live progress
  bool _hashOngoing = false; // Hash generation ongoing? (Used for abortion)

  // Hash algorithm selector key
  GlobalKey<T_HashSelector_state> globalkey_hashAlgSel = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: Style_FileTree_Item_Expander_Width_px),
        const Icon(Icons.description),
        Text(widget.parent, style: Style_FileTree_Item_Text_Parent),
        Text(widget.name, style: Style_FileTree_Item_Text_Name),
        const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        Expanded(child: _buildHashGenerationView(context)),
        const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        T_FileHashSelector(
            key: globalkey_hashAlgSel,
            onChanged: (selected) {
              generateHash(selected);
            }),
        const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
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
          color: Style_FileTree_HashComp_Colors[_hashComparisonResult],
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
    TextEditingController hashComp_controller = TextEditingController(text: _hashComp);
    hashComp_controller.selection = TextSelection.collapsed(offset: _hashComp_cursorPos);
    return SizedBox(
      width: Style_FileTree_ComparisonInput_Width_px,
      height: Style_FileTree_ComparisonInput_Height_px,
      child: TextField(
        style: Style_FileTree_ComparisonInput_Text,
        decoration: Style_FileTree_ComparisonInput_Decoration,
        controller: hashComp_controller,
        onChanged: (String hashComp) {
          // Update buffer
          _hashComp = hashComp;
          _hashComp_cursorPos = hashComp_controller.selection.baseOffset;

          // Compare
          _compareHash();
        },
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
    widget.s_hashAlg_stream.listen((hash) {
      globalkey_hashAlgSel.currentState!.set(hash.value);
    });
    widget.s_hashFile_savePath_stream.listen((file) {
      file.value.writeAsStringSync(
          // rootDir null means single file -> Use absolute path
          "$_hashGen,${globalkey_hashAlgSel.currentState!.get()},\"${file.rootDir == null ? widget.path : libpath.relative(widget.path, from: file.rootDir)}\"\n",
          mode: FileMode.append);
    });
    Controller_ComparisonInput.stream.listen((input) {
      // TODO: Can be done more efficient?
      // TODO: Filter by tree and single files as well
      if (input.itempath == null || input.itempath == widget.path) {
        // Update comparison input and selected hash algorithm
        // Trigger comparison explicitly if hash algorithm didn't change
        bool triggerComparison = input.hashAlg == null || input.hashAlg == globalkey_hashAlgSel.currentState!.get();
        if (input.compInput != null) {
          _hashComp = input.compInput!;
          _hashComp_cursorPos = _hashComp.length;
        }
        if (triggerComparison) {
          _compareHash();
        } else {
          globalkey_hashAlgSel.currentState!.set(input.hashAlg);
        }
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
      _hashGen = "<Can't find file in file system>";
      _hashGenProgress = 0;
      _compareHash();
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
      _hashGen = "<No hash to create>";
      _compareHash();
      return;
    } else {
      _hashGen = "<Can't use hash algorithm '$alg'>";
      _compareHash();
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
    _hashGen = hashOut.events.single.toString();

    // Compare hash (Widget is rebuilt from here)
    _compareHash();
  }

  // ##################################################
  // @brief: Abort current hash generation
  // ##################################################
  // BUG: Never called
  void abortHashGeneration() {
    // Unset flag to mark abortion
    _hashOngoing = false;

    // Reset hash generation view
    setState(() {
      _hashGen = "<aborted>";
    });
  }

  // ##################################################
  // @brief: Compare generated hash with text input
  //         hashComp Set comparison result accordingly
  // @param: hashComp Text input
  // ##################################################
  void _compareHash() {
    // If generated hash does not match expected format or comparison is empty, set comparison result None
    String r_allowedChars = "a-fA-F0-9";
    List<int> allowedLengths = [32, 40, 64, 96, 128];
    if (_hashComp.isEmpty || !RegExp('^(${allowedLengths.map((i) => '[$r_allowedChars]{$i}').join('|')})\$').hasMatch(_hashGen!)) {
      setState(() {
        _hashComparisonResult = E_HashComparisonResult.none;
      });
      return;
    }

    // For 2 valid inputs, the result is equal or not equal
    setState(() {
      _hashComparisonResult = _hashGen!.toLowerCase() == _hashComp.toLowerCase() ? E_HashComparisonResult.equal : E_HashComparisonResult.notEqual;
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
abstract class TC_Explicit<T> {
  final T _value;
  TC_Explicit(T value) : _value = value;
  T get value => _value;
}

class C_HashAlg extends TC_Explicit<String?> {
  C_HashAlg(super.value);
}

class C_HashFile_SavePath extends TC_Explicit<File> {
  final String? rootDir; // Directory of header if file saves a tree view
  C_HashFile_SavePath(super.value, [this.rootDir]);
}
