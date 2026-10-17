// Sample app: the Endfield kit on phone screens. Pick a screen and theme on web
// with ?screen=home|list|detail|settings|sheet|states&theme=light|dark (&dialog=1 on states)
// and another accent with &accent=yellow|lime|ice|amber.
import 'package:flutter/material.dart';

import 'ef/marks.dart';
import 'ef/tokens.dart';
import 'ef/widgets.dart';

void main() => runApp(const EfApp());

const _screens = ['home', 'list', 'detail', 'settings', 'sheet', 'states'];

class EfApp extends StatefulWidget {
  const EfApp({super.key});

  @override
  State<EfApp> createState() => _EfAppState();
}

class _EfAppState extends State<EfApp> {
  late ThemeMode _mode = switch (Uri.base.queryParameters['theme']) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };
  final Color _accent = switch (Uri.base.queryParameters['accent']) {
    'lime' => EfAccent.lime,
    'ice' => EfAccent.ice,
    'amber' => EfAccent.amber,
    _ => EfAccent.yellow,
  };

  @override
  Widget build(BuildContext context) {
    final start = _screens.indexOf(Uri.base.queryParameters['screen'] ?? 'home');
    return MaterialApp(
      title: 'Endfield UI',
      debugShowCheckedModeBanner: false,
      theme: efTheme(Brightness.light, accent: _accent),
      darkTheme: efTheme(Brightness.dark, accent: _accent),
      themeMode: _mode,
      home: Shell(
        start: start < 0 ? 0 : start,
        onToggleTheme: () => setState(() {
          _mode = Theme.of(context).brightness == Brightness.dark || _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        }),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key, required this.start, required this.onToggleTheme});
  final int start;
  final VoidCallback onToggleTheme;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  late String _screen = _screens[widget.start];

  void _go(String s) => setState(() => _screen = s);

  int get _tab => switch (_screen) {
        'home' => 0,
        'list' || 'detail' || 'sheet' => 1,
        'states' => 2,
        _ => 3,
      };

  @override
  Widget build(BuildContext context) {
    final body = switch (_screen) {
      'list' => ListScreen(
          onOpen: () => _go('detail'),
          onMore: () => showEfSheet<void>(context, (context) => ActionsSheet(onClose: () => Navigator.pop(context))),
        ),
      'detail' => DetailScreen(onBack: () => _go('list')),
      'settings' => SettingsScreen(onToggleTheme: widget.onToggleTheme),
      'sheet' => SheetScreen(onClose: () => _go('list')),
      'states' => const StatesScreen(),
      _ => HomeScreen(onOpen: () => _go('detail'), onAll: () => _go('list')),
    };
    return Scaffold(
      body: EfContours(child: body),
      bottomNavigationBar: _screen == 'detail'
          ? null
          : EfTabBar(
              items: const [EfTabItem('Home', '总览'), EfTabItem('Records', '记录'), EfTabItem('Status', '状态'), EfTabItem('Config', '设置')],
              current: _tab,
              onTap: (i) => _go(['home', 'list', 'states', 'settings'][i]),
            ),
    );
  }
}

// ---------------------------------------------------------------- sample data

const _records = [
  ('No.024', '10.17', '示例：仓储节点的布线记录', '6,380 字'),
  ('No.023', '10.10', '第二阶段的设备清单与替换计划', '9,102 字'),
  ('No.022', '10.08', '关于夜班巡检路线的调整', '4,577 字'),
  ('No.021', '09.29', '一份写给新成员的工具说明', '3,214 字'),
  ('No.020', '09.21', '旧仓库拆除前的最后一次盘点', '7,860 字'),
];

// ---------------------------------------------------------------- home

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpen, required this.onAll});
  final VoidCallback onOpen;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    final c = EfColors.of(context);
    final top = MediaQuery.of(context).padding.top;
    return ListView(padding: EdgeInsets.zero, children: [
      // Dark command bar: always dark, carries the status readout.
      Container(
        color: Ef.commandBar,
        padding: EdgeInsets.fromLTRB(Ef.pad, top + 10, Ef.pad, 10),
        child: Row(children: [
          Container(width: 8, height: 8, color: EfColors.of(context).signal),
          const SizedBox(width: 8),
          Text('ACME.WORKS', style: EfType.ui(13, weight: 700, width: 125, color: const Color(0xFFEDEDED))),
          const Spacer(),
          Text('SYS 07 | 第 214 天', style: EfType.field(const Color(0xFFA3A3A3))),
        ]),
      ),
      const EfTriStrip(),
      Padding(
        padding: const EdgeInsets.fromLTRB(Ef.pad, 28, Ef.pad, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const EfEyebrow('Field archive / 2026', slash: true),
          const SizedBox(height: 10),
          Text('ARCHIVE', style: EfType.display(c.ink, 64)),
          const SizedBox(height: 10),
          Text('仓储网络的工作记录', style: EfType.ui(22, weight: 700, color: c.ink)),
          const SizedBox(height: 6),
          const EfFacts(['48,210 字', '24 篇', '更新于 10.17']),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(Ef.pad, 20, Ef.pad, 0),
        child: EfPanel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 6),
            const EfPair('Records', '记录状态', size: 18),
            const SizedBox(height: 14),
            Row(children: const [
              Expanded(child: EfFigure('16', '已发布')),
              Expanded(child: EfFigure('2', '待审', alert: true)),
              Expanded(child: EfFigure('7', '草稿')),
            ]),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(Ef.pad, 28, Ef.pad, 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Expanded(child: EfPair('Latest', '最近记录', size: 18)),
          EfButton('全部', small: true, onPressed: onAll),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Ef.pad),
        child: Column(children: [
          for (final (i, r) in _records.take(3).indexed)
            EfRecord(no: r.$1, date: r.$2, name: r.$3, meta: r.$4, current: i == 0, onTap: onOpen),
        ]),
      ),
      const SizedBox(height: 24),
    ]);
  }
}

// ---------------------------------------------------------------- list

class ListScreen extends StatefulWidget {
  const ListScreen({super.key, required this.onOpen, required this.onMore});
  final VoidCallback onOpen;
  final VoidCallback onMore;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final c = EfColors.of(context);
    return SafeArea(
      bottom: false,
      child: Column(children: [
        EfTopBar(en: 'Records', title: '记录', actions: [EfButton('筛选', small: true, onPressed: widget.onMore)]),
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(Ef.pad, 14, Ef.pad, 24), children: [
            TextField(
              style: EfType.ui(16, color: c.ink),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: c.panel,
                hintText: '搜索标题、编号',
                hintStyle: EfType.ui(15, color: c.ink2),
                prefixIcon: Padding(padding: const EdgeInsets.only(left: 12, right: 8), child: Text('//', style: EfType.ui(15, weight: 700, color: c.ink2))),
                prefixIconConstraints: const BoxConstraints(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: c.rule)),
                focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: c.trace, width: 2)),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (i, f) in [('全部', 24), ('记录', 16), ('实验', 2), ('草稿', 7)].indexed)
                EfChip(f.$1, count: f.$2, active: i == _filter, onTap: () => setState(() => _filter = i)),
            ]),
            const SizedBox(height: 18),
            const EfEyebrow('2026 / October', slash: true),
            const SizedBox(height: 4),
            for (final r in _records) EfRecord(no: r.$1, date: r.$2, name: r.$3, meta: r.$4, onTap: widget.onOpen),
          ]),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- detail (reading)

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = EfColors.of(context);
    final p = EfType.body(c.ink);
    return SafeArea(
      child: Column(children: [
        EfTopBar(en: 'Records / No.024', title: '记录', leading: EfButton('‹', small: true, onPressed: onBack)),
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(Ef.pad, 22, Ef.pad, 32), children: [
            const Row(children: [EfTag('No.024', current: true), SizedBox(width: 8), EfState('已发布')]),
            const SizedBox(height: 12),
            Text('示例：仓储节点的布线记录', style: EfType.h1(c.ink)),
            const SizedBox(height: 10),
            const EfTriStrip(),
            const SizedBox(height: 10),
            const EfFacts(['2026.10.17', '6,380 字', '约 16 分钟']),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(style: p, children: [
                TextSpan(text: '一句话说明这是什么', style: TextStyle(backgroundColor: EfColors.of(context).signal.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.55))),
                const TextSpan(text: '：这里记录了二号节点重新布线的全过程，包括走线顺序、标签规则和最后的检查表。'),
              ]),
            ),
            const SizedBox(height: 14),
            Text('正文使用中文黑体常规字重，行高放宽到 1.85，一行不超过四十个字。界面上的标签、按钮和编号才使用宽体英文。', style: p),
            const SizedBox(height: 26),
            const EfBarTitle('走线顺序'),
            const SizedBox(height: 12),
            Text('先主干，后分支。每一段线缆两端都贴上同一个编号，编号写在记录表里，表格和实物一一对应。', style: p),
            const SizedBox(height: 16),
            const EfNotice('拆除旧线前先拍照存档，再断电。'),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: EfButton('标记为已读', kind: EfButtonKind.go, expand: true, onPressed: () {})),
              const SizedBox(width: 10),
              EfButton('分享', onPressed: () {}),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- settings (form)

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onToggleTheme});
  final VoidCallback onToggleTheme;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _public = true;
  bool _notify = false;
  int _density = 1;

  @override
  Widget build(BuildContext context) {
    final c = EfColors.of(context);
    Widget toggle(String label, String help, bool v, ValueChanged<bool> on) => Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.rule))),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: EfType.ui(16, weight: 600, color: c.ink)),
                Text(help, style: EfType.ui(12, color: c.ink2)),
              ]),
            ),
            EfSwitch(value: v, onChanged: on),
          ]),
        );
    return SafeArea(
      bottom: false,
      child: Column(children: [
        const EfTopBar(en: 'Config', title: '设置'),
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(Ef.pad, 18, Ef.pad, 24), children: [
            const EfField(label: '名字', initial: '示例读者#0001', help: '说明写在输入框下面，不写在占位符里。'),
            const SizedBox(height: 16),
            const EfField(label: '节点', hint: 'sample-node-07'),
            const SizedBox(height: 22),
            const EfEyebrow('Display', slash: true),
            const SizedBox(height: 8),
            EfSegmented(options: const ['紧凑', '标准', '宽松'], current: _density, onChanged: (i) => setState(() => _density = i)),
            const SizedBox(height: 14),
            toggle('公开记录', '关闭后只有自己能看到。', _public, (v) => setState(() => _public = v)),
            toggle('更新提醒', '有新记录时通知我。', _notify, (v) => setState(() => _notify = v)),
            const SizedBox(height: 20),
            EfButton('保存', kind: EfButtonKind.go, expand: true, onPressed: () {}),
            const SizedBox(height: 10),
            EfButton('切换深浅', expand: true, onPressed: widget.onToggleTheme),
            const SizedBox(height: 28),
            const EfEyebrow('Danger', slash: true),
            const SizedBox(height: 8),
            EfButton('删除这个节点', kind: EfButtonKind.danger, small: true, onPressed: () {}),
          ]),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- bottom sheet

/// The actions of one record. In the app it opens with showEfSheet (the
/// "筛选" button on the list); ?screen=sheet shows it standing still for screenshots.
class ActionsSheet extends StatelessWidget {
  const ActionsSheet({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => EfSheet(en: 'No.023 / Actions', title: '第二阶段的设备清单', children: [
        const EfActionRow('打开', meta: '9,102 字'),
        const EfActionRow('复制编号', meta: 'No.023'),
        const EfActionRow('移到草稿'),
        const EfActionRow('删除', danger: true),
        Padding(
          padding: const EdgeInsets.fromLTRB(Ef.pad, 12, Ef.pad, 0),
          child: EfButton('取消', expand: true, onPressed: onClose),
        ),
      ]);
}

class SheetScreen extends StatelessWidget {
  const SheetScreen({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = EfColors.of(context);
    return Stack(children: [
      ListScreen(onOpen: () {}, onMore: () {}),
      Positioned.fill(child: GestureDetector(onTap: onClose, child: ColoredBox(color: c.scrim))),
      Align(alignment: Alignment.bottomCenter, child: ActionsSheet(onClose: onClose)),
    ]);
  }
}

// ---------------------------------------------------------------- states

class StatesScreen extends StatefulWidget {
  const StatesScreen({super.key});

  @override
  State<StatesScreen> createState() => _StatesScreenState();
}

class _StatesScreenState extends State<StatesScreen> {
  bool _dialog = Uri.base.queryParameters['dialog'] == '1';

  @override
  Widget build(BuildContext context) {
    final c = EfColors.of(context);
    return Stack(children: [
      SafeArea(
        bottom: false,
        child: Column(children: [
          const EfTopBar(en: 'Status', title: '状态'),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(Ef.pad, 18, Ef.pad, 24), children: [
              const EfPanel(child: Padding(padding: EdgeInsets.only(top: 6), child: EfProgress(value: 0.625, label: 'Syncing / 同步中'))),
              const SizedBox(height: 18),
              const Wrap(spacing: 8, runSpacing: 8, children: [
                EfState('已发布'),
                EfState('草稿', kind: EfStateKind.draft),
                EfState('待审', kind: EfStateKind.alert),
              ]),
              const SizedBox(height: 18),
              const EfNotice('有 2 条记录等待审核。'),
              const SizedBox(height: 18),
              EfEmpty(text: '这里还没有记录', action: EfButton('新建', kind: EfButtonKind.go, small: true, onPressed: () {})),
              const SizedBox(height: 18),
              EfButton('打开对话框', onPressed: () => setState(() => _dialog = true)),
              const SizedBox(height: 18),
              const EfToast('已保存。'),
            ]),
          ),
        ]),
      ),
      if (_dialog) ...[
        Positioned.fill(child: GestureDetector(onTap: () => setState(() => _dialog = false), child: ColoredBox(color: c.scrim))),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: EfPanel(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                const EfPair('Confirm', '删除这条记录？', size: 20),
                const SizedBox(height: 10),
                Text('No.023 会被永久删除，不能恢复。', style: EfType.ui(15, color: c.ink)),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  EfButton('取消', small: true, onPressed: () => setState(() => _dialog = false)),
                  const SizedBox(width: 8),
                  EfButton('删除', small: true, kind: EfButtonKind.danger, onPressed: () => setState(() => _dialog = false)),
                ]),
              ]),
            ),
          ),
        ),
      ],
    ]);
  }
}
