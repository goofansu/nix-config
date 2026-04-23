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
      lazygit-nvim
      modus-themes-nvim
      lualine-nvim
      bufferline-nvim
      neo-tree-nvim
      nui-nvim
      plenary-nvim
    ];
    extraLuaConfig = ''
      vim.opt.undofile = true
      vim.opt.cmdheight = 0
      vim.opt.expandtab = true
      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.shiftwidth = 2

      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      vim.cmd.colorscheme('modus_vivendi')
      vim.api.nvim_set_hl(0, 'NeoTreeNormal', { bg = '#000000' })
      vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { bg = '#000000' })
      vim.api.nvim_set_hl(0, 'NeoTreeEndOfBuffer', { bg = '#000000' })

      local telescope = require('telescope')
      telescope.setup()
      telescope.load_extension('fzf')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
      vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })

      -- Neo-tree
      require('neo-tree').setup({})
      vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<cr>', { desc = 'Toggle file explorer' })
      vim.api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup('Neotree_start_directory', { clear = true }),
        once = true,
        callback = function()
          if package.loaded['neo-tree'] then return end
          local stats = vim.uv.fs_stat(vim.fn.argv(0))
          if stats and stats.type == 'directory' then
            require('neo-tree')
          end
        end,
      })

      -- Bufferline
      require('bufferline').setup({
        options = {
          always_show_bufferline = false,
          offsets = {
            {
              filetype = 'neo-tree',
              text = 'Neo-tree',
              highlight = 'Directory',
              text_align = 'left',
            },
          },
        },
      })
      vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev buffer' })
      vim.keymap.set('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })

      -- Lualine
      require('lualine').setup({ options = { theme = 'auto' } })
    '';
  };
}
