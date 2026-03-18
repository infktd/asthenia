# Crush TUI - local LLM via Ollama
{ config, pkgs, ... }: {
  home.packages = [ pkgs.crush ];
  xdg.configFile."crush/crush.json".text = builtins.toJSON {
    "$schema" = "https://charm.land/crush.json";
    providers.ollama = {
      id = "ollama"; name = "Local Ollama";
      base_url = "http://localhost:11434/v1"; api_key = "ollama";
      models = map (m: m // {
        cost_per_1m_in = 0; cost_per_1m_out = 0;
        cost_per_1m_in_cached = 0; cost_per_1m_out_cached = 0;
        context_window = 32768; default_max_tokens = 8192;
        supports_attachments = false; options = {};
      }) [
        { id = "qwen2.5-coder:14b"; name = "Qwen Coder 14B"; can_reason = false; }
        { id = "deepseek-r1:14b"; name = "DeepSeek R1 14B"; can_reason = true; }
        { id = "qwen3:14b"; name = "Qwen3 14B"; can_reason = false; }
      ];
    };
    models = {
      large = { model = "qwen2.5-coder:14b"; provider = "ollama"; };
      small = { model = "deepseek-r1:14b"; provider = "ollama"; };
    };
  };
}
