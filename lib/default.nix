{ lib }:

{
  # Extract the executable path from a package
  # Usage: lib.exe pkgs.fish => "/nix/store/.../bin/fish"
  exe = pkg: "${lib.getBin pkg}/bin/${pkg.pname or pkg.name}";

  # Remove newline from string
  removeNewline = str: lib.strings.removeSuffix "\n" str;

  # Secret management helper
  # Usage: lib.secretManager.readSecret "path/to/secret"
  secretManager = {
    readSecret = path: builtins.readFile path;
  };
}
