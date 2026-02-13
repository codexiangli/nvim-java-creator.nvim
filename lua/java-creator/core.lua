-- Core functionality for java-creator

local M = {}
local config = require('java-creator.config')

-- Find project root directory
local function find_project_root()
  local markers = config.get().module_detection.project_markers
  local path = vim.fn.expand('%:p:h')

  while path ~= '/' do
    for _, marker in ipairs(markers) do
      if vim.fn.filereadable(path .. '/' .. marker) == 1 then
        return path
      end
    end
    path = vim.fn.fnamemodify(path, ':h')
  end
  return vim.fn.getcwd()
end

-- Find all Java modules in the project
local function find_modules(root)
  local modules = {}
  local opts = config.get().module_detection

  local function scan_directory(dir, depth)
    if depth > opts.max_depth then
      return
    end

    local handle = vim.loop.fs_scandir(dir)
    if not handle then
      return
    end

    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then
        break
      end

      if type == 'directory' and not vim.tbl_contains(opts.excluded_dirs, name) then
        local subdir = dir .. '/' .. name

        -- Check if this directory is a Java module
        for _, marker in ipairs(opts.java_markers) do
          local java_src = subdir .. '/' .. marker
          if vim.fn.isdirectory(java_src) == 1 then
            local escaped_root = root:gsub('([%(%)%.%%%+%-%*%?%[%^%$%]])', '%%%1')
            local rel_path = subdir:gsub('^' .. escaped_root .. '/', '')
            table.insert(modules, {
              name = name,
              path = rel_path,
              full_path = subdir,
              java_src = java_src,
              java_src_rel = rel_path .. '/' .. marker
            })
            goto continue
          end
        end

        -- Continue scanning subdirectories
        scan_directory(subdir, depth + 1)
        ::continue::
      end
    end
  end

  scan_directory(root, 0)

  -- If no modules found, create a default one
  if #modules == 0 then
    local default_java_src = root .. '/src/main/java'
    table.insert(modules, {
      name = 'default',
      path = '.',
      full_path = root,
      java_src = default_java_src,
      java_src_rel = 'src/main/java'
    })
  end

  return modules
end

-- Intelligently guess the current module
local function guess_current_module(modules, current_file)
  local current_dir = vim.fn.expand('%:p:h')
  local best_match = nil
  local best_match_len = 0

  for _, module in ipairs(modules) do
    local module_path = module.full_path
    if current_dir:find(module_path, 1, true) == 1 then
      if #module_path > best_match_len then
        best_match = module
        best_match_len = #module_path
      end
    end
  end

  return best_match or modules[1]
end

-- Guess package name from current path
local function guess_package_from_path(module, current_file)
  local current_dir = vim.fn.expand('%:p:h')
  local java_src = module.java_src

  if current_dir:find(java_src, 1, true) == 1 then
    local escaped_java_src = java_src:gsub('([%(%)%.%%%+%-%*%?%[%^%$%]])', '%%%1')
    local package_path = current_dir:gsub('^' .. escaped_java_src .. '/?', '')

    if package_path == '' then
      return ''
    end

    return package_path:gsub('/', '.')
  end

  return ''
end

-- Display module selection menu
local function select_module(modules, current_module)
  if #modules == 1 then
    return modules[1]
  end

  print('=== Java Modules Found ===')
  for i, module in ipairs(modules) do
    local marker = (module == current_module) and ' (current)' or ''
    local status = vim.fn.isdirectory(module.java_src) == 1 and '✓' or '✗'
    print(string.format('%d. %s %s (%s)%s', i, status, module.name, module.path, marker))
  end
  print('')

  local choice = vim.fn.input('Select module (Enter for current, 1-' .. #modules .. '): ')
  if choice == '' then
    return current_module
  else
    local idx = tonumber(choice)
    if idx and idx >= 1 and idx <= #modules then
      return modules[idx]
    else
      print('Invalid choice, using current module')
      return current_module
    end
  end
end

-- Generate Java file content based on type
local function generate_java_content(java_type, class_name, package_name)
  local content = {}
  local opts = config.get()
  local author = opts.author
  local date = os.date('%Y-%m-%d')

  -- Package declaration
  if package_name ~= '' then
    table.insert(content, 'package ' .. package_name .. ';')
    table.insert(content, '')
  end

  -- Import statements
  local imports = {}

  if java_type == 'annotation' and opts.auto_imports.annotation then
    for _, import in ipairs(opts.auto_imports.annotation) do
      table.insert(imports, 'import ' .. import .. ';')
    end
  end

  if #imports > 0 then
    for _, import in ipairs(imports) do
      table.insert(content, import)
    end
    table.insert(content, '')
  end

  -- JavaDoc comment
  table.insert(content, '/**')
  table.insert(content, ' * ' .. class_name)
  table.insert(content, ' *')
  table.insert(content, ' * @author ' .. author)
  table.insert(content, ' * @date ' .. date)
  table.insert(content, ' */')

  -- Class/interface/enum declaration
  local template_opts = opts.templates[java_type] or {}

  if java_type == 'class' then
    local declaration = 'public class ' .. class_name
    if template_opts.extends then
      declaration = declaration .. ' extends ' .. template_opts.extends
    end
    if template_opts.implements and #template_opts.implements > 0 then
      declaration = declaration .. ' implements ' .. table.concat(template_opts.implements, ', ')
    end
    table.insert(content, declaration .. ' {')
    table.insert(content, '    ')
    table.insert(content, '}')

  elseif java_type == 'interface' then
    local declaration = 'public interface ' .. class_name
    if template_opts.extends and #template_opts.extends > 0 then
      declaration = declaration .. ' extends ' .. table.concat(template_opts.extends, ', ')
    end
    table.insert(content, declaration .. ' {')
    table.insert(content, '    ')
    table.insert(content, '}')

  elseif java_type == 'enum' then
    table.insert(content, 'public enum ' .. class_name .. ' {')
    table.insert(content, '    ')
    table.insert(content, '    ;')
    table.insert(content, '    ')
    table.insert(content, '}')

  elseif java_type == 'abstract' then
    local declaration = 'public abstract class ' .. class_name
    if template_opts.extends then
      declaration = declaration .. ' extends ' .. template_opts.extends
    end
    if template_opts.implements and #template_opts.implements > 0 then
      declaration = declaration .. ' implements ' .. table.concat(template_opts.implements, ', ')
    end
    table.insert(content, declaration .. ' {')
    table.insert(content, '    ')
    table.insert(content, '}')

  elseif java_type == 'record' then
    table.insert(content, 'public record ' .. class_name .. '(')
    table.insert(content, '    ')
    table.insert(content, ') {')
    table.insert(content, '    ')
    table.insert(content, '}')

  elseif java_type == 'annotation' then
    table.insert(content, '@Target(ElementType.TYPE)')
    table.insert(content, '@Retention(RetentionPolicy.RUNTIME)')
    table.insert(content, 'public @interface ' .. class_name .. ' {')
    table.insert(content, '    ')
    table.insert(content, '}')
  end

  return content
end

-- Generate test file content
local function generate_test_content(class_name, package_name)
  local content = {}
  local opts = config.get()
  local author = opts.author
  local date = os.date('%Y-%m-%d')

  if package_name ~= '' then
    table.insert(content, 'package ' .. package_name .. ';')
    table.insert(content, '')
  end

  -- Test imports
  if opts.auto_imports.test then
    for _, import in ipairs(opts.auto_imports.test) do
      table.insert(content, 'import ' .. import .. ';')
    end
    table.insert(content, '')
  end

  -- JavaDoc
  table.insert(content, '/**')
  table.insert(content, ' * ' .. class_name)
  table.insert(content, ' *')
  table.insert(content, ' * @author ' .. author)
  table.insert(content, ' * @date ' .. date)
  table.insert(content, ' */')
  table.insert(content, 'class ' .. class_name .. ' {')
  table.insert(content, '    ')
  table.insert(content, '    @BeforeEach')
  table.insert(content, '    void setUp() {')
  table.insert(content, '        ')
  table.insert(content, '    }')
  table.insert(content, '    ')
  table.insert(content, '    @Test')
  table.insert(content, '    @DisplayName("测试描述")')
  table.insert(content, '    void testSomething() {')
  table.insert(content, '        ')
  table.insert(content, '    }')
  table.insert(content, '}')

  return content
end

-- Create Java file with specified type
function M.create_java_file_type(java_type)
  local project_root = find_project_root()
  local modules = find_modules(project_root)

  if #modules == 0 then
    print('❌ No Java modules found in project')
    return
  end

  local current_module = guess_current_module(modules, vim.fn.expand('%:p'))
  local selected_module = select_module(modules, current_module)

  local type_label = java_type == 'interface' and 'Interface' or
                    java_type == 'enum' and 'Enum' or
                    java_type == 'abstract' and 'Abstract class' or
                    java_type == 'record' and 'Record' or
                    java_type == 'annotation' and 'Annotation' or
                    'Class'

  local class_name = vim.fn.input(type_label .. ' name: ')
  if class_name == '' then
    print('Cancelled')
    return
  end

  local suggested_package = guess_package_from_path(selected_module, vim.fn.expand('%:p'))
  local package_prompt = 'Package'
  if suggested_package ~= '' then
    package_prompt = package_prompt .. ' (default: ' .. suggested_package .. ')'
  end

  local package_name = vim.fn.input(package_prompt .. ': ')
  if package_name == '' then
    package_name = suggested_package
  end

  -- Build file path
  local package_path = package_name:gsub('%.', '/')
  local target_dir = selected_module.java_src
  if package_path ~= '' then
    target_dir = target_dir .. '/' .. package_path
  end
  local full_path = target_dir .. '/' .. class_name .. '.java'

  -- Check if file exists
  if vim.fn.filereadable(full_path) == 1 then
    local overwrite = vim.fn.input('File exists! Overwrite? (y/N): ')
    if overwrite:lower() ~= 'y' then
      print('Cancelled')
      return
    end
  end

  -- Create directory and file
  vim.fn.system('mkdir -p ' .. target_dir)
  local content = generate_java_content(java_type, class_name, package_name)
  vim.fn.writefile(content, full_path)

  -- Open file and position cursor
  vim.cmd('edit ' .. full_path)

  if java_type == 'enum' then
    vim.cmd('normal! ' .. (#content - 3) .. 'G$')
  elseif java_type == 'record' then
    vim.cmd('normal! ' .. (#content - 3) .. 'G$')
  else
    vim.cmd('normal! ' .. (#content - 1) .. 'G$')
  end

  print('✅ Created ' .. java_type .. ': ' .. full_path:gsub('^' .. project_root .. '/', ''))
end

-- Create test file
function M.create_test_file()
  local project_root = find_project_root()
  local modules = find_modules(project_root)

  if #modules == 0 then
    print('❌ No Java modules found in project')
    return
  end

  local current_module = guess_current_module(modules, vim.fn.expand('%:p'))
  local selected_module = select_module(modules, current_module)

  local class_name = vim.fn.input('Test class name (without Test suffix): ')
  if class_name == '' then
    return
  end

  if not class_name:match('Test$') then
    class_name = class_name .. 'Test'
  end

  local suggested_package = guess_package_from_path(selected_module, vim.fn.expand('%:p'))
  local package_name = vim.fn.input('Package (default: ' .. suggested_package .. '): ')
  if package_name == '' then
    package_name = suggested_package
  end

  -- Build test file path
  local test_src = selected_module.full_path .. '/src/test/java'
  local package_path = package_name:gsub('%.', '/')
  local target_dir = test_src
  if package_path ~= '' then
    target_dir = target_dir .. '/' .. package_path
  end
  local full_path = target_dir .. '/' .. class_name .. '.java'

  vim.fn.system('mkdir -p ' .. target_dir)
  local content = generate_test_content(class_name, package_name)
  vim.fn.writefile(content, full_path)
  vim.cmd('edit ' .. full_path)
  vim.cmd('normal! ' .. (#content - 3) .. 'G$')

  print('✅ Created test: ' .. full_path:gsub('^' .. project_root .. '/', ''))
end

return M