{ pkgs, lib, inputs, ... }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };

  # Generate a random number using a shell command
  randomSuffix = builtins.readFile (pkgs.runCommand "random-suffix" {} ''
    printf $((RANDOM % 10000)) > $out
  '');
  localtunnel-subdomain = "tololo-" + randomSuffix;
in
{
  devcontainer.enable = true;

  languages.elixir = {
    enable = true;
    package = pkgs-unstable.beamMinimal26Packages.elixir;
  };

  # https://devenv.sh/common-patterns/#configure-the-shell-based-on-the-current-machine
  packages = [
    pkgs.openssh
    pkgs.git
    pkgs.gnumake
    pkgs.grafana
    pkgs.prometheus
    pkgs.gnumake
    pkgs.antora

    pkgs.nodePackages_latest.localtunnel

    pkgs.zsh
    pkgs.oh-my-zsh
  ] ++ lib.optionals pkgs.stdenv.isLinux [
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

  enterShell = ''
    export PATH="$HOME/.mix/escripts:$PATH"

    if [ ! -d ".devenv/state/grafana" ]; then
      cp -rL .devenv/profile/share/grafana .devenv/state/grafana
      chmod 777 -R .devenv/state/grafana
    fi

    if [ ! -d ".devenv/state/prometheus" ]; then
      mkdir .devenv/state/prometheus
    fi
  '';

  enterTest = ''
    cd tololo
    mix test
    mix credo
  '';

  tasks = {
    "mix:deps" = {
      # overrides the imported task to cd
      exec = ''
        cd tololo
        mix deps.get
      '';
    };
    "mix:format" = {
      # overrides the imported task to cd
      exec = ''
        cd tololo
        mix format --check-formatted
      '';
    };
  };

  processes = {
    grafana.exec = "grafana server --homepath .devenv/state/grafana";
    prometheus.exec = "prometheus --storage.tsdb.path .devenv/state/prometheus/data";
    localtunnel.exec = "lt -p 4000 -s ${localtunnel-subdomain}";
  };

  services.kafka.enable = true;

  services.postgres = {
    enable = true;
    initialScript = ''
      CREATE ROLE postgres WITH SUPERUSER LOGIN PASSWORD 'postgres';
    '';
  };

  env.ADMIN_API_KEY = "test";
  env.TELEGRAM_WEBHOOK = "https://${localtunnel-subdomain}.loca.lt/telegram";
}
