# Flutter（iOS、Android、Web、桌面）

`templates/flutter/` 是一套可以直接用的 Flutter 套件加六个示例屏幕，已经用 Flutter 3.47.7 通过 `flutter analyze`（无问题）、`flutter test` 和 `flutter build web`，截图在 `examples/app/`。不依赖任何第三方包。

## 文件

| 文件 | 内容 |
| --- | --- |
| `lib/ef/tokens.dart` | `EfColors`（浅深两套，`ThemeExtension`）、`Ef`（常量：黄、三色、间距、切角、曲线、时长、`Ef.d()` 减少动效）、`EfType`（字体样式）、`efTheme()` |
| `lib/ef/marks.dart` | `efCut()` 切角形状、`EfTriStrip` 三色条、`EfHatch` 斜线纹、`EfContours` 等高线背景 |
| `lib/ef/widgets.dart` | `EfEyebrow` `EfPair` `EfTag` `EfChip` `EfButton` `EfRecord` `EfPanel` `EfFigure` `EfState` `EfNotice` `EfFacts` `EfTopBar` `EfTabBar` `EfField` `EfSwitch` `EfSegmented` `EfProgress` `EfEmpty` `EfToast` `EfSheet` `EfActionRow` `EfBarTitle`，以及 `showEfSheet()` `showEfDialog()`（带进出动效的弹出） |
| `lib/main.dart` | 示例：总览、列表、详情、设置、底部面板、状态（含对话框） |
| `test/widget_test.dart` | 冒烟测试：四个标签都能打开、底部面板能开能关 |
| `fonts/Saira.ttf` + `Saira-OFL.txt` | Saira 可变字体和许可证 |

## 跑起来

```sh
cp -r templates/flutter my_app && cd my_app
flutter create .        # 生成 android/ ios/ web/ 等平台目录，不覆盖已有的 lib/ 和 test/
flutter test            # 冒烟测试：四个标签都能打开
flutter run                              # 或 flutter run -d chrome
```

Web 上可以用地址参数直接打开某一屏：`?screen=home|list|detail|settings|sheet|states&theme=light|dark`，状态屏加 `&dialog=1` 打开对话框。

放进已有项目：复制 `lib/ef/` 和 `fonts/`，在 `pubspec.yaml` 里声明字体，`MaterialApp` 用 `theme: efTheme(Brightness.light), darkTheme: efTheme(Brightness.dark)`。换强调色时两处都传同一个颜色：`efTheme(Brightness.light, accent: EfAccent.ice)`（`EfAccent` 里有 yellow、lime、ice、amber，也可以传自己的颜色，规则见 `../variation.md`）。部件都从 `EfColors.of(context).signal` 取强调色，深色主题的 trace 线也会跟着换。

## 关键写法

**宽体字**：Flutter 里可变字体的字重和宽度都要通过 `fontVariations` 设，只写 `fontWeight` 不会改变可变字体的字形。

```dart
TextStyle(
  fontFamily: 'Saira',
  fontFamilyFallback: ['Noto Sans SC', 'PingFang SC', 'Noto Sans CJK SC'],
  fontSize: 11,
  fontVariations: [FontVariation('wght', 600), FontVariation('wdth', 125)],
  letterSpacing: 11 * 0.14,
)
```

`EfType.ui(size, weight:, width:)` 已经封装好。中文落到系统字体（iOS 苹方、Android Noto Sans CJK）；Web 上 Flutter 会自动下载 Noto Sans SC。想各平台一致，就把 Noto Sans SC 也打进 `fonts/`。

**切角**：`BeveledRectangleBorder` 以 45° 切角，圆角半径就是切掉的边长。

```dart
ShapeDecoration(color: Ef.signal, shape: efCut(br: Ef.cutSmall))
ClipPath(clipper: ShapeBorderClipper(shape: efCut(br: Ef.cutButton)), child: …)
```

**按下擦入**：`EfButton` 用 `GestureDetector` 记录按下状态，`AnimatedFractionallySizedBox` 从左把填充色推满（按下 100ms，松开 280ms，曲线 `Ef.mech`），没有 `InkWell` 涟漪。主题里 `splashFactory: NoSplash.splashFactory` 把全局涟漪关掉。

**减少动效**：所有时长都过一遍 `Ef.d(context, duration)`，系统要求减少动态效果时返回 0。

**斜线纹、等高线**：`CustomPainter` 画；颜色从 `EfColors.of(context).ink` 取再乘透明度，所以自动跟随主题。也可以用 `flutter_svg` 加载 `assets/contours/*.svg`。

**颜色**：一律通过 `EfColors.of(context)` 取，不在部件里写死浅色值；黄色 `Ef.signal` 两套主题一样，上面的字用 `Ef.onSignal`。

## 替换 Material 默认

| Material 默认 | 换成 |
| --- | --- |
| `AppBar` | `EfTopBar`（不填色、左对齐、中英成对、细线） |
| `NavigationBar` / `BottomNavigationBar` | `EfTabBar` |
| `ElevatedButton` / `FilledButton` | `EfButton(kind: go)`；`TextButton` → `EfButton(small: true)` |
| `Card` | `EfPanel`，或者干脆用细线分隔的行 |
| `ListTile` | `EfRecord` / `EfActionRow` |
| `Switch` | `EfSwitch`（方形） |
| `SegmentedButton` / `ToggleButtons` | `EfSegmented` |
| `CircularProgressIndicator` | `EfProgress`（分段条） |
| `showModalBottomSheet` | `showEfSheet(context, (_) => EfSheet(...))`：mech 360ms 推入、240ms 退出，不弹跳 |
| `AlertDialog` | `showEfDialog(context, (_) => EfPanel(...))`：从上往下通电 280ms、关上 180ms |
| `SnackBar` | `EfToast`（`SnackBar(backgroundColor: Colors.transparent, elevation: 0, content: EfToast(...))`） |
| `FloatingActionButton` | 底部操作条里的 `EfButton(kind: go)`；一定要浮动就用切角方块 |

其余部件（`TextField` 等）用 `InputDecoration` 改成直角、细线、聚焦时 2px trace 下边，见 `EfField`。

## 已知限制

- 等高线是程序生成的近似曲线，不是 `assets/contours/` 那两张图；要完全一致就用 `flutter_svg`。
- 示例里 `?screen=sheet` 和 `&dialog=1` 是把面板、对话框静止地叠在屏幕上，只为截图；App 里点列表的"筛选"走的是真正的 `showEfSheet()`。
- 可点的部件都带了 `Semantics`（按钮、选中、开关、单选组、进度值），读屏能读出"当前"。自己写的部件也要加。
