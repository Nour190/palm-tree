
import 'dart:async';
import 'dart:typed_data';

import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/chat/chat_cubit.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/manger/chat/chat_states.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

// Models
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';

// Project helpers
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

// ======================= Local UI Message (only used for streaming bubble and transient voice) =======================
class ChatEntry {
  final String id;
  final String text;
  final bool fromUser;
  final DateTime time;
  final String? mediaLabel;

  // Optional: local-only WAV bytes for immediate playback (not persisted)
  final Uint8List? voiceWav;
  final Duration? voiceDuration;

  // UI: per-message translation (streaming bubble may use this)
  final bool showTranslation;
  final String? translationText;
  final String? translationCode;

  ChatEntry({
    required this.id,
    required this.text,
    required this.fromUser,
    required this.time,
    this.mediaLabel,
    this.voiceWav,
    this.voiceDuration,
    this.showTranslation = false,
    this.translationText,
    this.translationCode,
  });

  ChatEntry copyWith({
    String? text,
    String? mediaLabel,
    Uint8List? voiceWav,
    Duration? voiceDuration,
    bool? showTranslation,
    String? translationText,
    String? translationCode,
  }) => ChatEntry(
    id: id,
    text: text ?? this.text,
    fromUser: fromUser,
    time: time,
    mediaLabel: mediaLabel ?? this.mediaLabel,
    voiceWav: voiceWav ?? this.voiceWav,
    voiceDuration: voiceDuration ?? this.voiceDuration,
    showTranslation: showTranslation ?? this.showTranslation,
    translationText: translationText ?? this.translationText,
    translationCode: translationCode ?? this.translationCode,
  );
}

// ======================= Screen =======================
class AIChatView extends StatefulWidget {
  const AIChatView({
    super.key,
    // Persona visuals
    this.botName = 'ithra AI',
    this.botAvatarIcon = Icons.smart_toy_outlined,

    // Gemini model
    this.modelName = 'gemini-1.5-flash',

    // Persona data
    required this.userId,
    required this.artworkId,
    this.userName,
    this.artwork,
    this.artist,

    // Optional label/metadata for conversation
    this.sessionLabel,
    this.metadata,
    required this.artworkDescription,
    required this.artworkGallery,
    required this.artworkName,
  });

  final String botName;
  final IconData botAvatarIcon;
  final String modelName;

  // Conversation identity
  final String userId;
  final String artworkId;

  // Persona
  final String? userName;
  final Artwork? artwork;
  final String? artworkDescription;
  final List<String>? artworkGallery;
  final String? artworkName;
  final Artist? artist;

  // Conversation labeling
  final String? sessionLabel;
  final Map<String, dynamic>? metadata;

  @override
  State<AIChatView> createState() => _AIChatViewState();
}

class _AIChatViewState extends State<AIChatView> {
  // Input
  final _textCtrl = TextEditingController();
  final _focusNode = FocusNode();

  // Scroll
  final _scrollCtrl = ScrollController();

  // Recorder (web-safe stream)
  final _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _recStreamSub;
  final BytesBuilder _pcmBuilder = BytesBuilder();
  final int _recSampleRate = 16000;
  final int _recChannels = 1;
  bool _isRecording = false;
  DateTime? _recordStart;

  // TTS
  final FlutterTts _tts = FlutterTts();
  List<Map<String, dynamic>> _voices = [];
  Map<String, dynamic>? _ttsVoice; // chosen voice for locale (if any)

  // TTS selectable languages (five)
  static const List<Map<String, String>> _ttsChoices = [
    {'code': 'en-US', 'label': 'EN'},
    {'code': 'ar-SA', 'label': 'AR'},
    {'code': 'fr-FR', 'label': 'FR'},
    {'code': 'es-ES', 'label': 'ES'},
    {'code': 'zh-CN', 'label': 'ZH'},
  ];

  // Gemini
  StreamSubscription<Candidates>? _streamSub;
  bool _isSending = false;

  // Persona prompt history for Gemini (NOT the persisted chat)
  final List<Content> _history = [];

  // Local: transient voice bubble (for recent recorded note only)
  final List<ChatEntry> _ephemeralLocal = [];

  @override
  void initState() {
    super.initState();

    // Build persona instruction if artwork is provided
    if (widget.artwork != null) {
      final persona = _artworkPersonaInstruction(
        widget.artwork!,
        userName: widget.userName,
        artist: widget.artist,
      );
      _history.add(Content(parts: [Part.text(persona)], role: 'user'));
    }

    // Load more when reaching top (older messages)
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels <= 48 &&
          _scrollCtrl.position.maxScrollExtent > 0) {
        final cubit = context.read<ChatCubit>();
        cubit.loadMore();
      }
    });

    // Initialize conversation via Cubit after first frame (BlocProvider must be available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ChatCubit>();
      cubit.init(
        userId: widget.userId,
        artworkId: widget.artworkId,
        sessionLabel: widget.sessionLabel,
        metadata: widget.metadata,
        singleActive: false,
        artworkName: widget.artworkName,
        artworkGallery: widget.artworkGallery,
        artworkDescription: widget.artworkDescription,
      );

      // Initialize TTS with Cubit default locale
      _initTts();
      // Keep TTS locale in sync with Cubit
      _applyTtsLocale(cubit.state.ttsLocale);
    });
  }

  // -----------------------------
  // Persona Instruction
  // -----------------------------
  String _artworkPersonaInstruction(
    Artwork a, {
    String? userName,
    Artist? artist,
  }) {
    final facts = <String>[];

    // Artwork basics
    facts.add('Artwork name: ${a.name}');
    if ((a.description ?? '').trim().isNotEmpty) {
      facts.add('Artwork description: ${a.description}');
    }
    if ((a.materials ?? '').trim().isNotEmpty) {
      facts.add('Artwork materials: ${a.materials}');
    }
    if ((a.vision ?? '').trim().isNotEmpty) {
      facts.add('Artwork vision: ${a.vision}');
    }
    if ((a.artistName ?? '').trim().isNotEmpty) {
      facts.add('Artist name (from artwork): ${a.artistName}');
    }
    if (a.gallery.isNotEmpty) {
      facts.add('Artwork gallery images: ${a.gallery.join(", ")}');
    }

    // Artist enrichment
    if (artist != null) {
      if ((artist.about ?? '').trim().isNotEmpty) {
        facts.add('Artist bio/about: ${artist.about}');
      }
      if (artist.age != null) {
        facts.add('Artist age: ${artist.age}');
      }
      final locBits = [
        if ((artist.address ?? '').trim().isNotEmpty) artist.address,
        if ((artist.city ?? '').trim().isNotEmpty) artist.city,
        if ((artist.country ?? '').trim().isNotEmpty) artist.country,
      ].whereType<String>().join(', ');
      if (locBits.isNotEmpty) {
        facts.add('Artist location: $locBits');
      }
      if (artist.latitude != null && artist.longitude != null) {
        facts.add(
          'Artist coordinates: ${artist.latitude}, ${artist.longitude}',
        );
      }
      if (artist.gallery.isNotEmpty) {
        facts.add('Artist gallery: ${artist.gallery.join(", ")}');
      }
      if ((artist.platform ?? '').trim().isNotEmpty ||
          (artist.url ?? '').trim().isNotEmpty) {
        facts.add(
          'Artist live audio: platform=${artist.platform ?? "-"}, url=${artist.url ?? "-"}, isLive=${artist.isLive}',
        );
      } else {
        facts.add('Artist live audio: isLive=${artist.isLive}');
      }
      if ((artist.profileImage ?? '').trim().isNotEmpty) {
        facts.add('Artist profile image: ${artist.profileImage}');
      }
      if (artist.createdAt != null) {
        facts.add('Artist createdAt: ${artist.createdAt!.toIso8601String()}');
      }
      if (artist.updatedAt != null) {
        facts.add('Artist updatedAt: ${artist.updatedAt!.toIso8601String()}');
      }
    }

    final visitorLine = (userName == null || userName.trim().isEmpty)
        ? ''
        : 'The visitor’s name is $userName.\n';

    return '''
You are the artwork “${a.name}”. Speak in FIRST PERSON as the artwork, not as an assistant. Address visitors as “you”.
You may reference my creator as “my artist” using the provided Artist details (but do not impersonate the artist).
Be truthful to the provided facts. $visitorLine
Policy:
- Mirror the visitor’s language (text or audio).
- For AUDIO: do NOT show a transcript or translation; answer the content only.
- If language is unclear or the visitor indicates confusion, reply briefly in Arabic and English.
- If you don’t know, say you don’t know.

Facts you can use (artwork + artist):
${facts.join('\n')}
''';
  }

  // -----------------------------
  // TTS init & helpers
  // -----------------------------
  Future<void> _initTts() async {
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);

      final raw = await _tts.getVoices;
      if (raw is List) {
        _voices = raw
            .whereType<Map>()
            .map<Map<String, dynamic>>((m) => Map<String, dynamic>.from(m))
            .toList();
      }
    } catch (_) {
      // Ignore; we'll still be able to call setLanguage
    }
  }

  Future<void> _applyTtsLocale(String localeCode) async {
    try {
      // Pick a voice that matches locale, else set language
      _ttsVoice = _pickVoiceForLocale(localeCode);
      if (_ttsVoice != null) {
        await _tts.setVoice({
          'name':
              (_ttsVoice!['name'] ??
                      _ttsVoice!['voice'] ??
                      _ttsVoice!['voiceId'] ??
                      '')
                  .toString(),
          'locale': (_ttsVoice!['locale'] ?? localeCode).toString(),
        });
      } else {
        await _tts.setLanguage(localeCode);
      }
    } catch (_) {
      // Fallback to coarse language
      final coarse = localeCode.split('-').first;
      try {
        await _tts.setLanguage(coarse);
      } catch (_) {
        await _tts.setLanguage('en-US');
      }
    }
  }

  Map<String, dynamic>? _pickVoiceForLocale(String localeCode) {
    if (_voices.isEmpty) return null;
    final want = localeCode.toLowerCase();
    for (final v in _voices) {
      final loc = ((v['locale'] ?? v['lang'] ?? '') as String).toLowerCase();
      if (loc.startsWith(want) || want.startsWith(loc)) return v;
    }
    final coarse = want.split('-').first;
    for (final v in _voices) {
      final loc = ((v['locale'] ?? v['lang'] ?? '') as String).toLowerCase();
      if (loc.split('-').first == coarse) return v;
    }
    return null;
  }

  String _labelForLocale(String code) {
    final m = _ttsChoices.firstWhere(
      (e) => e['code'] == code,
      orElse: () => const {'code': 'en-US', 'label': 'EN'},
    );
    return m['label']!;
  }

  // -----------------------------
  // Send text
  // -----------------------------
  Future<void> _sendText() async {
    final raw = _textCtrl.text.trim();
    if (raw.isEmpty) return;

    _textCtrl.clear();
    _focusNode.requestFocus();

    // Persist (user message)
    final cubit = context.read<ChatCubit>();
    await cubit.sendUserMessage(
      content: raw,
      isVoice: false,
      languageCode: null,
    );

    // Nudge Gemini
    _history.add(
      Content(
        parts: [
          Part.text(
            'Answer in the same language as this message. '
            'If unclear, reply briefly in Arabic and English.',
          ),
          Part.text(raw),
        ],
        role: 'user',
      ),
    );

    // Ask model
    await _streamModelReply();
  }

  // -----------------------------
  // Recording: stream PCM -> WAV
  // -----------------------------
  Future<void> _startRecording() async {
    if (_isRecording) return;
    try {
      bool permitted = true;
      try {
        permitted = await _recorder.hasPermission();
      } catch (_) {
        _showSnack(
          'Mic permission check unavailable. Ensure record_web is in pubspec.',
        );
      }

      if (!permitted && !kIsWeb) {
        _showSnack('Mic permission denied');
        return;
      }

      _pcmBuilder.clear();
      final stream = await _recorder.startStream(
        RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _recSampleRate,
          numChannels: _recChannels,
        ),
      );

      _recStreamSub = stream.listen(
        (chunk) => _pcmBuilder.add(chunk),
        onError: (e) => _showSnack('Record error: $e'),
      );

      setState(() {
        _isRecording = true;
        _recordStart = DateTime.now();
      });
    } catch (e) {
      _showSnack('Record error: $e');
    }
  }

  Future<void> _stopRecordingAndSend() async {
    if (!_isRecording) return;
    try {
      await _recStreamSub?.cancel();
      await _recorder.stop();

      final pcm = _pcmBuilder.toBytes();
      if (pcm.isEmpty) {
        setState(() => _isRecording = false);
        _showSnack('No audio captured. Try again.');
        return;
      }

      final wav = _pcm16ToWav(
        pcm,
        sampleRate: _recSampleRate,
        channels: _recChannels,
      );

      final dur = _recordStart == null
          ? Duration.zero
          : DateTime.now().difference(_recordStart!);

      // Show ephemeral local voice bubble with player (not persisted)
      final local = ChatEntry(
        id: 'local-voice-${DateTime.now().microsecondsSinceEpoch}',
        text: '🎙️ Voice note ${_formatDuration(dur)}',
        fromUser: true,
        time: DateTime.now(),
        mediaLabel: 'voice',
        voiceWav: wav,
        voiceDuration: dur,
      );
      setState(() {
        _ephemeralLocal.add(local);
      });
      _scrollToEnd();

      // Persist **text placeholder** only (no audio) for history
      await context.read<ChatCubit>().sendUserMessage(
        content: local.text, // store text only
        isVoice: true,
        voiceDuration: dur,
      );

      // Send audio to Gemini for **answer without transcript**
      final inline = InlineData.fromUint8List(wav); // audio/wav
      _history.add(
        Content(
          parts: [
            Part.text(
              'The visitor sent an audio question. Do NOT produce a transcript or translation. '
              'Answer the content only in the detected language. '
              'If language is uncertain or the visitor indicates confusion, respond briefly in Arabic and English.',
            ),
            Part.inline(inline),
          ],
          role: 'user',
        ),
      );

      await _streamModelReply();
    } catch (e) {
      _showSnack('Stop/send error: $e');
    } finally {
      _recordStart = null;
      setState(() => _isRecording = false);
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '($m:$s)';
  }

  Uint8List _pcm16ToWav(
    Uint8List pcm, {
    required int sampleRate,
    required int channels,
  }) {
    const bitsPerSample = 16;
    final totalAudioLen = pcm.length;
    final totalDataLen = totalAudioLen + 36;
    final byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
    final blockAlign = channels * (bitsPerSample ~/ 8);

    final header = BytesBuilder();
    void wStr(String s) => header.add(s.codeUnits);
    void w32(int v) => header.add([
      v & 0xff,
      (v >> 8) & 0xff,
      (v >> 16) & 0xff,
      (v >> 24) & 0xff,
    ]);
    void w16(int v) => header.add([v & 0xff, (v >> 8) & 0xff]);

    wStr('RIFF');
    w32(totalDataLen);
    wStr('WAVE');
    wStr('fmt ');
    w32(16);
    w16(1);
    w16(channels);
    w32(sampleRate);
    w32(byteRate);
    w16(blockAlign);
    w16(bitsPerSample);
    wStr('data');
    w32(totalAudioLen);

    final out = BytesBuilder();
    out.add(header.toBytes());
    out.add(pcm);
    return out.toBytes();
  }

  // -----------------------------
  // Gemini streaming (delegates persistence to Cubit when done)
  // -----------------------------
  Future<void> _streamModelReply() async {
    _streamSub?.cancel();
    final cubit = context.read<ChatCubit>();

    setState(() => _isSending = true);
    cubit.beginModelStream(
      showTranslation: false,
    ); // default: off while streaming
    _scrollToEnd();

    try {
      _streamSub = Gemini.instance
          .streamChat(
            _history,
            modelName: widget.modelName,
            generationConfig: GenerationConfig(
              maxOutputTokens: 2048,
              temperature: 0.4,
            ),
          )
          .listen(
            (c) {
              final chunk = c.output;
              if (chunk == null) return;
              cubit.appendModelChunk(chunk);
              _scrollToEnd();
            },
            onError: (e) {
              _showSnack('Gemini error: $e');
              setState(() => _isSending = false);
              // Clear streaming state
              cubit.endModelStream(); // will save empty -> no-op
            },
            onDone: () async {
              setState(() => _isSending = false);

              // Persist the final model message (with translation flag off by default)
              await cubit.endModelStream();

              // Also keep Gemini conversation history for next turns
              final finalText = cubit.state.messages.isNotEmpty
                  ? cubit.state.messages.last.content
                  : '';
              if (finalText.trim().isNotEmpty) {
                _history.add(
                  Content(parts: [Part.text(finalText)], role: 'model'),
                );
              }
            },
          );
    } catch (e) {
      _showSnack('Gemini stream error: $e');
      setState(() => _isSending = false);
    }
  }

  // -----------------------------
  // Speak (translate-for-speech only; UI text stays as-is)
  // -----------------------------
  Future<void> _speak(String text) async {
    final cubit = context.read<ChatCubit>();
    final translatedForSpeech = await cubit.translateForSpeech(text);

    // Re-apply locale/voice before speaking
    await _applyTtsLocale(cubit.state.ttsLocale);

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    await _tts.stop();
    await _tts.speak(translatedForSpeech);
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    _streamSub?.cancel();
    _recStreamSub?.cancel();
    _recorder.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TextStyleHelper.instance;

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final cubit = context.read<ChatCubit>();

        // Build render list: persisted messages + ephemeral voice bubbles + streaming bubble
        final render = <_RenderItem>[];

        // Add persisted messages first (ASC by created_at in state)
        for (final m in state.messages) {
          render.add(_RenderItem.persisted(m));
        }

        // Add ephemeral local voice notes (recently recorded; not persisted)
        for (final e in _ephemeralLocal) {
          render.add(_RenderItem.local(e));
        }

        // Add streaming bubble if any
        if (state.streamingMessageId != null) {
          final streamEntry = ChatEntry(
            id: state.streamingMessageId!,
            text: state.streamingText,
            fromUser: false,
            time: DateTime.now(),
            mediaLabel: null,
            voiceWav: null,
            voiceDuration: null,
            showTranslation: state.streamingShowTranslation,
            translationText: state.streamingTranslationText.isEmpty
                ? null
                : state.streamingTranslationText,
            translationCode: state.streamingTranslationCode,
          );
          render.add(_RenderItem.local(streamEntry));
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColor.gray900,
                  child: Icon(
                    widget.botAvatarIcon,
                    color: Colors.white,
                    size: 18.sSp,
                  ),
                ),
                 SizedBox(width: 10.sW),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.artwork?.name ?? widget.botName,
                      style:TextStyleHelper.instance.body14MediumInter,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8.sW,
                          height: 8.sH,
                          decoration: BoxDecoration(
                            color: _isSending ? Colors.orange : Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                         SizedBox(width: 6.sW),
                        Text(
                          _isSending ? 'Typing…' : 'Online',
                          style: TextStyleHelper.instance.body12MediumInter.copyWith(
                            color: AppColor.gray400,
                          ),
                        ),
                        if ((widget.userName ?? '').isNotEmpty) ...[
                           SizedBox(width: 10.sW),
                          Text(
                            'Visitor: ${widget.userName}',
                            style: TextStyleHelper.instance.body12MediumInter.copyWith(
                              color: AppColor.gray400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

              ],
            ),

            actions: [
              // TTS/Translation Language selector (five languages)
              PopupMenuButton<String>(
                tooltip: 'TTS/Translation language',
                onSelected: (code) async {
                  // Update cubit (for speak + translation toggles)
                  cubit.setTtsLocale(code);
                  // Align TTS engine
                  await _applyTtsLocale(code);
                  if (mounted) setState(() {});
                },
                itemBuilder: (ctx) => _ttsChoices
                    .map(
                      (m) => PopupMenuItem<String>(
                        value: m['code']!,
                        child: Row(
                          children: [
                            const Icon(Icons.translate_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text('${m['label']}  •  ${m['code']}'),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  margin:  EdgeInsets.symmetric(
                    vertical: 8.sH,
                    horizontal: 6.sW,
                  ),
                  padding:  EdgeInsets.symmetric(
                    horizontal: 10.sW,
                    vertical: 6.sH,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.gray400, width: 1),
                    borderRadius: BorderRadius.circular(10.sR),
                  ),
                  child: Row(
                    children: [
                       Icon(Icons.translate_rounded, size: 18.sSp),
                       SizedBox(width: 6.sW),
                      Text(
                        _labelForLocale(state.ttsLocale),
                        style: t.body14MediumInter,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy transcript',
                icon: const Icon(Icons.content_copy_rounded),
                onPressed: () => _copyTranscript(state),
              ),
              IconButton(
                tooltip: 'Clear chat',
                icon: const Icon(Icons.clear_all_rounded),
                onPressed: _confirmClear,
              ),
              // SizedBox(width: 4.sW),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (state.status == ChatStatus.loading)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.sSp,
                      vertical: 12.sSp,
                    ),
                    itemCount: render.length + (_isRecording ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (_isRecording && i == render.length) {
                        return const _RecordingBanner(
                          key: ValueKey('rec-banner'),
                        );
                      }

                      final item = render[i];
                      if (item.isPersisted) {
                        final m = item.persisted!;
                        final isUser = m.role == 'user';
                        final time = m.createdAt;
                        final text = m.content;
                        final showTranslation = m.showTranslation;
                        final translationText = m.translationText;
                        final canTranslate =
                            !(m.isVoice == true) && text.trim().isNotEmpty;
                        final isTranslating = state.translatingIds.contains(
                          m.id,
                        );
                        final label = _labelForLocale(state.ttsLocale);

                        return _Bubble(
                          fromUser: isUser,
                          time: time,
                          text: text,
                          mediaLabel: m.isVoice == true ? 'voice' : null,
                          translationOn: showTranslation,
                          translationText: translationText,
                          translateLabel: showTranslation
                              ? 'Hide translation'
                              : 'Show translation ($label)',
                          canTranslate: canTranslate,
                          isTranslating: isTranslating,
                          onSpeak: () => _speak(text),
                          onToggleTranslate: canTranslate
                              ? () => cubit.toggleMessageTranslation(m.id)
                              : null,
                        );
                      } else {
                        // Local ephemeral (voice or streaming)
                        final m = item.local!;
                        final isUser = m.fromUser;
                        final time = m.time;
                        final text = m.text;

                        return _Bubble(
                          fromUser: isUser,
                          time: time,
                          text: text.isEmpty ? '…' : text,
                          mediaLabel: m.mediaLabel,
                          // Streaming translation UI is OFF by default; voice never translates
                          translationOn: m.showTranslation,
                          translationText: m.translationText,
                          canTranslate: false,
                          isTranslating: false,
                          onSpeak: () => _speak(text),
                          onToggleTranslate: null,
                          voiceWav: m.voiceWav,
                          voiceDuration: m.voiceDuration,
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8.sSp, 0, 8.sSp, 8.sSp),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.sSp),
                          height: 56.sSp,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.sSp),
                            border: Border.all(
                              color: AppColor.gray400,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textCtrl,
                                  focusNode: _focusNode,
                                  minLines: 1,
                                  maxLines: 4,
                                  style: t.title18Inter,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText: 'Message…',
                                    hintStyle: t.title18Inter.copyWith(
                                      color: AppColor.gray400,
                                    ),
                                  ),
                                  onSubmitted: (_) => _sendText(),
                                  textInputAction: TextInputAction.send,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up_rounded),
                                color: AppColor.gray900,
                                onPressed: () => _speak(_textCtrl.text),
                                tooltip: 'Speak text (with translation)',
                              ),
                              IconButton(
                                icon: const Icon(Icons.send_rounded),
                                color: AppColor.gray900,
                                onPressed: _isSending ? null : _sendText,
                                tooltip: 'Send',
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.sSp),
                      Tooltip(
                        message: _isRecording
                            ? 'Tap to stop & send'
                            : 'Tap or hold to record',
                        child: GestureDetector(
                          onLongPressStart: (_) => _startRecording(),
                          onLongPressEnd: (_) => _stopRecordingAndSend(),
                          onTap: () => _isRecording
                              ? _stopRecordingAndSend()
                              : _startRecording(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56.sSp,
                            height: 56.sSp,
                            decoration: BoxDecoration(
                              color: _isRecording
                                  ? AppColor.gray900
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: AppColor.gray900,
                                width: 2,
                              ),
                              boxShadow: _isRecording
                                  ? [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(.25),
                                        blurRadius: 18,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              _isRecording
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              color: _isRecording
                                  ? Colors.white
                                  : AppColor.gray900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _copyTranscript(ChatState state) async {
    final b = StringBuffer();

    // Persisted messages only (DB history)
    for (final m in state.messages) {
      final who = m.role == 'user'
          ? (widget.userName ?? 'You')
          : (widget.artwork?.name ?? widget.botName);
      final tod = TimeOfDay.fromDateTime(m.createdAt).format(context);
      b.writeln('**$who** ($tod):');
      b.writeln(m.content);
      if (m.isVoice == true && m.voiceDurationS != null) {
        final dur = Duration(seconds: m.voiceDurationS!);
        b.writeln('[Voice note ${_formatDuration(dur)}]');
      }
      if (m.showTranslation && (m.translationText ?? '').isNotEmpty) {
        b.writeln(
          '[Translation ${m.translationLang ?? ''}]: ${m.translationText}',
        );
      }
      b.writeln();
    }

    // Include ephemeral local voice notes if any (recent, not in DB)
    for (final e in _ephemeralLocal) {
      final who = widget.userName ?? 'You';
      final tod = TimeOfDay.fromDateTime(e.time).format(context);
      b.writeln('**$who** ($tod):');
      b.writeln(e.text);
      if (e.voiceWav != null) {
        b.writeln(
          '[Voice note ${_formatDuration(e.voiceDuration ?? Duration.zero)}]',
        );
      }
      b.writeln();
    }

    await Clipboard.setData(ClipboardData(text: b.toString()));
    _showSnack('Transcript copied to clipboard');
  }

  Future<void> _confirmClear() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Clear conversation?'),
        content: const Text(
          'This removes all messages in this chat (local view).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (yes != true) return;

    // Clears local view only; your repository retains history unless you add a delete endpoint.
    setState(() {
      _history.clear();
      _ephemeralLocal.clear();
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ======================= Render item helper =======================
class _RenderItem {
  final MessageRecord? persisted;
  final ChatEntry? local;

  bool get isPersisted => persisted != null;

  _RenderItem.persisted(this.persisted) : local = null;
  _RenderItem.local(this.local) : persisted = null;
}

// ======================= Message Bubble =======================
class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.fromUser,
    required this.time,
    required this.text,
    required this.onSpeak,
    this.mediaLabel,
    this.translationOn = false,
    this.translationText,
    this.translateLabel,
    this.canTranslate = false,
    this.isTranslating = false,
    this.onToggleTranslate,
    this.voiceWav,
    this.voiceDuration,
  });

  final bool fromUser;
  final DateTime time;
  final String text;
  final VoidCallback onSpeak;

  final String? mediaLabel; // 'voice' or null

  final bool translationOn;
  final String? translationText;
  final String? translateLabel;
  final bool canTranslate;
  final bool isTranslating;
  final VoidCallback? onToggleTranslate;

  // Local-only voice playback
  final Uint8List? voiceWav;
  final Duration? voiceDuration;

  @override
  Widget build(BuildContext context) {
    final t = TextStyleHelper.instance;

    final bg = fromUser ? AppColor.gray900 : const Color(0xFFF0F2F5);
    final fg = fromUser ? Colors.white : AppColor.gray900;

    final radius = fromUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    final timeStr = TimeOfDay.fromDateTime(time).format(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.sSp, horizontal: 8.sSp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: fromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!fromUser)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppColor.gray900,
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          Flexible(
            child: Tooltip(
              message: timeStr,
              waitDuration: const Duration(milliseconds: 600),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 8.sSp,
                  horizontal: 12.sSp,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: radius,
                  border: Border.all(
                    color: fromUser ? bg : const Color(0xFFE3E5E8),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: fromUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (mediaLabel != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.sSp),
                        child: Text(
                          mediaLabel!,
                          style: t.body14MediumInter.copyWith(
                            color: fg.withOpacity(.8),
                          ),
                        ),
                      ),

                    // Local-only audio player (for just-recorded bubbles)
                    if (voiceWav != null)
                      _VoicePlayer(
                        bytes: voiceWav!,
                        tint: fg,
                        accent: fromUser
                            ? Colors.white24
                            : const Color(0xFFE3E5E8),
                        initialDuration: voiceDuration,
                        denseTextStyle: t.body14MediumInter.copyWith(
                          color: fg.withOpacity(.9),
                        ),
                      ),

                    if (text.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          top: voiceWav != null ? 8.sSp : 0,
                        ),
                        child: SelectableText(
                          text,
                          style: t.title18Inter.copyWith(color: fg),
                        ),
                      ),

                    // Translation block
                    if (translationOn && (translationText ?? '').isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 8.sSp),
                        padding: EdgeInsets.symmetric(
                          vertical: 8.sSp,
                          horizontal: 10.sSp,
                        ),
                        decoration: BoxDecoration(
                          color: fromUser
                              ? Colors.white12
                              : const Color(0xFFEDEFF2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.translate_rounded, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SelectableText(
                                translationText!,
                                style: t.body14MediumInter.copyWith(
                                  color: fg.withOpacity(.95),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Actions
                    Padding(
                      padding: EdgeInsets.only(top: 6.sSp),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            onPressed: onSpeak,
                            icon: Icon(Icons.volume_up_rounded, color: fg),
                            tooltip: 'Speak (with translation)',
                          ),
                          const SizedBox(width: 10),
                          if (onToggleTranslate != null)
                            IconButton(
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              onPressed: isTranslating
                                  ? null
                                  : onToggleTranslate,
                              icon: isTranslating
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(fg),
                                      ),
                                    )
                                  : Icon(
                                      translationOn
                                          ? Icons.g_translate_rounded
                                          : Icons.translate_rounded,
                                      color: fg,
                                    ),
                              tooltip: translateLabel ?? 'Show translation',
                            ),
                          const SizedBox(width: 10),
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied')),
                              );
                            },
                            icon: Icon(Icons.copy_rounded, color: fg),
                            tooltip: 'Copy',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= Compact audio player (local-only, web-safe) =======================
class _VoicePlayer extends StatefulWidget {
  const _VoicePlayer({
    required this.bytes,
    required this.tint,
    required this.accent,
    this.initialDuration,
    this.denseTextStyle,
  });

  final Uint8List bytes;
  final Color tint;
  final Color accent;
  final Duration? initialDuration;
  final TextStyle? denseTextStyle;

  @override
  State<_VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<_VoicePlayer> {
  late final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _state = PlayerState.stopped;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _player.setSource(BytesSource(widget.bytes));
    _duration = widget.initialDuration ?? Duration.zero;

    _player.onPlayerStateChanged.listen((s) {
      setState(() => _state = s);
    });
    _player.onDurationChanged.listen((d) {
      if (d.inMilliseconds > 0) {
        setState(() => _duration = d);
      }
    });
    _player.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });
    setState(() => _ready = true);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _state == PlayerState.playing;
    final canSeek = _duration.inMilliseconds > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.accent, width: 1),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: !_ready
                ? null
                : () async {
                    if (isPlaying) {
                      await _player.pause();
                    } else {
                      await _player.resume();
                    }
                  },
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: widget.tint,
            ),
            tooltip: isPlaying ? 'Pause' : 'Play',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: canSeek
                    ? _position.inMilliseconds
                          .clamp(0, _duration.inMilliseconds)
                          .toDouble()
                    : 0,
                min: 0,
                max: canSeek ? _duration.inMilliseconds.toDouble() : 1,
                onChanged: !_ready || !canSeek
                    ? null
                    : (v) => _player.seek(Duration(milliseconds: v.round())),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_fmt(_position)} / ${_fmt(_duration)}',
            style: widget.denseTextStyle,
          ),
        ],
      ),
    );
  }
}

// ======================= Recording banner =======================
class _RecordingBanner extends StatefulWidget {
  const _RecordingBanner({super.key});

  @override
  State<_RecordingBanner> createState() => _RecordingBannerState();
}

class _RecordingBannerState extends State<_RecordingBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TextStyleHelper.instance;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.sSp, vertical: 6.sSp),
      child: Row(
        children: [
          SizeTransition(
            sizeFactor: CurvedAnimation(parent: _c, curve: Curves.easeInOut),
            axis: Axis.horizontal,
            axisAlignment: -1.0,
            child: Container(
              width: 12.sSp,
              height: 12.sSp,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 8.sSp),
          Text('Recording… hold to stop', style: t.body14MediumInter),
        ],
      ),
    );
  }
}
