{
  description = "Zot flake with systemd service";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    zot = pkgs.callPackage ./default.nix {};
  in {
    packages.${system}.zot = zot;

    nixosModules.zotModule = {
      config, pkgs, lib, ... }: {
      
      options.services.zot = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Zot service";
        };
        configFile = lib.mkOption {
          type = lib.types.path;
          default = ./config.yaml;
          description = "Path to Zot config file";
        };
      };

      config = lib.mkIf config.enable {

        environment.systemPackages = [ zot ];

        users.users.zot = {
          createHome = false;
          isSystemUser = true;
          group = "zot";
          description = "Zot service user";
        };

        users.groups.zot = {
          gid = 3000;
        };

        systemd.services.zot = {
          description = "Zot OCI Registry";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${zot}/bin/zot serve /etc/zot/config.yaml";
            Restart = "always";
            User = "zot";
            Group = "zot";
            AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
            NoNewPrivileges = true;
          };
        };

      };
    };
  };
}
