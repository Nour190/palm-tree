// lib/modules/events/data/models/fav_extension.dart
// Extension to map EntityKind enum to a DB string value.

enum EntityKind { artist, artwork, speaker }

extension EntityKindDb on EntityKind {
  String get db => switch (this) {
    EntityKind.artist => 'artist',
    EntityKind.artwork => 'artwork',
    EntityKind.speaker => 'speaker',
  };
}
