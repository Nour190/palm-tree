import 'package:baseqat/core/database/type_adapters/conversation_adapter.dart';
import 'package:baseqat/core/database/type_adapters/message_adapter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'package:baseqat/modules/home/data/models/review_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/home/data/models/workshop_model.dart';
import 'package:baseqat/modules/artwork_details/data/models/pending_feedback_model.dart';
import 'package:baseqat/core/database/type_adapters/artist_adapter.dart';
import 'package:baseqat/core/database/type_adapters/artwork_adapter.dart';
import 'package:baseqat/core/database/type_adapters/info_adapter.dart';
import 'package:baseqat/core/database/type_adapters/review_adapter.dart';
import 'package:baseqat/core/database/type_adapters/pending_feedback_adapter.dart';
import 'package:baseqat/core/database/type_adapters/speaker_adapter.dart';
import 'package:baseqat/core/database/type_adapters/workshop_adapter.dart';
import 'package:baseqat/core/database/type_adapters/event_adapter.dart';
import 'package:baseqat/modules/home/data/models/event_model.dart';
import 'package:baseqat/core/database/type_adapters/museum_adapter.dart';
import 'package:baseqat/modules/home/data/models/museum_model.dart';

import '../../modules/artwork_details/data/models/conversation_models.dart';

class HiveService {
  static const String artistsBox = 'artists_box';
  static const String artworksBox = 'artworks_box';
  static const String infoBox = 'info_box';
  static const String reviewsBox = 'reviews_box';
  static const String sessionBox = 'session_box';
  static const String pendingFeedbackBox = 'pending_feedback_box';
  static const String metadataBox = 'metadata_box';
  static const String conversationsBox = 'conversations_box';
  static const String messagesBox = 'messages_box';
  static const String locationCacheBox = 'location_cache_box';

  static const String programsArtistsBox = 'programs_artists_box';
  static const String programsArtworksBox = 'programs_artworks_box';
  static const String programsSpeakersBox = 'programs_speakers_box';
  static const String programsWorkshopsBox = 'programs_workshops_box';
  static const String programsEventsBox = 'programs_events_box';
  static const String programsMuseumsBox = 'programs_museums_box';

  static Future<void> initialize() async {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    }

    // Register type adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ArtistAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ArtworkAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(InfoModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ReviewModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(PendingFeedbackAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ConversationAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(MessageAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(SpeakerAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(WorkshopAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(EventAdapter());
    }

    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(MuseumAdapter());
    }

    // Open boxes
    await Hive.openBox<Artist>(artistsBox);
    await Hive.openBox<Artwork>(artworksBox);
    await Hive.openBox<InfoModel>(infoBox);
    await Hive.openBox<ReviewModel>(reviewsBox);
    await Hive.openBox(sessionBox);
    await Hive.openBox<PendingFeedbackModel>(pendingFeedbackBox);
    await Hive.openBox<ConversationRecord>(conversationsBox);
    await Hive.openBox<MessageRecord>(messagesBox);
    await Hive.openBox(metadataBox);
    await Hive.openBox(locationCacheBox);
    await Hive.openBox<Event>(programsEventsBox);
    await Hive.openBox<Museum>(programsMuseumsBox);

    await Hive.openBox<Artist>(programsArtistsBox);
    await Hive.openBox<Artwork>(programsArtworksBox);
    await Hive.openBox<Speaker>(programsSpeakersBox);
    await Hive.openBox<Workshop>(programsWorkshopsBox);
  }

  static Future<void> clearAllData() async {
    await Hive.box<Artist>(artistsBox).clear();
    await Hive.box<Artwork>(artworksBox).clear();
    await Hive.box<InfoModel>(infoBox).clear();
    await Hive.box<ReviewModel>(reviewsBox).clear();
    await Hive.box(metadataBox).clear();
    await Hive.box<ConversationRecord>(conversationsBox).clear();
    await Hive.box<MessageRecord>(messagesBox).clear();
    await Hive.box(locationCacheBox).clear();
    await Hive.box<Event>(programsEventsBox).clear();
    await Hive.box<Museum>(programsMuseumsBox).clear();

    await Hive.box<Artist>(programsArtistsBox).clear();
    await Hive.box<Artwork>(programsArtworksBox).clear();
    await Hive.box<Speaker>(programsSpeakersBox).clear();
    await Hive.box<Workshop>(programsWorkshopsBox).clear();
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }
}
