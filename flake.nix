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
                lib,
                ...
            }: rec {
                packages.default = packages.cpp-bindings-test;
                packages.cpp-bindings-test = pkgs.callPackage ./cpp-bindings-test/package.nix {};
                packages.cpp-bindings-test-compat = pkgs.callPackage ./cpp-bindings-test/package.nix {
                    compat = true;
                };

                devShells.default = devShells.cpp-bindings-test;
                devShells.cpp-bindings-test = pkgs.mkShell {} // packages.cpp-bindings-test // {};
                devShells.cpp-bindings-test-compat = pkgs.mkShell {} // packages.cpp-bindings-test-compat // {};
                devShells.python = import ./bindings/python/shell.nix {inherit pkgs;};
            };
        };
}
