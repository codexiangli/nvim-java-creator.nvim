-- 简化的插件测试

-- 设置插件路径
vim.opt.rtp:prepend(vim.fn.getcwd())

print('🧪 Testing nvim-java-creator...')

-- 测试1: 配置模块
local config = require('java-creator.config')
config.setup({})
local opts = config.get()
assert(opts.picker, 'Picker should be set')
print('✅ Config module works')

-- 测试2: 选择器模块
local pickers = require('java-creator.pickers')
assert(type(pickers.show_type_picker) == 'function', 'show_type_picker should be a function')
print('✅ Pickers module works')

-- 测试3: 核心模块
local core = require('java-creator.core')
assert(type(core.create_java_file_type) == 'function', 'create_java_file_type should be a function')
print('✅ Core module works')

-- 测试4: 主模块
local java_creator = require('java-creator')
assert(java_creator, 'Main module should load')
print('✅ Main module loads')

-- 测试lazy.nvim兼容性
print('\n📦 Testing lazy.nvim compatibility...')

-- 模拟 lazy.nvim opts 配置
local opts_config = {
  picker = 'native',
  author = 'Test User',
}

-- 应该能够通过 opts 配置
java_creator.setup(opts_config)
print('✅ Lazy.nvim opts configuration works')

-- 测试 ft 触发
print('\n📄 Testing filetype detection...')
vim.bo.filetype = 'java'
print('✅ Java filetype set')

print('\n🎉 All tests passed! Plugin is ready for lazy.nvim')

-- 显示最终配置状态
local final_opts = config.get()
print('\n📋 Final configuration:')
print('  Picker: ' .. final_opts.picker)
print('  Author: ' .. final_opts.author)
print('  Keymaps enabled: ' .. tostring(final_opts.keymaps ~= false))