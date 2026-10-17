# Android 原生（Jetpack Compose / Views）

> 下面的代码片段按 Compose BOM 2024+ 写成，**没有在本 skill 里编译验证过**；概念和数值与已验证的 Flutter 套件（`templates/flutter/`）一一对应，遇到 API 出入以 Flutter 版的行为为准。

## 颜色

```kotlin
@Immutable
data class EfColors(
    val paper: Color, val panel: Color, val ink: Color, val ink2: Color,
    val rule: Color, val chip: Color, val trace: Color,
    val tagBg: Color, val tagFg: Color, val danger: Color, val scrim: Color,
)

val Signal = Color(0xFFFFFA00)
val OnSignal = Color(0xFF161616)
val CommandBar = Color(0xFF161616)
val TriA = Color(0xFFFF00F0); val TriB = Signal; val TriC = Color(0xFF00FFA2)

val EfLight = EfColors(
    paper = Color(0xFFF4F4F2), panel = Color.White, ink = Color(0xFF161616), ink2 = Color(0xFF5C5C5C),
    rule = Color(0xFFD9D9D6), chip = Color(0xFFE4E4E0), trace = Color(0xFF161616),
    tagBg = Color(0xFF161616), tagFg = Color.White, danger = Color(0xFFB3261E), scrim = Color(0x80161616),
)
val EfDark = EfColors(
    paper = Color(0xFF191919), panel = Color(0xFF222222), ink = Color(0xFFEDEDED), ink2 = Color(0xFFA3A3A3),
    rule = Color(0xFF353535), chip = Color(0xFF2E2E2E), trace = Signal,
    tagBg = Color(0xFF3A3A3A), tagFg = Color(0xFFEDEDED), danger = Color(0xFFFF8A7A), scrim = Color(0xA0000000),
)

val LocalEf = staticCompositionLocalOf { EfLight }

@Composable
fun EfTheme(dark: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit) {
    val c = if (dark) EfDark else EfLight
    val scheme = (if (dark) darkColorScheme() else lightColorScheme()).copy(
        // 主色是墨不是黄：Material 默认部件（光标、焦点线、进度条、复选框）用主色画线，
        // 黄线在浅色纸上看不见。黄色只在 ef 部件里手动用。
        primary = c.ink, onPrimary = c.paper, secondary = Signal, onSecondary = OnSignal,
        background = c.paper, surface = c.panel,
        onBackground = c.ink, onSurface = c.ink, outline = c.rule, error = c.danger,
    )
    val square = CutCornerShape(0.dp)
    CompositionLocalProvider(LocalEf provides c) {
        MaterialTheme(
            colorScheme = scheme,
            shapes = Shapes(square, square, square, square, square),   // 全部直角
            content = content,
        )
    }
}
```

状态栏和导航栏：`enableEdgeToEdge()`，内容自己处理 `WindowInsets`；浅色主题时状态栏图标用深色。

## 字体

把 `Saira.ttf` 放进 `res/font/saira.ttf`。可变字体在 API 26+ 支持 `variationSettings`：

```kotlin
@OptIn(ExperimentalTextApi::class)
fun saira(weight: Int, width: Float = 100f) = FontFamily(
    Font(
        R.font.saira,
        weight = FontWeight(weight),
        variationSettings = FontVariation.Settings(FontVariation.weight(weight), FontVariation.width(width)),
    )
)

val Eyebrow = TextStyle(fontFamily = saira(600, 125f), fontSize = 11.sp, letterSpacing = 1.54.sp)
val Field = TextStyle(fontFamily = saira(400, 112f), fontSize = 13.sp, fontFeatureSettings = "tnum")
val Label = TextStyle(fontFamily = saira(600), fontSize = 15.sp)
val H1 = TextStyle(fontFamily = saira(700), fontSize = 30.sp, lineHeight = 40.sp)
val Body = TextStyle(fontSize = 17.sp, lineHeight = 31.sp)   // 系统中文字体
```

- 中文自动落到系统的 Noto Sans CJK，不用打包。
- 每个 (weight, width) 组合建一个 `FontFamily` 并缓存，不要在重组时反复创建。
- API 26 以下不支持可变轴：用 fontTools 切出静态字体（见 `cross-platform.md`）放进 `res/font/` 当后备。

## 切角

Compose 自带 `CutCornerShape`：

```kotlin
val CutSmall = CutCornerShape(bottomEnd = 7.dp)
val CutButton = CutCornerShape(bottomEnd = 8.dp)
val CutPanel = CutCornerShape(bottomEnd = 26.dp)
val CutFrame = CutCornerShape(topStart = 52.dp, bottomEnd = 52.dp)

@Composable
fun EfTag(text: String, current: Boolean = false) {
    val c = LocalEf.current
    Text(
        text, style = Field.copy(fontWeight = FontWeight.SemiBold),
        color = if (current) OnSignal else c.tagFg,
        modifier = Modifier.background(if (current) Signal else c.tagBg, CutSmall).padding(start = 7.dp, end = 10.dp, top = 2.dp, bottom = 2.dp),
    )
}
```

## 按钮：按下擦入、没有涟漪

```kotlin
val Mech = CubicBezierEasing(0.7f, 0f, 0.2f, 1f)
val Snap = CubicBezierEasing(0.16f, 1f, 0.3f, 1f)

@Composable
fun EfButton(label: String, onClick: () -> Unit, go: Boolean = false, danger: Boolean = false) {
    val c = LocalEf.current
    val source = remember { MutableInteractionSource() }
    val pressed by source.collectIsPressedAsState()
    val wipe by animateFloatAsState(if (pressed) 1f else 0f, tween(if (pressed) 100 else 280, easing = Mech), label = "wipe")
    val rest = if (go) Signal else c.chip
    val fill = when { go -> c.ink.copy(alpha = 0.12f); danger -> c.danger; else -> Signal }
    val fg = when { pressed && danger -> c.panel; pressed || go -> OnSignal; danger -> c.danger; else -> c.ink }
    Box(
        Modifier
            .heightIn(min = 48.dp)
            .clip(CutButton)
            .drawBehind {
                drawRect(rest)
                drawRect(fill, size = size.copy(width = size.width * wipe))
            }
            .clickable(interactionSource = source, indication = null, role = Role.Button, onClick = onClick)
            .padding(horizontal = 20.dp),
        contentAlignment = Alignment.Center,
    ) { Text(label, style = Label.copy(fontFamily = saira(700, 112f)), color = fg) }
}
```

Compose 的动画会遵守系统的"动画时长缩放"（开发者选项和无障碍里的"移除动画"），设为 0 时直接跳到终点。主要操作按下加一次轻触感：`LocalView.current.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)`（不要用 `HapticFeedbackType.LongPress`，那是长按的重触感）。

全局去掉涟漪：`CompositionLocalProvider(LocalRippleConfiguration provides null)`（Material3 1.3+），或像上面一样每处 `indication = null`。

## 斜线纹与三色条

```kotlin
// 1.5dp 的线，垂直间距 6.5dp（沿 x 步进 6.5 × √2 ≈ 9.2dp），见 tokens.json size.hatch
fun Modifier.hatch(color: Color, step: Dp = 9.2.dp) = drawBehind {
    clipRect {
        val s = step.toPx()
        var x = -size.height
        while (x < size.width) { drawLine(color, Offset(x, size.height), Offset(x + size.height, 0f), 1.5.dp.toPx()); x += s }
    }
}

@Composable
fun TriStrip() = Row(Modifier.fillMaxWidth().height(3.dp)) {
    listOf(TriA, TriB, TriC).forEach { Box(Modifier.weight(1f).fillMaxHeight().background(it)) }
}
```

等高线：用 Android Studio 的 Vector Asset 导入 `assets/contours/contour-a.svg`，`Icon(painterResource(R.drawable.contour_a), null, tint = c.ink.copy(alpha = 0.09f))` 放在右上角背景。

## 替换 Material 3 默认

| 默认 | 换成 |
| --- | --- |
| `TopAppBar` | 自己的顶栏：`Column`（眉标 + 中文粗体），`paper` 底，下面 1px `rule`；`TopAppBarDefaults` 的颜色设成透明也行，但标题要左对齐、不放大号图标 |
| `NavigationBar` | 自定义 `Row`：当前项 `background(Signal, CutSmall)`，英文眉标 + 中文；`animateColorAsState(tween(280, easing = Mech))` |
| `Card` | 细线分隔的行，或 `EfPanel`（`panel` 底、`border(1.dp, rule, CutPanel)`、顶边 5dp 墨色页签） |
| `Switch` | 自定义方形开关（开 = 黄轨道墨方块） |
| `CircularProgressIndicator` | 24 格的分段条 + 百分比读数 |
| `ModalBottomSheet` | `shape = CutCornerShape(topStart = 26.dp)`、`containerColor = panel`、`dragHandle` 换成斜线纹带加 40×4 墨条、`scrimColor = scrim` |
| `AlertDialog` | `shape = CutPanel`、`containerColor = panel`，标题前加眉标 `// CONFIRM` |
| `Snackbar` | `CommandBar` 底、左边 6dp 黄条、直角 |
| `FloatingActionButton` | 底部操作条里的主要按钮；一定要浮动就 `shape = CutButton`、`containerColor = Signal`、`elevation = 0` |

## View 系统（XML）

`MaterialShapeDrawable` 加 `ShapeAppearanceModel.builder().setBottomRightCorner(CornerFamily.CUT, 8dp)` 做切角；主题里 `shapeAppearanceSmallComponent` 等全部设 `cornerFamily=cut, cornerSize=0dp`；`android:stateListAnimator="@null"` 去掉阴影；`rippleColor` 透明，按下擦入用 `ObjectAnimator` 驱动一个前景 `ClipDrawable` 的 level（0→10000），插值器 `PathInterpolator(0.7f, 0f, 0.2f, 1f)`；可变字体用 `Typeface.Builder(assets, "saira.ttf").setFontVariationSettings("'wght' 600, 'wdth' 125")`。
