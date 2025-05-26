{
    fetchFromGitHub,
    runCommand,
    system,
    binutils,
    python3,
}: let
    glibc-2-26 =
        (import (builtins.fetchTarball {
            url = "https://github.com/NixOS/nixpkgs/archive/0b307aa73804bbd7a7172899e59ae0b8c347a62d.tar.gz";
            sha256 = "1fr9fn0iv3qxdqcrnfg7l0y22s91rc9icfm0027q02245vx558p6";
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
        objdump -T ${glibc-2-26}/lib/libc.so.6 \
            | python3 ${glibc-compat}/gensym.py \
            > $out/include/glibc-compat.h
    ''
