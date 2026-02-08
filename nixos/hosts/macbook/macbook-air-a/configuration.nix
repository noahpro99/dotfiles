{ pkgs, ... }:

{
  boot.kernelParams = [ "hugepages=1280" ];

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
