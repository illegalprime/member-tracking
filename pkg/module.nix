{ config, lib, pkgs, ...}:
with lib;
let
  member-tracking = import ./.;
  cfg = config.services.member-tracking;
in
{
  options.services.member-tracking = {
    port = mkOption { type = types.int; default = 8484; };
    useSSL = mkOption { type = types.bool; default = true; };
    forceSSL = mkOption { type = types.bool; default = true; };
    virtualhost = mkOption { type = types.str; };
  };

  config = {
    services.nginx.virtualHosts."${cfg.virtualhost}" = {
      enableACME = cfg.useSSL;
      forceSSL = cfg.useSSL && cfg.forceSSL;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
        proxyWebsockets = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "member-tracking" ];
      ensureUsers = [{
        name = "member-tracking";
        ensurePermissions = {
          "DATABASE member-tracking" = "ALL PRIVILEGES";
        };
      }];
    };

    systemd.services.member-tracking = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        EnvironmentFile = ["/run/keys/member-tracking"];
        Environment = [
          "PORT=${toString cfg.port}"
          "PHX_HOST=${cfg.virtualhost}"
          "DATABASE_URL=ecto://member-tracking:member-tracking@localhost/member-tracking"
        ];
        User = "member-tracking";
        Group = "member-tracking";
        ExecStartPre = let
          passwd_set = "ALTER USER member-tracking PASSWORD 'member-tracking';";
        in pkgs.writeShellScript "member-tracking-pre" ''
          set -x
          ${pkgs.postgresql}/bin/psql -c "${passwd_set}"
          ${member-tracking}/bin/migrate
        '';
        ExecStart = "${member-tracking}/bin/server";
      };
    };

    users.users.member-tracking = {
      isSystemUser = true;
      createHome = true;
      group = "member-tracking";
    };
    users.groups.member-tracking = { };
  };
}
