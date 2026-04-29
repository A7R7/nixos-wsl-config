{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { 
    self, 
    nixpkgs, 
    nixos-wsl, 
    home-manager,
    ... 
  }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    inherit (import ./options.nix) username hostname flakeDir;
  in {
    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {
        system = "${system}";
        modules = [
          nixos-wsl.nixosModules.default
          ./zsh.nix
          {
            system.stateVersion = "25.11";

            # wsl specific settings
            wsl = {
              enable = true;
              defaultUser = "${username}";
              useWindowsDriver = true;
              usbip = {
                enable = true;
              };
            };

            virtualisation.docker = {
              enable = true;
              enableOnBoot = true;
              daemon.settings = {
                userland-proxy = false;
                experimental = true;
                # data-root = "/home/${username}/docker";
                registry-mirrors = [
                  "https://docker.m.daocloud.io"
                  "https://docker.nju.edu.cn"
                ];

              };
            };

            users = {
              users."${username}" = {
                isNormalUser = true;
                extraGroups = [ "wheel" "docker" ];
                shell = pkgs.zsh;
              };
            };

            environment.systemPackages = with pkgs; [
              coreutils vim git btop lazygit nerd-fonts.noto wget
              docker-buildx just zellij android-tools
              ripgrep fd inetutils unzip nmap
              python314
              zsh
              tar zip unzip
            ];
            
            environment.localBinInPath = true;
            environment.homeBinInPath = true;

            systemd.services.nix-daemon.environment = {
              http_proxy = "http://127.0.0.1:7890";
              https_proxy = "http://127.0.0.1:7890";
              all_proxy = "socks5://127.0.0.1:7890";
            };

            fonts.packages = with pkgs; [
              nerd-fonts.noto
            ];

            environment.variables = {
              FLAKE = "${flakeDir}";
            };

            programs.nh.enable = true;
            programs.nix-ld.enable = true;
            
            nix = {
              settings = {
                auto-optimise-store = true;
                experimental-features = [ "nix-command" "flakes" ];
                substituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];
              };
            };
          }
          home-manager.nixosModules.home-manager {
            home-manager.extraSpecialArgs = {
              inherit username;
              inherit hostname;
              inherit inputs;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./home.nix;
          }
        ];
      };
    };
  };
}
