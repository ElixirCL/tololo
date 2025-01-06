{ pkgs, ... }: 

{ 
  languages.elixir.enable = true;
  packages = [
    pkgs.inotify-tools
    pkgs.docker_25
    pkgs.gnumake
  ];

  services.postgres = {
    enable = true;
    initialScript = ''
      CREATE ROLE postgres WITH SUPERUSER LOGIN PASSWORD 'postgres';
    '';
  };
}
