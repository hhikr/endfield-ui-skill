# 动效

样张：`templates/motion.html`（每个动效一格，带重放、三条曲线和入场时间轴）。数值的唯一来源是 `assets/tokens.json` 的 `motion`；网页写法在 `assets/endfield.css`（第 10、13 节）和 `assets/fx.js`；Flutter 在 `templates/flutter/lib/ef/tokens.dart`。

## 原则

1. **短、硬、机械。** 出现的东西用 `snap`（迅速到位后稳住）；快门、擦入、灌满、页签伸开和**所有退出**用 `mech`（慢起、硬停，像闸门）。
2. **时长分三档**：回应一次操作 100–400ms；打开页面时的单个入场 ≤ 650ms；一整段入场序列 ≤ 1000ms。
3. **每个动效对应一次操作或状态变化**：悬停、聚焦、点击、换页、打开页面、数据到了、出错了、保存好了。没有"为了好看一直在动"的东西。
4. **不做持续循环的装饰动画。** 例外只有两个：承载内容的滚动条（悬停或聚焦即停），和不知道进度的加载条（完成即停）。
5. **系统要求减少动态效果时全部关闭**（网页 `prefers-reduced-motion: reduce`，iOS `accessibilityReduceMotion`，Android「移除动画」/ `ANIMATOR_DURATION_SCALE` 为 0，Flutter `MediaQuery.disableAnimations`），直接显示最终状态。表示数据的东西（阅读进度条、加载进度）仍然更新。
6. 只动 `transform`、`opacity`、`clip-path`、`background-size`、`stroke-dashoffset`，不动宽高、边距、`left/top` 这类布局属性。要"让出位置"时用 FLIP：先记下位置，改布局，再用 transform 从旧位置动回来（`fx.js` 的 `removeRow()` 就是这样）。
7. 不要：弹跳、弹簧、果冻、文字逐个缩放弹出或描边再填实（文字要么直接出现，要么用擦入），发光脉冲、视差滚动背景、滚动触发的逐段淡入、抖动表示出错、Material 涟漪（换成擦入）、iOS 默认弹性回弹以外的额外弹跳。

## 三条曲线

| token | 曲线 | 用在 |
| --- | --- | --- |
| `snap` / `--ef-snap` | `cubic-bezier(0.16, 1, 0.3, 1)` | 出现、列表行右移、逐行入场、圆盘组装、FLIP 补位 |
| `mech` / `--ef-mech` | `cubic-bezier(0.7, 0, 0.2, 1)` | 快门、擦入、灌满、页签伸开、面板推入、通电、**所有退出** |
| `ease` / `--ef-ease` | `cubic-bezier(0.2, 0.7, 0.1, 1)` | 普通过渡：三色条扫过、颜色变化 |

`linear` 只给两样：乱码落定（逐位锁定本身就是节奏）和滚动条。

## 编排：谁先动、隔多久

一页打开时，按"从页面的骨架到细节"的顺序：

1. **骨架**：三色条扫过、命令栏（硬切，不动）。
2. **主角**：展示页是字标，控制台是圆盘，App 首屏是字标或第一块看板。主角和骨架同时开始（0ms）。
3. **说明**：马克笔、副标题，在主角走到一半左右开始（约 420ms）。
4. **数据**：字段读数、大数字乱码落定、看板通电，在 120ms 后陆续开始。
5. **列表**：屏幕里看得见的记录行逐行亮起；看不见的不等它，滚到时直接显示（不做滚动触发的入场）。

**错开间隔只用三档**：

| 间隔 | token | 用在 |
| --- | --- | --- |
| 38ms | `stagger.row` | 列表行、筛选后的新结果 |
| 45ms | `stagger.segment` | 圆盘的段 |
| 100ms | `stagger.block` | 看板、大块内容（App 上可以缩到 40ms） |

同一组超过 6 个时，缩小间隔而不是拉长总时长：`fx.js` 的 `wireReadouts()` 把读数的错开压在 180ms 以内。

**时间轴**（ms，样张最下面有图）：

| 展示页 | 开始 | 结束 |
| --- | --- | --- |
| 三色条扫过 | 0 | 600 |
| 字标实心行 | 0 | 620 |
| 字标空心行 | 140 | 760 |
| 字段读数 ×3 | 120 | 800 |
| 马克笔 | 420 | 840 |

| 控制台 | 开始 | 结束 |
| --- | --- | --- |
| 圆盘 6 段 | 80 | 665 |
| 看板第 1 / 2 / 3 行 | 120 / 220 / 320 | 640 / 740 / 840 |
| 大数字 ×6 | 120 | 900 |

| App 首屏 | 开始 | 结束 |
| --- | --- | --- |
| 字标 | 0 | 620 |
| 看板通电 | 120 | 640 |
| 大数字 ×3 | 160 | 760 |
| 最近记录 ×3 | 300 | 696 |

自己加东西时，把它放进对应的一档，并检查最后一个结束点仍在 1000ms 以内。

## 动效清单

下面的动效名（通电、快门、灌满、乱码后落定……）是内部叫法，方便你对照代码。给人看的说明、界面文字里用 `glossary.md` 里"对人怎么说"那一列。

| 动效 | 触发 | 时长 | 曲线 | 动的属性 | 网页 | token |
| --- | --- | --- | --- | --- | --- | --- |
| 三色条扫过 | 一次访问的第一页 | 600 | ease | transform | `.ef-tri.ef-in-sweep` | `sweep` |
| 字标推入 | 打开展示页 | 620（第二行晚 140） | mech | clip-path, transform | `.ef-in-drive` | `drive` |
| 马克笔划过 | 打开展示页 | 420，晚 420 | mech | background-size | `.ef-in-stroke` | `stroke` |
| 乱码后落定（打开） | 打开页面 | 600 | linear | 文字 | `data-fx-load` | `scrambleLoad` |
| 乱码后落定（悬停） | 悬停在所在的块上 | 360 | linear | 文字 | `data-fx-host` + `data-fx` | `scramble` |
| 通电 | 打开控制台 | 520，每行晚 100 | mech | clip-path, opacity | `.ef-in-power` + `--i` | `power` |
| 逐行亮起 | 切换列表内容 | 320，每行晚 38 | snap | clip-path, transform | `.ef-in-come` + `--i` | `come` |
| 圆盘组装 | 打开控制台 | 360，每段晚 45 | snap | transform, opacity | `dial.js` 自带 | `assemble` |
| 黄色擦入 | 悬停、聚焦按钮（触屏：按下） | 280（按下 100） | mech | transform | `.ef-btn` | `wipe` / `press` |
| 亮边扫过 | 悬停按钮 | 300 | mech | transform | `.ef-btn::after` | `edge` |
| 按下 | 点击按钮 | 100 | — | transform（下沉 1px、缩 1.5%） | `.ef-btn:active` | `press` |
| 色条落下、整行右移 | 悬停 / 按下列表行 | 200（右移 250） | snap | transform | `.ef-record`、`.ef-rows` | `row` |
| 页签伸开 | 悬停看板 | 400 | mech | transform | `.ef-panel` | `tab` |
| 墨色灌满 | 悬停空心大编号 | 450 | mech | background-size | `.ef-hollow-no` | `fill` |
| 黄底灌满 | 悬停看板里的大数字 | 220 | mech | background-size | `.ef-figs` | `figFill` |
| 锁定 | 悬停圆盘某段 | 300 | mech | stroke-dashoffset | `dial.js` 自带 | `lock` |
| 换页快门 | 同源页面跳转 | 360 | mech | clip-path | `@view-transition`，`endfield.css` 自带 | `shutter` |
| 当前块滑动 | 换页 | 360 | mech | 位置 | 给"当前"导航项设 `view-transition-name` | `shutter` |
| 指针视差 | 指针在展示页首屏移动 | 跟手 | — | transform（≤ 12px） | `fx.js`：`wireParallax()` | — |
| 滚动条 | 一直，悬停即停 | 60s 一圈 | linear | transform | `.ef-ticker` | `ticker` |

## 进出：每个入场都有退出

退出约是进入的 60–70%，一律用 mech：慢慢松开，然后"咔"地关上。

| 东西 | 进入 | 退出 | 网页 |
| --- | --- | --- | --- |
| 底部面板 | 从下推入 360 | 推回下面 240 | `dialog.ef-drawer` + `fx.js` `wireDialogs()` |
| 遮罩 | 淡入 200 | 淡出 160 | `::backdrop` |
| 对话框 | 通电（从上往下展开）280 | 从下往上关上 180 | `dialog.ef-dialog` + `wireDialogs()` |
| 提示条（toast） | 从左擦入 280，停 2000 | 向右擦掉 160 | `fx.js` `toast()` |
| 提示（notice） | 从左擦入 280 | 隐藏时直接消失 | `.ef-in-wipe` |
| 列表里删掉一行 | — | 向右擦掉 200，下面的行上移 200（snap，FLIP） | `fx.js` `removeRow()` |
| 新加的一行 | 逐行亮起 320 | — | `.ef-in-come` |
| 换页 | 快门 360 | 旧页不动，被新页盖住 | `@view-transition` |

关闭要等退出动效播完再真正移除（`closeDialog()`、`removeRow()` 都会等）；减少动效时立即移除。

## 状态变化

| 变化 | 怎么动 | 网页 |
| --- | --- | --- |
| 正在处理（保存、发送中） | 按钮铺斜线纹、暂停响应，不放转圈 | `.ef-btn[aria-busy="true"]` |
| 处理完成 | 黄色从左到右穿过按钮一次 600（mech），字可以短暂换成"已保存"；再弹一个提示条 | `fx.js` `flashDone()`、`toast()` |
| 出错 | 提示从左擦入 280，前面插黄旗；**不抖动、不变红** | `.ef-notice.ef-in-wipe` |
| 加载中，知道进度 | 分段进度条按格跳（24 格），读数补零 `063%` | `.ef-progress` + `--p` |
| 加载中，不知道进度 | 一段黄格从左往右走，完成即停 | `.ef-progress.is-unknown` |
| 骨架屏 → 内容 | 骨架硬切成内容，然后看得见的行逐行亮起；骨架不闪光 | `.ef-skeleton` → `.ef-in-come` |
| 空 → 有数据 | 空状态硬切掉，新行逐行亮起 | `.ef-in-come` |
| 开关、分段 | 方块 / 墨块移动 280（mech） | `.ef-switch`、`.ef-seg` |
| 标签栏换项 | 黄块移到新位置 280（mech） | `.ef-tabbar` |
| 筛选 | 结果区硬切，新结果逐行亮起（38ms 一行） | `.ef-in-come` |
| 深浅切换 | 从切换按钮处扩散一个圆揭开新主题，约 3000 像素/秒，240–600ms；或者直接切换 | `fx.js` `wireTheme()` |

## 手机上的对应

| 网页 | 手机 |
| --- | --- |
| 悬停按钮时黄色擦入 | 按下时擦入（100ms），抬起后退回（280ms mech） |
| 悬停列表行：色条落下、右移 | 按下时同样，抬起即回；不要涟漪 |
| 换页快门 | 推入新屏：新屏被一扇斜切快门从右推入 360ms mech；返回反向。iOS 保留系统侧滑返回手势 |
| 页签伸开 | 标签栏黄块移动到新位置 280ms mech |
| 乱码后落定 | 打开屏幕时大数字滚动落定 360–700ms，只做一次 |
| 通电 | 打开总览时看板按行依次展开，间隔 40ms，总长 ≤ 1 秒 |
| 底部面板 / 对话框 | 同上面"进出"表；Flutter 用 `showEfSheet()` / `showEfDialog()` |
| 触感反馈 | 主要操作按下给一次轻触感（iOS `.light` impact、Android `KEYBOARD_TAP`），删除确认给一次警告触感；不给每次滚动加触感 |

各平台的写法见 `platforms/` 下的指南。小程序读不到"减少动态效果"，见 `platforms/miniprogram.md` 的做法。

## 减少动效

`endfield.css` 在 `prefers-reduced-motion: reduce` 下把 `.ef` 里所有 transition 和 animation 关掉，滚动条变成可横向滚动的一条；面板和对话框直接出现和消失。`fx.js` 的乱码、视差、揭幕、删行动画在这个设置下什么也不做，直接到最终状态。自己加动效时，同样要包在 `@media (prefers-reduced-motion: no-preference)` 里。
