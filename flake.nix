{
  description = "Helix editor with custom configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, yazi, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ];
        };
        yaziPackage = yazi.packages.${system}.default;
        yaziDeps = import ./dependencies.nix { inherit pkgs; };
        yaziConfig = import ./config/yazi.nix { inherit pkgs; };
        keymapConfig = import ./config/keymap.nix;
        themeConfig = import ./config/theme.nix;
        tomlFormat = pkgs.formats.toml { };
        yaziToml = tomlFormat.generate "yazi.toml" yaziConfig;
        keymapToml = tomlFormat.generate "keymap.toml" keymapConfig;
        themeToml = tomlFormat.generate "theme.toml" themeConfig;
      in
      {
        packages.default = pkgs.symlinkJoin {
          name = "yazi-wrapped";
          paths = [ yaziPackage ] ++ yaziDeps;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out/config
            cp ${yaziToml} $out/config/yazi.toml
            cp ${keymapToml} $out/config/keymap.toml
            cp ${themeToml} $out/config/theme.toml
            wrapProgram $out/bin/yazi \
              --set YAZI_CONFIG_HOME "$out/config" \
              --prefix PATH : ${pkgs.lib.makeBinPath yaziDeps}
          '';
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/yazi";
        };
      }
    );
}
