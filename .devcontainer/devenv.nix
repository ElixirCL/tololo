{ pkgs, ... }: 

{ 
  devcontainer.enable = true;

  languages.elixir.enable = true;
  packages = [
    pkgs.inotify-tools
    pkgs.gnumake
  ];

  services.postgres = {
    enable = true;
    initialScript = ''
      CREATE ROLE postgres WITH SUPERUSER LOGIN PASSWORD 'postgres';
    '';
  };
}
