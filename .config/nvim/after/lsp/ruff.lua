--[[
  Configure Ruff as a formatter and use (based)pyright as a linter.
]]--

return {
  init_options = {
    settings = {
    -- use pyrights import organizer
      organizeImports = false,
      lineLength = vim.filetype.get_option("python", "textwidth"),
      lint = {
        -- use Ruff exclusively as a formatter
        enable = false
      }
    }
  }
}
