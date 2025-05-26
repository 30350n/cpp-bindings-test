{
    description = "cpp-bindings-test";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    };

    outputs = inputs @ {flake-parts, ...}:
        flake-parts.lib.mkFlake {inherit inputs;} {
            systems = [
                "x86_64-linux"
                "aarch64-linux"
                "x86_64-darwin"
                "aarch64-darwin"
            ];
            perSystem = {
                pkgs,
                system,
                ...
            }: rec {
                packages.default = packages.cpp-bindings-test;
                packages.cpp-bindings-test = pkgs.callPackage ./cpp-bindings-test/package.nix {
                    useMusl = system == "x86_64-linux";
                    useGlibcCompat = system == "aarch64-linux";
                };

                devShells.default = devShells.cpp-bindings-test;
                devShells.cpp-bindings-test = pkgs.mkShell {
                    nativeBuildInputs = packages.default.nativeBuildInputs;
                };
                devShells.python = import ./bindings/python/shell.nix {inherit pkgs;};
            };
        };
}
