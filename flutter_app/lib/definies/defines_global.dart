enum E_HashAlgorithms {
  MD5("MD5"),
  SHA1("SHA1"),
  SHA256("SHA256"),
  SHA384("SHA384"),
  SHA512("SHA512");

  const E_HashAlgorithms(this.value);
  final String value;
}

List<String> getHashAlgorithmNames() {
  List<String> returnList = [];
  for (var alg in E_HashAlgorithms.values) {
    returnList.add(alg.value);
  }
  return returnList;
}
