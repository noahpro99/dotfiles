{ pkgs, ... }:

{
  boot.kernelParams = [ "hugepages=1280" ];

  # Home Assistant (Docker) web UI — allow access from the local network.
  # (tailscale0 is already trusted in server.nix, which is why the tailnet URL works.)
  networking.firewall.allowedTCPPorts = [ 8123 ];

  # Persistent swap (declarative). A runtime /swapfile was activated 2026-08-08;
  # this makes it survive reboots. Matches macbook-air-b's swapDevices.
  swapDevices = [
    { device = "/swapfile"; size = 4096; }
  ];

  systemd.services.xmrig = {
    description = "XMRig Monero Miner";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xmrig}/bin/xmrig -o 100.99.222.43:3333 -u 44Zby4fvfieUgu1JpvR7ajfCnh5beestVg7QF6oMPH215U7DpvtByaKhUAVhEmuDmoFj56oU1Aj1jFWZpNBbt7uuNbHKd8Y --rig-id macbook-air-a --keepalive";
      Restart = "always";
      Nice = 10;
      CapabilityBoundingSet = "CAP_SYS_RAWIO";
      AmbientCapabilities = "CAP_SYS_RAWIO";
      User = "root";
    };
  };
}
