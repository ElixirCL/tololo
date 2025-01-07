{ pkgs, lib, ... }: 

{ 
  devcontainer.enable = true;

  languages.elixir.enable = true;
  
  # https://devenv.sh/common-patterns/#configure-the-shell-based-on-the-current-machine
  packages = [
    pkgs.gnumake
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    pkgs.inotify-tools
  ];

  services.postgres = {
    enable = true;
    initialScript = ''
      CREATE ROLE postgres WITH SUPERUSER LOGIN PASSWORD 'postgres';
    '';
  };
}
