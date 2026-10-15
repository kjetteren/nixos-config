{ pkgs, ... }: {
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "toml" ];
    extraPackages = with pkgs; [
      rust-analyzer
      taplo
      clang-tools
      pyright
      nixd
    ];
    userSettings = {
      theme = {
        mode = "system";
        dark = "One Dark";
        light = "One Light";
      };
      hour_format = "hour24";
      load_direnv = "shell_hook";
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
