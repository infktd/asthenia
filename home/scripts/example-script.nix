# Example helper script
# Scripts here can be packaged and made available system-wide

{ writeShellScriptBin }:

writeShellScriptBin "hello-nix" ''
  echo "Hello from a custom Nix script!"
  echo "Add your own scripts to home/scripts/"
''
