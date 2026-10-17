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

## 内容

| 路径 | 内容 |
| --- | --- |
| `SKILL.md` | 气质、调子、字体、部件速查、规则、交付清单 |
| `assets/tokens.json` | 平台无关的 token |
| `assets/endfield.css` `fx.js` `dial.js` `contours/` | 网页套件 |
| `templates/*.html` | 展示 / 阅读 / 控制台 / 手机网页模板、动效样张、部件样张、反例对照页 |
| `templates/flutter/` | Flutter 套件和六个示例屏幕 |
| `references/` | 调研、token、部件、界面范式、动效、规则、各平台指南 |
| `examples/` | 网页和 App 示例截图 |
| `agents/openai.yaml` | OpenAI Codex 用的显示信息 |

![App screens](examples/app/overview-light.jpg)

![Console](examples/web/console-light.jpg)

## 许可

`templates/flutter/fonts/Saira.ttf` 是 [Saira](https://github.com/Omnibus-Type/Saira)，SIL Open Font License 1.1（见同目录 `Saira-OFL.txt`）。示例中的名字和数字都是虚构的。本项目与游戏及其开发商无关，不包含任何官方素材。
