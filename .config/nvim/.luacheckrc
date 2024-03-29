-- vim: ft=lua tw=80

stds.nvim = {
  read_globals = { "jit" }
}
std = "lua51+nvim"

-- Ignore W211 (unused variable) with preload files.
files["**/preload.lua"] = {ignore = { "211" }}
-- Allow vim module to modify itself, but only here.
files["src/nvim/lua/vim.lua"] = {ignore = { "122/vim" }}

-- Don't report unused self arguments of methods.
self = false

-- Rerun tests only if their modification time changed.
cache = true

ignore = {
  "631",  -- max_line_length
  "212/_.*",  -- unused argument, for vars with "_" prefix
}

-- Global objects defined by the C code
globals = {
  "vim",
}
