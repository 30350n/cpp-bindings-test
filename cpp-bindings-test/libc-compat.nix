{
    fetchFromGitHub,
    runCommand,
    stdenv,
    system,
    writeText,
    binutils,
    python3,
}: let
    nixpkgs-release-15-09 = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/cc7c26173149348ba43f0799fac3f3823a2d21fc.tar.gz";
        sha256 = "1pgsqjw7qfsiivy5hvvslw48mamq5w3zs2jnwaixn657rh509v86";
    }) {inherit system;};
    glibc-compat = fetchFromGitHub {
        owner = "billziss-gh";
        repo = "glibc-compat";
        rev = "8730a181bbdf6cb6b6579d143a25cfeaa288583b";
        sha256 = "Q7pkte0XW6gd95k0b7TJ5gB2sJUnzwWFOYgeh3q4wEo=";
    };
in rec {
    libc = nixpkgs-release-15-09.stdenv.cc.libc;

    libc-compat-header = runCommand "glibc-compat-header" {
        nativeBuildInputs = [binutils python3];
    } ''
        mkdir -p $out/include
        objdump -T ${libc}/lib/libc.so.6 \
            | python3 ${glibc-compat}/gensym.py \
            > $out/include/glibc-compat.h
    '';

    libcpp = let
        libcpp-compat-patch = writeText
        "libcpp-compat.patch" ''
            --- a/libstdc++-v3/Makefile.in
            +++ b/libstdc++-v3/Makefile.in
            @@ -421,3 +421,3 @@ WARN_CXXFLAGS = \
             # -I/-D flags to pass when compiling.
            -AM_CPPFLAGS = $(GLIBCXX_INCLUDES) $(CPPFLAGS)
            +AM_CPPFLAGS = -I ${libc-compat-header} $(GLIBCXX_INCLUDES) $(CPPFLAGS)
             @GLIBCXX_HOSTED_TRUE@hosted_source = doc po testsuite python
        '';
    in
        (stdenv.cc.cc.overrideAttrs (prevAttrs: {
            patches = prevAttrs.patches ++ [libcpp-compat-patch];
        }))
        .lib;
}
