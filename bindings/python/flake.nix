{
    description = "cpp-bindings-test-python";

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
            perSystem = {pkgs, ...}: {
                devShells.default = pkgs.mkShell {
                    packages = with pkgs; [
                        python3
                        uv
                    ];
                };
            };
        };
}
