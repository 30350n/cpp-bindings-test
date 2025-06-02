{
    lib,
    stdenv,
    callPackage,
    cmake,
    enableTests ? true,
    compat ? false,
}: let
    libc-compat = callPackage ./libc-compat.nix {};
in
    stdenv.mkDerivation rec {
        name = "cpp-bindings-test";
        src = lib.sourceByRegex ./. [
            "^include.*"
            "^src.*"
            "^test.*"
            "CMakeLists\.txt"
            ".*\.pc\.in"
        ];
        nativeBuildInputs = [cmake];

        COMPAT_HEADERS =
            if compat
            then "${libc-compat.libc-compat-header}/include/glibc-compat.h"
            else null;
        COMPAT_LIBS =
            if compat
            then "${libc-compat.libc}/lib;${libc-compat.libcpp}/lib"
            else null;

        doCheck = true;
        cmakeFlags = lib.intersperse " " (
            lib.optionals compat [
                "-DCOMPAT_HEADERS=${COMPAT_HEADERS}"
                "-DCOMPAT_LIBS=${COMPAT_LIBS}"
            ]
            ++ lib.optionals (!enableTests) ["-DTESTING=off"]
        );
    }
