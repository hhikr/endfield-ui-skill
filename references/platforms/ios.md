# iOS 原生（SwiftUI / UIKit）

> 下面的代码片段按 iOS 16+ SwiftUI 写成，**没有在本 skill 里编译验证过**；概念和数值与已验证的 Flutter 套件（`templates/flutter/`）一一对应，遇到 API 出入以 Flutter 版的行为为准。

## 颜色

在 Asset Catalog 里建颜色集，每个设 Any / Dark 两个外观，数值取 `assets/tokens.json`：`Paper` `Panel` `Ink` `Ink2` `Rule` `Chip` `Trace` `TagBg` `TagFg` `Danger`；`Signal` `#FFFA00`（或这个产品选定的强调色，见 `../variation.md`）和 `OnSignal` `#161616` 两套一样。或者用代码：

```swift
extension Color {
    static func ef(_ light: UInt32, _ dark: UInt32) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) })
    }
    static let paper = ef(0xF4F4F2, 0x191919)
    static let panel = ef(0xFFFFFF, 0x222222)
    static let ink   = ef(0x161616, 0xEDEDED)
    static let ink2  = ef(0x5C5C5C, 0xA3A3A3)
    static let rule  = ef(0xD9D9D6, 0x353535)
    static let chip  = ef(0xE4E4E0, 0x2E2E2E)
    static let trace = ef(0x161616, 0xFFFA00)   // 当前位置的线：浅色是墨，深色是黄
    static let danger = ef(0xB3261E, 0xFF8A7A)
    static let signal = Color(red: 1, green: 250/255, blue: 0)
    static let onSignal = Color(red: 22/255, green: 22/255, blue: 22/255)
}
extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
    }
}
```

## 字体

把 `templates/flutter/fonts/Saira.ttf` 加进工程，Info.plist 的 `UIAppFonts` 里登记。可变字体的宽度和字重用 Core Text 的变体属性设（轴标签 `wght` = 0x77676874，`wdth` = 0x77647468）：

```swift
import CoreText

func saira(_ size: CGFloat, weight: CGFloat = 400, width: CGFloat = 100) -> Font {
    let axes: [NSNumber: CGFloat] = [0x77676874: weight, 0x77647468: width]
    let desc = UIFontDescriptor(fontAttributes: [
        .family: "Saira",
        UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): axes,
    ])
    return Font(UIFont(descriptor: desc, size: size) as CTFont)
}

// 用法
Text("// RECORDS").font(saira(11, weight: 600, width: 125)).tracking(11 * 0.14)
Text("记录").font(saira(20, weight: 700))       // 中文自动落到苹方
Text("6,380 字").font(saira(13, width: 112)).monospacedDigit()
```

- 中文由系统自动回落到苹方，不需要另外打包。正文用 `.font(.system(size: 17))` 加 `.lineSpacing(17 * 0.85)` 即可。
- 不想打包字体的应急方案：iOS 16 起系统字体有宽度，`Font.system(size: 11, weight: .semibold).width(.expanded)`。味道差一些，但比普通宽度好得多。
- 支持动态字体：用 `@ScaledMetric var size: CGFloat = 17` 包住字号。

## 切角

```swift
struct Cut: Shape {
    var tl: CGFloat = 0, tr: CGFloat = 0, br: CGFloat = 0, bl: CGFloat = 0
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX + tl, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - tr, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY + tr))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY - br))
        p.addLine(to: CGPoint(x: r.maxX - br, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX + bl, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY - bl))
        p.addLine(to: CGPoint(x: r.minX, y: r.minY + tl))
        p.closeSubpath()
        return p
    }
}

// 编号标签
Text("No.024").font(saira(12, weight: 600, width: 112))
    .padding(.init(top: 2, leading: 7, bottom: 2, trailing: 10))
    .background(Color.ink, in: Cut(br: 7)).foregroundStyle(Color.paper)
```

## 按钮：按下擦入

```swift
extension Animation {
    static let efMech = Animation.timingCurve(0.7, 0, 0.2, 1, duration: 0.28)
    static let efSnap = Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.2)
}

struct EfButtonStyle: ButtonStyle {
    var go = false
    var danger = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration c: Configuration) -> some View {
        let pressed = c.isPressed
        let fg: Color = pressed ? (danger ? .panel : .onSignal) : (go ? .onSignal : (danger ? .danger : .ink))
        return c.label
            .font(saira(15, weight: 700, width: 112))
            .foregroundStyle(fg)
            .padding(.horizontal, 20).frame(minHeight: 48)
            .background {
                ZStack(alignment: .leading) {
                    (go ? Color.signal : Color.chip)
                    (go ? Color.ink.opacity(0.12) : (danger ? Color.danger : Color.signal))
                        .scaleEffect(x: pressed ? 1 : 0, anchor: .leading)
                }
            }
            .clipShape(Cut(br: 8))
            .animation(reduceMotion ? nil : .efMech, value: pressed)
    }
}

Button("保存") { … }.buttonStyle(EfButtonStyle(go: true))
```

主要操作按下时加一次轻触感：`.sensoryFeedback(.impact(weight: .light), trigger: …)`（iOS 17）或 `UIImpactFeedbackGenerator(style: .light)`。

## 斜线纹与三色条

```swift
struct Hatch: View {
    var body: some View {
        Canvas { ctx, size in
            var p = Path()
            var x = -size.height
            // 1.5 宽的线，垂直间距 6.5（沿 x 步进 6.5 × √2 ≈ 9.2），见 tokens.json size.hatch
            while x < size.width { p.move(to: .init(x: x, y: size.height)); p.addLine(to: .init(x: x + size.height, y: 0)); x += 9.2 }
            ctx.stroke(p, with: .color(.ink.opacity(0.22)), lineWidth: 1.5)
        }
    }
}

struct TriStrip: View {
    var body: some View {
        HStack(spacing: 0) {
            Color(red: 1, green: 0, blue: 240/255)
            Color.signal
            Color(red: 0, green: 1, blue: 162/255)
        }.frame(height: 3)
    }
}
```

等高线：把 `assets/contours/contour-a.svg` 加进 Asset Catalog（勾选 Preserve Vector Data、Render As Template），`Image("contour-a").foregroundStyle(Color.ink.opacity(0.09))` 放在右上角背景里。

## 导航与系统部件

- **标签栏**：系统 `TabView` 的选中样式改不成整格黄块。用自定义底栏：`TabView(selection:)` 加 `.toolbar(.hidden, for: .tabBar)`，底部 `safeAreaInset(edge: .bottom)` 放一排按钮，当前项 `.background(Color.signal, in: Cut(br: 7))`，切换动画 `.efMech`。
- **导航栏**：`NavigationStack` 保留系统返回手势；标题用 `.toolbar { ToolbarItem(placement: .principal) {…} }` 换成左对齐的中英成对标题（或隐藏系统栏，自己画顶栏），`.toolbarBackground(Color.paper)`，下面一条 1px `rule` 线，没有模糊材质。
- **列表**：不用 `List` 的 insetGrouped 圆角分组；`ScrollView` + `LazyVStack(spacing: 0)`，每行下面 1px 细线。若用 `List`，设 `.listStyle(.plain)`、`.listRowBackground(Color.paper)`、`.listRowSeparatorTint(.rule)`。
- **面板 / 对话框**：`.sheet` 加 `.presentationCornerRadius(0)`、`.presentationBackground(Color.panel)`；内容顶部画斜线纹带和把手。确认删除用 `.confirmationDialog` 也可以（系统样式），但更推荐自定义看板式对话框。
- **开关**：自定义 `ToggleStyle` 画方形轨道，开 = 黄底墨块。
- **减少动效**：`@Environment(\.accessibilityReduceMotion)` 为真时，所有 `.animation` 传 `nil`。

## UIKit

同样的数值：`UIView.layer.mask` 用 `CAShapeLayer` 画切角路径；按钮擦入用一个子 `CALayer`，按下时把 `transform` 的 x 缩放从 0 动画到 1（`CAMediaTimingFunction(controlPoints: 0.7, 0, 0.2, 1)`）；`UIFont(descriptor:size:)` 同上；`UINavigationBarAppearance` 设 `configureWithOpaqueBackground()`、`backgroundColor = paper`、`shadowColor = rule`。
