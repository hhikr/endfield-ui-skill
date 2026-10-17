# endfield-ui

An agent skill for building UI with an *Arknights: Endfield*-flavoured industrial look — on the web, mobile web, iOS, Android, Flutter, React Native, WeChat mini programs and desktop apps. Uses no game assets.

一个让 agent 做出"终末地风味"界面的 skill：浅色纸面与墨色、唯一的强调黄 `#FFFA00`、切角表示可按、宽体大写英文配粗体中文、`//` 眉标、编号记录行、斜线纹、极淡等高线、短而机械的动效。覆盖网页、手机网页、iOS、Android、Flutter、React Native、小程序和桌面应用。

## 安装

这是一个标准的 [Agent Skills](https://agentskills.io) 包（根目录 `SKILL.md`），不绑定某一家的 agent。挑一种装法：

**通用：skills CLI（推荐）**，一条命令装给本机已有的 agent（Claude Code、Codex、Cursor、Gemini CLI、GitHub Copilot 等）：

```sh
npx skills add hhikr/endfield-ui-skill
npx skills add hhikr/endfield-ui-skill -a codex   # 只装给某一个 agent，例如 claude-code / codex / cursor
```

**Claude Code**

```sh
git clone https://github.com/hhikr/endfield-ui-skill ~/.claude/skills/endfield-ui   # 所有项目可用
# 或放进某个项目：<项目>/.claude/skills/endfield-ui/
```

**OpenAI Codex**（CLI、IDE 插件、桌面版）

```sh
git clone https://github.com/hhikr/endfield-ui-skill ~/.agents/skills/endfield-ui   # 所有项目可用
# 或放进某个项目：<项目>/.agents/skills/endfield-ui/
```

装好后重启 Codex；可以直接说"做成终末地风格"，也可以用 `$endfield-ui` 点名调用。`agents/openai.yaml` 提供了 Codex 界面里的名字、简介和颜色。

**其他 agent / 不支持 skills 的工具**（只读 `AGENTS.md`、`.cursorrules`、`GEMINI.md` 这类规则文件的）：把仓库放进项目，例如 `vendor/endfield-ui/`，在规则文件里加一行：

```md
做界面时，先读 vendor/endfield-ui/SKILL.md，按里面的步骤和规则做；需要的文件都在同一目录。
```

**ChatGPT 网页 / 桌面对话**：没有安装目录。可以把 `SKILL.md` 和要用的平台指南（`references/platforms/*.md`）作为附件上传，让它照着做。

## 结构

agent 只在被触发时读 `SKILL.md`；其余文件按需打开，不会一次全塞进上下文。

```text
endfield-ui-skill/
├── SKILL.md                  入口：气质、选调子、选平台、字体、部件速查、规则、交付清单、文件地图
├── agents/openai.yaml        Codex 界面里的名字、简介、颜色（其他 agent 忽略）
├── references/               按需读的细节
│   ├── research.md           对官网和游戏界面的调研：看到了什么、借什么不借什么
│   ├── tokens.md             色值与对比度、深色主题、字体、字号
│   ├── components.md         每个部件的写法、含义和禁忌（含手机网页部件、表格、柱图）
│   ├── patterns.md           三种调子的页面范式，App 的标签栏、列表、详情、表单、面板、对话框
│   ├── motion.md             动效：原则、三条曲线、编排、完整清单、进出、状态变化、减少动效
│   ├── rules.md              做与不做，每条的理由
│   └── platforms/            web / mobile-web / ios / android / flutter / cross-platform / miniprogram
├── assets/                   可直接拷进项目的东西
│   ├── tokens.json           平台无关的 token：颜色、字体、字号、间距、切角、线宽、动效
│   ├── endfield.css          网页套件：全部变量和 ef- 部件，不依赖框架
│   ├── fx.js                 乱码后落定、深浅切换、视差、面板与对话框进出、提示条、删行、完成反馈
│   ├── dial.js               控制台的分段圆盘
│   └── contours/             背景等高线 SVG 和生成脚本
├── templates/                可运行的参考实现
│   ├── showcase.html         调子一：展示页（字标、三色条、索引）
│   ├── reading.html          调子二：阅读页（长文、目录、相关记录）
│   ├── console.html          调子三：控制台（看板、圆盘、读数）
│   ├── app.html              手机网页（H5 / PWA）：列表、设置、状态、底部面板、对话框
│   ├── motion.html           动效样张：每个动效一格，可重放
│   ├── specimen.html         全部网页部件的样张
│   ├── antipatterns.html     做与不做的对照页
│   └── flutter/              Flutter 套件（lib/ef/）和六个示例屏幕
└── examples/                 截图，不用跑就能看
    ├── web/                  各网页模板的浅色、深色、手机宽度截图
    ├── app/                  Flutter 示例屏幕（390×844，浅、深），overview-*.jpg 是六屏总览
    └── motion/               主要动效的 GIF 录屏
```

agent 的工作顺序：读 `SKILL.md` → 按调子和平台打开对应的 `references/platforms/*.md` → 网页直接引用 `assets/`，Flutter 拷 `templates/flutter/lib/ef/`，其他平台照 `tokens.json` 和平台指南自己落地 → 用 `SKILL.md` 末尾的清单自查。

## 预览

### 只看截图

`examples/web/` 和 `examples/app/` 里是全部模板的截图，GitHub 上直接点开即可。

![App screens](examples/app/overview-light.jpg)

![Console](examples/web/console-light.jpg)

### 在浏览器里跑网页模板

模板用了 ES module，浏览器不允许从 `file://` 加载，所以要在**仓库根目录**起一个静态服务器（不要在 `templates/` 里起，模板要引用上一级的 `assets/`）：

```sh
npx http-server -p 8766          # 有 Node 就用这个
python3 -m http.server 8766      # 或者 Python；Windows 上用 py -m http.server 8766
```

> Windows 上如果 `python` 敲下去什么都没发生，那是应用商店的占位程序，并没有装 Python，换用上面的 `npx` 或 `py`。端口被占用时（打开后看到的不是模板，比如只有 `{}`），换一个端口号。

然后打开：

| 地址 | 看什么 |
| --- | --- |
| `http://localhost:8766/templates/motion.html` | 动效样张，见下一节 |
| `http://localhost:8766/templates/showcase.html` | 展示页：三色条扫过、字标推入、马克笔划过、指针视差 |
| `http://localhost:8766/templates/console.html` | 控制台：看板通电、圆盘组装、读数乱码落定、指向圆盘锁定 |
| `http://localhost:8766/templates/reading.html` | 阅读页 |
| `http://localhost:8766/templates/app.html` | 手机网页。用浏览器的设备模式（F12 → 切换设备工具栏）调到 360–430 宽 |
| `http://localhost:8766/templates/specimen.html` | 全部部件，hover 状态也摆出来了 |
| `http://localhost:8766/templates/antipatterns.html` | 反例和正例并排 |

每页都有深浅切换按钮。`app.html` 和 `motion.html` 还认地址参数：

- `?theme=light` / `?theme=dark`：指定深浅
- `app.html?screen=list|settings|states`：直接打开某个标签页；加 `&sheet=1` 或 `&dialog=1` 打开底部面板或对话框

### 动效录屏

不想起服务器的话，先看 `examples/motion/` 里的录屏。全部是从模板实际录下来的，速度为真实速度。

**逐条看动效**（录自 `templates/motion.html`，每格写着触发、时长和曲线）

| 打开页面 | 回应操作 |
| --- | --- |
| ![打开页面](examples/motion/entrances.gif) | ![回应操作](examples/motion/responses.gif) |
| 三色条扫过、字标推入、马克笔划过、乱码落定、通电、逐行亮起、圆盘组装 | 按钮黄色擦入和按下、列表行右移、页签伸开、墨色灌满、保存完成、分段进度 |

![进出与状态变化](examples/motion/in-and-out.gif)

**进出与状态变化**：提示擦入、删除一行、提示条、底部面板、对话框

**放在页面里**

| 展示页 | 控制台 |
| --- | --- |
| ![展示页入场](examples/motion/showcase-in.gif) | ![控制台入场](examples/motion/console-in.gif) |
| 打开时的整段入场，然后是指针视差 | 圆盘组装、看板通电、大数字落定，然后指向圆盘的段 |

**真实 App 用起来**（录自 `templates/app.html`，手机宽度）

| 列表和底部面板 | 设置与对话框 | 状态 | 深浅切换 |
| --- | --- | --- | --- |
| ![底部面板](examples/motion/app-drawer.gif) | ![设置](examples/motion/app-settings.gif) | ![状态](examples/motion/app-states.gif) | ![深浅揭幕](examples/motion/theme-reveal.gif) |
| 列表逐行亮起，点一行推入底部面板，取消后推回 | 开关和分段移动，保存的处理中到完成，删除确认框的通电和关上 | 删一行后下面的行补位，提示条擦入再擦掉 | 从按钮处扩散一个圆揭开新主题 |

### 动效参考：`templates/motion.html`

所有动效都在这一页，按 `references/motion.md` 的清单排列，每格下面写着“触发 │ 时长 │ 曲线”：

- **三条曲线**：`snap`、`mech`、`ease` 的形状和用途
- **打开页面**：三色条扫过、字标推入、马克笔划过、乱码后落定、通电、逐行亮起、圆盘组装 —— 每格有“重放”
- **回应操作**：按钮黄色擦入与按下、列表行色条落下并右移、看板页签伸开、空心大编号墨色灌满、保存的处理中到完成、分段进度（“前进”一格一格跳）—— 用鼠标指向或按 Tab 聚焦来触发
- **进出与状态变化**：提示擦入、删除一行、提示条、底部面板、对话框、深浅揭幕 —— 点各格的按钮触发
- **入场时间轴**：一个页面的整段入场怎么错开，全程不超过 1 秒

顶部“全部重放”一次把入场动效全播一遍。

如果一格都不动：系统开了“减少动态效果”（Windows：设置 → 辅助功能 → 视觉效果 → 动画效果；macOS：辅助功能 → 显示 → 减弱动态效果），页面顶部会出现提示 —— 这是期望的行为，所有动效在这个设置下都会直接跳到结束。想临时看效果，可以在 Chrome 开发者工具的 Rendering 面板里把 `prefers-reduced-motion` 模拟成 `no-preference`。

想看清曲线和先后顺序，可以在开发者工具的 Animations 面板里把播放速度调到 25% 或 10%。

动效的具体数值（时长、曲线、错开间隔）在 `references/motion.md` 和 `assets/tokens.json` 的 `motion` 里；各平台怎么对应写在该文档的“手机上的对应”一节。

### 跑 Flutter 示例

`templates/flutter/` 只带了 `lib/`、`test/` 和字体，没有 `android/`、`ios/`、`web/` 这些平台目录，直接 `flutter run` 会失败，要先生成一次：

```sh
cp -r templates/flutter my_app && cd my_app
flutter create .   # 生成平台目录，不覆盖已有的 lib/ 和 test/
flutter run        # 任选一个设备；flutter run -d chrome 也行
```

底部标签栏是总览、记录、状态、设置四项；在记录里点一行进详情，点“筛选”拉出底部面板，设置页里能切换深浅（默认跟随系统）。用 `-d chrome` 跑时同样认 `?theme=dark` 和 `?screen=home|list|detail|settings|sheet|states`（状态页再加 `&dialog=1` 打开对话框）。`flutter test` 会跑一遍 widget 测试。

## 许可

`templates/flutter/fonts/Saira.ttf` 是 [Saira](https://github.com/Omnibus-Type/Saira)，SIL Open Font License 1.1（见同目录 `Saira-OFL.txt`）。示例中的名字和数字都是虚构的。本项目与游戏及其开发商无关，不包含任何官方素材。
