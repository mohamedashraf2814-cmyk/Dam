import 'guide.dart';

/// One answer card the assistant can attach to a reply.
class BotResult {
  final String fileId;
  final String fileName;
  final String title;
  final String text;
  final int? line;
  const BotResult({required this.fileId, required this.fileName, required this.title, required this.text, this.line});
}

class BotReply {
  final String text;
  final List<BotResult> results;
  const BotReply(this.text, [this.results = const []]);
}

/// Offline assistant that answers from the guide content.
class CodeBot {
  CodeBot(this.g);
  final Guide g;

  static const suggestions = [
    'إيه وظيفة AppState؟',
    'فين دالة fmtPrice؟',
    'الخريطة معمولة إزاي؟',
    'يعني إيه setState؟',
    'التطبيق بيبدأ منين؟',
    'كام سطر في المشروع؟',
  ];

  /// Arabic topic words → file ids.
  static const Map<String, List<String>> _topics = {
    'خريطه': ['lib_features_map_map_screen_dart', 'lib_widgets_map_canvas_dart'],
    'ماب': ['lib_features_map_map_screen_dart', 'lib_widgets_map_canvas_dart'],
    'مقارنه': ['lib_features_compare_compare_screen_dart'],
    'قارن': ['lib_features_compare_compare_screen_dart'],
    'مفضله': ['lib_features_favorites_favorites_screen_dart'],
    'محفوظ': ['lib_features_favorites_favorites_screen_dart'],
    'دخول': ['lib_features_auth_login_screen_dart', 'lib_features_auth_otp_screen_dart'],
    'تسجيل': ['lib_features_auth_login_screen_dart', 'lib_features_auth_otp_screen_dart'],
    'otp': ['lib_features_auth_otp_screen_dart'],
    'تحقق': ['lib_features_auth_otp_screen_dart'],
    'فلتر': ['lib_features_explore_filter_sheet_dart', 'lib_core_state_app_state_dart'],
    'فلاتر': ['lib_features_explore_filter_sheet_dart', 'lib_core_state_app_state_dart'],
    'بحث': ['lib_features_explore_explore_screen_dart'],
    'استكشف': ['lib_features_explore_explore_screen_dart'],
    'الوان': ['lib_core_theme_app_colors_dart'],
    'لون': ['lib_core_theme_app_colors_dart'],
    'ثيم': ['lib_core_theme_app_theme_dart'],
    'خط': ['lib_core_theme_app_theme_dart'],
    'خطوط': ['lib_core_theme_app_theme_dart'],
    'ترجمه': ['lib_core_l10n_strings_dart'],
    'لغه': ['lib_core_l10n_strings_dart'],
    'عربي': ['lib_core_l10n_strings_dart'],
    'تنقل': ['lib_core_router_routes_dart'],
    'مسار': ['lib_core_router_routes_dart'],
    'شاشات': ['lib_core_router_routes_dart'],
    'سعر': ['lib_core_utils_format_dart'],
    'اسعار': ['lib_core_utils_format_dart'],
    'تنسيق': ['lib_core_utils_format_dart'],
    'موبايل': ['lib_core_utils_format_dart'],
    'بيانات': ['lib_data_mock_data_dart', 'lib_data_models_dart'],
    'موديل': ['lib_data_models_dart'],
    'نموذج': ['lib_data_models_dart'],
    'حاسبه': ['lib_widgets_payment_calculator_dart'],
    'تقسيط': ['lib_widgets_payment_calculator_dart'],
    'قسط': ['lib_widgets_payment_calculator_dart'],
    'معاينه': ['lib_features_inquiries_inquiry_form_screen_dart'],
    'طلب': ['lib_features_inquiries_inquiry_form_screen_dart', 'lib_features_inquiries_inquiries_screen_dart'],
    'طلبات': ['lib_features_inquiries_inquiries_screen_dart'],
    'اضافه': ['lib_features_add_property_add_property_screen_dart'],
    'اعلان': ['lib_features_add_property_add_property_screen_dart', 'lib_features_add_property_my_listings_screen_dart'],
    'حساب': ['lib_features_profile_profile_screen_dart'],
    'بروفايل': ['lib_features_profile_profile_screen_dart'],
    'رئيسيه': ['lib_features_home_home_screen_dart'],
    'هوم': ['lib_features_home_home_screen_dart'],
    'مطور': ['lib_features_developers_developers_screen_dart', 'lib_features_developers_developer_details_screen_dart'],
    'مطورين': ['lib_features_developers_developers_screen_dart'],
    'مشروع': ['lib_features_projects_project_details_screen_dart', 'lib_features_projects_projects_screen_dart'],
    'مشروعات': ['lib_features_projects_projects_screen_dart'],
    'تنازل': ['lib_features_resale_resale_screen_dart'],
    'بيع': ['lib_features_resale_resale_screen_dart'],
    'عقار': ['lib_features_properties_property_details_screen_dart', 'lib_widgets_cards_dart'],
    'تفاصيل': ['lib_features_properties_property_details_screen_dart'],
    'كارت': ['lib_widgets_cards_dart'],
    'كروت': ['lib_widgets_cards_dart'],
    'زرار': ['lib_widgets_common_dart'],
    'ازرار': ['lib_widgets_common_dart'],
    'افتتاح': ['lib_features_splash_splash_screen_dart'],
    'سبلاش': ['lib_features_splash_splash_screen_dart'],
    'تعريف': ['lib_features_onboarding_onboarding_screen_dart'],
    'تبويب': ['lib_features_shell_main_shell_dart'],
    'تبويبات': ['lib_features_shell_main_shell_dart'],
    'حاله': ['lib_core_state_app_state_dart'],
    'اختبار': ['test_widget_test_dart'],
    'اختبارات': ['test_widget_test_dart'],
    'مكتبات': ['pubspec_yaml'],
    'باكدجات': ['pubspec_yaml'],
  };

  static const _stop = {
    'ايه', 'اي', 'هو', 'هي', 'في', 'من', 'على', 'عن', 'الى', 'الي', 'ده', 'دي', 'دا', 'اللي', 'يعني', 'ازاي',
    'فين', 'مين', 'ليه', 'امتى', 'كام', 'عايز', 'اعرف', 'اشرح', 'شرح', 'وظيفه', 'ممكن', 'لو', 'مع', 'ما',
    'هل', 'بتاع', 'بتاعه', 'بتاعت', 'معموله', 'معمول', 'بيشتغل', 'بتشتغل', 'كود', 'ملف', 'الملف', 'دالة', 'داله',
    'كلاس', 'the', 'is', 'what', 'where', 'how', 'a', 'of',
  };

  static String normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp('[ً-ْـ]'), '')
        .replaceAll(RegExp('[إأآا]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[؟?!.,،:;()\[\]{}"' "'" r'`]'), ' ');
  }

  static List<String> tokens(String s) {
    final out = <String>[];
    for (var w in normalize(s).split(RegExp(r'\s+'))) {
      if (w.isEmpty) continue;
      if (RegExp(r'^[؀-ۿ]').hasMatch(w)) {
        if (w.length > 4 && w.startsWith('ال')) w = w.substring(2);
        if (w.length > 3 && (w.startsWith('وال') || w.startsWith('بال') || w.startsWith('لل'))) {
          w = w.startsWith('لل') ? w.substring(2) : w.substring(3);
        }
      }
      if (_stop.contains(w)) continue;
      out.add(w);
    }
    return out;
  }

  BotReply answer(String q) {
    final norm = normalize(q).trim();
    final toks = tokens(q);
    if (norm.isEmpty) return const BotReply('اكتب سؤالك عن أي ملف أو دالة في المشروع.');

    if (RegExp(r'^(اهلا|السلام|سلام|هاي|مرحبا|hello|hi|hey|ازيك|صباح|مساء)').hasMatch(norm)) {
      return BotReply('أهلاً بيك! أنا مساعد كود DAMSTOCK. اسألني عن أي ملف أو كلاس أو دالة، '
          'أو عن نمط في Flutter زي setState وRow وNavigator، وأنا أوصّلك للسطر بالظبط.');
    }
    if (RegExp(r'شكرا|متشكر|thanks|thank').hasMatch(norm)) {
      return const BotReply('العفو! لو عندك سؤال تاني عن الكود أنا موجود.');
    }

    if (norm.contains('كام') || norm.contains('عدد')) {
      if (norm.contains('سطر')) {
        return BotReply('المشروع فيه ${_fmt(g.totalLines)} سطر كود في ${g.files.length} ملف.');
      }
      if (norm.contains('ملف') || norm.contains('ملفات')) {
        return BotReply('المشروع فيه ${g.files.length} ملف، متقسّمين على ${g.groups.length} طبقات: ${g.groups.join('، ')}.');
      }
      if (norm.contains('شاش')) {
        final n = g.files.where((f) => f.path.contains('/features/')).length;
        return BotReply('في $n ملف شاشات جوه فولدر features.');
      }
    }

    if (RegExp(r'بيبدا|يبدا|بدايه|نقطه البدايه|\bmain\b|اول ملف').hasMatch(norm)) {
      final f = g.file('lib_main_dart')!;
      return BotReply('التطبيق بيبدأ من lib/main.dart. دالة main بتجهّز Flutter وبتشغّل DamstockApp، '
          'واللي بدوره بيعمل AppState ويحدد اللغة والثيم وأول شاشة (Splash).', _fileResults(f, 3));
    }

    // 1) exact code symbol (class / function names)
    final latin = RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(q).map((m) => m.group(0)!).toList();
    for (final w in latin) {
      final hits = g.symbols.where((s) => s.name.toLowerCase() == w.toLowerCase()).toList();
      if (hits.isNotEmpty) {
        final results = <BotResult>[];
        for (final s in hits.take(3)) {
          final f = g.file(s.fileId)!;
          final ex = f.items.where((e) => e.title.toLowerCase().contains(s.name.toLowerCase())).toList();
          results.add(BotResult(
            fileId: f.id,
            fileName: f.name,
            title: s.name,
            text: ex.isNotEmpty ? ex.first.text : '${_kind(s.kind)} موجود في ${f.name}. ${f.summary}',
            line: s.line,
          ));
        }
        final s = hits.first;
        return BotReply('${s.name} ${_kind(s.kind)} في ملف ${g.file(s.fileId)!.name}، سطر ${s.line}.', results);
      }
    }

    // 2) glossary (Flutter / Dart patterns)
    for (final w in latin) {
      final lw = w.toLowerCase();
      if (lw.length < 3) continue;
      final rx = RegExp('\\b${RegExp.escape(lw)}\\b');
      var hit = g.glossary.where((e) => rx.hasMatch(e.term.toLowerCase())).toList();
      if (hit.isEmpty) hit = g.glossary.where((e) => rx.hasMatch(e.text.toLowerCase())).toList();
      if (hit.isNotEmpty) {
        final e = hit.first;
        return BotReply('${e.term}\n${e.text}');
      }
    }

    // 3) file names
    for (final w in latin) {
      final lw = w.toLowerCase().replaceAll('.dart', '');
      if (lw.length < 3) continue;
      final f = g.files.where((f) => f.name.toLowerCase().replaceAll('.dart', '').contains(lw)).toList();
      if (f.isNotEmpty) {
        return BotReply('${f.first.name}: ${f.first.summary}', _fileResults(f.first, 3));
      }
    }

    // 4) Arabic topics + text scoring
    final scores = <String, double>{};
    for (final t in toks) {
      for (final e in _topics.entries) {
        if (t == e.key || (t.length > 3 && (t.startsWith(e.key) || e.key.startsWith(t)))) {
          for (final id in e.value) {
            scores[id] = (scores[id] ?? 0) + 3;
          }
        }
      }
    }
    final itemScores = <BotResult, double>{};
    for (final f in g.files) {
      final fs = normalize('${f.summary} ${f.name}');
      for (final t in toks) {
        if (t.length > 2 && fs.contains(t)) scores[f.id] = (scores[f.id] ?? 0) + 1.5;
      }
      for (final it in f.items) {
        final hay = normalize('${it.title} ${it.text}');
        var s = 0.0;
        for (final t in toks) {
          if (t.length > 2 && hay.contains(t)) s += 1;
        }
        if (s > 0) {
          s += (scores[f.id] ?? 0) * .5;
          itemScores[BotResult(fileId: f.id, fileName: f.name, title: it.title, text: it.text, line: it.line)] = s;
        }
      }
    }
    if (itemScores.isNotEmpty || scores.isNotEmpty) {
      final best = itemScores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final results = best.take(3).map((e) => e.key).toList();
      if (results.isEmpty) {
        final ids = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        final f = g.file(ids.first.key)!;
        return BotReply('${f.name}: ${f.summary}', _fileResults(f, 3));
      }
      final topFile = g.file(results.first.fileId)!;
      return BotReply('لقيت ده في ${topFile.name}:', results);
    }

    return const BotReply('مش لاقي إجابة دقيقة للسؤال ده. جرّب تكتب اسم كلاس أو دالة (زي PropertyCard أو toggleFav)، '
        'أو موضوع زي «الخريطة» أو «الفلاتر» أو «تسجيل الدخول».');
  }

  List<BotResult> _fileResults(SourceFile f, int n) => f.items
      .take(n)
      .map((e) => BotResult(fileId: f.id, fileName: f.name, title: e.title, text: e.text, line: e.line))
      .toList();

  static String _kind(String k) => switch (k) {
        'class' => 'كلاس',
        'enum' => 'enum',
        'extension' => 'extension',
        _ => 'دالة',
      };

  static String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}
