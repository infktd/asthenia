{ config, pkgs, ... }:

{
  # 1. Install the package
  # Note: If 'crush' isn't in your nixpkgs channel yet,
  # you can use pkgs.charm-freeze or similar, but assuming it's available:
  home.packages = [
    pkgs.crush
  ];

  # 2. Manage the configuration file
  # This places the config at ~/.config/crush/crush.json
  xdg.configFile."crush/crush.json".text = builtins.toJSON {
    "$schema" = "https://charm.land/crush.json";

    # Define Ollama as the provider
    providers = {
      ollama = {
        id = "ollama";
        name = "Local Ollama";
        base_url = "http://localhost:11434/v1";
        api_key = "ollama"; # Ollama doesn't require a real key, but Crush expects a string
      };
    };

    # Set your 3080-optimized Qwen model as the default
    models = [
      {
        id = "qwen2.5-coder:14b";
        name = "Qwen Coder 14B";
        provider = "ollama";
        default = true;
      }
      {
        id = "deepseek-r1:14b";
        name = "DeepSeek Reasoning";
        provider = "ollama";
      }
      {
        id = "qwen3:14b";
        name = "Qwen Coder 14B";
        provider = "ollama";
      }
    ];

    # Optional: UI Preferences
    ui = {
      theme = "charm";
      border = "rounded";
    };
  };
}
