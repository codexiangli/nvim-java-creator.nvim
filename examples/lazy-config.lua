-- lazy.nvim 配置示例

return {
  -- 基础配置
  {
    'your-username/nvim-java-creator.nvim',
    dependencies = {
      'folke/snacks.nvim', -- 推荐的选择器
    },
    config = function()
      require('java-creator').setup()
    end,
    ft = 'java', -- 仅在 Java 文件时懒加载
  },

  -- 完整配置示例
  {
    'your-username/nvim-java-creator.nvim',
    dependencies = {
      'folke/snacks.nvim',
      -- 或者使用其他选择器
      -- 'nvim-telescope/telescope.nvim',
      -- 'junegunn/fzf.vim',
    },
    config = function()
      require('java-creator').setup({
        picker = 'snacks', -- 明确指定选择器
        author = '张三',    -- 自定义作者名
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
            extends = 'BaseEntity', -- 默认继承
            implements = {'Serializable'}, -- 默认实现
          },
        },
      })
    end,
    ft = 'java',
    cmd = {
      'JavaCreate',
      'JavaCreateClass',
      'JavaCreateTest',
      'JavaCreateInterface',
      'JavaCreateEnum',
    },
  },

  -- 最小配置
  {
    'your-username/nvim-java-creator.nvim',
    opts = {}, -- 使用默认配置
    ft = 'java',
  },

  -- 禁用快捷键的配置
  {
    'your-username/nvim-java-creator.nvim',
    config = function()
      require('java-creator').setup({
        keymaps = false, -- 禁用默认快捷键
      })

      -- 自定义快捷键
      local java_creator = require('java-creator')
      vim.keymap.set('n', '<C-j>c', java_creator.create_class, { desc = '创建Java类' })
      vim.keymap.set('n', '<C-j>i', java_creator.create_interface, { desc = '创建Java接口' })
      vim.keymap.set('n', '<C-j>e', java_creator.create_enum, { desc = '创建Java枚举' })
    end,
    ft = 'java',
  },
}