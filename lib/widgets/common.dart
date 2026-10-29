import 'package:flutter/material.dart';

import '../theme.dart';

const mono = 'monospace';

/// Shrinks slightly while pressed.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const Pressable({super.key, required this.child, this.onTap});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? .97 : 1,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.radius = 16, this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.panel,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.line),
        boxShadow: [BoxShadow(color: Colors.black.op(.04), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String kicker;
  final String title;
  final String? subtitle;
  const SectionTitle(this.kicker, this.title, {super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(kicker, style: TextStyle(color: p.gold, fontWeight: FontWeight.w800, fontSize: 12.5, letterSpacing: .6)),
        const SizedBox(height: 2),
        Text(title, style: TextStyle(color: p.accent, fontWeight: FontWeight.w900, fontSize: 24, height: 1.3)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: TextStyle(color: p.muted, fontSize: 14, height: 1.6)),
        ],
      ],
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  final bool strong;
  const Tag(this.text, {super.key, this.strong = false});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: strong ? p.accent : p.panel,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: strong ? p.accent : p.line),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: strong ? p.bg : p.muted, fontWeight: FontWeight.w600)),
    );
  }
}

/// Small pill that shows a line number and jumps to it.
class LineChip extends StatelessWidget {
  final int line;
  final VoidCallback onTap;
  const LineChip(this.line, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 2),
        decoration: BoxDecoration(color: p.goldSoft, borderRadius: BorderRadius.circular(99)),
        child: Text('سطر $line', style: TextStyle(color: p.gold, fontWeight: FontWeight.w800, fontSize: 12)),
      ),
    );
  }
}

/// Fades and slides in when first built.
class FadeIn extends StatelessWidget {
  final Widget child;
  final int delay;
  const FadeIn({super.key, required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 14), child: child),
      ),
      child: child,
    );
  }
}
