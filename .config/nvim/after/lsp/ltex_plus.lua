--[[
  Configure ltex_plus and implement ltex commands.
--]]

local function ltex_command(setting, id)
  return function(command, ctx)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      local values = client.config.settings.ltex[setting] or {}

      for lang, new in pairs(command.arguments[1][id]) do
          values[lang] = vim.list_extend(values[lang] or {}, new)
      end

      client.config.settings.ltex[setting] = values
      return client.notify("workspace/didChangeConfiguration", client.config.settings)
  end
end

return {
  settings = {
    ltex = {
      language = "auto", -- using "auto" also disables spell checking (for which we use nvim)
      checkFrequency = "save",
      diagnosticSeverity = "hint",
      completionEnabled = true,
      --languageToolHttpServerUri = "https://api.languagetool.org",
      additionalRules = {
        motherTongue = "de-DE",
        languageModel = "/usr/share/ngrams", -- aur/languagetool-ngrams-{en,de,..}
        word2VecModel = "/usr/share/word2vec", -- aur/languagetool-word2vec-{en,de,..}
        enablePickyRules = true
      },
    }
  },
  on_attach = function(client)
    local namespace = vim.lsp.diagnostic.get_namespace(client.id)
    vim.diagnostic.config({virtual_text = false, signs = false}, namespace)

    -- implement ltex commands which must be handled by neovim
    vim.lsp.commands["_ltex.hideFalsePositives"] = ltex_command("hiddenFalsePositives", "falsePositives")
    vim.lsp.commands["_ltex.disableRules"] = ltex_command("disabledRules", "ruleIds")
    vim.lsp.commands["_ltex.addToDictionary"] = ltex_command("dictionary", "words")
  end
}
