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
          curl
          flex
          help2man
          libtool
          ncurses
          python3
          texinfo
          unzip
          wget
          which
        ];

        configurePhase = ''
          sh ./bootstrap
          sh ./configure --prefix=$out
        '';
      };

      devShells.${system}.default = pkgs.mkShell {

        hardeningDisable = [ "all" ];

        packages = with pkgs; [
          self.packages.${system}.default
          autoconf
          curl
          m4
          python3
          wget
        ];

        shellHook = ''
          unset CC
          unset CXX
        '';
      };
    };
}
