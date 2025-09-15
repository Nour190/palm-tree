import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';

import '../../data/models/gallery_item.dart';

sealed class EventsState {
  const EventsState();
}

class EventsInitial extends EventsState {
  const EventsInitial();
}

class EventsLoading extends EventsState {
  const EventsLoading();
}

class EventsLoaded extends EventsState {
  final List<Artist> artists;
  final List<Artwork> artworks;
  final List<Speaker> speakers;
  final List<GalleryItem> gallery;

  const EventsLoaded({
    required this.artists,
    required this.artworks,
    required this.speakers,
    required this.gallery,
  });
}

class EventsError extends EventsState {
  final String message;
  const EventsError(this.message);
}
