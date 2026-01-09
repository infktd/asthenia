{ callPackage, ... }:

{
  # Example of how to package scripts
  # hello-nix = callPackage ./example-script.nix { };
  
  # Helper script for rebuilding NixOS and Home Manager
  asthenia = callPackage ./asthenia.nix { };
}
