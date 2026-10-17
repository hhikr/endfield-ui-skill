# 手机网页、H5、PWA

和桌面网页用同一套 `endfield.css`。它已经处理了：页边距随屏宽缩到 16px、记录行名称换行、等高线只留右上角、触屏上主要按钮静止就是黄底且按下即擦入、触屏上输入框 16px（后两条在 `@media (hover: none)` 里）。模板里也示范了阅读页侧栏折成格子、控制台看板改为一列。下面是需要你自己补的。

## 视口与安全区

```html
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
```

```css
.app-top { padding-top: env(safe-area-inset-top); }
.app-tabbar { padding-bottom: env(safe-area-inset-bottom); }
html { -webkit-tap-highlight-color: transparent; -webkit-text-size-adjust: 100%; }
.app-screen { min-height: 100dvh; }
```

- 不要禁止缩放（`user-scalable=no`）。
- 输入框字号至少 16px，避免 iOS 聚焦时自动放大（`.ef-form` 在触屏上已经是 16px；自己写的输入框也要）。

## 像 App 一样的网页：底部标签栏

在 H5、PWA、嵌入 App 的网页里，一级导航用底部标签栏（规则见 `../patterns.md`）：

```html
<nav class="app-tabbar" aria-label="主导航">
  <a href="/" aria-current="page"><small>Home</small>总览</a>
  <a href="/records/"><small>Records</small>记录</a>
  <a href="/status/"><small>Status</small>状态</a>
  <a href="/config/"><small>Config</small>设置</a>
</nav>
```

```css
.app-tabbar {
  position: fixed; inset: auto 0 0;
  display: grid; grid-auto-flow: column; grid-auto-columns: 1fr; gap: 6px;
  padding: 8px 8px calc(8px + env(safe-area-inset-bottom));
  background: var(--ef-panel); border-top: 1px solid var(--ef-rule);
}
.app-tabbar a {
  display: grid; place-items: center; min-height: 52px;
  color: var(--ef-ink); text-decoration: none; font: 500 0.875rem/1.3 var(--ef-font-ui);
  transition: background-color 0.28s var(--ef-mech);
}
.app-tabbar small {
  font-size: 0.5625rem; font-weight: 600; font-stretch: var(--ef-wider);
  letter-spacing: 0.14em; text-transform: uppercase; color: var(--ef-ink-2);
}
.app-tabbar [aria-current='page'] {
  background: var(--ef-signal); color: var(--ef-on-signal); font-weight: 700;
  clip-path: polygon(0 0, 100% 0, 100% calc(100% - 7px), calc(100% - 7px) 100%, 0 100%);
}
.app-tabbar [aria-current='page'] small { color: var(--ef-on-signal); }
body { padding-bottom: calc(72px + env(safe-area-inset-bottom)); }
```

顶栏、列表、详情、表单、底部面板、对话框、加载与空状态的样子见 `../patterns.md` 第二部分；Flutter 截图 `examples/app/` 就是目标效果，网页上用 `ef-` 部件拼出来即可。

## 触屏交互

- 没有悬停：所有"指向时出现"的信息必须在静止时也能看到或点一下就到。悬停才显示的按钮在触屏上要常显。
- 按下反馈：`.ef-btn` 在触屏上按下就擦入；自己做的可点块加 `:active` 状态（色条落下、底色变纸色），不要依赖浏览器的灰色点击高亮。
- 点击区域至少 44×44。小标签（`.ef-tag`）放在整行可点的记录行里，不要单独当按钮。
- 横向滚动只用于真正的长内容（宽表格、图表），并留出可见的半截提示；导航不做横向滚动。

## PWA

```json
{
  "name": "…", "display": "standalone",
  "background_color": "#F4F4F2", "theme_color": "#F4F4F2",
  "icons": [{ "src": "/icon-512.png", "sizes": "512x512", "type": "image/png", "purpose": "any maskable" }]
}
```

图标：纸色方块里一个宽体大写字母，字下垫一小块黄、右下切角（整块铺黄就成了大面积黄色）；不要用游戏标志。

## 性能

- 中文字体只加载 unicode-range 切片（fontsource 已经切好）；Saira 只需要拉丁切片。
- 等高线 SVG 很小，可以直接用；手机上 `endfield.css` 只保留右上角一片。
- 动效只动 `transform`、`opacity`、`clip-path`，低端机也稳。

## 验收

- 360、390、430 宽，竖屏和横屏，浅深两套。
- 真机或模拟器上：安全区不被遮挡、软键盘弹起时输入框可见、底部标签栏不挡内容。
