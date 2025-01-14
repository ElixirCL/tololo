{ pkgs, lib, inputs, ... }: 

# top-level devenv.nix. contains services not essential to running the backend, such as Prometheus and Kafka
{ 
    devcontainer.enable = true;

    # https://devenv.sh/common-patterns/#configure-the-shell-based-on-the-current-machine
    packages = [
        pkgs.gnumake
        pkgs.antora
    ];

    # for Antora extensions
    languages.javascript.enable = true;
    languages.javascript.yarn = {
        enable = true;
        install.enable = true;
    };
}
