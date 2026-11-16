local M = {}

M.defaults = {
  theme = "greenit",
  variant = "dark",
  transparent = false,
}

function M.greet(name)
  local message = string.format("hello, %s", name or "grub")
  return message
end

function M.apply(opts)
  opts = vim.tbl_deep_extend("force", M.defaults, opts or {})
  vim.o.termguicolors = true
  vim.o.background = opts.variant
  vim.cmd.colorscheme(opts.theme .. (opts.variant == "light" and "-light" or ""))
  return opts
end

return M
