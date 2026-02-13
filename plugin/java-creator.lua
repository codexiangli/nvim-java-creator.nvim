-- java-creator.nvim plugin entry point

-- Prevent loading twice
if vim.g.loaded_java_creator then
  return
end
vim.g.loaded_java_creator = 1

-- Only load for Java files or when explicitly called
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    -- Plugin is now available for Java files
    vim.b.java_creator_loaded = true
  end,
})

-- Global command for manual setup
vim.api.nvim_create_user_command('JavaCreatorSetup', function(opts)
  require('java-creator').setup(opts.args and vim.json.decode(opts.args) or {})
end, {
  nargs = '?',
  desc = 'Setup Java Creator plugin with optional configuration'
})