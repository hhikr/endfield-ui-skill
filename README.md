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

agent 读 skill 的方式是：先读根目录的 `SKILL.md`，里面有气质、调子、部件速查、规则和交付清单，足够做出大部分界面；遇到具体问题时，再按 `SKILL.md` 里的指引去读 `references/` 下对应的那一篇，照着 `assets/` 和 `templates/` 里现成的代码改。所以 `SKILL.md` 是入口，其余文件按需加载。

```text
endfield-ui-skill/
├── SKILL.md                   入口：气质、选调子、选平台、字体、部件速查、规则、交付清单、文件地图
├── agents/openai.yaml         OpenAI Codex 界面里显示的名字、简介和颜色
├── assets/                    可以直接用的网页套件和 token
│   ├── tokens.json            平台无关的 token：颜色、字号、间距、斜线纹、触控尺寸、动效时长和曲线
│   ├── endfield.css           网页部件（全部以 ef- 开头），含 App 部件、动效和减少动效的处理
│   ├── fx.js                  样式表做不了的小动效：乱码落定、深浅揭幕、面板和对话框、提示条、删行、完成
│   ├── dial.js                控制台的分段圆盘
│   └── contours/              极淡的等高线底纹（SVG），和生成它的脚本
├── references/                按需阅读的细则
│   ├── research.md            对官网和游戏界面的调研：看到了什么，借什么不借什么
│   ├── tokens.md              色值和对比度、深色主题、字体、字号
│   ├── components.md          每个部件的写法、含义和禁忌
│   ├── patterns.md            版式和界面范式：三种调子的页面、App 的各类屏幕
│   ├── motion.md              动效：原则、曲线、编排和时间轴、完整清单、进出、状态变化
│   ├── rules.md               做与不做，每条附理由
│   └── platforms/             各平台指南：web、mobile-web、ios、android、flutter、miniprogram、cross-platform
├── templates/                 可以直接打开、复制改写的模板
│   ├── showcase.html          展示页（首页、落地页）：响亮的调子
│   ├── reading.html           阅读页（文章、记录列表、资料）：安静的调子
│   ├── console.html           控制台（仪表盘、后台）：中间圆盘、两侧看板
│   ├── app.html               手机网页（H5、PWA）：列表、设置、状态三屏，底部面板和对话框
│   ├── motion.html            动效样张：每个动效一格带重放，三条曲线，入场时间轴
│   ├── specimen.html          全部网页部件的样张，每个都标了类名和含义
│   ├── antipatterns.html      反例对照：左边是常见错误，右边是正确做法
│   └── flutter/               Flutter 套件（lib/ef/）和六个示例屏幕，带冒烟测试
└── examples/                  截图
    ├── web/                   上面各个网页模板的亮色、暗色和手机宽度截图
    └── app/                   Flutter 示例各屏的亮色、暗色截图和总览图
```

![App screens](examples/app/overview-light.jpg)

![Console](examples/web/console-light.jpg)

## 预览模板和动效

模板用 ES 模块加载脚本，浏览器不允许从 `file://` 直接打开，需要在仓库根目录起一个静态服务器。任选一种：

```sh
npx http-server -p 8766          # 有 Node 就行
python3 -m http.server 8766      # macOS / Linux；Windows 上装了 Python 用 py -m http.server 8766
```

然后在浏览器打开 `http://localhost:8766/templates/` 下的页面。如果端口已经被别的程序占用（打开后看到的不是模板），换一个端口号即可。

**动效**

| 打开 | 能看到什么 |
| --- | --- |
| `templates/motion.html` | 所有动效集中在一页。每格写着触发方式、时长和曲线；"打开页面"类的动效点"重放"再看一遍，"回应操作"类的用指针悬停或点击；顶部"全部重放"一次播完；最下面是展示页、控制台、App 首屏的入场时间轴 |
| `templates/showcase.html` | 打开页面时的完整入场：三色条扫过、字标推入、马克笔划过、读数乱码落定、记录行逐行亮起；指针在首屏移动有轻微视差 |
| `templates/console.html` | 圆盘逐段组装、看板逐行通电、大数字落定；指向看板时页签伸开，指向圆盘的段时锁定 |
| `templates/app.html` | 手机上的交互动效：底部面板推入推出、对话框通电、提示条、删除一行后补位、保存按钮的处理中和完成、深浅切换的圆形揭开 |
| `templates/specimen.html` | 按钮擦入、列表行右移、编号灌满等悬停效果（标了 hover 的格子是静止展示） |

看动效时建议：

- 用浏览器开发者工具的 Animations 面板把速度调到 25% 或 10%，能看清曲线和先后顺序。
- 系统打开"减少动态效果"时，所有动效都不会播放，这是故意的；`motion.html` 顶部会出现提示。想看动效就先关掉这个系统设置。
- `app.html` 要用手机宽度看（360–430px，或开发者工具的设备模式）。地址参数：`?screen=list|settings|states` 选屏，`&sheet=1` 打开底部面板，`&dialog=1` 打开对话框，`&theme=light|dark` 指定深浅。`motion.html` 也支持 `?theme=`。
- 动效的规则和完整清单在 `references/motion.md`，数值在 `assets/tokens.json` 的 `motion`。

**Flutter 示例**

`templates/flutter/` 只包含 `lib/`、`test/` 和字体，没有平台目录，要先生成：

```sh
cp -r templates/flutter my_app && cd my_app
flutter create .               # 生成 android/ ios/ web/ 等目录，不覆盖 lib/ 和 test/
flutter run -d chrome          # 或连上手机直接 flutter run
```

在 Web 上可以用 `?screen=home|list|detail|settings|sheet|states&theme=light|dark` 直接打开某一屏。列表页的"筛选"按钮会弹出底部面板，状态页能看到进度、提示和对话框。

## 许可

`templates/flutter/fonts/Saira.ttf` 是 [Saira](https://github.com/Omnibus-Type/Saira)，SIL Open Font License 1.1（见同目录 `Saira-OFL.txt`）。示例中的名字和数字都是虚构的。本项目与游戏及其开发商无关，不包含任何官方素材。
