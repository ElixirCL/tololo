{ pkgs, lib, inputs, ... }: 

let
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
in
{ 
  devcontainer.enable = true;

  languages.elixir = {
    enable = true;
    package = pkgs-unstable.beamMinimal26Packages.elixir;
  };
  enterShell = ''
    export PATH="$HOME/.mix/escripts:$PATH"
  '';
  
  # https://devenv.sh/common-patterns/#configure-the-shell-based-on-the-current-machine
  packages = [
    pkgs.gnumake
    pkgs.antora
    pkgs.python314
  ] ++ 
  # Linux only
  lib.optionals pkgs.stdenv.isLinux [
    # for ExUnit notifier
    pkgs.libnotify

    # for package - file_system
    pkgs.inotify-tools
  ] ++
  # Darwin only
  lib.optionals pkgs.stdenv.isDarwin [
    # for ExUnit notifier
    pkgs.terminal-notifier

    # for package - file_system
    pkgs.darwin.apple_sdk.frameworks.CoreFoundation
    pkgs.darwin.apple_sdk.frameworks.CoreServices
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
