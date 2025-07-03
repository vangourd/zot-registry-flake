{
  description = "Zot flake with systemd service";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    zot = pkgs.callPackage ./default.nix {};
  in {
    packages.${system}.zot = zot;

    nixosModules.zotModule = { lib, pkgs, config, ... }: 
    with lib;
    let
      cfg = config.services.zot;
    in {
      options = {
        services.zot = {
          enable = lib.mkEnableOption "Enable Module";
          configFile = lib.mkOption {
            type = lib.types.path;
            default = ./examples/config-anonymous-authz.yaml;
            description = "Path to config.yaml";
          };
        };
      };

      config = lib.mkIf cfg.enable {

        environment.systemPackages = [ zot ];
        environment.etc."zot/config.yaml".source = cfg.configFile;

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

        systemd.tmpfiles.rules = [
          "d /tmp/zot 0755 zot zot -"
        ];

      };
    };
  };
}
