{ pkgs, ... }:

{
    programs.zed-editor = {
        enable = true;
        package = pkgs.zed-editor; # Latest from zed-editor flake overlay
    };
}