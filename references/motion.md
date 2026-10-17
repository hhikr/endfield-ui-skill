# 动效

## 原则

1. **短、硬、机械。** 出现的东西用 `--ef-snap`（迅速到位后稳住）；快门、擦入、灌满、页签伸开用 `--ef-mech`（慢起、硬停，像机械臂和闸门）。时长多在 120–400ms，一个入场序列整体不超过 1 秒。
2. **每个动效对应一次操作或状态变化**：指向、聚焦、点击、换页、打开页面。没有"为了好看一直在动"的东西。
3. **不做持续循环的装饰动画。** 例外只有两个：承载内容的滚动条（悬停或聚焦即停），和不确定进度的加载条（完成即停）。
4. **系统要求减少动态效果时全部关闭**（网页 `prefers-reduced-motion: reduce`，iOS `accessibilityReduceMotion`，Android「移除动画」/ `ANIMATOR_DURATION_SCALE` 为 0，Flutter `MediaQuery.disableAnimations`），直接显示最终状态。表示数据的东西（阅读进度条）仍然更新。
5. 只动 `transform`、`opacity`、`clip-path`、`background-size`、`stroke-dashoffset`，不动布局属性。
6. 不要：弹跳、弹簧、果冻、发光脉冲、视差滚动背景、滚动触发的逐段淡入、Material 涟漪（换成擦入）、iOS 默认的弹性回弹以外的额外弹跳。

## 动效清单

| 动效 | 触发 | 写法 | 类 / 函数 |
| --- | --- | --- | --- |
| 三色条扫过 | 一次访问的第一页 | `scaleX(0→1)`，600ms，`--ef-ease` | `.ef-tri.ef-in-sweep` |
| 换页快门 | 同源页面跳转 | 新页面被一扇斜切的快门从左推入，360ms `--ef-mech`（`@view-transition`） | 全局，`endfield.css` 自带 |
| 当前块滑动 | 换页 | 给"当前"导航项设 `view-transition-name`，黄块会滑到新位置 | 自己加 |
| 黄色擦入 | 指向、聚焦按钮 | 黄色从左擦入，前面一条亮边扫过，280ms `--ef-mech` | `.ef-btn` |
| 按下 | 点击按钮 | 下沉 1px，缩小 1.5% | `.ef-btn:active` |
| 色条落下、整行右移 | 指向列表行 | 4px `--ef-trace` 色条从上往下落，内容右移 6px | `.ef-record`、`.ef-rows` |
| 页签伸开 | 指向看板 | 顶边粗墨页签从 14% 伸到 100%，400ms `--ef-mech` | `.ef-panel` |
| 墨色灌满 | 指向空心大编号 | 背景从 0% 到 100% 宽，裁进字形，450ms | `.ef-hollow-no` |
| 黄底灌满 | 指向看板里的大数字 | 同上，换成黄色 | `.ef-figs` |
| 乱码后落定 | 打开页面 / 指向数字所在的块 | 数字和字母随机滚动，从左往右逐位锁定，360–700ms | `fx.js`：`data-fx-load`、`data-fx-host` 加 `data-fx` |
| 字标推入 | 打开展示页 | 被一扇快门从左推出来，略带位移，620ms | `.ef-in-drive` |
| 马克笔划过 | 打开展示页 | 黄底从 0 宽到全宽，延迟 420ms | `.ef-in-stroke` |
| 通电 | 打开控制台 | 看板从上往下展开，按行依次延迟 | `.ef-in-power` 加 `--i` |
| 逐行亮起 | 切换索引内容 | 每行从左擦出，间隔 38ms | `.ef-in-come` 加 `--i` |
| 圆盘组装 | 打开控制台 | 各段依次放大到位，间隔 45ms | `dial.js` 自带 |
| 锁定 | 指向圆盘某段 | 外缘画出括弧，一束光射向中心（`stroke-dashoffset`），中心换读数 | `dial.js` 自带 |
| 指针视差 | 指针在展示页首屏移动 | 画框和影子反向轻移（12px 以内） | `fx.js`：`wireParallax()` |
| 滚动条 | 一直 | 60 秒一圈，悬停即停 | `.ef-ticker` |

## 深浅切换

可以做一个从切换按钮位置扩散开的圆形揭幕（约 3000 像素/秒），也可以直接切换。网页用 View Transitions API 给 `::view-transition-new(root)` 做 `clip-path: circle()` 动画；原生直接切换主题即可。减少动效时直接切换。

## 手机上的对应

| 网页 | 手机 |
| --- | --- |
| 指向按钮时黄色擦入 | 按下时擦入（100ms），抬起后退回（280ms mech） |
| 指向列表行：色条落下、右移 | 按下时同样，抬起即回；不要涟漪 |
| 换页快门 | 推入新屏：新屏被一扇斜切快门从右推入 360ms mech；返回反向。iOS 保留系统侧滑返回手势 |
| 页签伸开 | 标签栏黄块移动到新位置 280ms mech |
| 乱码后落定 | 打开屏幕时大数字滚动落定 360–700ms，只做一次 |
| 通电 | 打开总览时看板按行依次展开，间隔 40ms，总长 ≤ 1 秒 |
| 底部面板 | 从下推入 360ms mech，遮罩 200ms 淡入；不弹跳 |
| 触感反馈 | 主要操作按下给一次轻触感（iOS `.light` impact、Android `KEYBOARD_TAP`），删除确认给一次警告触感；不给每次滚动加触感 |

时长和曲线见 `assets/tokens.json` 的 `motion`；各平台的写法见 `platforms/` 下的指南。

## 减少动效

`endfield.css` 最后一段在 `prefers-reduced-motion: reduce` 下把 `.ef` 里所有 transition 和 animation 关掉，滚动条变成可横向滚动的一条。`fx.js` 的乱码和视差在这个设置下什么也不做。自己加动效时，同样要包在 `@media (prefers-reduced-motion: no-preference)` 里。
