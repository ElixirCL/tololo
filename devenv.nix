{ pkgs, lib, inputs, ... }: 

# top-level devenv.nix. contains services not essential to running the backend, such as Prometheus and Kafka
{ 
  devcontainer.enable = true;

  enterShell = ''
    if [ ! -d ".devenv/state/grafana" ]; then
      cp -rL .devenv/profile/share/grafana .devenv/state/grafana
      chmod 777 -R .devenv/state/grafana
    fi

    if [ ! -d ".devenv/state/prometheus" ]; then
      mkdir .devenv/state/prometheus
    fi
  '';

  # https://devenv.sh/common-patterns/#configure-the-shell-based-on-the-current-machine
  packages = [
    pkgs.gnumake
    pkgs.antora
    pkgs.python314
    pkgs.grafana
    pkgs.prometheus
  ];

  # for Antora extensions
  languages.javascript.enable = true;
  languages.javascript.yarn = {
    enable = true;
    install.enable = true;
  };

  tasks = {
    "mix:deps" = {
      # overrides the imported task to cd
      exec = lib.mkForce ''
        cd tololo
        mix deps.get
      '';
    };
    "mix:format" = {
      # overrides the imported task to cd
      exec = lib.mkForce ''
        cd tololo
        mix format --check-formatted
      '';
    };
  };

  enterTest = ''
    cd tololo
    mix test
    mix credo
  '';

  processes = {
    grafana.exec = "grafana server --homepath .devenv/state/grafana";
    prometheus.exec = "prometheus --storage.tsdb.path .devenv/state/prometheus/data";
  };

  services.kafka.enable = true;
}
