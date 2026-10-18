# React Native、Electron / Tauri、其他平台

## 通用：固定宽度的静态字体

不支持可变字体轴的平台（React Native、旧 Android、部分小程序、游戏引擎 UI、Qt 等），用 fontTools 从 Saira 切出需要的几种宽度和字重：

```sh
pip install fonttools brotli
fonttools varLib.instancer Saira.ttf wdth=125 wght=600 -o Saira-Wide-SemiBold.ttf   # 眉标、标签
fonttools varLib.instancer Saira.ttf wdth=112 wght=400 -o Saira-Field.ttf          # 字段、编号、日期
fonttools varLib.instancer Saira.ttf wdth=100 wght=700 -o Saira-Bold.ttf           # 按钮、标题
fonttools varLib.instancer Saira.ttf wdth=125 wght=800 -o Saira-Wide-ExtraBold.ttf # 字标、大数字
```

需要更小的文件就再用 `pyftsubset … --unicodes=U+0020-007E` 只留拉丁字符。切出来的字体仍然受 SIL OFL 1.1 约束：随应用附上许可证文本（`templates/flutter/fonts/Saira-OFL.txt`），不要单独售卖字体文件。

## React Native（含 Expo）

```js
// theme.js
export const ef = {
  light: { paper: '#F4F4F2', panel: '#FFFFFF', ink: '#161616', ink2: '#5C5C5C', rule: '#D9D9D6', chip: '#E4E4E0', trace: '#161616', tagBg: '#161616', tagFg: '#FFFFFF', danger: '#B3261E' },
  dark:  { paper: '#191919', panel: '#222222', ink: '#EDEDED', ink2: '#A3A3A3', rule: '#353535', chip: '#2E2E2E', trace: '#FFFA00', tagBg: '#3A3A3A', tagFg: '#EDEDED', danger: '#FF8A7A' },
  signal: '#FFFA00', onSignal: '#161616',
  mech: Easing.bezier(0.7, 0, 0.2, 1), snap: Easing.bezier(0.16, 1, 0.3, 1),
};
export const useEf = () => (useColorScheme() === 'dark' ? ef.dark : ef.light);
```

- **字体**：用上面切出的静态字体（RN 不支持可变轴），`expo-font` 或 `react-native.config.js` 链接；`fontFamily: 'Saira-Wide-SemiBold'`。中文自动落到系统字体。数字加 `fontVariant: ['tabular-nums']`。
- **切角**：RN 没有 `clip-path`。用 `react-native-svg` 画背景：

  ```jsx
  const Cut = ({ w, h, br = 8, fill }) => (
    <Svg width={w} height={h} style={StyleSheet.absoluteFill}>
      <Polygon points={`0,0 ${w},0 ${w},${h - br} ${w - br},${h} 0,${h}`} fill={fill} />
    </Svg>
  );
  ```

  尺寸用 `onLayout` 拿到。背景是纯色时，也可以在角上叠一个纸色的小三角（`borderTopWidth` 技巧），但换背景就会穿帮。
- **按下擦入**：`Pressable` 的 `onPressIn` / `onPressOut` 驱动一个 `Animated.Value`（或 Reanimated 的 `withTiming(1, { duration: 100, easing: ef.mech })`），作用在绝对定位的填充层 `transform: [{ scaleX }]` 上，`transformOrigin: 'left'`（RN 0.73+；更早版本用 `translateX` 从 `-width` 移到 0）。Android 上关掉 `android_ripple`。
- **减少动效**：`AccessibilityInfo.isReduceMotionEnabled()`，或 Reanimated 的 `useReducedMotion()`，为真时时长设 0。
- **斜线纹 / 等高线**：`react-native-svg` 的 `Pattern` 画 45° 线；等高线直接用 `assets/contours/*.svg`（`react-native-svg-transformer`），`fill="none" stroke={ink} strokeOpacity={0.09}`。
- **导航**：React Navigation 的 `tabBar` 属性传自定义组件（当前项黄底切角，英文眉标 + 中文）；`headerShadowVisible: false`、`headerStyle: { backgroundColor: paper }`、`headerTitleAlign: 'left'`，标题用自定义组件渲染中英成对。

## Electron / Tauri / 网页套壳的桌面应用

- 直接用网页套件（`platforms/web.md`）。
- **窗口标题栏**：用自定义标题栏做成深色命令栏（`#161616`，两套主题都深色）：Electron `titleBarStyle: 'hidden'` + `titleBarOverlay: { color: '#161616', symbolColor: '#EDEDED', height: 40 }`；Tauri `decorations: false` 并给拖拽区加 `data-tauri-drag-region`。命令栏左边徽记和应用名，中间分区，当前分区一小块黄。
- **布局**：桌面窗口宽，用控制台类型的看板布局或阅读类型的侧栏布局；最小窗口宽度设到 960 左右，避免挤成手机版。
- **原生菜单、托盘、对话框**用系统样式，不要强改。

## 其他（Qt、WinUI、SwiftUI on macOS、游戏引擎 UI 等）

照 `assets/tokens.json` 的数值建主题，按下面的顺序检查：

1. 圆角全部 0、阴影全部去掉、强调色只有一种（默认 `#FFFA00`，或这个产品在变体卡里定的那种）。
2. 拉丁字用宽体（Saira 静态实例），中文用系统黑体。
3. 可点击的块切掉右下角；当前项整格黄块。
4. 按下（或悬停）时黄色从左擦入，曲线 `cubic-bezier(0.7, 0, 0.2, 1)`，100–280ms。
5. 细线分区、`//` 眉标、中英成对标题、真实字段。
6. 跟随系统的深浅和减少动效设置。
