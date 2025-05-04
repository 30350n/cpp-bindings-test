{
    lib,
    stdenv,
    clang,
    cmake,
    musl,
    enableTests ? true,
}:
stdenv.mkDerivation {
    name = "cpp-bindings-test";
    src = lib.sourceByRegex ./. [
        "^include.*"
        "^src.*"
        "^test.*"
        "CMakeLists\.txt"
        ".*\.pc\.in"
    ];
    nativeBuildInputs = [clang cmake musl];

    doCheck = true;
    cmakeFlags = lib.optional (!enableTests) "-DTESTING=off";
}
