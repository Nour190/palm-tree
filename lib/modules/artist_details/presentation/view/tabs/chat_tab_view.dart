import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

/// Public, lightweight message descriptor (no extra VM classes needed).
enum ChatKind { meText, aiText, meImage, meVoice }

class ChatEntry {
  final ChatKind kind;
  final String? text;
  final String? imageUrl; // for meImage
  final bool tailOnLeft; // optional stylistic flag for AI bubbles

  const ChatEntry._(
    this.kind, {
    this.text,
    this.imageUrl,
    this.tailOnLeft = false,
  });

  const ChatEntry.meText(String text) : this._(ChatKind.meText, text: text);
  const ChatEntry.aiText(String text, {bool tailOnLeft = false})
    : this._(ChatKind.aiText, text: text, tailOnLeft: tailOnLeft);
  const ChatEntry.meImage(String? imageUrl)
    : this._(ChatKind.meImage, imageUrl: imageUrl);
  const ChatEntry.meVoice() : this._(ChatKind.meVoice);
}

class AIChatView extends StatefulWidget {
  const AIChatView({
    super.key,
    this.botName = 'ithra Ai',
    this.botAvatarIcon = Icons.smart_toy_outlined,
    this.initialMessages = const [],
    this.onSendText,
    this.onTapMic,
    this.onTapAdd,
  });

  /// Header name/icon
  final String botName;
  final IconData botAvatarIcon;

  /// Seed conversation
  final List<ChatEntry> initialMessages;

  /// Callbacks
  final ValueChanged<String>? onSendText;
  final VoidCallback? onTapMic;
  final VoidCallback? onTapAdd;

  @override
  State<AIChatView> createState() => _AIChatViewState();
}

class _AIChatViewState extends State<AIChatView> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late final List<ChatEntry> _items = List.of(widget.initialMessages);

  bool get _isDesktop => SizeUtils.width >= 1200;
  bool get _isTablet => SizeUtils.width >= 840 && SizeUtils.width < 1200;

  double get _bubbleMaxWidthFactor =>
      _isDesktop ? 0.55 : (_isTablet ? 0.65 : 0.8);

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = TextStyleHelper.instance;

    return RepaintBoundary(
      child: SingleChildScrollView(
        controller: _scrollCtrl,
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Header =====
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColor.gray400, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60.h,
                    height: 60.h,
                    decoration: const BoxDecoration(
                      color: AppColor.blueGray100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.botAvatarIcon,
                      size: 32.h,
                      color: AppColor.gray900,
                    ),
                  ),
                  SizedBox(width: 12.h),
                  Expanded(
                    child: Text(
                      widget.botName,
                      style: s.headline24MediumInter.copyWith(
                        color: AppColor.gray900,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Icon(Icons.more_vert, color: AppColor.gray900, size: 24.h),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // ===== Messages =====
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                _items.length,
                (i) => _buildChatItem(_items[i]),
              ),
            ),

            SizedBox(height: 12.h),

            // ===== Typing indicator (decorative) =====
            Row(
              children: [
                _dot(12.h),
                SizedBox(width: 8.h),
                _dot(16.h),
                SizedBox(width: 8.h),
                _dot(24.h),
              ],
            ),

            SizedBox(height: 16.h),

            // ===== Composer =====
            _ComposerBar(
              controller: _inputCtrl,
              onSend: _handleSend,
              onMic: widget.onTapMic,
              onAdd: widget.onTapAdd,
            ),
          ],
        ),
      ),
    );
  }

  // One bubble. Kept small and fast.
  Widget _buildChatItem(ChatEntry item) {
    final maxWidth = (SizeUtils.width * _bubbleMaxWidthFactor).clamp(
      280.h,
      560.h,
    );
    final s = TextStyleHelper.instance;

    switch (item.kind) {
      case ChatKind.meText:
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            margin: EdgeInsets.symmetric(vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColor.gray900,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.h),
                topRight: Radius.circular(20.h),
                bottomLeft: Radius.circular(20.h),
                bottomRight: Radius.circular(0.h),
              ),
            ),
            child: Text(
              item.text ?? '',
              style: s.headline24MediumInter.copyWith(
                color: AppColor.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );

      case ChatKind.aiText:
        final tailOnLeft = item.tailOnLeft;
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            margin: EdgeInsets.symmetric(vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColor.blueGray100,
              borderRadius: tailOnLeft
                  ? BorderRadius.only(
                      topLeft: Radius.circular(20.h),
                      topRight: Radius.circular(20.h),
                      bottomRight: Radius.circular(20.h),
                      bottomLeft: Radius.circular(0.h),
                    )
                  : BorderRadius.circular(20.h),
            ),
            child: Text(
              item.text ?? '',
              style: s.headline24MediumInter.copyWith(
                color: AppColor.gray900,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );

      case ChatKind.meImage:
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 351.h,
            height: 191.h,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColor.gray900,
              borderRadius: BorderRadius.circular(20.h),
            ),
            padding: EdgeInsets.all(3.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.h),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColor.backgroundGray,
                  border: Border.all(color: AppColor.gray900, width: 1),
                  borderRadius: BorderRadius.circular(16.h),
                ),
                child: _buildImage(item.imageUrl),
              ),
            ),
          ),
        );

      case ChatKind.meVoice:
        return Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                margin: EdgeInsets.symmetric(vertical: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColor.gray900,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.h),
                    topRight: Radius.circular(20.h),
                    bottomLeft: Radius.circular(20.h),
                    bottomRight: Radius.circular(0.h),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _playButton(),
                    SizedBox(width: 16.h),
                    _waveformBars(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 8.h),
                child: Text(
                  '✏️ Message',
                  style: s.title16RegularInter.copyWith(
                    color: AppColor.white,
                    fontWeight: FontWeight.w300,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildImage(String? urlOrAsset) {
    if (urlOrAsset == null || urlOrAsset.isEmpty) {
      return Center(
        child: Icon(Icons.image, size: 48.h, color: AppColor.gray900),
      );
    }
    if (urlOrAsset.startsWith('http')) {
      return Image.network(
        urlOrAsset,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        frameBuilder: (_, child, frame, wasSync) => AnimatedOpacity(
          opacity: wasSync || frame != null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: child,
        ),
        errorBuilder: (_, __, ___) => Center(
          child: Icon(Icons.broken_image, size: 36.h, color: AppColor.gray900),
        ),
      );
    }
    return Image.asset(
      urlOrAsset,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
    );
  }

  Widget _dot(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xFFd9d9d9).withOpacity(0.69),
      shape: BoxShape.circle,
    ),
  );

  Widget _playButton() => Container(
    width: 40.h,
    height: 40.h,
    decoration: const BoxDecoration(
      color: AppColor.transparent,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Icon(Icons.play_arrow, color: AppColor.white, size: 25.h),
  );

  Widget _waveformBars() {
    final bars = <double>[
      0.5,
      0.5,
      0.5,
      5.3,
      10.1,
      27.2,
      15.9,
      11.2,
      5.6,
      1.7,
      16.2,
      11.4,
      5.7,
      1.4,
      10.6,
      6.3,
      1.4,
      1.4,
      1.4,
      1.4,
      5.5,
      10.6,
      27.2,
      16.8,
      11.3,
      5.4,
      1.5,
      10.6,
      27.2,
      16.8,
      11.3,
      5.4,
      1.5,
      16.2,
      11.3,
      5.8,
      1.4,
      10.8,
      6.2,
      1.7,
    ];
    return SizedBox(
      height: 40.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final h in bars) ...[
            Container(width: 2.2.h, height: (h).h, color: AppColor.white),
            SizedBox(width: 1.h),
          ],
        ],
      ),
    );
  }

  void _handleSend() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _items.add(ChatEntry.meText(text));
      _inputCtrl.clear();
    });

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    // Bubble the message up if needed
    widget.onSendText?.call(text);
  }
}

/* =============================
   Composer Bar
   ============================= */

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.onSend,
    this.onMic,
    this.onAdd,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onMic;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final s = TextStyleHelper.instance;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 64.h,
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.gray400, width: 2.h),
              borderRadius: BorderRadius.circular(24.h),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Icon(
                    Icons.emoji_emotions_outlined,
                    color: AppColor.gray900,
                    size: 32.h,
                  ),
                ),
                SizedBox(width: 16.h),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: s.title16RegularInter.copyWith(
                      color: AppColor.gray900,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Message...',
                      hintStyle: s.headline24MediumInter.copyWith(
                        color: AppColor.gray400,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                SizedBox(width: 16.h),
                IconButton(
                  onPressed: onMic,
                  icon: Icon(
                    Icons.mic_none,
                    color: AppColor.gray900,
                    size: 24.h,
                  ),
                  splashRadius: 20.h,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.h),
        SizedBox(
          width: 40.h,
          height: 40.h,
          child: OutlinedButton(
            onPressed: onAdd ?? onSend,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColor.gray900, width: 1),
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              foregroundColor: AppColor.gray900,
            ),
            child: Icon(Icons.add, size: 24.h),
          ),
        ),
      ],
    );
  }
}
