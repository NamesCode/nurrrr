{
  lib,
  config,
  nurrrr-pkgs,
  ...
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
        example = "/var/log/ddnsh.log";
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

      apiKeyFile = lib.mkOption {
        example = "/run/secrets/ddnsh-cf-apikey";
        description = ''
          WARN: THIS IS A SECRET FILE AND MUST BE KEPT AS MUCH. 
          Ensure that ONLY the user defined (default is `ddnsh`) can read this file.
          If this gets leaked ANYONE can edit you're DNS entries.

          The api key to use.
          Select the `Edit Zone` template from [here](https://dash.cloudflare.com/profile/api-tokens) and fill in the options.
          This must have edit permissions.
        '';
        type = lib.types.path;
      };

      # Systemd
      delay = lib.mkOption {
        default = "5m";
        example = "5m";
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
        default = "ddnsh";
        example = "ddnsh";
        description = ''
          The user {command}`ddnsh` is run as.
          User or group needs write permission
          for the specified {option}`path`.
        '';
        type = lib.types.str;
      };
    };
  };
  config = lib.mkIf cfg.enable {
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
      script = ''
        DDNSH_CF_ZONEID="${cfg.zoneId}" \
        DDNSH_CF_APIKEY="$(cat ${cfg.apiKeyFile})" \
        ${nurrrr-pkgs.ddnsh}/bin/ddnsh >> ${cfg.logLocation}
      '';
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
      };
    };
  };
}
