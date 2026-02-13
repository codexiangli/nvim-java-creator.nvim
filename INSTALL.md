# 安装指南

## 🚀 快速开始

### Lazy.nvim 安装（推荐）

```lua
-- 添加到你的 lazy.nvim 配置中
{
  'your-username/nvim-java-creator.nvim',
  dependencies = {
    'folke/snacks.nvim', -- 推荐的选择器
  },
  config = function()
    require('java-creator').setup()
  end,
  ft = 'java', -- 仅在 Java 文件时加载
}
```

### 最小配置

```lua
{
  'your-username/nvim-java-creator.nvim',
  opts = {}, -- 使用默认配置
  ft = 'java',
}
```

### 完整配置

```lua
{
  'your-username/nvim-java-creator.nvim',
  dependencies = { 'folke/snacks.nvim' },
  config = function()
    require('java-creator').setup({
      picker = 'snacks',     -- 选择器: 'auto', 'snacks', 'telescope', 'fzf', 'native'
      author = '你的名字',    -- 作者信息
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
      templates = {
        class = {
          extends = 'BaseEntity',      -- 默认继承
          implements = {'Serializable'}, -- 默认实现接口
        },
      },
    })
  end,
  ft = 'java',
  cmd = { 'JavaCreate', 'JavaCreateClass', 'JavaCreateTest' }, -- 懒加载命令
}
```

## 🎯 选择器支持

插件支持多种选择器，优先级如下：

1. **Snacks** (推荐) - 现代、快速、美观
2. **Telescope** - 功能丰富、广泛使用
3. **FZF** - 轻量级、高性能
4. **Native** - 内置备选方案

### 配置特定选择器

#### 使用 Snacks
```lua
dependencies = { 'folke/snacks.nvim' },
config = function()
  require('java-creator').setup({
    picker = 'snacks',
  })
end,
```

#### 使用 Telescope
```lua
dependencies = { 'nvim-telescope/telescope.nvim' },
config = function()
  require('java-creator').setup({
    picker = 'telescope',
  })
end,
```

#### 使用 FZF
```lua
dependencies = { 'junegunn/fzf.vim' },
config = function()
  require('java-creator').setup({
    picker = 'fzf',
  })
end,
```

## 📋 使用方法

安装后，在 Java 文件中使用以下快捷键：

- `<leader>jc` - 创建 Java 类
- `<leader>jC` - 选择类型创建（显示选择器）
- `<leader>jt` - 创建测试类
- `<leader>ji` - 创建接口
- `<leader>je` - 创建枚举
- `<leader>ja` - 创建抽象类
- `<leader>jr` - 创建记录类
- `<leader>j@` - 创建注解

### 命令

- `:JavaCreate` - 打开类型选择器
- `:JavaCreateClass` - 创建类
- `:JavaCreateTest` - 创建测试类

## 🔧 故障排除

### 选择器不工作

1. 确保安装了对应的依赖（Snacks、Telescope 或 FZF）
2. 检查配置中的 `picker` 设置
3. 尝试设置 `picker = 'native'` 使用内置选择器

### 包名推断不正确

插件会自动检测 Maven/Gradle 项目结构。如果项目结构特殊，包名可能需要手动输入。

### 模块检测问题

插件通过搜索 `src/main/java` 目录来检测 Java 模块。确保项目结构符合标准 Maven/Gradle 布局。

## 🎉 享受编码！

插件现在已经配置完成，开始享受高效的 Java 开发吧！