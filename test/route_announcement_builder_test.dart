import 'package:flutter_test/flutter_test.dart';
import 'package:suarawarga_ai/core/services/route_announcement_builder.dart';
import 'package:suarawarga_ai/core/services/routing_service.dart';

void main() {
  group('RouteAnnouncementBuilder', () {
    test('English announcement uses actual selected route metrics', () {
      final announcement = RouteAnnouncementBuilder.build(
        destination: 'KL Sentral',
        route: _route(id: 'coolest'),
        resolvedTtsLocale: 'en-US',
      );

      expect(announcement, contains('Coolest route to KL Sentral'));
      expect(announcement, contains('38 minutes'));
      expect(announcement, contains('72 percent'));
      expect(announcement, contains('12 percent'));
      expect(announcement, contains('81 out of 100'));
    });

    test('Mandarin zh-CN announcement uses Simplified Chinese', () {
      final announcement = RouteAnnouncementBuilder.build(
        destination: 'KL Sentral',
        route: _route(id: 'coolest'),
        resolvedTtsLocale: 'zh-CN',
      );

      expect(announcement, contains('最凉快路线'));
      expect(announcement, contains('KL Sentral'));
      expect(announcement, contains('38分钟'));
      expect(announcement, contains('72%'));
      expect(announcement, contains('12%'));
      expect(announcement, contains('81分'));
    });

    test('Traditional Chinese family uses Traditional Chinese wording', () {
      final announcement = RouteAnnouncementBuilder.build(
        destination: 'KL Sentral',
        route: _route(id: 'coolest'),
        resolvedTtsLocale: 'zh-TW',
      );

      expect(announcement, contains('最涼快路線'));
      expect(announcement, contains('KL Sentral'));
      expect(announcement, contains('38分鐘'));
      expect(announcement, contains('遮蔭覆蓋72%'));
      expect(announcement, contains('有蓋步道12%'));
      expect(announcement, contains('81分'));
    });

    test('Tamil announcement contains destination and metrics', () {
      final announcement = RouteAnnouncementBuilder.build(
        destination: 'KL Sentral',
        route: _route(id: 'coolest'),
        resolvedTtsLocale: 'ta-IN',
      );

      expect(announcement, contains('KL Sentral'));
      expect(announcement, contains('38'));
      expect(announcement, contains('72'));
      expect(announcement, contains('12'));
      expect(announcement, contains('81/100'));
    });

    test('Malay announcement contains destination and metrics', () {
      final announcement = RouteAnnouncementBuilder.build(
        destination: 'KL Sentral',
        route: _route(id: 'coolest'),
        resolvedTtsLocale: 'ms-MY',
      );

      expect(announcement, contains('KL Sentral'));
      expect(announcement, contains('38 minit'));
      expect(announcement, contains('72%'));
      expect(announcement, contains('12%'));
      expect(announcement, contains('81 daripada 100'));
    });

    test('unknown shade is not announced as zero percent', () {
      final announcement = RouteAnnouncementBuilder.build(
        destination: 'KL Sentral',
        route: _route(id: 'balanced', shadePercentage: null),
        resolvedTtsLocale: 'en-US',
      );

      expect(announcement, isNot(contains('0 percent')));
      expect(announcement, isNot(contains('0%')));
      expect(announcement, contains('covered walkway coverage is 12 percent'));
    });

    test('route IDs have distinct English labels', () {
      expect(
        RouteAnnouncementBuilder.routeLabel(
          'fastest',
          resolvedTtsLocale: 'en-US',
        ),
        'Fastest',
      );
      expect(
        RouteAnnouncementBuilder.routeLabel(
          'coolest',
          resolvedTtsLocale: 'en-US',
        ),
        'Coolest',
      );
      expect(
        RouteAnnouncementBuilder.routeLabel(
          'covered',
          resolvedTtsLocale: 'en-US',
        ),
        'Covered',
      );
      expect(
        RouteAnnouncementBuilder.routeLabel(
          'balanced',
          resolvedTtsLocale: 'en-US',
        ),
        'Balanced',
      );
    });
  });
}

RouteOption _route({required String id, double? shadePercentage = 0.72}) {
  final name = switch (id) {
    'fastest' => 'Fastest',
    'coolest' => 'Coolest',
    'covered' => 'Covered',
    _ => 'Balanced',
  };

  return RouteOption(
    id: id,
    name: name,
    duration: const Duration(minutes: 38),
    distance: 2900,
    shadePercentage: shadePercentage,
    coveredPercentage: 0.12,
    comfortScore: 81,
    description: 'Test route',
    segments: const [],
  );
}
