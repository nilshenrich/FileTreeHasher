// ####################################################################################################
// # @file styles.dart
// # @author Nils Henrich
// # @brief General widget styles
// # @version 0.0.0+1
// # @date 2023-04-03
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################
// ignore_for_file: constant_identifier_names

// ##################################################
// # Style for tree view
// ##################################################

// Icons
import 'package:file_tree_hasher/definies/datatypes.dart';
import 'package:flutter/material.dart';

const double Style_FileTree_Icon_Width_px = 24;
const double Style_FileTree_Icon_Height_px = 24;

// Hash selector
const double Style_FileTree_HashSelector_Height_px = 24;
const double Style_FileTree_HashSelector_FontSize_px = 14;

// Hash comparison input
const double Style_FileTree_ComparisonInput_Width_px = 200;
const double Style_FileTree_ComparisonInput_Height_px = 25;
const double Style_FileTree_ComparisonInput_FontSize_px = 14;

// Sub-item
const double Style_FileTree_SubItem_ShiftRight_px = 20;

// Item spacing
const double Style_FileTree_Item_ElementSpaces_px = 10;

// Text style for generated hash
const TextStyle Style_FileTree_HashGen = TextStyle(color: Colors.grey);
const Map<E_HashComparisonResult, Color> Style_FileTree_HashComp_Colors = {
  E_HashComparisonResult.none: Colors.transparent,
  E_HashComparisonResult.equal: Colors.green,
  E_HashComparisonResult.notEqual: Colors.red
};
