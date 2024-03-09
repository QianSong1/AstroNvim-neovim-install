local lspconfig = require("lspconfig")
return {
  -- capabilities = capabilities,
  -- cmd = { "@sumneko_lua_language_server@/bin/lua-language-server" },
  root_dir = function(file)
    return lspconfig.util.root_pattern("lua-globals", ".luacheckrc")(file)
        or lspconfig.util.find_git_ancestor(file)
        or lspconfig.util.path.dirname(file)
  end,
  on_new_config = function(new_config, new_root_dir)
    new_config.settings.Lua.diagnostics.globals = {}

    local file = io.open(new_root_dir .. "/lua-globals", "r")
    if file then
      for line in file:lines() do
        table.insert(new_config.settings.Lua.diagnostics.globals, line)
      end
      file:close()
      return
    end

    local lcrc = loadfile(new_root_dir .. "/.luacheckrc", "t", {})
    if lcrc then
      local function read_config(cfg)
        local function add_globals(globals)
          if globals then
            for _, global in pairs(globals) do
              table.insert(new_config.settings.Lua.diagnostics.globals, global)
            end
          end
        end

        add_globals(cfg.globals)
        add_globals(cfg.new_globals)
        add_globals(cfg.new_read_globals)
        add_globals(cfg.read_globals)
      end

      local lc = {}
      setfenv(lcrc, lc)
      lcrc()

      read_config(lc)
      if lc.std then
        read_config(lc.std)
      end

      if lc.files then
        for _, cfg in lc.files do
          if cfg then
            read_config(cfg)
            if cfg.std then
              read_config(cfg.std)
            end
          end
        end
      end
    end
  end,
  on_attach = function(c, buf)
    on_attach(c, buf)
    c.server_capabilities.documentFormattingProvider = false
    c.server_capabilities.documentRangeFormattingProvider = false
    for _, i in pairs(c.config.settings.Lua.diagnostics.globals) do
      if i == "vim" then
        cmp.setup.buffer({
          sources = {
            { name = "nvim_lua" },
            { name = "nvim_lsp" },
            { name = "crates" },
            { name = "path" },
            { name = "luasnip" },
            { name = "buffer",  keyword_length = 3 },
          },
        })
        break
      end
    end
  end,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim", "hs" },
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        },
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
