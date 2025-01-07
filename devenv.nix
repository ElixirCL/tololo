{ pkgs, lib, ... }: 

{ 
  devcontainer.enable = true;

  languages.elixir = {
    enable = true;
    package = pkgs.elixir;
  };
  
  # https://devenv.sh/common-patterns/#configure-the-shell-based-on-the-current-machine
  packages = [
    pkgs.gnumake
    pkgs.antora
    pkgs.python314
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    pkgs.inotify-tools
  ];

  # for Antora extensions
  languages.javascript.enable = true;
  languages.javascript.yarn = {
    enable = true;
    install.enable = true;
  };

  services.postgres = {
    enable = true;
    initialScript = ''
      CREATE ROLE postgres WITH SUPERUSER LOGIN PASSWORD 'postgres';
    '';
  };
}
