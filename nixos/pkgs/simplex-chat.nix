{ pkgs, ... }:

let
  pname = "simplex-chat";
  version = "6.4.8";

  src = pkgs.fetchurl {
    url = "https://github.com/simplex-chat/simplex-chat/releases/download/v${version}/simplex-chat-ubuntu-22_04-x86_64";
    sha256 = "ad68643e0c7c100d2e32919b149b00f906e65aeb3dc29cb44f691abc3b015a98";
  };

in
pkgs.stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.gmp pkgs.zlib pkgs.openssl ];
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/simplex-chat
    chmod +x $out/bin/simplex-chat
  '';

  meta = with pkgs.lib; {
    description = "SimpleX Chat - the first messaging network that is 100% private by design.";
    homepage = "https://simplex.chat/";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
  };
}
