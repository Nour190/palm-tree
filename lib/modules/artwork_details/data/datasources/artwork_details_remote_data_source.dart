import 'dart:async';
import 'dart:typed_data'; // for Uint8List
import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/remote/net_guard.dart';
import 'package:baseqat/modules/artwork_details/data/models/chat_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';

/// Abstract contract
abstract class ArtworkDetailsRemoteDataSource {
  Future<Artwork> getArtworkById(String id);
  Future<Artist> getArtistById(String id);
  Future<void> submitFeedback({
    required String userId,
    required String artworkId,
    required int rating,
    required String message,
    required List<String> tags,
    bool upsertIfExists, // optional behavior flag
  });

  // Chat
  Future<List<ChatMessage>> getChatHistory({
    required String artworkId,
    required String userId,
    int limit,
  });

  Stream<List<ChatMessage>> watchChat({
    required String artworkId,
    required String userId,
  });

  Future<ChatMessage> sendChatMessage({
    required String artworkId,
    required String userId,
    String? text,
    List<UploadBlob> files,
  });

  Future<List<ChatAttachment>> uploadFiles({
    required String artworkId,
    required String userId,
    required List<UploadBlob> files,
    bool useSignedUrls,
    Duration signedUrlTTL,
  });

  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  });

  Future<void> deleteAttachment({required String storagePath});
}

/// Implementation
class ArtworkDetailsRemoteDataSourceImpl
    implements ArtworkDetailsRemoteDataSource {
  final SupabaseClient client;
  ArtworkDetailsRemoteDataSourceImpl(this.client);

  // Tables / storage
  static const _tableArtworks = 'artworks';
  static const _tableArtists = 'artists';
  static const _tableFeedback = 'feedback'; // ✅ real feedback table
  static const _tableChats = 'artwork_chats';
  static const _bucket = 'artwork-uploads';

  @override
  Future<Artwork> getArtworkById(String id) async {
    try {
      await ensureOnline();
      final res = await client
          .from(_tableArtworks)
          .select()
          .eq('id', id)
          .single();
      return Artwork.fromMap(res);
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<Artist> getArtistById(String id) async {
    try {
      await ensureOnline();
      final res = await client
          .from(_tableArtists)
          .select()
          .eq('id', id)
          .single();
      return Artist.fromMap(res);
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<void> submitFeedback({
    required String userId,
    required String artworkId,
    required int rating,
    required String message,
    required List<String> tags,
    bool upsertIfExists = true, // default matches common UX
  }) async {
    try {
      await ensureOnline();

      // lightweight client-side guardrails
      final int safeRating = rating.clamp(1, 5);
      final String safeMessage = message.trim();

      final payload = {
        'user_id': userId,
        'artwork_id': artworkId,
        'rating': safeRating,
        'message': safeMessage,
        'tags': tags,
      };

      if (upsertIfExists) {
        // requires a UNIQUE(artwork_id, user_id) index to be meaningful
        await client
            .from(_tableFeedback)
            .upsert(payload, onConflict: 'artwork_id,user_id');
      } else {
        await client.from(_tableFeedback).insert(payload);
      }
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  // ---------------- Chat ----------------

  @override
  Future<List<ChatMessage>> getChatHistory({
    required String artworkId,
    required String userId,
    int limit = 50,
  }) async {
    try {
      await ensureOnline();

      final List<dynamic> rows = await client
          .from(_tableChats)
          .select()
          .eq('artwork_id', artworkId)
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final list =
          rows
              .map((e) => ChatMessage.fromMap(e as Map<String, dynamic>))
              .toList()
            ..sort(
              (a, b) => a.createdAt.compareTo(b.createdAt),
            ); // oldest → newest

      return list;
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Stream<List<ChatMessage>> watchChat({
    required String artworkId,
    required String userId,
  }) async* {
    await ensureOnline();
    yield* client
        .from(_tableChats)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map(
          (rows) => rows
              .where(
                (row) =>
                    (row['artwork_id'] as String?) == artworkId &&
                    (row['user_id'] as String?) == userId,
              )
              .map((e) => ChatMessage.fromMap(e))
              .toList(),
        );
  }

  @override
  Future<ChatMessage> sendChatMessage({
    required String artworkId,
    required String userId,
    String? text,
    List<UploadBlob> files = const [],
  }) async {
    try {
      await ensureOnline();

      final trimmed = text?.trim();
      if ((trimmed == null || trimmed.isEmpty) && files.isEmpty) {
        throw ArgumentError(
          'Cannot send an empty message with no attachments.',
        );
      }

      List<ChatAttachment> attachments = [];
      if (files.isNotEmpty) {
        attachments = await uploadFiles(
          artworkId: artworkId,
          userId: userId,
          files: files,
          useSignedUrls: false,
          signedUrlTTL: const Duration(hours: 1),
        );
      }

      final inserted = await client
          .from(_tableChats)
          .insert({
            'artwork_id': artworkId,
            'user_id': userId,
            'text': trimmed,
            'attachments': attachments.map((a) => a.toMap()).toList(),
          })
          .select()
          .single();

      return ChatMessage.fromMap(inserted);
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<List<ChatAttachment>> uploadFiles({
    required String artworkId,
    required String userId,
    required List<UploadBlob> files,
    bool useSignedUrls = false,
    Duration signedUrlTTL = const Duration(hours: 1),
  }) async {
    try {
      await ensureOnline();
      final bucket = client.storage.from(_bucket);
      final List<ChatAttachment> results = [];

      for (final f in files) {
        final nowIso = DateTime.now().toUtc().toIso8601String().replaceAll(
          ':',
          '-',
        );
        final safeName = f.fileName.replaceAll('/', '_');
        final path = '$artworkId/$userId/${nowIso}_$safeName';

        final Uint8List bytes = Uint8List.fromList(f.bytes);

        await bucket.uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: f.contentType, upsert: false),
        );

        final url = useSignedUrls
            ? (await bucket.createSignedUrl(path, signedUrlTTL.inSeconds))
            : bucket.getPublicUrl(path);

        results.add(
          ChatAttachment(
            name: safeName,
            path: path,
            url: url,
            contentType: f.contentType,
            size: bytes.length,
          ),
        );
      }
      return results;
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  }) async {
    try {
      await ensureOnline();
      await client
          .from(_tableChats)
          .delete()
          .eq('id', messageId)
          .eq('user_id', userId);
    } catch (e, st) {
      throw mapError(e, st);
    }
  }

  @override
  Future<void> deleteAttachment({required String storagePath}) async {
    try {
      await ensureOnline();
      await client.storage.from(_bucket).remove([storagePath]);
    } catch (e, st) {
      throw mapError(e, st);
    }
  }
}
