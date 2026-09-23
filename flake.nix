{
  description = "A drawing library that targets Wayland.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib;

      nativeBuildInputs = with pkgs; [
        gcc
        pkg-config
        wayland-scanner
      ];

      buildInputs = with pkgs; [
        wayland
        wayland-protocols
        fontconfig
        pixman
        libdrm
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        inherit nativeBuildInputs buildInputs;
        packages = [ pkgs.clang-tools ];
      };

      packages.${system}.default = pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "wld";
        version = "20260811";
        src = ./.;

        __structuredAttrs = true;
        strictDeps = true;

        inherit nativeBuildInputs buildInputs;

        outputs = [
          "out"
        ];

        preConfigure = ''
          substituteInPlace config.mk \
            --replace-fail "ENABLE_DEBUG" "# ENABLE_DEBUG" \
            --replace-fail "ENABLE_DRM" "# ENABLE_DRM"
          substituteInPlace Makefile \
            --replace-fail "/usr/local" "$out"
        '';

        doInstallCheck = true;

        meta = {
          description = "A drawing library that targets Wayland.";
          homepage = "https://github.com/michaelforney/wld";
          license = lib.licenses.mit;
          platforms = lib.platforms.linux;
        };

      });
    };
}
