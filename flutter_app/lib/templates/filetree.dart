// ####################################################################################################
// # @file filetree.dart
// # @author Nils Henrich
// # @brief Templates for loaded file, file tree and corresponding hashing and comparison funcionality
// # @version 1.0.1+4
// # @date 2023-03-30
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:file_tree_hasher/definies/datatypes.dart';
import 'package:file_tree_hasher/definies/defaults.dart';
import 'package:file_tree_hasher/definies/hashalgorithms.dart';
import 'package:file_tree_hasher/definies/styles.dart';
import 'package:file_tree_hasher/functions/general.dart';
import 'package:file_tree_hasher/templates/hashselector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';

// ##################################################
// # PROVIDER
// # Provide loaded folder
// # DEV: Just folder name
// ##################################################
class P_FileTree extends ChangeNotifier {
  // List of loaded file trees
  List<T_TreeItem> loadedTrees = [];

  // Constructor
  P_FileTree();

  // Load file tree to GUI
  void loadFileTree(String path) {
    loadedTrees.add(T_TreeHeader(path: path));
    loadedTrees.add(T_FolderItem(path: path)); // DEV: Just to have both underneath each other
    notifyListeners();
  }
}

// ##################################################
// # TEMPLATE
// # Single tree view item (header, folder or file)
// ##################################################
abstract class T_TreeItem extends StatelessWidget {
  // Parameter
  final String name; // Elements name (to be shown in GUI)
  final String path; // Elements absolute system path (used for hash generation and shown in tree header)

  // Constructor
  T_TreeItem({super.key, required this.path}) : name = GetFileName(path);
}

// ##################################################
// # TEMPLATE
// # Single folder
// ##################################################
class T_FolderItem extends T_TreeItem {
  // Style parameters
  Widget? get _style_leading => null;
  bool get _style_pathAsName => false;
  TextStyle get _style_textStyle => const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black);
  EdgeInsetsGeometry get _style_childrenPadding => const EdgeInsets.symmetric(horizontal: Style_FileTree_Item_ElementSpaces_px);
  double get _style_marginTop => 0;

  // Constructor
  T_FolderItem({super.key, required super.path});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: _style_marginTop),
      ExpansionTile(
          maintainState: true,
          initiallyExpanded: true,
          leading: _style_leading,
          title: Text(_style_pathAsName ? path : name, style: _style_textStyle),
          childrenPadding: _style_childrenPadding,
          children: [])
    ]);
  }
}

// ##################################################
// # TEMPLATE
// # File tree header
// ##################################################
class T_TreeHeader extends T_FolderItem {
  // Override style parameters
  @override
  Widget? get _style_leading => const Icon((Icons.folder));
  @override
  bool get _style_pathAsName => true;
  @override
  TextStyle get _style_textStyle => const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  @override
  EdgeInsetsGeometry get _style_childrenPadding => const EdgeInsets.symmetric(horizontal: 0);
  @override
  double get _style_marginTop => 10;

  // Constructor
  T_TreeHeader({required super.path});
}

// ##################################################
// # TEMPLATE
// # Hash generation view
// # This widget can be inserted into file view to show hash calculation progress or generated hash comparison
// ##################################################
class T_HashGenerationView extends StatefulWidget {
  // Attributes
  final String filepath;
  final GlobalKey<T_HashComparisonView_state> globKey_HashComparisonView;

  // Constructor
  const T_HashGenerationView({super.key, required this.filepath, required this.globKey_HashComparisonView});

  @override
  State<StatefulWidget> createState() => T_HashGenerationView_state();
}

// ##################################################
// # STATE
// # Hash generation view state
// ##################################################
class T_HashGenerationView_state extends State<T_HashGenerationView> {
  // State attributes
  String _hashGen = "";
  double _genProgress = 0;
  bool _ongoing = false;
  E_HashComparisonResult _comparisonResult = E_HashComparisonResult.none;

  @override
  Widget build(BuildContext context) {
    return _hashGen.isEmpty
        ? LinearPercentIndicator(
            percent: _genProgress,
            lineHeight: Style_FileTree_HashGen_Prg_Height_px,
            center: Text("${(_genProgress * 100).toStringAsFixed(1)}%", style: Style_FileTree_HashGen_Prg_Text),
            progressColor: Style_FileTree_HashGen_Prg_Color)
        : Row(children: [
            Flexible(
                child:
                    Container(color: Style_FileTree_HashComp_Colors[_comparisonResult], child: Text(_hashGen, style: Style_FileTree_HashGen_Text))),
            SizedBox(
                height: Style_FileTree_HashSelector_FontSize_px,
                child: IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _hashGen));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
                    },
                    iconSize: Style_FileTree_HashSelector_FontSize_px,
                    padding: EdgeInsets.zero,
                    color: Style_FileTree_HashGen_Text.color,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: const Icon(Icons.copy)))
          ]);
  }

  @override
  void initState() {
    super.initState();
    generateHash(SelectedGlobalHashAlg);
  }

  // ##################################################
  // @brief: Compare generated hash with text input
  // @param: hashComp
  // ##################################################
  void compareHashes(String hashComp) {
    setState(() {
      // If any of both hashes is empty, no comparison is done
      if (_hashGen.isEmpty || hashComp.isEmpty) {
        _comparisonResult = E_HashComparisonResult.none;
        return;
      }

      // For 2 valid inputs, the result is equal or not equal
      _comparisonResult = _hashGen.toLowerCase() == hashComp.toLowerCase() ? E_HashComparisonResult.equal : E_HashComparisonResult.notEqual;

      return;
    });
  }

  // ##################################################
  // @brief: Calculate hash and update GUI
  // @param alg
  // ##################################################
  void generateHash(String? alg) async {
    // -------------------- Read file --------------------
    File file = File(widget.filepath);
    if (!await file.exists()) {
      // throw FileSystemException("File ${widget.filepath} does not exist");
      setState(() {
        _hashGen = "<Can't find file in file system>";
        _genProgress = 0;
        _comparisonResult = E_HashComparisonResult.none;
      });
      return;
    }

    // -------------------- Generate hash --------------------

    // Reset old hash and comparison
    setState(() {
      _genProgress = 0;
      _hashGen = "";
      _comparisonResult = E_HashComparisonResult.none;
    });

    // File size and processed size for progress calculation
    int totalBytes = await file.length();
    int bytesRead = 0;

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

    // -------------------- Start --------------------
    _ongoing = true;

    // Read file step by step and generate hash
    await for (var chunk in file.openRead()) {
      // Abort process here if flag is unset
      if (!_ongoing) {
        return;
      }

      // Generate hash for next file part
      bytesRead += chunk.length;
      hasher.add(chunk);

      // Update progress bar
      if (!mounted) {
        return;
      }
      setState(() {
        _genProgress = bytesRead / totalBytes;
      });
    }

    _ongoing = false;
    // -------------------- Done --------------------

    // Extract hash string
    hasher.close();
    String hashString = hashOut.events.single.toString();

    _hashGen = hashString;
    compareHashes(widget.globKey_HashComparisonView.currentState!.get());
  }

  // ##################################################
  // @brief: Abort current hash generation
  // ##################################################
  void abortHashGeneration() {
    // Unset flag to mark abortion
    _ongoing = false;

    // Reset hash generation view
    setState(() {
      _hashGen = "<aborted>";
    });
  }

  // ##################################################
  // @brief: Getter: generated hash
  // @return: String
  // ##################################################
  String get HashGen {
    return _hashGen;
  }
}

// ##################################################
// # TEMPLATE
// # Hash comparison view
// # This widget can be inserted into file view to provide user input for hash comparison
// ##################################################
class T_HashComparisonView extends StatefulWidget {
  // Function call on changed
  final Function(String)? onChanged;

  // Constructor
  T_HashComparisonView({super.key, this.onChanged});

  // Hash comparison view key
  final globKey_HashCompView = GlobalKey<T_HashComparisonView_state>();

  @override
  State<StatefulWidget> createState() => T_HashComparisonView_state();
}

// ##################################################
// # STATE
// # Hash comparison view state
// ##################################################
class T_HashComparisonView_state extends State<T_HashComparisonView> {
  // state attributes
  String _hashComp = "";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: Style_FileTree_ComparisonInput_Width_px,
        height: Style_FileTree_ComparisonInput_Height_px,
        child: TextField(
            style: Style_FileTree_ComparisonInput_Text,
            decoration: Style_FileTree_ComparisonInput_Decoration,
            controller: TextEditingController(text: _hashComp),
            onChanged: _onChange));
  }

  // ##################################################
  // @brief: Work on onChange
  // @param: value
  // ##################################################
  void _onChange(String value) {
    _hashComp = value;
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  // ##################################################
  // @brief: Getter/Setter
  // @param: val
  // @return: String
  // ##################################################
  String get() {
    return _hashComp;
  }

  void set(String val) {
    setState(() {
      _hashComp = val;
    });
    _onChange(val);
  }
}
