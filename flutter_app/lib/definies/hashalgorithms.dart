// ####################################################################################################
// # @file hashalgorithms.dart
// # @author Nils Henrich
// # @brief Global definitions about hash algorithms that are used
// # @version 0.0.0+1
// # @date 2023-03-29
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: camel_case_types, constant_identifier_names

// ##################################################
// # ENUM
// # All hash algorithms the tool can handle
// ##################################################
enum E_HashAlgorithms {
  MD5("MD5"),
  SHA1("SHA1"),
  SHA256("SHA256"),
  SHA384("SHA384"),
  SHA512("SHA512"),
  USERDEFINED("user defined");

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
//         Not including the user defined selection
// @return: List<String>
// ##################################################
List<String> getSoftHashAlgorithmNames() {
  List<String> returnList = [];
  for (E_HashAlgorithms alg in E_HashAlgorithms.values) {
    returnList.add(alg.name);
  }
  return returnList;
}

// ##################################################
// @brief: Get list of all known hash algorithm names
//         Not including the user defined selection
// @return: List<String>
// ##################################################
List<String> getHardHashAlgorithmNames() {
  List<String> returnList = [];
  for (E_HashAlgorithms alg in E_HashAlgorithms.values) {
    if (alg != E_HashAlgorithms.USERDEFINED) {
      returnList.add(alg.name);
    }
  }
  return returnList;
}
