import 'package:baseqat/modules/home/data/models/event_model.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';

class EventWithArtists {
  final Event event;
  final List<Artist> artists;

  const EventWithArtists({
    required this.event,
    required this.artists,
  });
}
