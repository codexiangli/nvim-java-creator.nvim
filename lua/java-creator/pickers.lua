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
  local ok, snacks = pcall(require, 'snacks')
  if not ok then
    vim.notify('Snacks not available, falling back to native picker', vim.log.levels.WARN)
    M.native_picker()
    return
  end

  -- Snacks picker 期望的正确格式
  local items = {}
  for i, type_info in ipairs(java_types) do
    table.insert(items, {
      text = type_info.icon .. ' ' .. type_info.name .. ' - ' .. type_info.desc,
      value = type_info.name,
      idx = i,
    })
  end

  -- 使用正确的 Snacks picker API
  local picker_ok, err = pcall(function()
    snacks.picker.pick({
      prompt = 'Select Java Type',
      items = items,
      format = function(item, ctx)
        return item.text
      end,
      on_submit = function(item, ctx)
        if item and item.value then
          core.create_java_file_type(item.value)
        end
      end,
    })
  end)

  if not picker_ok then
    -- 如果还是失败，尝试更简单的格式
    picker_ok, err = pcall(function()
      local simple_items = {}
      for _, type_info in ipairs(java_types) do
        table.insert(simple_items, {
          text = type_info.icon .. ' ' .. type_info.name .. ' - ' .. type_info.desc,
          java_type = type_info.name,
        })
      end

      snacks.picker.select({
        prompt = 'Select Java Type',
        items = simple_items,
        format = function(item)
          return item.text
        end,
      }, function(item)
        if item and item.java_type then
          core.create_java_file_type(item.java_type)
        end
      end)
    end)
  end

  -- 最后降级到原生选择器
  if not picker_ok then
    vim.notify('Snacks picker error: ' .. (err or 'unknown'), vim.log.levels.WARN)
    M.native_picker()
  end
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