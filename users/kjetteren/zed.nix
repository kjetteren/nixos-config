{ pkgs, lib, ... }: {
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "toml" ];
    extraPackages = with pkgs; [
      rust-analyzer
      taplo
      clang-tools
      pyright
      nixfmt
      nixd
      nodejs
      package-version-server
    ];
    userSettings = {
      theme = {
        mode = "system";
        dark = "One Dark";
        light = "One Light";
      };
      hour_format = "hour24";
      load_direnv = "shell_hook";
      agent_servers."Claude Code" = {
        type = "custom";
        command = lib.getExe pkgs.claude-agent-acp;
        args = [ ];
        env = { };
      };
      lsp = {
        rust-analyzer = {
          binary = {
            path_lookup = true;
          };
        };
        clangd = {
          binary = {
            path_lookup = true;
          };
        };
        pyright = {
          binary = {
            path_lookup = true;
          };
        };
        nixd = {
          binary.path_lookup = true;
          settings.formatting.command = [ "nixfmt" ];
        };
        package-version-server = {
          binary.path = lib.getExe pkgs.package-version-server;
        };
      };
      languages = {
        "Rust" = {
          language_servers = [ "rust-analyzer" ];
          format_on_save = "on";
        };
        "C++" = {
          language_servers = [ "clangd" ];
          format_on_save = "on";
        };
        "Python" = {
          language_servers = [ "pyright" ];
          format_on_save = "on";
        };
        "Nix" = {
          language_servers = [ "nixd" ];
          format_on_save = "on";
        };
        "TOML" = {
          language_servers = [ "taplo" ];
          format_on_save = "on";
        };
      };
    };
  };
}
