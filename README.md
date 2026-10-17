# endfield-ui

An agent skill for building UI with an *Arknights: Endfield*-flavoured industrial look — on the web, mobile web, iOS, Android, Flutter, React Native, WeChat mini programs and desktop apps. Uses no game assets.

一个让 agent 做出"终末地风味"界面的 skill：浅色纸面与墨色、唯一的强调黄 `#FFFA00`、切角表示可按、宽体大写英文配粗体中文、`//` 眉标、编号记录行、斜线纹、极淡等高线、短而机械的动效。覆盖网页、手机网页、iOS、Android、Flutter、React Native、小程序和桌面应用。

## 安装

```sh
git clone https://github.com/hhikr/endfield-ui-skill ~/.claude/skills/endfield-ui
```

或者复制到某个项目的 `.claude/skills/endfield-ui/`。入口是 [`SKILL.md`](SKILL.md)。

## 内容

| 路径 | 内容 |
| --- | --- |
| `SKILL.md` | 气质、调子、字体、部件速查、规则、交付清单 |
| `assets/tokens.json` | 平台无关的 token |
| `assets/endfield.css` `fx.js` `dial.js` `contours/` | 网页套件 |
| `templates/*.html` | 展示 / 阅读 / 控制台模板、部件样张、反例对照页 |
| `templates/flutter/` | Flutter 套件和六个示例屏幕 |
| `references/` | 调研、token、部件、界面范式、动效、规则、各平台指南 |
| `examples/` | 网页和 App 示例截图 |

![App screens](examples/app/overview-light.jpg)

![Console](examples/web/console-light.jpg)

## 许可

`templates/flutter/fonts/Saira.ttf` 是 [Saira](https://github.com/Omnibus-Type/Saira)，SIL Open Font License 1.1（见同目录 `Saira-OFL.txt`）。示例中的名字和数字都是虚构的。本项目与游戏及其开发商无关，不包含任何官方素材。
