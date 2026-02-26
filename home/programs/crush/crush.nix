{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.crush
  ];

  xdg.configFile."crush/crush.json".text = builtins.toJSON {
    "$schema" = "https://charm.land/crush.json";

    providers = {
      ollama = {
        id = "ollama";
        name = "Local Ollama";
        base_url = "http://localhost:11434/v1";
        api_key = "ollama";
        models = [
          {
            id = "qwen2.5-coder:14b";
            name = "Qwen Coder 14B";
            cost_per_1m_in = 0;
            cost_per_1m_out = 0;
            cost_per_1m_in_cached = 0;
            cost_per_1m_out_cached = 0;
            context_window = 32768;
            default_max_tokens = 8192;
            can_reason = false;
            supports_attachments = false;
            options = {};
          }
          {
            id = "deepseek-r1:14b";
            name = "DeepSeek R1 14B";
            cost_per_1m_in = 0;
            cost_per_1m_out = 0;
            cost_per_1m_in_cached = 0;
            cost_per_1m_out_cached = 0;
            context_window = 32768;
            default_max_tokens = 8192;
            can_reason = true;
            supports_attachments = false;
            options = {};
          }
          {
            id = "qwen3:14b";
            name = "Qwen3 14B";
            cost_per_1m_in = 0;
            cost_per_1m_out = 0;
            cost_per_1m_in_cached = 0;
            cost_per_1m_out_cached = 0;
            context_window = 32768;
            default_max_tokens = 8192;
            can_reason = false;
            supports_attachments = false;
            options = {};
          }
        ];
      };
    };

    models = {
      large = {
        model = "qwen2.5-coder:14b";
        provider = "ollama";
      };
      small = {
        model = "deepseek-r1:14b";
        provider = "ollama";
      };
    };
  };
}
