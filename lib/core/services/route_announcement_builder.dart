import 'routing_service.dart';
import 'tts_locale_resolver.dart';

class RouteAnnouncementBuilder {
  static String build({
    required String destination,
    required RouteOption route,
    required String? resolvedTtsLocale,
  }) {
    final locale = TtsLocaleResolver.normalizeLocaleId(
      resolvedTtsLocale ?? 'en-US',
    );
    final routeName = routeLabel(
      route.id,
      resolvedTtsLocale: resolvedTtsLocale,
    );
    final minutes = route.duration.inMinutes;
    final covered = _percent(route.coveredPercentage);
    final comfort = route.comfortScore;
    final shade = route.shadePercentage != null
        ? _percent(route.shadePercentage!)
        : null;

    if (locale.startsWith('zh-cn')) {
      final shadeText = shade != null ? '遮荫覆盖$shade%，' : '';
      return '已选择前往 $destination 的$routeName路线。步行约$minutes分钟。'
          '$shadeText有盖步道$covered%，舒适度$comfort分。';
    }

    if (_isTraditionalChineseFamily(locale)) {
      final shadeText = shade != null ? '遮蔭覆蓋$shade%，' : '';
      return '已選擇前往 $destination 的$routeName路線。步行約$minutes分鐘。'
          '$shadeText有蓋步道$covered%，舒適度$comfort分。';
    }

    if (locale.startsWith('ta-')) {
      final shadeText = shade != null ? 'நிழல் பாதுகாப்பு $shade%, ' : '';
      return '$destination-க்கு $routeName வழி தேர்ந்தெடுக்கப்பட்டது. '
          'நடக்கும் நேரம் சுமார் $minutes நிமிடங்கள். '
          '$shadeTextமூடப்பட்ட நடைபாதை $covered%, வசதி மதிப்பெண் $comfort/100.';
    }

    if (locale.startsWith('ms')) {
      final shadeText = shade != null ? 'Liputan teduhan ialah $shade%, ' : '';
      return 'Laluan $routeName ke $destination telah dipilih. '
          'Masa berjalan kira-kira $minutes minit. '
          '${shadeText}liputan laluan berbumbung ialah $covered%, dan skor keselesaan ialah $comfort daripada 100.';
    }

    final shadeText = shade != null ? 'Shade coverage is $shade percent, ' : '';
    return '$routeName route to $destination selected. '
        'Walking time is about $minutes minutes. '
        '$shadeText'
        'covered walkway coverage is $covered percent, and the comfort score is $comfort out of 100.';
  }

  static String routeLabel(
    String routeId, {
    required String? resolvedTtsLocale,
  }) {
    final locale = TtsLocaleResolver.normalizeLocaleId(
      resolvedTtsLocale ?? 'en-US',
    );
    final id = routeId.toLowerCase().trim();

    if (locale.startsWith('zh-cn')) {
      return switch (id) {
        'fastest' => '最快',
        'coolest' => '最凉快',
        'covered' => '有遮盖',
        _ => '均衡',
      };
    }

    if (_isTraditionalChineseFamily(locale)) {
      return switch (id) {
        'fastest' => '最快',
        'coolest' => '最涼快',
        'covered' => '有遮蓋',
        _ => '均衡',
      };
    }

    if (locale.startsWith('ta-')) {
      return switch (id) {
        'fastest' => 'மிக வேகமான',
        'coolest' => 'மிக குளிர்ச்சியான',
        'covered' => 'மூடப்பட்ட',
        _ => 'சமச்சீரான',
      };
    }

    if (locale.startsWith('ms')) {
      return switch (id) {
        'fastest' => 'paling pantas',
        'coolest' => 'paling sejuk',
        'covered' => 'berbumbung',
        _ => 'seimbang',
      };
    }

    return switch (id) {
      'fastest' => 'Fastest',
      'coolest' => 'Coolest',
      'covered' => 'Covered',
      _ => 'Balanced',
    };
  }

  static bool _isTraditionalChineseFamily(String locale) {
    return locale.startsWith('zh-tw') ||
        locale.startsWith('zh-hk') ||
        locale.startsWith('yue-hk') ||
        locale.startsWith('nan-tw');
  }

  static int _percent(double value) {
    return (value * 100).round();
  }
}
