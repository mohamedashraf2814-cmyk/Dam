import 'package:flutter/material.dart';

import '../data/guide.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'chat_sheet.dart';
import 'file_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();
  final _filesKey = GlobalKey();
  String _q = '';

  Guide get g => Guide.I;

  void _openFile(SourceFile f, {int? line}) {
    Navigator.of(context).push(_route(FileScreen(file: f, initialLine: line)));
  }

  void _toFiles() {
    final ctx = _filesKey.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final q = _q.trim().toLowerCase();
    final found = q.isEmpty
        ? const <SourceFile>[]
        : g.files.where((f) => f.name.toLowerCase().contains(q) || f.summary.toLowerCase().contains(q)).toList();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _BotButton(onTap: () => showChat(context, onOpen: _openFile)),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverToBoxAdapter(child: _Hero(onStart: _toFiles, onBot: () => showChat(context, onOpen: _openFile))),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
            sliver: SliverToBoxAdapter(
              child: TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  hintText: 'ابحث عن ملف…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: p.panel,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.line)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.line)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.gold, width: 1.5)),
                ),
              ),
            ),
          ),
          if (q.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
              sliver: found.isEmpty
                  ? SliverToBoxAdapter(child: Text('مفيش ملف بالاسم ده.', style: TextStyle(color: p.muted)))
                  : SliverList.separated(
                      itemCount: found.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _FileCard(found[i], onTap: () => _openFile(found[i])),
                    ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 30, 18, 0),
              sliver: SliverToBoxAdapter(child: _ProjectMap(onOpen: _openFile)),
            ),
            const SliverPadding(padding: EdgeInsets.fromLTRB(18, 36, 18, 0), sliver: SliverToBoxAdapter(child: _Flow())),
            SliverPadding(
              padding: const EdgeInsets.only(top: 36),
              sliver: SliverToBoxAdapter(child: _Glossary(entries: g.glossary)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 36, 18, 6),
              sliver: SliverToBoxAdapter(
                child: SectionTitle('04 · الملفات', 'شرح الملفات', subtitle: 'افتح أي ملف تلاقي شرحه والكود كامل بالألوان.', key: _filesKey),
              ),
            ),
            for (final group in g.groups) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                sliver: SliverToBoxAdapter(child: Text(group, style: TextStyle(fontWeight: FontWeight.w800, color: p.muted, fontSize: 13))),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                sliver: SliverList.separated(
                  itemCount: g.inGroup(group).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final f = g.inGroup(group)[i];
                    return _FileCard(f, onTap: () => _openFile(f));
                  },
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 40, 18, 110),
                child: Center(child: Text('DAMSTOCK HOMES · Soft Stream © 2026', style: TextStyle(color: p.muted, fontSize: 12.5))),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Route<T> _route<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) {
        final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: c,
          child: SlideTransition(position: Tween(begin: const Offset(0, .04), end: Offset.zero).animate(c), child: child),
        );
      },
    );

/* ---------------------------------------------------------------- Hero */

class _Hero extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onBot;
  const _Hero({required this.onStart, required this.onBot});

  @override
  Widget build(BuildContext context) {
    final g = Guide.I;
    const light = Color(0xFFF4EFE4);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Brand.forest, Brand.deep]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const _Logo(),
                    const Spacer(),
                    IconButton(
                      onPressed: () => toggleTheme(context),
                      icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: light),
                      tooltip: 'الوضع الفاتح / الغامق',
                    ),
                  ]),
                  const SizedBox(height: 26),
                  const Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('Flutter · Dart 3 · Soft Stream', style: TextStyle(color: Brand.gold, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 12.5)),
                  ),
                  const SizedBox(height: 8),
                  FadeIn(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: light, fontSize: 32, fontWeight: FontWeight.w900, height: 1.25),
                        children: [
                          const TextSpan(text: 'كود تطبيق\n'),
                          TextSpan(text: 'DAMSTOCK HOMES', style: TextStyle(color: Brand.gold.op(1))),
                          const TextSpan(text: '\nمشروح ملف ملف'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'كل ملف بوظيفته، وكل كلاس ودالة مربوطين بأرقام السطور، والكود كامل بالألوان. وعندك مساعد بيرد على أي سؤال عن الكود.',
                    style: TextStyle(color: light.op(.78), fontSize: 15, height: 1.7),
                  ),
                  const SizedBox(height: 20),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    _HeroButton(label: 'ابدأ القراءة', gold: true, icon: Icons.menu_book_rounded, onTap: onStart),
                    _HeroButton(label: 'اسأل المساعد', icon: Icons.smart_toy_rounded, onTap: onBot),
                  ]),
                  const SizedBox(height: 22),
                  Row(children: [
                    _Stat(g.files.length, 'ملف'),
                    const SizedBox(width: 8),
                    _Stat(g.totalLines, 'سطر'),
                    const SizedBox(width: 8),
                    _Stat(g.totalItems, 'جزء مشروح'),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(colors: [Brand.forestSoft, Brand.deep], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: Brand.gold.op(.5)),
          ),
          child: CustomPaint(painter: _MarkPainter()),
        ),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('DAMSTOCK', style: TextStyle(color: Color(0xFFF4EFE4), fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 15, height: 1.1)),
          Text('CODE GUIDE', style: TextStyle(color: Brand.gold, fontWeight: FontWeight.w700, letterSpacing: 3, fontSize: 9.5)),
        ]),
      ]),
    );
  }
}

/// Gold roof over code brackets: the app mark.
class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = Brand.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * .075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(s.width * .2, s.height * .45)
        ..lineTo(s.width * .5, s.height * .2)
        ..lineTo(s.width * .8, s.height * .45),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(s.width * .38, s.height * .53)
        ..lineTo(s.width * .29, s.height * .64)
        ..lineTo(s.width * .38, s.height * .75),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(s.width * .62, s.height * .53)
        ..lineTo(s.width * .71, s.height * .64)
        ..lineTo(s.width * .62, s.height * .75),
      p,
    );
    canvas.drawLine(Offset(s.width * .54, s.height * .5), Offset(s.width * .46, s.height * .78), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = Brand.gold.op(.06)
      ..strokeWidth = 1;
    for (double x = 0; x < s.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, s.height), p);
    }
    for (double y = 0; y < s.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(s.width, y), p);
    }
    canvas.drawCircle(Offset(s.width * .9, 0), s.width * .5, Paint()..color = Brand.gold.op(.08));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool gold;
  final VoidCallback onTap;
  const _HeroButton({required this.label, required this.icon, required this.onTap, this.gold = false});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: gold ? const LinearGradient(colors: [Color(0xFFE9CF9C), Brand.gold, Brand.goldDeep]) : null,
          color: gold ? null : Colors.white.op(.08),
          border: gold ? null : Border.all(color: Colors.white.op(.2)),
          boxShadow: gold ? [BoxShadow(color: Brand.gold.op(.35), blurRadius: 22, offset: const Offset(0, 10))] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 19, color: gold ? Brand.deep : const Color(0xFFF4EFE4)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: gold ? Brand.deep : const Color(0xFFF4EFE4))),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.op(.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.op(.12)),
        ),
        child: Column(children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Text(
              _fmt(v.round()),
              style: const TextStyle(color: Brand.gold, fontWeight: FontWeight.w900, fontSize: 22, fontFeatures: [FontFeature.tabularFigures()]),
            ),
          ),
          Text(label, style: TextStyle(color: const Color(0xFFF4EFE4).op(.72), fontSize: 12)),
        ]),
      ),
    );
  }
}

String _fmt(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/* ---------------------------------------------------------------- Sections */

class _ProjectMap extends StatelessWidget {
  final void Function(SourceFile) onOpen;
  const _ProjectMap({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final g = Guide.I;
    final p = context.pal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('01 · الهيكل', 'خريطة المشروع', subtitle: 'الملفات متقسّمة على ${g.groups.length} طبقات. دوس على أي ملف عشان تفتح شرحه.'),
        const SizedBox(height: 14),
        for (var i = 0; i < g.groups.length; i++)
          FadeIn(
            delay: i * 60,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: p.goldSoft, borderRadius: BorderRadius.circular(8)),
                      child: Text('${i + 1}', style: TextStyle(color: p.gold, fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(g.groups[i], style: TextStyle(fontWeight: FontWeight.w800, color: p.accent))),
                    Text('${g.inGroup(g.groups[i]).length} ملف', style: TextStyle(color: p.muted, fontSize: 12)),
                  ]),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final f in g.inGroup(g.groups[i]))
                        Pressable(
                          onTap: () => onOpen(f),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: p.panel2, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.line)),
                            child: Text(f.name, textDirection: TextDirection.ltr, style: TextStyle(fontFamily: mono, fontSize: 12, color: p.ink)),
                          ),
                        ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
      ],
    );
  }
}

class _Flow extends StatelessWidget {
  const _Flow();

  static const steps = [
    ('main.dart', 'بيجهّز اللغة والثيم والحالة'),
    ('Splash', 'شاشة الافتتاح المتحركة'),
    ('Onboarding', '3 صفحات تعريف'),
    ('Login + OTP', 'الدخول برقم الموبايل'),
    ('Main Shell', '5 تبويبات وشريط تنقل'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('02 · التشغيل', 'التطبيق بيشتغل إزاي'),
      const SizedBox(height: 14),
      for (var i = 0; i < steps.length; i++)
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Column(children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Brand.gold, shape: BoxShape.circle),
                child: Text('${i + 1}', style: const TextStyle(color: Brand.deep, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
              if (i < steps.length - 1) Expanded(child: Container(width: 2, color: p.line)),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14, top: 2),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(steps[i].$1, textDirection: TextDirection.ltr, style: TextStyle(fontFamily: mono, fontWeight: FontWeight.w700, color: p.accent)),
                  Text(steps[i].$2, style: TextStyle(color: p.muted, fontSize: 13)),
                ]),
              ),
            ),
          ]),
        ),
      const SizedBox(height: 4),
      Panel(
        color: p.goldSoft,
        child: Text(
          'AppState هو قلب التطبيق: مكان واحد فيه المفضلة والمقارنة والفلاتر والطلبات والمستخدم واللغة. '
          'أي تغيير فيه بيحدّث كل الشاشات اللي بتعرضه.',
          style: TextStyle(height: 1.7, color: p.ink),
        ),
      ),
    ]);
  }
}

class _Glossary extends StatelessWidget {
  final List<GlossaryEntry> entries;
  const _Glossary({required this.entries});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: SectionTitle('03 · القاموس', 'قاموس السطور', subtitle: 'الأنماط اللي بتتكرر في كل ملف. اسحب للجنب، ودوس على أي كارت يفتح كامل.'),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final e = entries[i];
            return Pressable(
              onTap: () => showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (_) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.term, textDirection: TextDirection.ltr, style: TextStyle(fontFamily: mono, color: p.kw, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(e.text, style: const TextStyle(fontSize: 15, height: 1.8)),
                  ]),
                ),
              ),
              child: SizedBox(
                width: 250,
                child: Panel(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.term, maxLines: 2, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
                        style: TextStyle(fontFamily: mono, color: p.kw, fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(e.text, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, height: 1.6, color: p.ink)),
                    ),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _FileCard extends StatelessWidget {
  final SourceFile f;
  final VoidCallback onTap;
  const _FileCard(this.f, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Pressable(
      onTap: onTap,
      child: Panel(
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.goldSoft, borderRadius: BorderRadius.circular(12)),
            child: Icon(f.name.endsWith('.dart') ? Icons.code_rounded : Icons.settings_rounded, color: p.gold, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.name, textDirection: TextDirection.ltr, style: TextStyle(fontFamily: mono, fontWeight: FontWeight.w700, color: p.accent, fontSize: 14)),
              const SizedBox(height: 2),
              Text(f.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.muted, fontSize: 13, height: 1.5)),
            ]),
          ),
          const SizedBox(width: 8),
          Column(children: [
            Text('${f.lines}', style: TextStyle(fontWeight: FontWeight.w800, color: p.ink)),
            Text('سطر', style: TextStyle(color: p.muted, fontSize: 11)),
          ]),
        ]),
      ),
    );
  }
}

class _BotButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BotButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(colors: [Color(0xFFEBD3A3), Brand.gold, Brand.goldDeep]),
          boxShadow: [BoxShadow(color: Brand.deep.op(.35), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.smart_toy_rounded, color: Brand.deep),
          SizedBox(width: 8),
          Text('اسأل المساعد', style: TextStyle(color: Brand.deep, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}
