# 部件：写法、含义、禁忌

这是**网页**写法：所有类都在 `assets/endfield.css`。效果图见 `examples/web/specimen-light.jpg`、`specimen-dark.jpg`。部件的含义在所有平台都一样，原生写法见 `platforms/` 下的指南。外层容器要带 `class="ef"`（通常放在 `<body>` 上）。

---

## 三色条 `.ef-tri`

```html
<div class="ef-tri" aria-hidden="true"><i></i><i></i><i></i></div>
```

3px 高，品红、黄、薄荷绿三等分。**只放两处**：页面最顶上；文章标题正下方。一次访问的第一页可以加 `.ef-in-sweep`，让它从左往右画出来。

不要：放在正文中间、当列表分隔、做成渐变、加粗。

## 记录字段 `.ef-field` `.ef-facts`

```html
<ul class="ef-facts ef-field">
  <li><time datetime="2026-10-12">2026.10.12</time></li>
  <li>12,464 字</li>
  <li>约 34 分钟</li>
</ul>
```

界面字体 13px、宽度 112%、次要墨色、等宽数字。`.ef-facts` 用竖线分隔，换行时行首不出现竖线。日期写成 `2026.10.12`；计数带单位；`当前 / 总数` 写成 `3 / 100`。

不要：用 `·` 串字段；写"三天前"这种相对时间；编造数字。

## 入口：编号、键值、小块 `.ef-tag` `.ef-kv` `.ef-chip`

```html
<a class="ef-tag is-current" href="/records/">No.016</a>
<a class="ef-kv" href="/c/notes/"><span>分类</span><span>记录</span></a>
<button class="ef-chip" aria-pressed="true">全部 <span class="n">16</span></button>
```

右下角切掉 7px（`--ef-cut`，随变体缩放），表示"可以点进去"。切角画在背景渐变里，所以焦点框完整。右侧内边距是一段固定值加 `--ef-cut`，切角放大时字也不会压进切角。

- `.ef-tag`：墨底编号。`.is-current` 或悬停时变黄 = 当前所在。
- `.ef-kv`：成对键值，左键右值，中间一条细线。来自官网的"键｜值"小标签。
- `.ef-chip`：浅灰小块，用于筛选和标签。`aria-pressed="true"` 或 `.is-active` 变黄。

不要：给不能点的东西切角；同一排出现两个黄色的"当前"。

## 按钮 `.ef-btn`

```html
<a class="ef-btn go" href="#">读最新一篇 <span class="sub">No.016</span></a>
<a class="ef-btn" href="#">全部文章</a>
<button class="ef-btn small danger" type="button">删除</button>
```

右下角切掉 0.5rem（用 `mask` 实现，所以焦点框画在块内）。悬停：黄色从左擦入，前面带一条亮边扫过，字在边经过时变色；按下时下沉 1px、缩小 1.5%。

- 默认：浅灰底，次要操作。
- `.go`：主要操作，一组按钮里最多一个。有鼠标时墨底白字、悬停时擦黄；触屏（`hover: none`）上静止就是黄底墨字，按下时擦入。
- `.small`：放进列表行、表格。
- `.danger`：字是红色，擦入的也是红色。**只给删除**。撤回、隐藏、封禁、从列表移除这些可以恢复的操作，用普通按钮加确认框。
- `:disabled`：现在不能按，半透明，指针 not-allowed。
- `aria-busy="true"`：已经按下、正在处理（保存、发送中），铺斜线纹并暂停响应。处理完去掉这个属性。

一排按钮放在 `<p class="ef-actions">` 里。

不要：圆角、胶囊形、投影、渐变底、图标加箭头 `→`（用"查看全部"这样的文字）。

## 马克笔 `.ef-marker`

```html
<p><span class="ef-marker">示例：一个人的工程记录</span></p>
```

一行黄底墨字粗体，像荧光笔划过。**一页最多一处**，用来说"这是什么"。加 `.ef-in-stroke` 时，打开页面会有一笔划过的动效。

## 状态 `.ef-state`

```html
<span class="ef-state">已发布</span>
<span class="ef-state is-hidden">隐藏</span>
<span class="ef-state is-draft">草稿</span>
<span class="ef-state is-alert">待审</span>
```

实线墨框 = 生效中；虚线 = 在后台（草稿、隐藏、暂停）；黄块 = 需要看一眼（待审、失败、被封禁）。**不用红色**。

## 提示 `.ef-notice`

```html
<p class="ef-notice" data-flag="出错">这个地址已经被另一个作品使用。</p>
```

墨框白底，前面一面黄色小旗（默认写"注意"，用 `data-flag` 改字）。出错、警告、需要读的说明都用它。空的时候隐藏起来。

## 记录行 `.ef-records`

```html
<ol class="ef-records">
  <li>
    <a class="ef-record" href="/records/24/">
      <span class="ef-tag">No.016</span>
      <time class="ef-field">2026.10.12</time>
      <span class="name ef-read">示例：仓储节点的布线记录</span>
      <span class="ef-field">12,464 字</span>
    </a>
  </li>
</ol>
```

四列：编号 / 日期 / 名称 / 计数，每一列都是真实字段。悬停：左边落下一条 4px 的 `--ef-trace` 色条，行内容右移 6px，底色变成纸色。手机上名称换到第二行。

阅读页的列表一律用它，不用卡片。来自游戏内"一行一条记录"的列表。

## 阅读页零件

```html
<p class="ef-crumb ef-field"><a href="/posts/">全部文章</a><span>学习</span></p>
<header class="ef-sheet-head"><h1 class="ef-read">文章</h1><p class="ef-field">共 16 篇</p></header>
<p class="ef-lede ef-read">一两句话说明这里有什么。</p>
<h2 class="ef-group-head ef-read"><span>2025</span><span class="ef-field">12 篇</span></h2>
<ul class="ef-ledger"><li><span>字数合计</span><span class="ef-field">97,976 字</span></li></ul>
<p class="ef-empty">还没有发布文章。写好的笔记会按发布顺序编号，列在这里。</p>
```

- `.ef-sheet-head`：页名在左，计数在右，下面一条墨线。
- `.ef-group-head`：列表里的分组（年份、分类），下面一条墨线，计数在右。
- `.ef-ledger`：页边的"标签｜数字"表；值需要注意时加 `.warn`（黄块）。
- `.ef-empty`：空状态写成完整的一句话，说明将来会出现什么。

## 正文 `.ef-prose`

黑体常规 17px，行高 1.85，最长约 38 字一行。

- 链接：墨字压在一条 0.4em 粗的黄色下划块上；悬停时黄块变厚盖住整个字。深色主题里改成 1.5px 的黄色细线（黄块会吞掉浅色字）。
- 强调：加粗（700）。
- 引用：左边 3px 墨线，字退成次要墨色。
- 二级标题：上方一条细线隔开，界面字体 700。
- 行内代码：等宽，细边框，纸色底。

## 大字标 `.ef-wordmark`

```html
<h1 class="ef-wordmark">
  <span class="solid ef-in-drive">ACME</span>
  <span class="hollow ef-in-drive" style="animation-delay:140ms" aria-hidden="true">.WORKS</span>
</h1>
```

实心超大字，下面跟一行约一半大的空心字（2px 描边）。界面字体 800、宽度 125%、全大写、行高 0.84。名字较长时用 `--ef-wordmark` 调字号。只用在展示页。

## 空心大编号 `.ef-hollow-no`

```html
<a href="/records/24/" data-fx-host>
  <span class="ef-hollow-no" aria-hidden="true" data-fx>016</span>
  …标题、字段、按钮…
</a>
```

超大的空心数字。鼠标悬停在它所在的链接上时，墨色从左往右灌满；配合 `fx.js` 的 `data-fx`，数字同时"乱码后落定"。来自游戏里行底的大号半透明编号。

## 画框与铭牌 `.ef-frame` `.ef-plate`

```html
<figure class="ef-frame">
  <div class="window"><img src="cover.webp" alt="…" /></div>
  <figcaption class="ef-plate">一句话说明这张图。</figcaption>
</figure>
```

左上、右下各切掉 3.25rem 的画框；后面错开一块斜线纹"影子"（硬边，不是投影）；左下压一块切角的墨色铭牌，写一句话。画框的高度由容器决定，`.window` 绝对定位铺满。配合 `fx.js` 的 `wireParallax()`，图和影子随指针反向轻移。

图要用**自己的**：线稿、照片、自己画的等轴测线图都行。不要用游戏立绘或官方插画。

## 滚动条 `.ef-ticker`

```html
<div class="ef-ticker" aria-label="最近的文章">
  <div class="track">
    <ul>…<li><a href="#"><b>No.016</b>标题</a></li>…</ul>
    <ul aria-hidden="true">…同一份，链接加 tabindex="-1"…</ul>
  </div>
</div>
```

墨色横带，编号是黄块。两份列表首尾相接，60 秒滚完一圈，悬停或聚焦即停。减少动效时停止，变成可以横向滚动的一条。它是全套里唯一允许持续运动的东西，因为它承载内容。

## 眉标与中英成对 `.ef-eyebrow` `.ef-pair`

```html
<p class="ef-eyebrow slash">Records / 2026</p>
<h2 class="ef-pair"><span class="ef-eyebrow">Records</span><span>记录</span></h2>
```

`.ef-eyebrow`：11px、宽度 125%、600、全大写、字距 0.14em、次要墨色。`.slash` 在前面加 `// `。`.ef-pair`：英文小字在上，中文粗体在下，用来给段落和看板起名。

不要：把中文也拉宽、全大写的长句、一屏里每个元素都挂眉标。

## 斜线纹标题 `.ef-bar-title` `.ef-head`

```html
<h2 class="ef-bar-title">全站索引</h2>
<header class="ef-head"><h1>文章 <small>Posts</small></h1><p>一句说明。</p></header>
```

粗体标题，后面拖一条斜线纹带，带子起头是一个实心墨块。`.ef-bar-title` 用在展示页的段落，`.ef-head` 用作控制台的页名（中文加小号英文）。

## 命令栏 `.ef-cmdbar`

```html
<header class="ef-cmdbar">
  <a class="brand" href="/admin/"><span class="seal">A</span>CONSOLE</a>
  <nav>
    <a href="/admin/" aria-current="page">概览<small>Overview</small></a>
    <a href="/admin/comments/">评论<small>Comments</small><span class="count">2</span></a>
  </nav>
  <div class="util"><a href="/">查看网站</a></div>
</header>
```

两套主题下**都是深色**，所以黄色"当前分区"块在哪里看起来都一样。徽记是黄色切角方块里的一个大写字母（用自己的字母，不要用游戏标志）。悬停分区时，一条黄线沿底边从左擦过。待处理数量用黄色小角标。控制台没有左侧列表，命令栏是唯一的导航。

## 看板 `.ef-panel`

```html
<section class="ef-panel cut-br">
  <h2>文章 <a href="/admin/posts/">全部</a></h2>
  <div class="ef-figs">
    <a href="#"><b data-fx-load>16</b><span>已发布</span></a>
    <a href="#" class="is-alert"><b>2</b><span>待审</span></a>
    <a href="#"><b>7</b><span>草稿</span></a>
  </div>
</section>
```

白板，顶边有一段 5px 的粗墨"页签"（占 14% 宽）。悬停或聚焦看板时，页签沿整条边伸开。

修饰：
- `.cut-br` / `.cut-bl` / `.cut-tr` / `.cut-tl`：切掉朝向中心圆盘的那个角，让一侧的看板顺着圆的轮廓排，而不是摆成方格。
- `.tab-right`：页签从右端伸出（右侧看板用，左右镜像）。
- `.lead-right` / `.lead-left`：从看板中线引出一根细线，末端一个 7px 方块，接到圆盘边上；用 `--lead` 设长度。窄屏时隐藏。

内容：`.ef-figs`（三个大数字；`.is-alert` 的数字带黄底）、`.ef-ledger`（标签｜数值，`.warn` 黄块）、`.ef-rows`（工作行）。

## 工作行 `.ef-rows`

```html
<ul class="ef-rows">
  <li>
    <div><div>后端 <span class="ef-state is-draft">草稿</span></div><div class="meta"><span>compiler-ch-8</span><span>2,058 字</span></div></div>
    <div class="acts"><a class="ef-btn small" href="#">编辑</a><button class="ef-btn small go">发布</button></div>
  </li>
</ul>
```

放在看板里，左右贴边。左边是名称、状态和一行等宽元信息，右边是一组小按钮。悬停有当前位置色条。

## 圆盘 `.ef-dial` + `dial.js`

```html
<svg class="ef-dial" data-dial role="group" aria-label="分区"></svg>
<script type="module">
  import { drawDial } from './assets/dial.js';
  drawDial(document.querySelector('[data-dial]'), {
    idle: { label: '系统已运行', big: 16, unit: '小时', sub: '读数 11:36' },
    gauges: [{ label: '处理器', share: 0.12 }, { label: '内存', share: 0.64 }],
    sections: [
      { zh: '概览', en: 'Overview', href: '/admin/', big: 16, unit: '小时', here: true },
      { zh: '评论', en: 'Comments', href: '/admin/comments/', big: 10, unit: '条', sub: '待审 2', alert: true },
    ],
  });
</script>
```

外圈是 N 段弧形块，每段是一个链接：当前分区是墨色块；需要处理的分区边框加粗，并挂一个黄色小方块。悬停某段时：块变黄，外缘画出一道括弧，一束光从块射向中心，中心显示这一段的数字。内圈可放几条四分之三圈的仪表弧，平时是次要墨色；快满（超过 85%）的那条变成 `--ef-trace` 色，标签垫黄。

## 表单 `.ef-form`

```html
<form class="ef-form">
  <label class="field"><span>名字</span><input name="name" /><small>登录时填完整的名字。</small></label>
  <p class="ef-notice" data-flag="出错" hidden></p>
  <p class="ef-actions"><button class="ef-btn go">保存</button></p>
</form>
```

方角输入框，白底细边；悬停边框变深，聚焦时墨色边框加一圈 2px 的 `--ef-trace`。标签用界面字体 600，说明写在框下面。

## 等高线背景 `.ef-contours`

放在 `<body>` 上。右上角一大片、左下角一小片，墨色 9%，向边缘渐隐；手机上只留右上角。线条不闭合、成束流动，像水流。用 `assets/contours/draw-contours.mjs` 改随机种子就能生成新的一组，样式里用作遮罩，所以颜色跟随主题。

不要：铺满全屏、加深、换成点阵或方格纸、画成一圈圈闭合的山丘。

---

# App 部件（手机网页、H5、PWA）

和 Flutter 套件（`templates/flutter/`）一一对应，模板 `templates/app.html`。需要 `env(safe-area-inset-*)` 时记得在 viewport 里写 `viewport-fit=cover`。

## 顶栏 `.ef-topbar` 和返回键 `.ef-back`

```html
<header class="ef-topbar">
  <button class="ef-back" type="button" aria-label="返回">‹</button>
  <h1 class="ef-pair"><span class="ef-eyebrow slash">Config</span><span>设置</span></h1>
  <button class="ef-btn small" type="button">筛选</button>
</header>
```

不填色、不居中、不加投影，下面一条细线。返回键是切角小方块，不是圆形图标按钮。右侧最多一两个文字按钮。

## 底部标签栏 `.ef-tabbar`

```html
<body class="ef ef-has-tabbar">
  …
  <nav class="ef-tabbar can-rail" aria-label="主导航">
    <a href="/" aria-current="page"><small>Home</small>总览</a>
    <a href="/records/"><small>Records</small>记录</a>
  </nav>
</body>
```

3–5 项，每项英文眉标加中文，**必须有字**。当前项整格黄块、右下切角、加粗。`body` 加 `.ef-has-tabbar` 给内容让出底部；加 `.can-rail` 后宽于 600 时竖到左边（平板）。

## 侧栏 `.ef-rail`

```html
<nav class="ef-rail" aria-label="主导航">
  <a class="brand" href="/">ACME.WORKS</a>
  <a href="/posts/" aria-current="page">文章</a>
  <a href="/c/">分类</a>
</nav>
```

阅读页的竖排导航，当前项整格黄块。窄于 1100 时自动横过来。要它贴顶，自己加 `position: sticky`（见 `templates/reading.html`）。

## 搜索 `.ef-search`

```html
<label class="ef-search"><input type="search" placeholder="搜索标题、编号" aria-label="搜索" /></label>
```

白底细框，前缀 `//`，聚焦时下边变 2px trace 线。字号不小于 16px（iOS 不会放大）。

## 开关 `.ef-switch`、分段 `.ef-seg`、设置行 `.ef-setting`

```html
<label class="ef-setting">
  <span><b>公开记录</b><small>关闭后只有自己能看到。</small></span>
  <input class="ef-switch" type="checkbox" role="switch" checked />
</label>

<div class="ef-seg" role="radiogroup" aria-label="显示密度">
  <label><input type="radio" name="d" /><span>紧凑</span></label>
  <label><input type="radio" name="d" checked /><span>标准</span></label>
</div>
```

- 开关是方的：开 = 黄轨道墨方块，关 = 浅灰轨道白方块。用的是原生 checkbox，键盘和读屏都不用另外处理。
- 分段：墨色细框，当前段墨底反白。**不用黄**：黄留给导航的"当前"和主要操作。每段至少 44 高。
- 设置行：名称加一行说明在左，控件在右，下面细线。

## 进度 `.ef-progress`、骨架 `.ef-skeleton`

```html
<div class="ef-progress" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="63" style="--p: 0.63">
  <span class="ef-eyebrow">Syncing / 同步中</span><span class="ef-field">063%</span><i></i>
</div>
<div class="ef-progress is-unknown" role="progressbar" aria-label="正在连接">…<i></i></div>
<span class="ef-skeleton line"></span>
```

24 格的分段条，亮的格是黄的，读数补零。不知道进度时加 `.is-unknown`，一段黄格从左往右走，完成后换成有数的或者移除。不用转圈。骨架屏是 chip 色的块，不闪光。

## 底部面板 `.ef-drawer`、对话框 `.ef-dialog`

```html
<button data-open="actions">更多</button>

<dialog class="ef-drawer" id="actions" aria-labelledby="t">
  <div class="body">
    <div class="grab" aria-hidden="true"></div>
    <header class="ef-pair" id="t"><span class="ef-eyebrow slash">No.023 / Actions</span><span>第二阶段的设备清单</span></header>
    <button class="ef-act" data-close="open"><span>打开</span><span class="ef-field">9,102 字</span></button>
    <button class="ef-act danger" data-close="delete"><span>删除</span></button>
    <p class="ef-actions"><button class="ef-btn" data-close>取消</button></p>
  </div>
</dialog>

<dialog class="ef-dialog" id="confirm" aria-labelledby="c">
  <div class="ef-panel cut-br">
    <p class="ef-eyebrow slash">Confirm</p>
    <h2 id="c">删除这条记录？</h2>
    <p>No.023 会被永久删除，不能恢复。</p>
    <p class="ef-actions"><button class="ef-btn small" data-close>取消</button><button class="ef-btn small danger" data-close="delete">删除</button></p>
  </div>
</dialog>

<script type="module">
  import { wireDialogs } from './assets/fx.js';
  wireDialogs(); // data-open 打开，data-close / Esc / 点遮罩关闭，都带进出动效
</script>
```

类名是 `.ef-drawer` 而不是 sheet：`.ef-sheet` 是阅读页的白纸。用原生 `<dialog>`，焦点圈在里面、Esc 能关、背后的页面不能点。面板左上切角、顶部斜线纹带和把手；对话框就是一块看板，确认在右，删除用 `.danger`。`dialog.returnValue` 是被点的那个 `data-close` 的值。

## 提示条 `toast()`

```js
import { toast } from './assets/fx.js';
toast('已保存。');
```

深色条、左边 6px 黄条、一句话，从左擦入，2 秒后向右擦掉，`role="status"` 会被读屏读出。错误不用它，用 `.ef-notice`。

## 数据表 `.ef-table`

```html
<div class="ef-table-wrap">
  <table class="ef-table">
    <thead><tr><th>节点</th><th class="num">吞吐 / 分</th></tr></thead>
    <tbody><tr><td>sample-node-07</td><td class="num">1,284</td></tr></tbody>
  </table>
</div>
```

表头是眉标样式加墨线，行间细线，数字右对齐、等宽数字，没有斑马纹；悬停的行左边出现 trace 色条。宽表放进 `.ef-table-wrap` 横向滚动。

## 柱图 `.ef-bars`

```html
<ol class="ef-bars" aria-label="最近 7 天的访问">
  <li style="--v: 0.4"><span>10.11</span></li>
  <li style="--v: 0.9" class="is-here is-over"><span>10.12</span></li>
</ol>
```

灰柱；悬停的或 `.is-here` 的那根变成 trace 色；超过阈值的在顶上挂一个黄色小方块（`.is-over`）。不用红绿、不用渐变。给它一个 `aria-label`，数值另外写在表格或文字里。

## 进出和状态的小函数（`fx.js`）

| 函数 | 做什么 |
| --- | --- |
| `wireDialogs()` / `closeDialog(d)` | 面板和对话框的进出动效、Esc、点遮罩 |
| `toast(text, ms)` | 提示条 |
| `removeRow(li)` | 一行向右擦掉，下面的行用 transform 补位 |
| `flashDone(btn, label)` | 去掉 `aria-busy`，黄色穿过按钮一次，可选地短暂换字 |
| `wireTheme()` | 深浅切换、记住选择、同步 `aria-pressed`、圆形揭幕 |

`.ef-in-wipe`（从左擦入）和 `.ef-out-wipe`（向右擦掉）两个类也可以直接用。时长和曲线见 `motion.md`。
