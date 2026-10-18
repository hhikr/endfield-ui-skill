# 网页（桌面浏览器）

起点：`assets/endfield.css`（部件）、`assets/fx.js`（小动效、深浅切换）、`assets/dial.js`（控制台圆盘）、`assets/contours/`（等高线），以及 `templates/` 里的三张模板。不依赖任何框架。

## 接入

1. 把 `assets/` 整个复制进项目（`endfield.css` 用相对路径引用 `contours/`）。
2. 字体自托管（见 `../tokens.md`）：

   ```css
   @import '@fontsource-variable/saira/standard.css';
   @import '@fontsource-variable/noto-sans-sc/wght.css';
   @import './endfield.css';
   ```

3. 页面骨架：

   ```html
   <!-- 变体写在 <html> 上，见 ../variation.md -->
   <html lang="zh-CN" data-ef-accent="ice" data-ef-paper="cool" data-ef-cut="tight" data-ef-ground="grid">
     <head>
       <!-- 先写好主题，避免闪烁 -->
       <script>
         try { const t = localStorage.getItem('theme'); if (t) document.documentElement.dataset.theme = t; } catch {}
       </script>
       <meta name="theme-color" content="#F4F4F2" media="(prefers-color-scheme: light)" />
       <meta name="theme-color" content="#191919" media="(prefers-color-scheme: dark)" />
     </head>
     <body class="ef ef-contours">
       <div class="ef-tri" aria-hidden="true"><i></i><i></i><i></i></div>
       …
       <script type="module">
         import { wireTheme, wireReadouts } from './assets/fx.js';
         wireTheme();
         wireReadouts(document);
       </script>
     </body>
   </html>
   ```

   如果内容安全策略不允许内联脚本，把这两段放进外部文件。

4. 变体只在 `<html>` 上设置一次：`data-ef-accent`、`data-ef-paper`、`data-ef-cut`、`data-ef-ground`、`data-ef-density`、`data-ef-motion`，或者写一个 `data-ef-variant` 预设，再在 `<head>` 里引用 `assets/variant.js`（它还能从地址读 `?variant=`，方便对比）。自定义强调色就直接覆盖 `--ef-signal`。
5. 部件怎么写、怎么组合，参考模板：阅读 `templates/reading.html`、展示 `templates/showcase.html`、控制台 `templates/console.html`、手机屏幕 `templates/app.html`；动效对照 `templates/motion.html`。版式按自己的内容排，不照搬模板的结构和占位内容。页面自己的 `<style>` 只写布局（grid、间距），颜色、字、部件全部用 `ef-` 类和 `--ef-*` 变量。

模板要用静态服务器打开（浏览器不允许从 `file://` 加载 ES 模块）：在 skill 目录运行 `python3 -m http.server`，打开 `http://localhost:8000/templates/showcase.html`。

## 在框架里用

- **React / Vue / Svelte / Astro**：直接写类名（`className="ef-btn go"`）。把 `endfield.css` 作为全局样式引入一次。`fx.js` 的函数在组件挂载后调用（`useEffect` / `onMounted`），传入组件根节点。
- **Tailwind**：保留 `endfield.css` 做部件，用 token 扩展主题，布局用 Tailwind：

  ```js
  // tailwind.config.js
  export default {
    theme: {
      extend: {
        colors: {
          paper: 'var(--ef-paper)', panel: 'var(--ef-panel)', ink: 'var(--ef-ink)', 'ink-2': 'var(--ef-ink-2)',
          rule: 'var(--ef-rule)', chip: 'var(--ef-chip)', signal: 'var(--ef-signal)', trace: 'var(--ef-trace)',
        },
        fontFamily: { ui: 'var(--ef-font-ui)', text: 'var(--ef-font-text)' },
        borderRadius: { DEFAULT: '0', none: '0' },
        boxShadow: { DEFAULT: 'none' },
      },
    },
  };
  ```

  然后把默认的 `rounded-*`、`shadow-*` 当成禁用词。

- **组件库**（MUI、Ant Design、Element、shadcn/ui 等）：把圆角设为 0、关掉阴影和涟漪、主色设为墨（`#161616`）而不是黄，强调色只给"当前"和主操作；按钮、标签、表格换成 `ef-` 部件更省事。Ant Design：`token: { borderRadius: 0, colorPrimary: '#161616', boxShadow: 'none', fontFamily: 'var(--ef-font-ui)' }`。

## 网页特有的细节

- **焦点**：`.ef` 下所有可聚焦元素有 2px、颜色跟随文字（`currentColor`）的焦点框，所以在深色命令栏、墨色滚动条上也看得见；输入框聚焦用 `--ef-trace`。切角按钮的焦点框向内缩 4px，不会被切掉。
- **换页快门**：`endfield.css` 自带同源 `@view-transition`，新页面被一扇斜切快门推入。不想要就删掉那一段。
- **链接**：正文链接墨字压黄色下划块；深色里改成细黄线。
- **表格**：列表用 `.ef-records` 或 `.ef-rows`；真正的数据表用 `<table class="ef-table">`：表头是眉标样式，行间细线，数字右对齐用等宽数字，没有斑马纹。
- **图表**：灰色柱和线，悬停的那一项变成 `--ef-trace`；超阈值的点用黄色方块标记。不用红绿、不用渐变填充。简单柱图用 `.ef-bars`；用图表库时照这几条改它的配色。
- **滚动条**：可以把 `scrollbar-color` 设成 `var(--ef-rule) transparent`，细而直角。

## 验收

- 375、768、1024、1440 四个宽度，浅深两套，都没有横向滚动。
- 开系统的"减少动态效果"后一切静止。
- 键盘 Tab 走一遍：焦点框都看得见，顺序合理。
