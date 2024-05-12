{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "ct-ng";
        version = "1.26.0";
        src = pkgs.fetchFromGitHub {
          owner = "moritz-meier";
          repo = "crosstool-ng";
          rev = "local";
          hash = "sha256-g9vZQksoTi5bNBlccfUXFqow3lJSG+hlni/Y5sN7mfs=";
        };

        buildInputs = with pkgs; [
          autoconf
          automake
          bison
          flex
          help2man
          libtool
          ncurses
          python3
          texinfo
          unzip
          which
          glibc
          glibc.static
        ];

        configurePhase = ''
          sh ./bootstrap
          sh ./configure --prefix=$out
        '';
      };

      devShells.${system}.default = pkgs.mkShell {

        hardeningDisable = [ "all" ];

        packages = [
          self.packages.${system}.default
          pkgs.autoconf
          pkgs.m4
          pkgs.python3
          pkgs.glibc
          pkgs.glibc.static
        ];

        shellHook = ''
          unset CC
          unset CXX
        '';
      };
    };
}
