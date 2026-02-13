-- nvim-java-creator.nvim
-- A powerful Neovim plugin for creating Java files with multi-module support

local M = {}

local config = require('java-creator.config')
local core = require('java-creator.core')
local pickers = require('java-creator.pickers')

-- Setup function
function M.setup(opts)
  config.setup(opts or {})

  -- Set up keymaps if enabled
  if config.options.keymaps and config.options.keymaps ~= false then
    local keymaps = config.options.keymaps

    vim.keymap.set('n', keymaps.create_class, M.create_class, {
      desc = 'Create Java class'
    })

    vim.keymap.set('n', keymaps.create_with_picker, M.create_with_picker, {
      desc = 'Create Java file (with type picker)'
    })

    vim.keymap.set('n', keymaps.create_test, M.create_test, {
      desc = 'Create Java test class'
    })

    vim.keymap.set('n', keymaps.create_interface, M.create_interface, {
      desc = 'Create Java interface'
    })

    vim.keymap.set('n', keymaps.create_enum, M.create_enum, {
      desc = 'Create Java enum'
    })

    vim.keymap.set('n', keymaps.create_abstract, M.create_abstract_class, {
      desc = 'Create Java abstract class'
    })

    vim.keymap.set('n', keymaps.create_record, M.create_record, {
      desc = 'Create Java record'
    })

    vim.keymap.set('n', keymaps.create_annotation, M.create_annotation, {
      desc = 'Create Java annotation'
    })
  end

  -- Set up commands
  vim.api.nvim_create_user_command('JavaCreate', M.create_with_picker, {
    desc = 'Create Java file with type picker'
  })

  vim.api.nvim_create_user_command('JavaCreateClass', M.create_class, {
    desc = 'Create Java class'
  })

  vim.api.nvim_create_user_command('JavaCreateTest', M.create_test, {
    desc = 'Create Java test class'
  })

  vim.api.nvim_create_user_command('JavaCreateInterface', M.create_interface, {
    desc = 'Create Java interface'
  })

  vim.api.nvim_create_user_command('JavaCreateEnum', M.create_enum, {
    desc = 'Create Java enum'
  })
end

-- Public API functions
function M.create_class()
  core.create_java_file_type('class')
end

function M.create_test()
  core.create_test_file()
end

function M.create_interface()
  core.create_java_file_type('interface')
end

function M.create_enum()
  core.create_java_file_type('enum')
end

function M.create_abstract_class()
  core.create_java_file_type('abstract')
end

function M.create_record()
  core.create_java_file_type('record')
end

function M.create_annotation()
  core.create_java_file_type('annotation')
end

function M.create_with_picker()
  pickers.show_type_picker()
end

-- Expose internal modules for advanced usage
M.config = config
M.core = core
M.pickers = pickers

return M