local M = {}

function M.setup(opts)
  opts = opts or {}
  if opts.termguicolors ~= false then
    vim.o.termguicolors = true
  end
  if opts.background then
    vim.o.background = opts.background
  end
  vim.cmd.colorscheme(opts.variant == "light" and "greenit-light" or "greenit")
end

return M
