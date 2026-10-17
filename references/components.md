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

右下角切掉 7px，表示"可以点进去"。切角画在背景渐变里，所以焦点框完整。

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
- `.go`：主要操作，一组按钮里最多一个。有鼠标时墨底白字、指向时擦黄；触屏（`hover: none`）上静止就是黄底墨字，按下时擦入。
- `.small`：放进列表行、表格。
- `.danger`：擦入的是红色。**只给删除**。撤回、隐藏、封禁、从列表移除这些可以恢复的操作，用普通按钮加确认框。
- `:disabled`：半透明，指针变成 progress。

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

超大的空心数字。指向所在的链接时，墨色从左往右灌满；配合 `fx.js` 的 `data-fx`，数字同时"乱码后落定"。来自游戏里行底的大号半透明编号。

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

白板，顶边有一段 5px 的粗墨"页签"（占 14% 宽）。指向或聚焦看板时，页签沿整条边伸开。

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

放在看板里，左右贴边。左边是名称、状态和一行等宽元信息，右边是一组小按钮。悬停有"这里"色条。

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

外圈是 N 段弧形块，每段是一个链接：当前分区是墨色块；需要处理的分区边框加粗，并挂一个黄色小方块。指向某段时：块变黄，外缘画出一道括弧，一束光从块射向中心，中心显示这一段的数字。内圈可放几条四分之三圈的仪表弧；快满（超过 85%）的那条变成 `--ef-trace` 色，标签垫黄。

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
