{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      telescope-nvim
      plenary-nvim
      telescope-fzf-native-nvim
    ];
    extraLuaConfig = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "
      require("lazy").setup(
        {
          {
            'nvim-telescope/telescope.nvim',
            dependencies = {
              'nvim-lua/plenary.nvim',
              'nvim-telescope/telescope-fzf-native.nvim'
            },
            config = function()
              local telescope = require('telescope')
              local builtin = require('telescope.builtin')

              telescope.setup({
                defaults = {
                  mappings = {
                    i = {
                      ["<C-j>"] = "move_selection_next",
                      ["<C-k>"] = "move_selection_previous",
                    },
                  },
                  file_ignore_patterns = {
                    "node_modules",
                    ".git"
                  }
                }
              })

              telescope.load_extension('fzf')

              -- Keymaps
              vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
              vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
              vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
            end
          },
        },
        {
          rocks = { enabled = false },
          install = { missing = false },
          checker = { enabled = false }
        }
      )
    '';
  };
}
