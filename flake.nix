{
  description = "The terminal for ExpidusOS";

  inputs.libtokyo = {
    url = path:./subprojects/libtokyo;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.expidus-sdk = {
    url = github:ExpidusOS/sdk;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, libtokyo, nixpkgs, expidus-sdk, ... }:
    let
      supportedSystems = builtins.attrNames libtokyo.packages;
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          tokyo = libtokyo.packages.${system}.gtk3;
          expidus-sdk-pkg = expidus-sdk.packages.${system}.default;
        in
        {
          default = pkgs.stdenv.mkDerivation rec {
            name = "expidus-terminal";
            src = self;
            outputs = [ "out" ];

            nativeBuildInputs = with pkgs; [ meson ninja pkg-config vala glib expidus-sdk-pkg ];
            buildInputs = with pkgs; [ libhandy tokyo vte ];

            enableParallelBuilding = true;

            meta = with pkgs.lib; {
              homepage = "https://github.com/ExpidusOS/terminal";
              license = with licenses; [ gpl3Only ];
              maintainers = with expidus-sdk.lib.maintainers; [ TheComputerGuy ];
            };
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          tokyo = libtokyo.packages.${system}.gtk3;
          expidus-sdk-pkg = expidus-sdk.packages.${system}.default;
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              tokyo
              meson
              ninja
              pkg-config
              vala
              gtk3
              vte
              libhandy
              expidus-sdk-pkg
            ];
          };
        });
    };
}
