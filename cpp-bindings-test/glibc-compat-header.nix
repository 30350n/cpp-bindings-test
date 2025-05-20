{
    fetchFromGitHub,
    runCommand,
    system,
    binutils,
    python3,
}: let
    glibc-2-24 =
        (import (builtins.fetchTarball {
            url = "https://github.com/NixOS/nixpkgs/archive/c0c50dfcb70d48e5b79c4ae9f1aa9d339af860b4.tar.gz";
            sha256 = "17p3w4mgfr4yj2p0jz6kqgzhyr04h4fap5hnd837664xd1xhwdjb";
        }) {inherit system;})
        .glibc;
    glibc-compat = fetchFromGitHub {
        owner = "billziss-gh";
        repo = "glibc-compat";
        rev = "8730a181bbdf6cb6b6579d143a25cfeaa288583b";
        sha256 = "Q7pkte0XW6gd95k0b7TJ5gB2sJUnzwWFOYgeh3q4wEo=";
    };
in
    runCommand "glibc-compat-header" {
        nativeBuildInputs = [binutils python3];
    } ''
        mkdir -p $out/include
        objdump -T ${glibc-2-24}/lib/libc.so.6 \
            | python3 ${glibc-compat}/gensym.py \
            > $out/include/glibc-compat.h
    ''
