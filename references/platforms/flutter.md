# Flutter（iOS、Android、Web、桌面）

`templates/flutter/` 是一套可以直接用的 Flutter 套件加六个示例屏幕，已经用 Flutter 3.47 通过 `flutter analyze`（无问题）、`flutter test` 和 `flutter build web`，截图在 `examples/app/`。不依赖任何第三方包。

## 文件

| 文件 | 内容 |
| --- | --- |
| `lib/ef/tokens.dart` | `EfColors`（浅深两套，`ThemeExtension`）、`Ef`（常量：黄、三色、间距、切角、曲线、时长、`Ef.d()` 减少动效）、`EfType`（字体样式）、`efTheme()` |
| `lib/ef/marks.dart` | `efCut()` 切角形状、`EfTriStrip` 三色条、`EfHatch` 斜线纹、`EfContours` 等高线背景 |
| `lib/ef/widgets.dart` | `EfEyebrow` `EfPair` `EfTag` `EfChip` `EfButton` `EfRecord` `EfPanel` `EfFigure` `EfState` `EfNotice` `EfFacts` `EfTopBar` `EfTabBar` `EfField` `EfSwitch` `EfSegmented` `EfProgress` `EfEmpty` `EfToast` `EfSheet` `EfActionRow` `EfBarTitle` |
| `lib/main.dart` | 示例：总览、列表、详情、设置、底部面板、状态（含对话框） |
| `test/widget_test.dart` | 冒烟测试 |
| `fonts/Saira.ttf` + `Saira-OFL.txt` | Saira 可变字体和许可证 |

## 跑起来

```sh
cp -r templates/flutter my_app && cd my_app
flutter create .        # 生成 android/ ios/ web/ 等平台目录，不覆盖已有的 lib/ 和 test/
flutter test            # 冒烟测试：四个标签都能打开
flutter run                              # 或 flutter run -d chrome
```

Web 上可以用地址参数直接打开某一屏：`?screen=home|list|detail|settings|sheet|states&theme=light|dark`，状态屏加 `&dialog=1` 打开对话框。

放进已有项目：复制 `lib/ef/` 和 `fonts/`，在 `pubspec.yaml` 里声明字体，`MaterialApp` 用 `theme: efTheme(Brightness.light), darkTheme: efTheme(Brightness.dark)`。

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
| `showModalBottomSheet` | 内容用 `EfSheet`，`backgroundColor: Colors.transparent`、`shape` 不设圆角 |
| `AlertDialog` | `Dialog` 里放 `EfPanel`，`shape: efCut(br: Ef.cutPanel)` |
| `SnackBar` | `EfToast`（`SnackBar(backgroundColor: Colors.transparent, elevation: 0, content: EfToast(...))`） |
| `FloatingActionButton` | 底部操作条里的 `EfButton(kind: go)`；一定要浮动就用切角方块 |

其余部件（`TextField` 等）用 `InputDecoration` 改成直角、细线、聚焦时 2px trace 下边，见 `EfField`。

## 已知限制

- 等高线是程序生成的近似曲线，不是 `assets/contours/` 那两张图；要完全一致就用 `flutter_svg`。
- `EfSheet` 和对话框在示例里是直接叠在屏幕上的；正式项目里用 `showModalBottomSheet` / `showDialog` 包起来，并把转场改成 `Ef.mech` 曲线、360ms。
