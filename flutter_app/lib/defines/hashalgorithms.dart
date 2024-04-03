// ####################################################################################################
// # @file hashalgorithms.dart
// # @author Nils Henrich
// # @brief Global definitions about hash algorithms that are used
// # @version 2.0.0+1
// # @date 2023-03-29
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: camel_case_types, constant_identifier_names, non_constant_identifier_names

// ##################################################
// # ENUM
// # All hash algorithms the tool can handle
// ##################################################
enum E_HashAlgorithms {
  MD5("MD5"), // Length: 32 chars
  SHA1("SHA1"), // Length: 40 chars
  SHA256("SHA256"), // Length: 64 chars
  SHA384("SHA384"), // Length: 96 chars
  SHA512("SHA512"), // Length: 128 chars
  NONE("NONE");

  // Constructor and value to hold
  const E_HashAlgorithms(this.value);
  final String value;

// ##################################################
// @brief: Getter: name
// @return: String
// ##################################################
  String get name {
    return value;
  }
}

// ##################################################
// @brief: Get list of all known hash algorithm names
// @return: List<String>
// ##################################################
List<String> GetAllHashAlgorithmNames() {
  List<String> returnList = [];
  for (E_HashAlgorithms alg in E_HashAlgorithms.values) {
    returnList.add(alg.name);
  }
  return returnList;
}
