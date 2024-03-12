local map = vim.keymap.set
local config = {
  colorscheme = 'everforest',
  options = {
    opt = {
      clipboard = 'unnamedplus', -- use the system clipboard
      --colorcolumn = "80,100",
      showtabline = 0,           -- tab line is clutter for my usage
      relativenumber = false, -- sets vim.opt.relativenumber
      number = true, -- sets vim.opt.number
      spell = false, -- sets vim.opt.spell
      signcolumn = "auto", -- sets vim.opt.signcolumn to auto
      wrap = false, -- sets vim.opt.wrap
      expandtab = true, -- do expand tab to space
      shiftwidth = 8, -- auto indent have 8 space
      tabstop = 8, -- one tab have 8 space
      softtabstop = 8, -- one backspace will delete 8 space of 1 tab or 1 indentation
      guicursor= "a:blinkon100", -- enable cursor blinking
    },
  },
  icons = function()
    local myicons = require("astronvim.icons.nerd_font")
    myicons['FileModified'] = "💾"
    return myicons
  end,
  diagnostics = {
    update_in_insert = false, -- this helps see codeium suggestions clearly
  },
  plugins = {
    --{
    --  'Exafunction/codeium.vim',
    --  event = "BufReadPost",
    --  config = function()
    --    vim.keymap.set('i', '<S-Right>', function()
    --        return vim.fn['codeium#Accept']()
    --      end,
    --      { expr = true })
    --    vim.keymap.set('i', '<c-Right>', function()
    --        return vim.fn['codeium#CycleCompletions'](1)
    --      end,
    --      { expr = true })
    --    vim.g.codeium_tab_fallback = '' -- don't insert a tab
    --    vim.g.codeium_idle_delay = 1000 -- avoid frantic suggestions
    --    vim.cmd([[let g:codeium_filetypes = {
    --\ "nim": v:false,
    --\ "fish": v:false,
    --\ }]])
    --  end
    --},
    {
      "rebelot/heirline.nvim",
      opts = function(_, opts)
        local status = require("astronvim.utils.status")
        opts.statusline = {
          hl = { fg = "fg", bg = "bg" },
          status.component.mode { 
            mode_text = { padding = { left = 1, right = 1 } },
            surround = { separator = "left", color = "#611A66" },
          }, -- add the mode text
          status.component.git_branch(),
          status.component.file_info(),            -- filename & modified status
          status.component.git_diff(),
          status.component.diagnostics(),
          status.component.fill(),
          status.component.cmd_info(),
          status.component.fill(),
          status.component.lsp(),
          status.component.treesitter(),
          status.component.nav { scrollbar = false },
          -- removed right-side mode color block
        }
        return opts
      end,
    },
    {
      "Mofiqul/dracula.nvim", -- in case of issue, try catppuccin
      config = function()
        local dracula = require("dracula")
        local c = dracula.colors()
        c['bg'] = '#1A1A1A' -- the same as my terminal background
        dracula.setup({
          colors = c
        })
      end,
    },
    {
      'tpope/vim-sleuth',      -- detect indentation style
      event = "User Astrofile" -- for plugins related to "real files"
    },
    {
      'roxma/vim-paste-easy', -- paste without indent
      event = "BufReadPost"
    },
    {
      'mechatroner/rainbow_csv',
      ft = { 'csv' }
    },
    {
      'dag/vim-fish', -- highlighting for fish
      ft = { 'fish' }
    },
    {
      'alaviss/nim.nvim', -- highlighting for nim
      ft = { 'nim' }
    },
    {
      'NoahTheDuke/vim-just', -- highlighting for just
      ft = { 'just' }
    },
    {
      'AndrewRadev/inline_edit.vim', -- InlineEdit command
      event = "BufReadPost"
    },
    {
      'lukas-reineke/virt-column.nvim', -- discreet color column
      event = "BufEnter",
      opts = { char = '.' },
    },
    {
      'beauwilliams/focus.nvim', -- window management and resizing
      event = "BufEnter",
      opts = { hybridnumber = true },
      config = function()
        require('focus').setup({ hybridnumber = true })
        map("n", "g,", ":FocusSplitCycle<CR>", { desc = "Cycle Focus" })
      end,
    },
    {
      'ojroques/nvim-bufdel', -- no buffer deletion puzzles
      event = "BufReadPost",
      config = function()
        require('bufdel').setup()
        map("n", "<leader>Q", ":BufDel<CR>", { desc = "Delete Buffer" })
        map("n", "<leader>q", ":BufDel<CR>:q<CR>",
          { desc = "Delete Buffer and window" })
      end,
    },
    {
      'levouh/tint.nvim', -- unfocused windows are darker
      event = "BufReadPost",
      config = function()
        require('tint').setup({
          tint = -65,
          highlight_ignore_patterns = { "WinSeparator", "Status.*" },
        })
        -- fix neotree/tint issue not giving colors back to the text buffer
        map('n', '<leader>e', function()
            vim.cmd([[Neotree toggle]])
            local t = require("tint")
            t.toggle()
            t.toggle()
          end,
          { desc = "Toggle Explorer" })
      end
    },
    {
      'echasnovski/mini.jump2d', -- Jump around with ',' key
      version = false,
      event = "BufReadPost",
      dependencies = { 'echasnovski/mini.nvim' },
      config = function()
        local jump = require("mini.jump2d")
        local sp1 = jump.gen_pattern_spotter('[%w\'"]+', 'start')
        local sp2 = jump.gen_pattern_spotter('[{,}]$', 'start')
        local opts = {
          spotter = jump.gen_union_spotter(sp1, sp2),
          labels = "abcdefghiklmnopqrsuvwxy",
          mappings = {
            start_jumping = ',',
          },
          view = {
            n_steps_ahead = 1,
          },
        }
        jump.setup(opts)
        vim.cmd([[hi MiniJump2dSpot guifg=#FFFFEE guibg=#DD2222]])
        vim.cmd([[hi MiniJump2dSpotAhead guifg=#FFFFEE guibg=#B52222]])
      end,
    },
    {
      "folke/todo-comments.nvim",                 -- highlight todos & jump
      event = "BufReadPost",
      dependencies = { "nvim-lua/plenary.nvim" }, -- + "brew install ripgrep"
      opts = function(_, opts)
        local td = require("todo-comments")
        opts.highlight = {
          throttle = 2000,
          multiline = false,
          comments_only = true,
          pattern = { [[.*<(KEYWORDS)\s*:?]], },
        }
        return opts
      end,
    },
    {
      "folke/trouble.nvim",
      event = "BufReadPost",
      cmd = { "TroubleToggle", "Trouble" },
      keys = {
        { "<leader>x", desc = "Trouble" },
        {
          "<leader>i",
          "<cmd>TodoTrouble<cr>",
          desc = "Document TODO comments"
        },
        {
          "<leader>x" .. "X",
          "<cmd>TroubleToggle workspace_diagnostics<cr>",
          desc = "Workspace Diagnostics (Trouble)"
        },
        {
          "<leader>x" .. "x",
          "<cmd>TroubleToggle document_diagnostics<cr>",
          desc = "Document Diagnostics (Trouble)"
        },
        {
          "<leader>x" .. "l",
          "<cmd>TroubleToggle loclist<cr>",
          desc = "Location List (Trouble)"
        },
        {
          "<leader>x" .. "q",
          "<cmd>TroubleToggle quickfix<cr>",
          desc = "Quickfix List (Trouble)"
        },
      },
      opts = {
        use_diagnostic_signs = true,
        action_keys = {
          close = { "q", "<esc>" },
          cancel = "<c-e>",
        },
      },
    },
    {
      "romainl/vim-cool", -- prevent stale search highlighting
      event = "BufReadPost",
    },
    -- other plugins to consider
    -- emmet-vim, for expanding abbreviations (essential for web dev?)
    {
      "catppuccin/nvim",
      name = "catppuccin",
      config = function()
        require("catppuccin").setup {}
      end,
    },
    {
      "AstroNvim/astrocommunity",
      { import = "astrocommunity.colorscheme.everforest" },
      { import = "astrocommunity.color.transparent-nvim" },
    },
  },

  polish = function()
    -- cmd+S can save, this needs a terminal (kitty) config to send ctrl-s
    -- note: normal mode shortcut already exists in vanilla astronvim
    map("i", "<C-s>", "<Esc>:w!<CR>i", { desc = "Save in insert mode" })

    -- fix some colors
    vim.cmd([[hi WinSeparator ctermbg=NONE guibg=NONE guifg=#AA0000]])
    vim.cmd([[hi CursorLine guibg=#401A11]])
    require("notify").setup({ background_colour = "#000000" })

    -- close automatic line wrapping when a line exceeds the window width
    vim.cmd([[set nowrap]])
    -------------------------------------- shell start ---------------------------------------------
    vim.cmd([[
    autocmd BufNewFile *.sh exec ":call SeTitle()"
    func SeTitle()
    if expand("%:e")  == 'sh'
        call setline(1,"#!/bin/bash")
        call setline(2,"#")
        call setline(3,"#******************************************************************************************")
        call setline(4,"#Author:                QianSong")
        call setline(5,"#QQ:                    xxxxxxxxxx")
        call setline(6,"#Date:                  ".strftime("%Y-%m-%d"))
        call setline(7,"#FileName:              ".expand("%"))
        call setline(8,"#URL:                   https://github.com")
        call setline(9,"#Description:           The test script")
        call setline(10,"#Copyright (C):         QianSong ".strftime("%Y")." All rights reserved")
        call setline(11,"#******************************************************************************************")
        call setline(12,"")
    endif
    endfunc
    ]])
    -------------------------------------- shell end -----------------------------------------------

    map("n", "<leader>b", "<cmd>s/^ *//<cr>" ..
      "<cmd>s/$/ /<cr>" ..
      "o<esc><up>" ..
      "<cmd>.!toilet -f pagga -w 77<cr>" ..
      "<cmd>lua require('Comment.api').toggle.linewise(3)<cr>" ..
      "<down><down><down>",
      { desc = "Comment banner" })

    map('n', '<leader>gg', function()
        require("astronvim.utils").toggle_term_cmd "lazygit"
      end,
      { desc = "Toggle Lazygit" })

    map('n', '<leader>tt',
      "<cmd>TermExec size=10 direction=horizontal cmd='just tdd'<cr>",
      { desc = "TDD" })

    require("luasnip.loaders.from_vscode").lazy_load(
      { paths = { "./lua/user/vscode_snippets" } })
    require("luasnip").filetype_extend("just", { "sh" })
  end
}

return config
