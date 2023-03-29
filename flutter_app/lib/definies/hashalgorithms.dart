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

// ##################################################
// # ENUM
// # All hash algorithms the tool can handle
// ##################################################
enum E_HashAlgorithms {
  MD5("MD5"),
  SHA1("SHA1"),
  SHA256("SHA256"),
  SHA384("SHA384"),
  SHA512("SHA512");

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
List<String> getAllHashAlgorithmNames() {
  List<String> returnList = [];
  for (E_HashAlgorithms alg in E_HashAlgorithms.values) {
    returnList.add(alg.name);
  }
  return returnList;
}
