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
}

// ##################################################
// @brief: Get list of all known hash algorithm names
// @return: List<String>
// ##################################################
List<String> getHashAlgorithmNames() {
  List<String> returnList = [];
  for (var alg in E_HashAlgorithms.values) {
    returnList.add(alg.value);
  }
  return returnList;
}
