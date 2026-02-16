{ pkgs, ... }:

{
  boot.kernelParams = [ "hugepages=1280" ];

  systemd.services.monerod = {
    description = "Monero Full Node";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.monero-cli}/bin/monerod --prune-blockchain --zmq-pub tcp://127.0.0.1:18083 --rpc-bind-ip 0.0.0.0 --rpc-bind-port 18081 --confirm-external-bind --restricted-rpc --disable-dns-checkpoints --add-priority-node p2pmd.xmrvsbeast.com:18080 --add-priority-node nodes.hashvault.pro:18080 --non-interactive";
      User = "noahpro";
      Group = "users";
      Restart = "always";
      SuccessExitStatus = "0 1";
    };
  };

  systemd.services.p2pool = {
    description = "P2Pool Monero Node (Nano)";
    after = [ "monerod.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.p2pool}/bin/p2pool --host 127.0.0.1 --wallet 44Zby4fvfieUgu1JpvR7ajfCnh5beestVg7QF6oMPH215U7DpvtByaKhUAVhEmuDmoFj56oU1Aj1jFWZpNBbt7uuNbHKd8Y --nano --stratum 127.0.0.1:3333,100.99.222.43:3333";
      User = "noahpro";
      Group = "users";
      WorkingDirectory = "/home/noahpro";
      Restart = "always";
    };
  };

  systemd.services.xmrig = {
    description = "XMRig Monero Miner";
    after = [ "p2pool.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xmrig}/bin/xmrig -o 127.0.0.1:3333 -u 44Zby4fvfieUgu1JpvR7ajfCnh5beestVg7QF6oMPH215U7DpvtByaKhUAVhEmuDmoFj56oU1Aj1jFWZpNBbt7uuNbHKd8Y --rig-id macbook-air-b --keepalive";
      Restart = "always";
      Nice = 10;
      CapabilityBoundingSet = "CAP_SYS_RAWIO";
      AmbientCapabilities = "CAP_SYS_RAWIO";
      User = "root";
    };
  };
}
