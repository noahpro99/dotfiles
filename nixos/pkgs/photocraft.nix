{ pkgs, ... }:

let
  pname = "photocraft";
  version = "0.12.0";

  src = pkgs.fetchurl {
    url = "https://github.com/storytold/photocraft/releases/download/v${version}/photocraft-${version}-linux-x86_64.tar.gz";
    sha256 = "fb2b830230e3202a1ee18ec20e3f6d250d276b165d78811e83eb6a75725f9ce2";
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
    libxcb
  ];

  # the tarball is already an FHS tree (bin/, share/)
  installPhase = ''
    mkdir -p $out
    cp -r bin share $out/
  '';

  meta = with pkgs.lib; {
    description = "PhotoCraft - open-source photo and layered PSD editor written in Rust";
    homepage = "https://github.com/storytold/photocraft";
    license = with licenses; [ mit asl20 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "photocraft";
  };
}
