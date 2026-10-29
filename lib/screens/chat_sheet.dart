import 'package:flutter/material.dart';

import '../data/bot.dart';
import '../data/guide.dart';
import '../theme.dart';
import '../widgets/common.dart';

class _Msg {
  final bool me;
  final String text;
  final List<BotResult> results;
  const _Msg(this.me, this.text, [this.results = const []]);
}

/// Conversation is kept for the whole session.
final List<_Msg> _history = [];

Future<void> showChat(BuildContext context, {required void Function(SourceFile file, {int? line}) onOpen}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ChatSheet(onOpen: onOpen),
  );
}

class _ChatSheet extends StatefulWidget {
  final void Function(SourceFile file, {int? line}) onOpen;
  const _ChatSheet({required this.onOpen});

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final _bot = CodeBot(Guide.I);
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    if (_history.isEmpty) {
      _history.add(const _Msg(false, 'أهلاً! أنا مساعد كود DAMSTOCK. اسألني عن أي ملف أو كلاس أو دالة، وأنا أشرحهالك وأوديك للسطر بالظبط.'));
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final q = text.trim();
    if (q.isEmpty || _typing) return;
    _input.clear();
    setState(() {
      _history.add(_Msg(true, q));
      _typing = true;
    });
    _toEnd();
    await Future.delayed(const Duration(milliseconds: 420));
    final r = _bot.answer(q);
    if (!mounted) return;
    setState(() {
      _typing = false;
      _history.add(_Msg(false, r.text, r.results));
    });
    _toEnd();
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _open(BotResult r) {
    final f = Guide.I.file(r.fileId);
    if (f == null) return;
    Navigator.of(context).pop();
    widget.onOpen(f, line: r.line);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final h = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        height: h * .86,
        decoration: BoxDecoration(color: p.panel, borderRadius: const BorderRadius.vertical(top: Radius.circular(26))),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Brand.forest, Brand.deep])),
            child: Row(children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: const Color(0xFF5FD39A), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF5FD39A).op(.4), blurRadius: 8)]),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('مساعد DAMSTOCK', style: TextStyle(color: Color(0xFFF4EFE4), fontWeight: FontWeight.w800, fontSize: 15)),
                  Text('بيرد من شرح الكود نفسه، ومن غير إنترنت', style: TextStyle(color: Color(0xB3F4EFE4), fontSize: 11.5)),
                ]),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _history.clear();
                  _history.add(const _Msg(false, 'بدأنا من الأول. اسألني عن أي حاجة في الكود.'));
                }),
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFFF4EFE4)),
                tooltip: 'محادثة جديدة',
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Color(0xFFF4EFE4))),
            ]),
          ),
          Expanded(
            child: Container(
              color: p.panel2,
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(14),
                itemCount: _history.length + (_typing ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _history.length) return const _Typing();
                  return _Bubble(_history[i], onOpen: _open);
                },
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              itemCount: CodeBot.suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) => Pressable(
                onTap: () => _send(CodeBot.suggestions[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), border: Border.all(color: p.line), color: p.panel),
                  child: Text(CodeBot.suggestions[i], style: TextStyle(fontSize: 12.5, color: p.ink)),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _send,
                    decoration: InputDecoration(
                      hintText: 'اسأل عن أي ملف أو دالة…',
                      filled: true,
                      fillColor: p.panel2,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.line)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.line)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.gold, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Pressable(
                  onTap: () => _send(_input.text),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.send_rounded, color: p.bg, textDirection: TextDirection.rtl),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Msg m;
  final void Function(BotResult) onOpen;
  const _Bubble(this.m, {required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return FadeIn(
      child: Align(
        alignment: m.me ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .82),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: m.me ? p.accent : p.panel,
            border: m.me ? null : Border.all(color: p.line),
            borderRadius: BorderRadiusDirectional.only(
              topStart: const Radius.circular(16),
              topEnd: const Radius.circular(16),
              bottomStart: Radius.circular(m.me ? 4 : 16),
              bottomEnd: Radius.circular(m.me ? 16 : 4),
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.text, style: TextStyle(color: m.me ? p.bg : p.ink, height: 1.7, fontSize: 14)),
            for (final r in m.results)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: p.panel2, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.line)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.title, textDirection: TextDirection.ltr, textAlign: TextAlign.right,
                      style: TextStyle(fontFamily: mono, color: p.accent, fontWeight: FontWeight.w700, fontSize: 12.5)),
                  Text(r.fileName, textDirection: TextDirection.ltr, textAlign: TextAlign.right, style: TextStyle(fontFamily: mono, color: p.gold, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(r.text, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, height: 1.6, color: p.ink)),
                  const SizedBox(height: 6),
                  Pressable(
                    onTap: () => onOpen(r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                      decoration: BoxDecoration(color: p.goldSoft, borderRadius: BorderRadius.circular(99)),
                      child: Text(r.line != null ? 'افتح سطر ${r.line}' : 'افتح الملف', style: TextStyle(color: p.gold, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ),
                ]),
              ),
          ]),
        ),
      ),
    );
  }
}

class _Typing extends StatefulWidget {
  const _Typing();

  @override
  State<_Typing> createState() => _TypingState();
}

class _TypingState extends State<_Typing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: p.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < 3; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.muted.op(((_c.value * 3 - i) % 3) < 1 ? 1 : .3),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
