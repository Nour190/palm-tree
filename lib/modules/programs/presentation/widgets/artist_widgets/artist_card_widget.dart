import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum ArtistCardViewType { list, grid }

class ArtistCardWidget extends StatelessWidget {
  const ArtistCardWidget({
    super.key,
    required this.artist,
    required this.userId,
    required this.languageCode,
    this.onTap,
    this.viewType = ArtistCardViewType.list,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final Artist artist;
  final VoidCallback? onTap;
  final ArtistCardViewType viewType;
  final String userId;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final spacingSmall = ProgramsLayout.spacingSmall(context);
    final spacingMedium = ProgramsLayout.spacingMedium(context);
    final localizedName = artist.localizedName(languageCode: languageCode);
    final localizedAbout = artist.localizedAbout(languageCode: languageCode);
    final localizedCountry = artist.localizedCountry(
      languageCode: languageCode,
    );

    return Semantics(
      button: onTap != null,
      label: 'programs.artist_card.semantics'.tr(args: [localizedName]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ProgramsLayout.radius20(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopImage(profileImage: artist.profileImage),
              SizedBox(height: spacingSmall),
              _TitleRow(name: localizedName, country: localizedCountry),
              SizedBox(height: spacingSmall),
              if (localizedAbout?.isNotEmpty ?? false)
                Text(
                  localizedAbout!,
                  style: ProgramsTypography.bodySecondary(
                    context,
                  ).copyWith(color: AppColor.gray600, height: 1.45),
                  maxLines: viewType == ArtistCardViewType.grid ? 4 : 5,
                  overflow: TextOverflow.ellipsis,
                ),
              if (onFavoriteTap != null) ...[
                SizedBox(height: spacingMedium),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite
                          ? AppColor.primaryColor
                          : AppColor.gray400,
                    ),
                    onPressed: onFavoriteTap,
                    tooltip: isFavorite
                        ? 'programs.actions.remove_from_favourites'.tr()
                        : 'programs.actions.add_to_favourites'.tr(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopImage extends StatelessWidget {
  const _TopImage({required this.profileImage});

  final String? profileImage;

  @override
  Widget build(BuildContext context) {
    final radius = ProgramsLayout.radius20(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: AppColor.gray100,
          child: profileImage?.isNotEmpty == true
              ? Image.network(
                  profileImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(context),
                )
              : _placeholder(context),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Center(
    child: Icon(
      Icons.person_rounded,
      size: ProgramsLayout.size(context, 48),
      color: AppColor.gray400,
    ),
  );
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.name, required this.country});

  final String name;
  final String? country;

  @override
  Widget build(BuildContext context) {
    final spacingSmall = ProgramsLayout.spacingSmall(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ProgramsTypography.headingMedium(
              context,
            ).copyWith(color: AppColor.black),
          ),
        ),
        if (country?.isNotEmpty ?? false) ...[
          SizedBox(width: spacingSmall),
          _CountryBadge(countryName: country!),
        ],
      ],
    );
  }
}

class _CountryBadge extends StatelessWidget {
  const _CountryBadge({required this.countryName});

  final String countryName;

  @override
  Widget build(BuildContext context) {
    final code = _iso2FromCountryName(countryName);
    final textStyle = ProgramsTypography.labelSmall(
      context,
    ).copyWith(color: AppColor.gray600);

    if (code == null) {
      return Text(countryName, style: textStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(ProgramsLayout.size(context, 3)),
          child: Flag.fromString(
            code,
            height: ProgramsLayout.size(context, 16),
            width: ProgramsLayout.size(context, 24),
            fit: BoxFit.fill,
          ),
        ),
        SizedBox(width: ProgramsLayout.spacingSmall(context)),
        Text(countryName, style: textStyle),
      ],
    );
  }

  static String? _iso2FromCountryName(String name) {
    final lookup = name.trim().toLowerCase();
    const map = {
      'saudi arabia': 'sa',
      'egypt': 'eg',
      'united arab emirates': 'ae',
      'qatar': 'qa',
      'kuwait': 'kw',
      'bahrain': 'bh',
      'oman': 'om',
      'jordan': 'jo',
      'lebanon': 'lb',
      'morocco': 'ma',
      'algeria': 'dz',
      'tunisia': 'tn',
      'iraq': 'iq',
      'syria': 'sy',
      'palestine': 'ps',
      'yemen': 'ye',
      'turkey': 'tr',
      'united states': 'us',
      'usa': 'us',
      'united kingdom': 'gb',
      'uk': 'gb',
      'canada': 'ca',
      'france': 'fr',
      'germany': 'de',
      'italy': 'it',
      'spain': 'es',
      'portugal': 'pt',
      'netherlands': 'nl',
      'belgium': 'be',
      'switzerland': 'ch',
      'austria': 'at',
      'sweden': 'se',
      'norway': 'no',
      'denmark': 'dk',
      'finland': 'fi',
      'ireland': 'ie',
      'greece': 'gr',
      'russia': 'ru',
      'china': 'cn',
      'japan': 'jp',
      'south korea': 'kr',
      'india': 'in',
      'pakistan': 'pk',
      'bangladesh': 'bd',
      'indonesia': 'id',
      'malaysia': 'my',
      'singapore': 'sg',
      'philippines': 'ph',
      'thailand': 'th',
      'vietnam': 'vn',
      'australia': 'au',
      'new zealand': 'nz',
      'mexico': 'mx',
      'brazil': 'br',
      'argentina': 'ar',
      'south africa': 'za',
      'nigeria': 'ng',
      'kenya': 'ke',
      'ethiopia': 'et',
      'ghana': 'gh',
    };

    return map[lookup];
  }
}
