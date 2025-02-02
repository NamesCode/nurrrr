{
  lib,
  config,
  nurrrr-pkgs,
  pkgs,
}:
let
  cfg = config.services.ddnsh;
in
{
  options = {
    services.ddnsh = {
      enable = lib.mkEnableOption "ddnsh";

      # Config
      logLocation = lib.mkOption {
        default = "/var/log/ddnsh.log";
        description = "Filepath for logs.";
        type = lib.types.str;
      };

      # Cloudflare
      zoneId = lib.mkOption {
        description = ''
          The zoneId for your domain.
          You can find out where to find it [here](https://developers.cloudflare.com/fundamentals/setup/find-account-and-zone-ids/).
        '';
        type = lib.types.str;
      };

      apiKey = lib.mkOption {
        description = ''
          The api key to use.
          Select the `Edit Zone` template from [here](https://dash.cloudflare.com/profile/api-tokens) and fill in the options.
          This must have edit permissions.
        '';
        type = lib.types.str;
      };

      # Systemd
      delay = lib.mkOption {
        default = "5m";
        description = ''
          Time taken between runs.
          Must be in the format described in
          {manpage}`systemd.time(7)`.
        '';
        type = lib.types.str;
      };

      persistentTimer = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Set the `Persistent` option for the
          {manpage}`systemd.timer(5)`
          which triggers the script immediately if the last trigger
          was missed (e.g. if the system was powered down).
        '';
        type = lib.types.bool;
      };

      user = lib.mkOption {
        type = lib.types.str;
        description = ''
          The user {command}`ddnsh` is run as.
          User or group needs write permission
          for the specified {option}`path`.
        '';
        default = "ddnsh";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      nurrrr-pkgs.ddnsh    ];

    systemd.timers."ddnsh" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        Persistent = cfg.persistentTimer;
        OnBootSec = cfg.delay;
        OnUnitActiveSec = cfg.delay;
        Unit = "ddnsh.service";
      };
    };

    systemd.services."ddnsh" = {
      # WARN: Yes, I am aware this is EXTREMELY dangerous as it enters the Nix Store as world readable
      script = ''
        DDNSH_CF_ZONEID="${cfg.zoneId}" \
        DDNSH_CF_APIKEY="${cfg.apiKey}" \
        ddnsh >> ${cfg.logLocation}
      '';
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
      };
    };
  };
}
