import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/modules/profile/presentation/cubit/favorites_cubit.dart';
import 'package:baseqat/modules/profile/presentation/cubit/favorites_state.dart';
import 'package:baseqat/modules/profile/data/models/favorite_item.dart';

import '../../../events/data/models/fav_extension.dart';

class LikesTabWidget extends StatelessWidget {
  const LikesTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        switch (state.status) {
          case FavoritesStatus.loading:
            return const Center(
              child: CircularProgressIndicator(),
            );

          case FavoritesStatus.error:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sSp,
                    color: AppColor.gray400,
                  ),
                  SizedBox(height: 16.sH),
                  Text(
                    'Error loading favorites',
                    style: TextStyleHelper.instance.title16BoldInter.copyWith(
                      color: AppColor.gray700,
                    ),
                  ),
                  if (state.error != null) ...[
                    SizedBox(height: 8.sH),
                    Text(
                      state.error!,
                      style: TextStyleHelper.instance.body12LightInter.copyWith(
                        color: AppColor.gray400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 16.sH),
                  ElevatedButton(
                    onPressed: () => context.read<FavoritesCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );

          case FavoritesStatus.success:
            if (state.items.isEmpty) {
              return _buildNoFavoritesView();
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 16.sH),
              child: Column(
                children: state.items.map((item) => _buildLikedItem(context, item, state)).toList(),
              ),
            );

          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildLikedItem(BuildContext context, FavoriteItem item, FavoritesState state) {
    final isRemoving = state.removingKeys.contains('${item.entityKind}::${item.entityId}');

    return Container(
      margin: EdgeInsets.only(bottom: 16.sH),
      padding: EdgeInsets.all(16.sW),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.sW),
        border: Border.all(color: AppColor.gray400.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          Container(
            width: 80.sW,
            height: 80.sW,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.sW),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.sW),
              child: item.imageUrl != null
                  ? Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColor.gray400.withOpacity(0.3),
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColor.gray400,
                      size: 24.sSp,
                    ),
                  );
                },
              )
                  : Container(
                color: AppColor.gray400.withOpacity(0.3),
                child: Icon(
                  Icons.image,
                  color: AppColor.gray400,
                  size: 24.sSp,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.sW),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? 'Untitled',
                  style: TextStyleHelper.instance.title16BoldInter.copyWith(
                    color: AppColor.black,
                  ),
                ),

                SizedBox(height: 8.sH),

                Text(
                  item.description ?? 'No description available',
                  style: TextStyleHelper.instance.body12LightInter.copyWith(
                    color: AppColor.gray700,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8.sH),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.sW, vertical: 4.sH),
                  decoration: BoxDecoration(
                    color: AppColor.gray400.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.sW),
                  ),
                  child: Text(
                    item.entityKind.toUpperCase(),
                    style: TextStyleHelper.instance.body12LightInter.copyWith(
                      color: AppColor.gray700,
                      fontSize: 10.sSp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: isRemoving ? null : () async {
              // Parse entityKind from string to EntityKind enum
              final entityKind = _parseEntityKind(item.entityKind);
              if (entityKind != null) {
                await context.read<FavoritesCubit>().remove(
                  kind: entityKind,
                  entityId: item.entityId,
                );
              }
            },
            child: Container(
              width: 30.sW,
              height: 30.sW,
              decoration: BoxDecoration(
                  color: isRemoving ? AppColor.white.withOpacity(0.5) : AppColor.white,
                  shape: BoxShape.circle,
                  border:Border.all(color: Colors.black)
              ),
              child: isRemoving
                  ? SizedBox(
                width: 16.sSp,
                height: 16.sSp,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.white),
                ),
              )
                  : Icon(
                Icons.favorite,
                color: AppColor.red,
                size: 25.sSp,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildNoFavoritesView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.sW),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_outlined,
              size: 70.sSp,
              color: AppColor.gray400,
            ),
            SizedBox(height: 15.sH),
            Text(
              'No favorites yet',
              style: TextStyleHelper.instance.title18BoldInter.copyWith(
                color: AppColor.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.sH),
            Text(
              'Start exploring and add items to your favorites',
              style: TextStyleHelper.instance.title14MediumInter.copyWith(
                color: AppColor.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  EntityKind? _parseEntityKind(String entityKindString) {
    switch (entityKindString.toLowerCase()) {
      case 'artist':
        return EntityKind.artist;
      case 'artwork':
        return EntityKind.artwork;
      case 'speaker':
        return EntityKind.speaker;
      default:
        return null;
    }
  }
}
