{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;  # or pkgs.firefox-beta, pkgs.firefox-esr
    
    profiles.default = {
      id = 0;
      
      settings = {
        # Basic privacy & QoL settings
        "browser.startup.homepage" = "about:blank";
        "privacy.donottrackheader.enabled" = true;
        "browser.shell.checkDefaultBrowser" = false;
        
        # Disable telemetry
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;
      };
    };
  };
}
