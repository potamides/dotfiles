--[[
  This plugin defines a 'thesaurusfunc' which can read thesauri written in the
  openoffice.org mythes format. When 'thesaurusfunc' is set to this function,
  this allows users to add such thesauri to the 'thesaurus' option.

  See https://wiki.services.openoffice.org/wiki/Dictionaries
--]]

vim.openoffice = {}

function vim.openoffice.thesaurusfunc(findstart, base)
  if findstart == 1 then
    local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2]
    return vim.fn.match(line:sub(1, col), '\\k*$')
  end

  local completions, term = {}, base:lower() .. "|"
  for _, file in ipairs(vim.opt_local.thesaurus:get()) do
    if vim.fn.filereadable(file) == 1 then
      local iterator = io.lines(file)
      iterator() -- skip first line
      for line in iterator do
        if vim.startswith(line, term) then
          for _ = 1,tonumber(line:sub(#term + 1)) do
            local synonyms = vim.split(iterator(), "|")
            local pos = table.remove(synonyms, 1)
            for _, synonym in ipairs(synonyms) do
              -- remove additional information for to be inserted word which is often given in parentheses
              local insert = vim.trim(synonym:gsub("%(.-%)", ""):gsub(" +", " "))
              if insert ~= base then
                table.insert(completions, {
                  abbr = synonym,
                  word = insert,
                  menu = not vim.tbl_contains({"-", ""}, pos) and (pos:match("^%((.+)%)$") or pos) or nil
                })
              end
            end
          end
        end
      end
    end
  end

  return completions
end
