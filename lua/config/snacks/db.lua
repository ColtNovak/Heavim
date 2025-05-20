require("snacks").setup({
  dashboard = {
    enabled = true, 
    width = 68, 
    row = 3, 
    col = nil,
    pane_gap = 3, 
    autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    preset = {
      ---@type fun(cmd:string, opts:table)|nil
      pick = nil,
      ---@type snacks.dashboard.Item[]
      keys = {
        { icon = "󰈞 ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = "󰝒 ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = "󰊄 ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = "󰋚 ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = "󰒓 ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = "󱣻 ", key = "p", desc = "Projects", action = ":lua Snacks.dashboard.pick('projects')", enabled = package.loaded.project ~= nil },
        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
        { icon = "󰦛 ", key = "s", desc = "Restore Session", section = "session", enabled = package.loaded.possession ~= nil or package.loaded.persisted ~= nil },
        { icon = "󰗼 ", key = "u", desc = "Update Plugins", action = ":Lazy sync" },
        { icon = "󰗽 ", key = "q", desc = "Quit", action = ":qa" },
      },
      header = [[
  ██╗  ██╗███████╗ █████╗ ██╗   ██╗██╗███╗   ███╗
  ██║  ██║██╔════╝██╔══██╗██║   ██║██║████╗ ████║
  ███████║█████╗  ███████║██║   ██║██║██╔████╔██║
  ██╔══██║██╔══╝  ██╔══██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║  ██║███████╗██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
    },
    formats = {
      icon = function(item)
        if item.file and (item.icon == "file" or item.icon == "directory") then
          return require("snacks.utils").icon(item.file, item.icon)
        end
        return { item.icon, width = 3, hl = "SpecialComment" } 
      end,
      key = function(item)
        return { { "[", hl = "Special" }, { item.key, hl = "Label" }, { "]", hl = "Special" } }
      end,
      footer = { "%s", align = "center", hl = "Comment" },
      header = { "%s", align = "center", hl = "Title" },
      file = function(item, ctx)
        local fname = vim.fn.fnamemodify(item.file, ":~")
        fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
        if ctx.width and #fname > ctx.width then
          local dir = vim.fn.fnamemodify(fname, ":h")
          local file = vim.fn.fnamemodify(fname, ":t")
          if dir and file then
            file = file:sub(-(ctx.width - #dir - 2))
            fname = dir .. "/…" .. file
          end
        end
        local dir, file = fname:match("^(.*)/(.+)$")
        return dir and { { dir .. "/", hl = "Directory" }, { file, hl = "Normal" } } or { { fname, hl = "Normal" } }
      end,
      desc = { "%s", hl = "String" },
      title = { "%s", hl = "Title", align = "left" },
    sections = {
      { section = "header", padding = 1 },
      { section = "keys", title = "󰌆  Menu", padding = 1, pane = 1 },
      { 
        title = "󰋚  Recent Files", 
        section = "recent_files", 
        limit = 6, 
        padding = 1, 
        pane = 2,
        format = function(item, ctx)
          local modified = (vim.fn.filereadable(item.file) == 1 and 
                          vim.fn.getftime(item.file) > os.time() - 86400) and "  " or " "
          return {
            ctx.formats.icon(item, ctx),
            { modified, hl = "Boolean" },
            ctx.formats.file(item, ctx)
          }
        end
      },
      { 
        title = "󱣻  Projects", 
        section = "projects", 
        limit = 5, 
        padding = 1, 
        pane = 2,
        enabled = package.loaded.project ~= nil or package.loaded.telescope ~= nil and package.loaded.telescope.extensions.projects ~= nil
      },
      {
        section = "terminal", 
        title = "󱄅  System",
        limit = 15, 
        padding = 1,
        pane = 2,
        cmd = "fastfetch -l none -c examples/8", 
        fallback_cmd = "fastfetch --structure Title:OS:Kernel:Uptime:Packages:Shell:DE:WM:Terminal -l none --pipe"
      },
      { 
        section = "footer", 
        title = function()
          local datetime = os.date("%a %d %b %Y | %H:%M:%S")
          local plugins = package.loaded.lazy and #vim.tbl_keys(require("lazy").plugins()) or 0
          local v = vim.version()
          return string.format("⚡ %d plugins | 🕒 %s | 🚀 v%d.%d.%d", 
            plugins, datetime, v.major, v.minor, v.patch)
        end,
        padding = 1,
        pane = 0
      },
    },
    mappings = {
      ["<Leader>d"] = function() 
        require("snacks.dashboard").open()
      end,
    },
    highlights = {
      header = { link = "Title" },
      title = { link = "Type" },
      desc = { link = "String" },
      icon = { link = "Special" },
      key = { link = "Identifier" },
    },
  }
})
