{
  pkgs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "btop-rocm" ''
      exec ${pkgs.btop-rocm}/bin/btop "$@"
    '')
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
  ];
}
