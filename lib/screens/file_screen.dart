import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/guide.dart';
import '../data/highlight.dart';
import '../theme.dart';
import '../widgets/common.dart';

class FileScreen extends StatefulWidget {
  final SourceFile file;
  final int? initialLine;
  const FileScreen({super.key, required this.file, this.initialLine});

  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> with SingleTickerProviderStateMixin {
  static const double rowH = 22;
  static const double charW = 7.7;

  late final TabController _tabs = TabController(length: 2, vsync: this, initialIndex: widget.initialLine != null ? 1 : 0);
  final _codeScroll = ScrollController();
  late final Future<List<String>> _code = Guide.I.code(widget.file.id);
  int? _hit;

  SourceFile get f => widget.file;

  @override
  void initState() {
    super.initState();
    if (widget.initialLine != null) {
      _hit = widget.initialLine;
      _code.then((_) => Future.delayed(const Duration(milliseconds: 250), () {
            if (mounted) _jump(widget.initialLine!);
          }));
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    _codeScroll.dispose();
    super.dispose();
  }

  void goToLine(int line) {
    setState(() => _hit = line);
    _tabs.animateTo(1);
    Future.delayed(const Duration(milliseconds: 320), () => _jump(line));
  }

  void _jump(int line) {
    if (!_codeScroll.hasClients) return;
    final pos = _codeScroll.position;
    final target = ((line - 1) * rowH - pos.viewportDimension / 3).clamp(0.0, pos.maxScrollExtent);
    _codeScroll.animateTo(target, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
  }

  Future<void> _copy() async {
    final lines = await _code;
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اتنسخ الكود كله')));
  }

  void _neighbor(int d) {
    final all = Guide.I.files;
    final i = all.indexWhere((x) => x.id == f.id) + d;
    if (i < 0 || i >= all.length) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => FileScreen(file: all[i])));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final all = Guide.I.files;
    final idx = all.indexWhere((x) => x.id == f.id);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(f.name, textDirection: TextDirection.ltr, style: TextStyle(fontFamily: mono, fontWeight: FontWeight.w800, fontSize: 16, color: p.accent)),
          Text(f.path, textDirection: TextDirection.ltr, style: TextStyle(fontFamily: mono, fontSize: 11, color: p.gold)),
        ]),
        actions: [IconButton(onPressed: _copy, icon: const Icon(Icons.copy_rounded), tooltip: 'نسخ الكود')],
        bottom: TabBar(
          controller: _tabs,
          labelColor: p.accent,
          unselectedLabelColor: p.muted,
          indicatorColor: p.gold,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800),
          tabs: [const Tab(text: 'الشرح'), Tab(text: 'الكود (${f.lines} سطر)')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_explain(p), _codeView(p)],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
          child: Row(children: [
            Expanded(child: _NavBtn(label: idx > 0 ? all[idx - 1].name : '', icon: Icons.arrow_forward_rounded, onTap: idx > 0 ? () => _neighbor(-1) : null)),
            const SizedBox(width: 10),
            Expanded(child: _NavBtn(label: idx < all.length - 1 ? all[idx + 1].name : '', icon: Icons.arrow_back_rounded, end: true, onTap: idx < all.length - 1 ? () => _neighbor(1) : null)),
          ]),
        ),
      ),
    );
  }

  Widget _explain(Palette p) {
    final isMain = f.id == 'lib_main_dart';
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        FadeIn(
          child: Panel(
            color: p.goldSoft,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 6, runSpacing: 6, children: [Tag(f.group), Tag('${f.lines} سطر'), if (isMain) const Tag('مشروح سطر بسطر', strong: true)]),
              const SizedBox(height: 10),
              Text(f.summary, style: TextStyle(fontSize: 15.5, height: 1.75, color: p.ink, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < f.items.length; i++)
          FadeIn(
            delay: math.min(i * 40, 300),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text(f.items[i].title, textDirection: TextDirection.ltr, textAlign: TextAlign.right,
                          style: TextStyle(fontFamily: mono, fontWeight: FontWeight.w700, color: p.accent, fontSize: 13.5)),
                    ),
                    if (f.items[i].line != null) ...[const SizedBox(width: 8), LineChip(f.items[i].line!, onTap: () => goToLine(f.items[i].line!))],
                  ]),
                  const SizedBox(height: 6),
                  Text(f.items[i].text, style: TextStyle(height: 1.75, color: p.ink, fontSize: 14.5)),
                ]),
              ),
            ),
          ),
        if (isMain) ...[
          const SizedBox(height: 12),
          const SectionTitle('سطر بسطر', 'شرح main.dart كامل'),
          const SizedBox(height: 10),
          FutureBuilder<List<String>>(
            future: _code,
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox(height: 40);
              final lines = snap.data!;
              return Column(children: [
                for (var i = 0; i < lines.length; i++)
                  if (Guide.I.mainNotes[i + 1] != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: p.panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.line)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: p.panel2, borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text.rich(
                                TextSpan(children: [
                                  TextSpan(text: '${i + 1}  ', style: TextStyle(color: p.muted)),
                                  ...highlightDart(lines[i].trim(), p),
                                ]),
                                style: TextStyle(fontFamily: mono, fontSize: 12.5, color: p.ink),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                          child: Text(Guide.I.mainNotes[i + 1]!, style: TextStyle(height: 1.6, color: p.ink)),
                        ),
                      ]),
                    ),
              ]);
            },
          ),
        ],
      ],
    );
  }

  Widget _codeView(Palette p) {
    return FutureBuilder<List<String>>(
      future: _code,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('تعذّر تحميل الكود', style: TextStyle(color: p.muted)));
        if (!snap.hasData) return Center(child: CircularProgressIndicator(color: p.gold));
        final lines = snap.data!;
        final longest = lines.fold<int>(0, (m, l) => math.max(m, l.length));
        final numW = lines.length.toString().length * charW + 22;
        return LayoutBuilder(builder: (context, c) {
          final width = math.max(c.maxWidth, numW + longest * charW + 40);
          return Container(
            color: p.panel2,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: width,
                    child: ListView.builder(
                      controller: _codeScroll,
                      itemExtent: rowH,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: lines.length,
                      itemBuilder: (context, i) {
                        final hit = _hit == i + 1;
                        return Container(
                          color: hit ? p.highlight : null,
                          child: Row(children: [
                            Container(
                              width: numW,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(border: Border(right: BorderSide(color: p.line))),
                              child: Text('${i + 1}', style: TextStyle(fontFamily: mono, fontSize: 12, color: hit ? p.gold : p.muted)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text.rich(
                                TextSpan(children: highlightDart(lines[i], p)),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: TextStyle(fontFamily: mono, fontSize: 12.5, height: 1.4, color: p.ink),
                              ),
                            ),
                          ]),
                        );
                      },
                    ),
                  ),
              ),
            ),
          );
        });
      },
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool end;
  final VoidCallback? onTap;
  const _NavBtn({required this.label, required this.icon, this.end = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    if (onTap == null) return const SizedBox.shrink();
    final text = Flexible(
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
          style: TextStyle(fontFamily: mono, fontSize: 12.5, color: p.accent, fontWeight: FontWeight.w700)),
    );
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: p.panel, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.line)),
        child: Row(
          mainAxisAlignment: end ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: end
              ? [text, const SizedBox(width: 6), Icon(icon, size: 18, color: p.gold)]
              : [Icon(icon, size: 18, color: p.gold), const SizedBox(width: 6), text],
        ),
      ),
    );
  }
}
