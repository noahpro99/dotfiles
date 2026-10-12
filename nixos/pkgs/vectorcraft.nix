{ pkgs, ... }:

let
  pname = "vectorcraft";
  version = "0.9.0";

  src = pkgs.fetchurl {
    url = "https://github.com/storytold/vectorcraft/releases/download/v${version}/vectorcraft-${version}-linux-x86_64.tar.gz";
    sha256 = "afbc4a0904740dfd1208e717664eb294965055e74c227c2ac3dc53af502e46a4";
  };

in
pkgs.stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.stdenv.cc.cc.lib ];

  # winit/wgpu dlopen these at runtime, so they have to be on the RUNPATH
  runtimeDependencies = with pkgs; [
    wayland
    libxkbcommon
    libGL
    vulkan-loader
    dbus.lib
    libx11
    libxcursor
    libxi
  ];

  # the tarball is already an FHS tree (bin/, share/)
  installPhase = ''
    mkdir -p $out
    cp -r bin share $out/
  '';

  meta = with pkgs.lib; {
    description = "VectorCraft - open-source vector illustration tool written in Rust";
    homepage = "https://github.com/storytold/vectorcraft";
    license = with licenses; [ mit asl20 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "vectorcraft";
  };
}
