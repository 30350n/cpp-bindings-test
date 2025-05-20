{
    lib,
    stdenv,
    callPackage,
    clang,
    cmake,
    musl,
    enableTests ? true,
    useMusl ? false,
    useGlibcCompat ? false,
}:
assert !(useMusl && useGlibcCompat);
    stdenv.mkDerivation {
        name = "cpp-bindings-test";
        src = lib.sourceByRegex ./. [
            "^include.*"
            "^src.*"
            "^test.*"
            "CMakeLists\.txt"
            ".*\.pc\.in"
        ];
        nativeBuildInputs = [clang cmake] ++ lib.optionals useMusl [musl];

        GLIBC_COMPAT_HEADER = let
            glibc-compat-header = callPackage ./glibc-compat-header.nix {};
        in
            if useGlibcCompat
            then "${glibc-compat-header}/include/glibc-compat.h"
            else null;

        doCheck = true;
        cmakeFlags = lib.optional (!enableTests) "-DTESTING=off";
    }
