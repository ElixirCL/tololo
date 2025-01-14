{ pkgs, lib, inputs, ... }: 

# backend devenv.nix. contains only the essential dependencies to run the project
let
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
in
{ 
  languages.elixir = {
    enable = true;
    package = pkgs-unstable.beamMinimal26Packages.elixir;
  };
  enterShell = ''
    export PATH="$HOME/.mix/escripts:$PATH"
  '';

  tasks = {
    "mix:deps" = {
      exec = ''
        mix deps.get
      '';
      # runs before entering shell and before testing
      before = [ "devenv:enterShell" "devenv:enterTest" ];
    };
    "mix:format" = {
      exec = ''
        mix format --check-formatted
      '';
    };
  };
  
  enterTest = ''
    mix test
    mix credo
  '';

  # https://devenv.sh/common-patterns/#configure-the-shell-based-on-the-current-machine
  packages =  # Linux only
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

  services.postgres = {
    enable = true;
    initialScript = ''
      CREATE ROLE postgres WITH SUPERUSER LOGIN PASSWORD 'postgres';
    '';
  };
}

