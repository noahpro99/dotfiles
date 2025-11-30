{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
}:

stdenv.mkDerivation rec {
  pname = "hid-apple-patched";
  version = "1c6b7874ee18860106817d7056f19e9293cf7726";

  src = fetchFromGitHub {
    owner = "free5lot";
    repo = "hid-apple-patched";
    rev = version;
    sha256 = "16pl20qrj22cn7q2igj4qx885lvlbbdylspih096cdypvpb419v6";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KVERSION=${kernel.modDirVersion}"
    "LINUX_HEADER_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "CONFIG_HID_APPLE=m"
  ];

  installPhase = ''
    install -D hid-apple.ko $out/lib/modules/${kernel.modDirVersion}/extra/hid-apple.ko
  '';

  meta = with lib; {
    description = "Patched hid-apple kernel module";
    homepage = "https://github.com/free5lot/hid-apple-patched";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
