# 微信小程序（及支付宝、抖音等小程序）

> WXSS / WXML 片段**没有在本 skill 里用开发者工具验证过**；数值和行为与已验证的网页套件、Flutter 套件一致。其他小程序平台语法相近（`.acss`、`.ttss`），改文件后缀和 API 前缀即可。

小程序的样式就是受限的 CSS，`assets/endfield.css` 的大部分写法可以搬过来，但要注意：没有 `:hover`、不能用 `@import` 网络地址、不支持 `@view-transition`、`mask` 和 `clip-path` 在老版本基础库上可能不全（切角优先用 `clip-path`，并在真机上看）。

## 单位

`assets/tokens.json` 里的数值是逻辑像素，**乘 2 得 rpx**（750rpx 设计宽度）：页边 16 → 32rpx，正文 17 → 34rpx，小切角 7 → 14rpx，触控区 44 → 88rpx。细线保持 `1px`，不要写成 2rpx（会在有的屏幕上消失或变粗）。

## 变量与主题

```css
/* app.wxss */
page {
  --paper: #f4f4f2; --panel: #ffffff; --ink: #161616; --ink-2: #5c5c5c;
  --rule: #d9d9d6; --chip: #e4e4e0; --trace: #161616; --danger: #b3261e;
  --tag-bg: #161616; --tag-fg: #ffffff;
  --signal: #fffa00; --on-signal: #161616;
  --tri-a: #ff00f0; --tri-c: #00ffa2;
  --hatch: rgba(22, 22, 22, 0.22);
  --mech: cubic-bezier(0.7, 0, 0.2, 1); --snap: cubic-bezier(0.16, 1, 0.3, 1);
  background: var(--paper); color: var(--ink);
  font-family: 'Saira', -apple-system, 'PingFang SC', 'Noto Sans CJK SC', sans-serif;
}
@media (prefers-color-scheme: dark) {
  page {
    --paper: #191919; --panel: #222222; --ink: #ededed; --ink-2: #a3a3a3;
    --rule: #353535; --chip: #2e2e2e; --trace: #fffa00; --danger: #ff8a7a;
    --tag-bg: #3a3a3a; --tag-fg: #ededed;
    --hatch: rgba(237, 237, 237, 0.22);
  }
}
```

在 `app.json` 里设 `"darkmode": true`，并用 `theme.json` 给导航栏、标签栏、窗口背景配两套颜色（`#F4F4F2` / `#191919`）。

## 字体

小程序里中文直接用系统字体（苹方、Noto Sans CJK），不要加载中文网络字体（太大）。拉丁宽体用 `wx.loadFontFace` 加载一个**只含拉丁字符**的小字体：

```js
// app.js
wx.loadFontFace({
  global: true,
  family: 'Saira',
  source: 'url("https://你的域名/fonts/saira-wide-600.woff2")',
  desc: { weight: '600' },
});
```

- 字体文件要放在 https 域名上，并加进后台的 downloadFile 合法域名。
- 小程序对可变字体的宽度轴支持不稳定。用 fontTools 先切出**固定宽度的静态字体**，再只保留拉丁字符（每个 woff2 不到 10 KB）：

  ```sh
  pip install fonttools brotli
  fonttools varLib.instancer Saira.ttf wdth=125 wght=600 -o saira-wide-600.ttf
  pyftsubset saira-wide-600.ttf --unicodes=U+0020-007E,U+00B7,U+2014,U+2215 --flavor=woff2 --output-file=saira-wide-600.woff2
  ```

  常用三个：`wdth=125 wght=600`（眉标、标签栏英文）、`wdth=112 wght=400`（字段、日期、编号）、`wdth=125 wght=800`（字标、大数字）。分别注册成 `Saira`（`desc.weight` 600 / 400 / 800）。

## 切角、三色条、斜线纹

```css
.cut-sm  { clip-path: polygon(0 0, 100% 0, 100% calc(100% - 14rpx), calc(100% - 14rpx) 100%, 0 100%); }
.cut-btn { clip-path: polygon(0 0, 100% 0, 100% calc(100% - 16rpx), calc(100% - 16rpx) 100%, 0 100%); }
.cut-panel { clip-path: polygon(0 0, 100% 0, 100% calc(100% - 52rpx), calc(100% - 52rpx) 100%, 0 100%); }

.tri { display: flex; height: 3px; }
.tri view { flex: 1; }
.tri view:nth-child(1) { background: var(--tri-a); }
.tri view:nth-child(2) { background: var(--signal); }
.tri view:nth-child(3) { background: var(--tri-c); }

.hatch {
  background-image: repeating-linear-gradient(-45deg, transparent 0 5px, var(--hatch) 5px 6.5px);
}
```

斜线纹的颜色走 `--hatch` 变量，深色主题里自动换成浅色线。等高线：把 `assets/contours/contour-a.svg` 导出成透明 PNG（墨色 9%、深色版一张），放在页面右上角 `position: fixed` 的 `<image>` 里，`pointer-events: none`。

## 按钮：用 hover-class 做按下擦入

小程序没有悬停，`hover-class` 就是"按下"：

```html
<button class="ef-btn go cut-btn" hover-class="is-pressed" hover-stay-time="120">保存</button>
<button class="ef-btn cut-btn" hover-class="is-pressed">取消</button>
```

```css
button.ef-btn { margin: 0; border-radius: 0; line-height: normal; }
button.ef-btn::after { border: 0; }               /* 去掉微信按钮的默认描边 */
.ef-btn {
  position: relative; overflow: hidden;
  display: inline-flex; align-items: center; justify-content: center;
  min-height: 88rpx; padding: 0 40rpx;
  background: var(--chip); color: var(--ink);
  font-size: 30rpx; font-weight: 700;
}
.ef-btn::before {
  content: ''; position: absolute; inset: 0;
  background: var(--signal);
  transform: translateX(-101%); transition: transform 0.28s var(--mech);
}
.ef-btn.is-pressed::before { transform: none; transition-duration: 0.1s; }
.ef-btn.is-pressed { color: var(--on-signal); }
.ef-btn.go { background: var(--signal); color: var(--on-signal); }
.ef-btn.go::before { background: rgba(22, 22, 22, 0.12); }
.ef-btn.danger { color: var(--danger); }
.ef-btn.danger::before { background: var(--danger); }
.ef-btn.danger.is-pressed { color: var(--panel); }
.ef-btn > text { position: relative; }
```

按钮文字要包在 `<text>` 里，才能叠在擦入层上面。

## 导航栏与标签栏

- **导航栏**：简单页面用系统导航栏，`navigationBarBackgroundColor: #F4F4F2`、`navigationBarTextStyle: black`。想要左对齐的中英成对标题，就在页面 json 里设 `"navigationStyle": "custom"`，自己画顶栏，并用 `wx.getMenuButtonBoundingClientRect()` 让出右上角胶囊按钮的位置和高度。
- **标签栏**：系统 tabBar 只能改颜色，做不出整格黄块。用自定义 tabBar：`app.json` 里 `"tabBar": { "custom": true, … }`，在根目录建 `custom-tab-bar/` 组件，每项是英文眉标 + 中文，当前项黄底切角；页面 `onShow` 里 `this.getTabBar().setData({ current: i })`。底部留 `env(safe-area-inset-bottom)`。

## 记录行与其他部件

```html
<view class="record" hover-class="is-pressed" hover-stay-time="80" bindtap="open" data-id="24">
  <view class="record-head">
    <text class="tag cut-sm">No.024</text>
    <text class="field">10.17</text>
    <text class="field right">6,380 字</text>
  </view>
  <text class="record-name">示例：仓储节点的布线记录</text>
</view>
```

```css
.record { position: relative; padding: 24rpx 8rpx 24rpx 16rpx; border-bottom: 1px solid var(--rule); }
.record > view, .record > text { transition: transform 0.2s var(--snap); }   /* 只动 transform，不动 padding */
.record::before { content: ''; position: absolute; left: 0; top: 0; width: 8rpx; height: 0; background: var(--trace); transition: height 0.2s var(--snap); }
.record.is-pressed > view, .record.is-pressed > text { transform: translateX(12rpx); }
.record.is-pressed::before { height: 100%; }
.tag { padding: 4rpx 20rpx 4rpx 14rpx; background: var(--tag-bg); color: var(--tag-fg); font-size: 24rpx; font-weight: 600; }
.field { color: var(--ink-2); font-size: 26rpx; font-variant-numeric: tabular-nums; }
```

其余部件（眉标、看板、开关、分段、进度、空状态、底部面板、对话框、提示条）照 `../patterns.md` 第二部分和 `examples/app/` 的截图做：都是矩形、细线、切角和黄块，用 `view` 加上面的变量就能拼出来。系统 `switch`、`slider`、`picker` 的外观改动有限，用 `color="#FFFA00"`（或你选定的强调色）至少把强调色换掉，或者自己画。

## 动效

- 小程序页面切换动画由宿主控制，不要模拟快门。
- 页面内用 CSS transition（上面的擦入、色条）即可；`wx.createAnimation` 只在需要逐步序列时用。
- 小程序读不到系统的"减少动态效果"。在设置页给一个"减少动效"开关，存进 storage，在页面根节点加一个类，样式里统一关掉：

  ```js
  // app.js
  App({ globalData: { still: wx.getStorageSync('still') === true } });
  // 每个页面
  Page({ data: { still: getApp().globalData.still } });
  ```

  ```html
  <view class="page {{still ? 'is-still' : ''}}">…</view>
  ```

  ```css
  .is-still, .is-still view, .is-still text, .is-still button,
  .is-still ::before, .is-still ::after { transition: none !important; animation: none !important; }
  ```

  其余时候保持所有动效短（≤ 400ms）且只响应操作。时长和曲线照 `../motion.md` 的清单。
