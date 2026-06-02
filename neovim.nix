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
      modus-themes-nvim
      lualine-nvim
    ];
    initLua = ''
      -- =============================================================================
      -- CORE SETTINGS
      -- =============================================================================

      vim.opt.number = true          -- line numbers
      vim.opt.relativenumber = true  -- relative line numbers
      vim.opt.cursorline = true      -- highlight current line

      -- Indentation
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.softtabstop = 2
      vim.opt.expandtab = true       -- spaces instead of tabs
      vim.opt.smartindent = true

      -- Search
      vim.opt.ignorecase = true
      vim.opt.smartcase = true       -- case-sensitive if uppercase used
      vim.opt.hlsearch = true
      vim.opt.incsearch = true

      -- Splits
      vim.opt.splitbelow = true
      vim.opt.splitright = true

      -- UI
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes"
      vim.opt.scrolloff = 8
      vim.opt.wrap = false

      -- Files
      vim.opt.undofile = true
      vim.opt.swapfile = false
      vim.opt.backup = false
      vim.opt.updatetime = 250

      -- Clipboard
      vim.opt.clipboard = "unnamedplus"

      -- =============================================================================
      -- KEYMAPS
      -- =============================================================================

      vim.g.mapleader = " "

      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
      end

      -- Clear search highlight
      map("n", "<Esc>", "<cmd>nohlsearch<CR>")

      -- Better window navigation
      map("n", "<C-h>", "<C-w>h", "Window left")
      map("n", "<C-j>", "<C-w>j", "Window down")
      map("n", "<C-k>", "<C-w>k", "Window up")
      map("n", "<C-l>", "<C-w>l", "Window right")

      -- Move lines in visual mode
      map("v", "J", ":m '>+1<CR>gv=gv", "Move line down")
      map("v", "K", ":m '<-2<CR>gv=gv", "Move line up")

      -- Keep cursor centered on search
      map("n", "n", "nzzzv")
      map("n", "N", "Nzzzv")

      -- Keep cursor in place on J (join lines)
      map("n", "J", "mzJ`z")

      -- Stay in indent mode
      map("v", "<", "<gv")
      map("v", ">", ">gv")

      -- Paste without losing register
      map("v", "p", '"_dP', "Paste without yanking")

      -- Buffer navigation
      map("n", "<leader>bn", "<cmd>bnext<CR>", "Next buffer")
      map("n", "<leader>bp", "<cmd>bprev<CR>", "Prev buffer")
      map("n", "<leader>bd", "<cmd>bdelete<CR>", "Delete buffer")

      -- Quick file explorer (built-in netrw)
      map("n", "<leader>e", "<cmd>Explore<CR>", "File explorer")

      -- =============================================================================
      -- PLUGINS
      -- =============================================================================

      local telescope = require("telescope")
      telescope.setup()
      telescope.load_extension("fzf")

      local builtin = require("telescope.builtin")
      map("n", "<leader>ff", builtin.find_files, "Telescope find files")
      map("n", "<leader>fg", builtin.live_grep, "Telescope live grep")
      map("n", "<leader>fb", builtin.buffers, "Telescope buffers")
      map("n", "<leader>fh", builtin.help_tags, "Telescope help tags")

      vim.cmd.colorscheme('modus_vivendi')
      require("lualine").setup()
    '';
  };
}
