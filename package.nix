{
    lib,
    stdenv,
    cmake,
    enableTests ? true,
}:
stdenv.mkDerivation {
    name = "cpp-bindings-test";
    src = lib.sourceByRegex ./. [
        "^src.*"
        "^test.*"
        "CMakeLists.txt"
    ];
    nativeBuildInputs = [cmake];

    doCheck = true;
    cmakeFlags = lib.optional (!enableTests) "-DTESTING=off";
}
