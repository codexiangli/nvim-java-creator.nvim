-- Picker implementations for java-creator

local M = {}
local config = require('java-creator.config')
local core = require('java-creator.core')

-- Java type definitions
local java_types = {
  { name = 'class', desc = 'Regular class', icon = '🏛️' },
  { name = 'interface', desc = 'Interface', icon = '🔌' },
  { name = 'enum', desc = 'Enumeration', icon = '📝' },
  { name = 'abstract', desc = 'Abstract class', icon = '🎭' },
  { name = 'record', desc = 'Record (Java 14+)', icon = '📋' },
  { name = 'annotation', desc = 'Annotation', icon = '🏷️' }
}

-- Show type picker based on configuration
function M.show_type_picker()
  local picker = config.get().picker

  if picker == 'snacks' then
    M.snacks_picker()
  elseif picker == 'telescope' then
    M.telescope_picker()
  elseif picker == 'fzf' then
    M.fzf_picker()
  else
    M.native_picker()
  end
end

-- Snacks picker implementation
function M.snacks_picker()
  -- 直接使用 vim.ui.select，由 Snacks 自动接管
  local choices = {}
  local choice_map = {}

  for i, type_info in ipairs(java_types) do
    local choice = type_info.icon .. ' ' .. type_info.name .. ' - ' .. type_info.desc
    table.insert(choices, choice)
    choice_map[choice] = type_info.name
  end

  vim.ui.select(choices, {
    prompt = 'Select Java Type: ',
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice and choice_map[choice] then
      core.create_java_file_type(choice_map[choice])
    end
  end)
end

-- Telescope picker implementation
function M.telescope_picker()
  local ok, telescope = pcall(require, 'telescope')
  if not ok then
    vim.notify('Telescope not found, falling back to native picker', vim.log.levels.WARN)
    M.native_picker()
    return
  end

  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers.new({}, {
    prompt_title = 'Select Java Type',
    finder = finders.new_table({
      results = java_types,
      entry_maker = function(entry)
        return {
          value = entry.name,
          display = entry.icon .. ' ' .. entry.name .. ' - ' .. entry.desc,
          ordinal = entry.name .. ' ' .. entry.desc,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          core.create_java_file_type(selection.value)
        end
      end)
      return true
    end,
  }):find()
end

-- FZF picker implementation
function M.fzf_picker()
  if vim.fn.executable('fzf') ~= 1 then
    vim.notify('FZF not found, falling back to native picker', vim.log.levels.WARN)
    M.native_picker()
    return
  end

  local items = {}
  for _, type_info in ipairs(java_types) do
    table.insert(items, type_info.icon .. ' ' .. type_info.name .. ' - ' .. type_info.desc)
  end

  vim.fn['fzf#run']({
    source = items,
    sink = function(selected)
      local java_type = selected:match('(%w+) %-')
      if java_type then
        core.create_java_file_type(java_type)
      end
    end,
    options = '--prompt="Java Type> " --height=40% --layout=reverse --border --no-info'
  })
end

-- Native picker implementation (fallback)
function M.native_picker()
  print('=== Select Java Type ===')
  for i, type_info in ipairs(java_types) do
    print(i .. '. ' .. type_info.name .. ' - ' .. type_info.desc)
  end

  local choice = vim.fn.input('Select type (1-' .. #java_types .. ', default: 1): ')
  if choice == '' then
    choice = '1'
  end

  local index = tonumber(choice)
  if index and index >= 1 and index <= #java_types then
    core.create_java_file_type(java_types[index].name)
  else
    print('Invalid choice')
  end
end

return M