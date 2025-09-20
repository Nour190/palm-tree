import 'package:baseqat/modules/artwork_details/data/datasources/chat_datasoures/chat__remote_data_source.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/chat_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:translator/translator.dart';

import 'package:baseqat/modules/artwork_details/presentation/view/manger/chat/chat_cubit.dart';
import 'package:baseqat/modules/artwork_details/data/repositories/chat_repository.dart';

import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';

class ChatRoute extends StatelessWidget {
  const ChatRoute({
    super.key,
    required this.userId,
    required this.artworkId,
    this.userName,
    this.artwork,
    this.artist,
    this.sessionLabel,
    this.metadata,
    this.modelName = 'gemini-1.5-flash',
  });

  final String userId;
  final String artworkId;
  final String? userName;
  final Artwork? artwork;
  final Artist? artist;
  final String? sessionLabel;
  final Map<String, dynamic>? metadata;

  final String modelName;

  @override
  Widget build(BuildContext context) {
    // Supabase client
    final client = Supabase.instance.client;

    // Chat repository wiring
    final repo = ChatRepositoryImpl(ChatRemoteDataSourceImpl(client), client);

    return BlocProvider<ChatCubit>(
      create: (_) => ChatCubit(repo, translator: GoogleTranslator()),
      child: AIChatView(
        userId: userId,
        artworkId: artworkId,
        userName: userName,
        artwork: artwork,
        artworkDescription: artwork?.description,
        artworkGallery: artwork?.gallery,
        artworkName: artwork?.name,
        artist: artist,
        sessionLabel: sessionLabel,
        metadata: metadata,
        modelName: modelName,
        botName: artwork?.name ?? 'ithra AI',
        botAvatarIcon: Icons.smart_toy_outlined,
      ),
    );
  }
}
