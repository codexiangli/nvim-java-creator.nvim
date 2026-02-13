-- 简单的插件测试

-- 设置插件路径
vim.opt.rtp:prepend(vim.fn.getcwd())

-- 测试配置模块
local function test_config()
  local config = require('java-creator.config')

  -- 测试默认配置
  config.setup({})
  local opts = config.get()

  assert(opts.picker, 'Picker should be set')
  assert(opts.author, 'Author should be set')
  assert(opts.keymaps, 'Keymaps should be set')

  print('✅ Config module test passed')
end

-- 测试核心模块
local function test_core()
  local core = require('java-creator.core')

  -- 核心模块应该能正常加载
  assert(type(core.create_java_file_type) == 'function', 'create_java_file_type should be a function')
  assert(type(core.create_test_file) == 'function', 'create_test_file should be a function')

  print('✅ Core module test passed')
end

-- 测试选择器模块
local function test_pickers()
  local pickers = require('java-creator.pickers')

  assert(type(pickers.show_type_picker) == 'function', 'show_type_picker should be a function')
  assert(type(pickers.native_picker) == 'function', 'native_picker should be a function')

  print('✅ Pickers module test passed')
end

-- 测试主模块
local function test_main()
  local java_creator = require('java-creator')

  -- 首先执行 setup
  java_creator.setup({})

  -- 测试 API 函数
  assert(type(java_creator.setup) == 'function', 'setup should be a function')
  assert(type(java_creator.create_class) == 'function', 'create_class should be a function')
  assert(type(java_creator.create_test) == 'function', 'create_test should be a function')
  assert(type(java_creator.create_interface) == 'function', 'create_interface should be a function')
  assert(type(java_creator.create_enum) == 'function', 'create_enum should be a function')
  assert(type(java_creator.create_with_picker) == 'function', 'create_with_picker should be a function')

  print('✅ Main module test passed')
end

-- 运行所有测试
local function run_tests()
  print('🧪 Running nvim-java-creator tests...')

  test_config()
  test_core()
  test_pickers()
  test_main()

  print('🎉 All tests passed!')
end

-- 如果直接运行此文件
if ... == nil then
  run_tests()
end

return {
  test_config = test_config,
  test_core = test_core,
  test_pickers = test_pickers,
  test_main = test_main,
  run_tests = run_tests,
}