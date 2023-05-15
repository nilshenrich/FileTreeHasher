// ####################################################################################################
// # @file datatypes.dart
// # @author Nils Henrich
// # @brief Definition of useful datatypes usable in entire project
// # @version 0.0.0+1
// # @date 2023-05-15
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: camel_case_types

// ##################################################
// # Hash comparison result
// ##################################################
enum E_HashComparisonResult {
  none, // No comparison
  equal, // Generated hash and comparison hash match
  notEqual, // Generated hash and comparison hash differ
}
