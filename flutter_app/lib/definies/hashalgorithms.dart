// ####################################################################################################
// # @file hashalgorithms.dart
// # @author Nils Henrich
// # @brief Global definitions about hash algorithms that are used
// # @version 0.0.0+1
// # @date 2023-03-19
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// Default hash algorithm
// This algorithm is selected on startup
const E_HashAlgorithms DefaultHashAlgorithm = E_HashAlgorithms.MD5;

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

  const E_HashAlgorithms(this.value);
  final String value;

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
  for (var alg in E_HashAlgorithms.values) {
    returnList.add(alg.name);
  }
  return returnList;
}
