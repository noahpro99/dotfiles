{ ... }:

{
  # Home Assistant (Docker) web UI — allow access from the local network.
  # (tailscale0 is already trusted in server.nix, which is why the tailnet URL works.)
  networking.firewall.allowedTCPPorts = [ 8123 ];

  # Persistent swap (declarative). A runtime /swapfile was activated 2026-08-08;
  # this makes it survive reboots. Matches macbook-air-b's swapDevices.
  swapDevices = [
    { device = "/swapfile"; size = 4096; }
  ];
}
