{ username, hostname, ... }:

{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  programs = {
    home-manager.enable = true;

    lsd = {
      enable = true;
      settings = {
        icons = {
          when = "auto";
          theme = "fancy";
          separator = " ";
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    starship.enable = true;

    fish = {
      enable = true;
    };
  };
}
