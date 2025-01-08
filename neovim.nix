{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      telescope-fzf-native-nvim
      (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          markdown
          markdown_inline
        ]
      ))
    ];
    extraLuaConfig = ''
      vim.opt.undofile = true
      vim.opt.expandtab = true
      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.shiftwidth = 2

      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      local telescope = require('telescope')
      telescope.setup()
      telescope.load_extension('fzf')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

      require('nvim-treesitter.configs').setup({
        auto_install = false,
        sync_install = false,
        highlight = {
          enable = true
        }
      })
    '';
  };
}
