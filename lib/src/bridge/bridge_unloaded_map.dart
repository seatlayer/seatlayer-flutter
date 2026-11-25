import '../json.dart';

/// Whether the picker page answered ready without a map.
///
/// It does when the map did not load: no network, a server that does not
/// answer, an event that is not there. It then names the event by its key and
/// has no level and no price. A session that was refused has a telling of its
/// own and is left to it.
bool seatLayerPickerMapDidNotLoad(Object? snapshot) {
  final event = jGet(snapshot, 'event');
  final key = jStr(jGet(event, 'key'));
  if (key == null || jStr(jGet(event, 'name')) != key) return false;
  final catalog = jGet(snapshot, 'catalog');
  final lists = <Object?>[
    jGet(jGet(snapshot, 'map'), 'floors'),
    jGet(catalog, 'categories'),
    jGet(catalog, 'gaAreas'),
  ];
  if (lists.any((list) => list is List && list.isNotEmpty)) return false;
  final access = jGet(snapshot, 'access');
  final status = jStr(jGet(access, 'status'));
  return (status != 'unavailable' && status != 'expired') ||
      (status == 'unavailable' &&
          jStr(jGet(access, 'reason')) == 'provider_failed');
}
