{
  description = "";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs =
    { flake-parts
    , self
    , ...
    }:
    flake-parts.lib.mkFlake { inherit self; } {
      perSystem = { pkgs, ... }:
        let
          buildTools = c: with c; [
            cabal-install
            pkgs.gnumake
            pkgs.zlib
          ];
          devTools = c: with c; [
            ghcid
            haskell-language-server
          ];
          ghc-version = "ghc902";
          hlib = pkgs.haskell.lib;
          compiler = pkgs.haskell.packages."${ghc-version}";
          hsOverlay =
            (pkgs.haskellPackages.extend (hlib.compose.packageSourceOverrides {
              lib1 = ./lib1;
              lib2 = ./lib2;
            }));
          packages = p: [
            p.lib1
            p.lib2
          ];
        in
        {
          devShells.default = hsOverlay.shellFor {
            inherit packages;
            withHoogle = true;
            buildInputs = (buildTools compiler) ++ (devTools compiler);
          };
        };
      systems = [
        "x86_64-linux"
      ];
    };
}
