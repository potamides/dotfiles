--[[
  This plugin defines a 'thesaurusfunc' which can read thesauri written in the
  openoffice.org mythes format. When 'thesaurusfunc' is set to this function,
  this allows users to add such thesauri to the 'thesaurus' option.

  See https://wiki.services.openoffice.org/wiki/Dictionaries
--]]

vim.openoffice = {}

function vim.openoffice.thesaurusfunc(findstart, base)
  if findstart == 1 then
    return vim.fn.match(vim.fn.getline("."):sub(1, vim.fn.col(".")), '\\k*$')
  end

  local completions = {}
  for _, file in ipairs(vim.opt_local.thesaurus:get()) do
    if vim.fn.filereadable(file) == 1 then
      local iterator = io.lines(file)
      for line in iterator do
        local term, count = unpack(vim.split(line, "|"))
        if base:lower() == term then
          for _ = 1,tonumber(count) do
            local synonyms = vim.split(iterator(), "|")
            local pos = table.remove(synonyms, 1):sub(2, -2)
            for _, entry in ipairs(synonyms) do
              local synonym, info = entry:match("^([^%p]+) ?%(?([^%p]*)%)?$")
              table.insert(completions, {
                word = synonym,
                menu = table.concat(vim.tbl_filter(function(v) return v and v ~= "" end, {pos, info}), ", ")
              })
            end
          end
        end
      end
    end
  end

  return completions
end
