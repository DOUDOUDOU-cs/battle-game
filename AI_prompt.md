# AI Agent Rules for [battle-game]

## 1. 运行模式定义
- **Task: Debug** -> 允许深入搜索，需分析依赖关系。
- **Task: UI_Tweak** -> 仅限修改目标文件属性。禁止执行全局搜索，禁止运行项目。
- **Task: Document** -> 必须先执行 `touch [filename]`，然后再写入内容。

## 2. 技术规范 (Godot/C++ 等)
- 修改 .tscn 文件时，优先使用正则替换 `scale = Vector2(x, y)` 字段，不要重写整个节点树。
- DNS 解析逻辑仅限在 `src/network/parser.cpp` 中修改，严禁触碰 `main.cpp`。

## 3. 强制确认流程
- 执行任何 `git push` 或 `rm` 动作前，必须请求人工授权。
- 每次任务完成后，必须通过终端命令验证结果（如 cat 或 ls）。