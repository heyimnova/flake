{inputs, ...}: {
  # Base home-manager config
  flake.modules.homeManager.home = {
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.spicetify-nix.homeManagerModules.default];

    home.stateVersion = lib.mkDefault "26.11";

    programs.spicetify = let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in {
      enable = true;
      theme = spicePkgs.themes.starryNight;
      colorScheme = "Cotton-candy";

      enabledExtensions = with spicePkgs.extensions; [
        catJamSynced
        playlistIntersection
        volumePercentage
      ];
    };
  };
}
