import 'package:baseqat/core/components/custom_widgets/cached_network_image_widget.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum ArtworkCardViewType { list, grid }

class ArtWorkCardWidget extends StatelessWidget {
  const ArtWorkCardWidget({
    super.key,
    required this.artwork,
    required this.languageCode,
    this.onTap,
    this.viewType = ArtworkCardViewType.list,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.userId,
  });

  final Artwork artwork;
  final VoidCallback? onTap;
  final ArtworkCardViewType viewType;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final String? userId;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final spacingLarge = ProgramsLayout.spacingLarge(context);
    final spacingSmall = ProgramsLayout.spacingSmall(context);
    final radius = ProgramsLayout.radius20(context);
    final description = artwork.localizedDescription(
      languageCode: languageCode,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColor.blueGray100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ArtworkImage(url: _coverImage(artwork)),
              Padding(
                padding: EdgeInsets.all(spacingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artwork.localizedName(languageCode: languageCode),
                      style: ProgramsTypography.headingMedium(
                        context,
                      ).copyWith(color: AppColor.black),
                    ),
                    SizedBox(height: spacingSmall),
                    if (description?.isNotEmpty ?? false)
                      Text(
                        description!,
                        maxLines: viewType == ArtworkCardViewType.grid ? 3 : 4,
                        overflow: TextOverflow.ellipsis,
                        style: ProgramsTypography.bodySecondary(
                          context,
                        ).copyWith(color: AppColor.gray600),
                      ),
                    SizedBox(height: spacingLarge),
                    _ArtistInfo(artwork: artwork, languageCode: languageCode),
                    SizedBox(height: spacingSmall),
                    if (onFavoriteTap != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          tooltip: isFavorite
                              ? 'programs.actions.remove_favourite'.tr()
                              : 'programs.actions.mark_favourite'.tr(),
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? AppColor.primaryColor
                                : AppColor.gray400,
                          ),
                          onPressed: onFavoriteTap,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _coverImage(Artwork artwork) =>
      artwork.gallery.isNotEmpty ? artwork.gallery.first : null;
}

class _ArtworkImage extends StatelessWidget {
  const _ArtworkImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final height = ProgramsLayout.size(context, 180);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(ProgramsLayout.radius20(context)),
        topRight: Radius.circular(ProgramsLayout.radius20(context)),
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: url?.isNotEmpty ?? false
            ? OfflineCachedImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          placeholder: _placeholder(context),
          errorWidget: _placeholder(context),
        )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => ColoredBox(
    color: AppColor.gray100,
    child: Center(
      child: Icon(
        Icons.brush_rounded,
        color: AppColor.gray400,
        size: ProgramsLayout.size(context, 40),
      ),
    ),
  );
}

class _ArtistInfo extends StatelessWidget {
  const _ArtistInfo({required this.artwork, required this.languageCode});

  final Artwork artwork;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    if (artwork.artistName == null && artwork.artistProfileImage == null) {
      return const SizedBox.shrink();
    }

    final spacingSmall = ProgramsLayout.spacingSmall(context);
    final radius = ProgramsLayout.radius16(context);
    final artistName =
        artwork.localizedArtistName(languageCode: languageCode) ??
            'programs.artwork_card.unknown_artist'.tr();
    final materials = artwork.localizedMaterials(languageCode: languageCode);

    return Row(
      children: [
        if (artwork.artistProfileImage?.isNotEmpty ?? false)
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: OfflineCachedImage(
              imageUrl: artwork.artistProfileImage!,
              width: ProgramsLayout.size(context, 44),
              height: ProgramsLayout.size(context, 44),
              fit: BoxFit.cover,
              errorWidget: _artistPlaceholder(context),
            ),
          )
        else
          _artistPlaceholder(context),
        SizedBox(width: spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                artistName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ProgramsTypography.bodyPrimary(
                  context,
                ).copyWith(color: AppColor.black, fontWeight: FontWeight.w600),
              ),
              if (materials?.isNotEmpty ?? false)
                Text(
                  materials!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ProgramsTypography.bodySecondary(
                    context,
                  ).copyWith(color: AppColor.gray500),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _artistPlaceholder(BuildContext context) => Container(
    width: ProgramsLayout.size(context, 44),
    height: ProgramsLayout.size(context, 44),
    decoration: BoxDecoration(
      color: AppColor.gray100,
      borderRadius: BorderRadius.circular(ProgramsLayout.radius16(context)),
    ),
    child: Icon(
      Icons.person_outline_rounded,
      size: ProgramsLayout.size(context, 24),
      color: AppColor.gray400,
    ),
  );
}
