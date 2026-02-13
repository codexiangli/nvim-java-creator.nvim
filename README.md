# nvim-java-creator.nvim

🚀 强大的 Neovim Java 文件创建插件，支持智能多模块项目检测

## ✨ 功能特性

- 🏗️ **多模块项目检测** - 自动发现 Maven/Gradle 模块
- 🎯 **智能包名推断** - 根据当前目录智能推断包名
- 🎨 **多种文件类型** - 支持 Class、Interface、Enum、Abstract Class、Record、Annotation
- 🔍 **美观的选择器** - 支持 Snacks、Telescope、FZF 和原生输入
- ⚡ **快捷创建** - 直接创建或类型选择
- 📝 **丰富的模板** - 自动生成 JavaDoc，包含作者和日期
- 🧪 **测试文件支持** - 创建标准的 JUnit 测试类
- 📁 **自动创建目录** - 自动创建缺失的包目录
- ✅ **文件存在检查** - 防止意外覆盖

## 📦 安装

### 使用 [lazy.nvim](https://github.com/folke/lazy.nvim) (推荐)

```lua
{
  'codexiangli/nvim-java-creator.nvim',
  dependencies = {
    -- 可选：选择你喜欢的选择器
    'folke/snacks.nvim',          -- 推荐
    -- 'nvim-telescope/telescope.nvim', -- 备选
    -- 'junegunn/fzf.vim',             -- 备选
  },
  config = function()
    require('java-creator').setup()
  end,
  ft = 'java', -- 懒加载，仅在 Java 文件时加载
}
```

### 使用 [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'your-username/nvim-java-creator.nvim',
  requires = {
    'folke/snacks.nvim', -- 可选
  },
  config = function()
    require('java-creator').setup()
  end,
  ft = 'java',
}
```

## ⚙️ 配置

```lua
require('java-creator').setup({
  -- 选择器偏好（默认自动检测）
  picker = 'auto', -- 可选：'auto', 'snacks', 'telescope', 'fzf', 'native'

  -- 默认作者名（默认使用 git config）
  author = '你的名字',

  -- 自定义快捷键
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

  -- 模板自定义
  templates = {
    class = {
      extends = nil,    -- 例如：'BaseClass'
      implements = {},  -- 例如：{'Serializable'}
    },
    interface = {
      extends = {},     -- 例如：{'BaseInterface'}
    },
  },

  -- 自动导入常用包
  auto_imports = {
    test = {
      'org.junit.jupiter.api.Test',
      'org.junit.jupiter.api.BeforeEach',
      'org.junit.jupiter.api.DisplayName',
    },
  },
})
```

## 🎯 使用方法

### 快速创建（无选择）
- `<leader>jc` - 创建 Java 类
- `<leader>jt` - 创建测试类
- `<leader>ji` - 创建接口
- `<leader>je` - 创建枚举
- `<leader>ja` - 创建抽象类
- `<leader>jr` - 创建记录类
- `<leader>j@` - 创建注解

### 使用类型选择器
- `<leader>jC` - 打开美观的类型选择器

### 命令
- `:JavaCreate` - 打开类型选择器
- `:JavaCreateClass` - 直接创建类
- `:JavaCreateTest` - 创建测试类
- `:JavaCreateInterface` - 创建接口
- `:JavaCreateEnum` - 创建枚举

## 🎨 选择器支持

插件自动检测并使用最佳可用选择器：

1. **Snacks**（推荐）- 现代、快速、美观
2. **Telescope** - 功能丰富、使用广泛
3. **FZF** - 轻量、快速
4. **Native** - 内置备选方案

## 📝 生成的模板

### 类
```java
package com.example.service;

/**
 * UserService
 *
 * @author 你的名字
 * @date 2024-01-01
 */
public class UserService {

}
```

### 接口
```java
package com.example.service;

/**
 * UserRepository
 *
 * @author 你的名字
 * @date 2024-01-01
 */
public interface UserRepository {

}
```

### 枚举
```java
package com.example.enums;

/**
 * Status
 *
 * @author 你的名字
 * @date 2024-01-01
 */
public enum Status {

    ;

}
```

### 测试类
```java
package com.example.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;

/**
 * UserServiceTest
 *
 * @author 你的名字
 * @date 2024-01-01
 */
class UserServiceTest {

    @BeforeEach
    void setUp() {

    }

    @Test
    @DisplayName("测试描述")
    void testSomething() {

    }
}
```

## 🏗️ 项目结构支持

无缝支持：
- **Maven** 多模块项目
- **Gradle** 多模块项目
- **单模块** 项目
- **非标准** Java 项目结构

通过扫描 `src/main/java` 目录自动检测模块。

## 🤝 贡献

欢迎贡献！请随时提交 Pull Request。

## 📄 许可证

MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- 受到在 Neovim 中需要更好的 Java 开发工具的启发
- 感谢 Neovim 社区提供的出色插件生态系统
