{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      username = builtins.getEnv "USER";
      homeDirectory = builtins.getEnv "HOME";
      dotfilesDir = "${homeDirectory}/dotfiles";

      mkApp = name: script: {
        type = "app";
        program = "${
          pkgs.writeShellApplication {
            inherit name;
            text = script;
          }
        }/bin/${name}";
      };
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit username homeDirectory; };
        modules = [ ./home-manager ];
      };

      # nix run .#switch --impure で実行
      apps.${system} = {
        switch = mkApp "hm-switch" ''
          nix run home-manager -- switch --flake "${dotfilesDir}" --impure
        '';

        update = mkApp "hm-update" ''
          echo "Updating flake..."
          nix flake update --flake "${dotfilesDir}"
          echo "Applying home-manager..."
          nix run home-manager -- switch --flake "${dotfilesDir}" --impure
          echo "Update complete!"
        '';

        check = mkApp "hm-check" ''
          nix flake check "${dotfilesDir}" --impure
        '';

        clean = mkApp "hm-clean" ''
          nix-collect-garbage -d
        '';
      };
    };
}
