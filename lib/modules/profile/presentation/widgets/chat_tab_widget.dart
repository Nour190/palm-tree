import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/modules/profile/presentation/cubit/conversations_cubit.dart';
import 'package:intl/intl.dart';
import 'package:baseqat/core/services_locator/dependency_injection.dart';

import '../../../artwork_details/data/models/conversation_models.dart';

class ChatTabWidget extends StatelessWidget {
  final String userId;

  const ChatTabWidget({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ConversationsCubit>()..loadFirst(userId: userId),
      child: BlocBuilder<ConversationsCubit, ConversationsState>(
        builder: (context, state) {
          if (state.status == ConversationsStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == ConversationsStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading conversations',
                    style: TextStyleHelper.instance.body14RegularInter.copyWith(
                      color: AppColor.red,
                    ),
                  ),
                  SizedBox(height: 8.sH),
                  ElevatedButton(
                    onPressed: () => context.read<ConversationsCubit>().refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.items.isEmpty) {
            return Center(
              child: Text(
                'No conversations yet',
                style: TextStyleHelper.instance.body14RegularInter.copyWith(
                  color: AppColor.gray700,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ConversationsCubit>().refresh(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 16.sH),
              child: Column(
                children: [
                  ...state.items.map((conversation) => _buildChatItem(conversation)),
                  if (state.hasMore)
                    Padding(
                      padding: EdgeInsets.all(16.sH),
                      child: state.isLoadingMore
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: () => context.read<ConversationsCubit>().loadMore(),
                        child: const Text('Load More'),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatItem(ConversationRecord conversation) {
    final lastMessageTime = conversation.lastMessageAt != null
        ? DateFormat('hh:mm a').format(conversation.lastMessageAt!)
        : DateFormat('hh:mm a').format(conversation.startedAt);

    return Container(
      margin: EdgeInsets.only(bottom: 1.sH),
      padding: EdgeInsets.symmetric(vertical: 16.sH, horizontal: 16.sW),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border(
          bottom: BorderSide(color: AppColor.gray400.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60.sW,
            height: 60.sW,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: conversation.artworkGallery.isNotEmpty
                  ? Image.network(
                conversation.artworkGallery.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset(AppAssetsManager.imgRectangle1, fit: BoxFit.cover),
              )
                  : Image.asset(AppAssetsManager.imgRectangle1, fit: BoxFit.cover),
            ),
          ),

          SizedBox(width: 12.sW),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.artworkName ?? 'Untitled Artwork',
                  style: TextStyleHelper.instance.title16BoldInter.copyWith(
                    color: AppColor.black,
                  ),
                ),

                SizedBox(height: 4.sH),

                Text(
                  conversation.sessionLabel ??
                      (conversation.messageCount > 0
                          ? '${conversation.messageCount} messages'
                          : 'Start a conversation...'),
                  style: TextStyleHelper.instance.body12LightInter.copyWith(
                    color: AppColor.gray700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                lastMessageTime,
                style: TextStyleHelper.instance.body12LightInter.copyWith(
                  color: AppColor.gray400,
                ),
              ),
              if (conversation.isActive == true)
                Container(
                  margin: EdgeInsets.only(top: 4.sH),
                  width: 8.sW,
                  height: 8.sW,
                  decoration: BoxDecoration(
                    color: AppColor.green,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
