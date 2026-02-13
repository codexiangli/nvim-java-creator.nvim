-- Configuration management for java-creator

local M = {}

-- Default configuration
local defaults = {
  -- Picker preference
  picker = 'auto', -- 'auto', 'snacks', 'telescope', 'fzf', 'native'

  -- Author name (auto-detected from git config)
  author = nil,

  -- Keymaps
  keymaps = {
    create_class = '<leader>jc',
    create_with_picker = '<leader>jC',
    create_test = '<leader>jt',
    create_interface = '<leader>ji',
    create_enum = '<leader>je',
    create_abstract = '<leader>ja',
    create_record = '<leader>jr',
    create_annotation = '<leader>j@',
  },

  -- Template customization
  templates = {
    class = {
      extends = nil,
      implements = {},
    },
    interface = {
      extends = {},
    },
    abstract = {
      extends = nil,
      implements = {},
    },
  },

  -- Auto-import settings
  auto_imports = {
    test = {
      'org.junit.jupiter.api.Test',
      'org.junit.jupiter.api.BeforeEach',
      'org.junit.jupiter.api.DisplayName',
    },
    annotation = {
      'java.lang.annotation.ElementType',
      'java.lang.annotation.Retention',
      'java.lang.annotation.RetentionPolicy',
      'java.lang.annotation.Target',
    },
  },

  -- Module detection settings
  module_detection = {
    max_depth = 3,
    excluded_dirs = { 'target', 'build', 'node_modules', '.git' },
    java_markers = { 'src/main/java' },
    project_markers = { 'pom.xml', 'build.gradle', 'build.gradle.kts', '.git' },
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', defaults, opts or {})

  -- Auto-detect author if not provided
  if not M.options.author then
    local git_author = vim.fn.system('git config user.name'):gsub('\n', '')
    M.options.author = git_author ~= '' and git_author or 'Unknown'
  end

  -- Auto-detect picker if set to auto
  if M.options.picker == 'auto' then
    M.options.picker = M.detect_best_picker()
  end
end

-- Detect the best available picker
function M.detect_best_picker()
  -- Check for snacks
  local has_snacks = pcall(require, 'snacks')
  if has_snacks then
    return 'snacks'
  end

  -- Check for telescope
  local has_telescope = pcall(require, 'telescope')
  if has_telescope then
    return 'telescope'
  end

  -- Check for fzf
  if vim.fn.executable('fzf') == 1 then
    return 'fzf'
  end

  -- Fallback to native
  return 'native'
end

-- Get current configuration
function M.get()
  return M.options
end

-- Validate configuration
function M.validate()
  local valid_pickers = { 'auto', 'snacks', 'telescope', 'fzf', 'native' }
  if not vim.tbl_contains(valid_pickers, M.options.picker) then
    vim.notify(
      'Invalid picker: ' .. M.options.picker .. '. Using auto-detection.',
      vim.log.levels.WARN
    )
    M.options.picker = 'auto'
  end
end

return M