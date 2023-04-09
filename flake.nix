{
  description = "flake for the rofi-todoist application";

  outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
    in
    {
      overlay = final: prev: {
        rofi-todoist = with final; stdenv.mkDerivation rec {
          name = "rofi-todoist-1.0.1";

          src = ./.;

          nativeBuildInputs = [ makeWrapper ];

          installPhase = ''
            mkdir -p $out/bin
            cp rofi-todoist $out/bin
            wrapProgram $out/bin/rofi-todoist --set PATH ${lib.makeBinPath [ todoist rofi coreutils ]}
          '';
        };
      };
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) rofi-todoist;
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.rofi-todoist);
    };
}
