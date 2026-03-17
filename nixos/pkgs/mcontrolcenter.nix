{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenv.mkDerivation rec {
  pname = "mcontrolcenter";
  version = "0.3.4";

  src = pkgs.fetchFromGitHub {
    owner = "dmitry-s93";
    repo = "MControlCenter";
    rev = "v${version}";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    # TODO: Update the hash after first build attempt
    # nix will provide the correct hash when it fails
  };

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = with pkgs; [
    qt6.qtbase
    qt6.qttools
    libqalculate
  ];

  meta = with pkgs.lib; {
    description = "Control application for MSI laptops";
    homepage = "https://github.com/dmitry-s93/MControlCenter";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
