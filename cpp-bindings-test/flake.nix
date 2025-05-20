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
            }: {
                packages.default = pkgs.callPackage ./package.nix {
                    useMusl = system == "x86_64-linux";
                    useGlibcCompat = system == "aarch64-linux";
                };
            };
        };
}
