// ===================== ArtistCardWidget (with real flags via 'flag' package) =====================
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

// NEW: flag package
import 'package:flag/flag.dart';

enum ArtistCardViewType { list, grid }

class ArtistCardWidget extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;
  final ArtistCardViewType viewType;

  /// favorites plumbing (not shown in UI, kept for future)
  final String userId;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const ArtistCardWidget({
    super.key,
    required this.artist,
    required this.userId,
    this.onTap,
    this.viewType = ArtistCardViewType.list,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: 'Artist card: ${artist.name}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.h),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopImage(profileImage: artist.profileImage),
                SizedBox(height: 10.h),
                _TitleRow(name: artist.name, country: artist.country),
                SizedBox(height: 8.h),
                if (artist.about?.isNotEmpty == true)
                  Text(
                    artist.about!,
                    style: TextStyleHelper.instance.body12LightInter.copyWith(
                      color: AppColor.gray600,
                      height: 1.45,
                    ),
                    maxLines: viewType == ArtistCardViewType.grid ? 4 : 5,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- Pieces --------------------

class _TopImage extends StatelessWidget {
  final String? profileImage;
  const _TopImage({required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.h),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: AppColor.gray100,
          child: (profileImage?.isNotEmpty == true)
              ? Image.network(
                  profileImage!,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() => Center(
        child: Icon(Icons.person_rounded, size: 44.h, color: AppColor.gray400),
      );
}

class _TitleRow extends StatelessWidget {
  final String name;
  final String? country;
  const _TitleRow({required this.name, required this.country});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Name (left)
        Expanded(
          child: Text(
            name,
            style: TextStyleHelper.instance.title16BoldInter
                .copyWith(color: AppColor.black),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Country (right): rectangular flag + country text
        if (country?.isNotEmpty == true) ...[
          SizedBox(width: 8.h),
          _CountryBadge(countryName: country!),
        ],
      ],
    );
  }
}

class _CountryBadge extends StatelessWidget {
  final String countryName;
  const _CountryBadge({required this.countryName});

  @override
  Widget build(BuildContext context) {
    final code = _iso2FromCountryName(countryName); // e.g., 'sa'
    if (code == null) {
      // Fallback – show just the text if we can’t map the name
      return Text(
        countryName,
        style: TextStyle(
          fontSize: 12.fSize,
          color: AppColor.gray600,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rounded-rect flag (exact look from the photo)
        ClipRRect(
          borderRadius: BorderRadius.circular(3.h),
          child: Flag.fromString(
            code,
            height: 14.h,
            width: 20.h,
            fit: BoxFit.fill,
          ),
        ),
        SizedBox(width: 6.h),
        Text(
          countryName,
          style: TextStyle(
            fontSize: 12.fSize,
            color: AppColor.gray600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Minimal, robust name → ISO-3166 alpha-2 mapping.
  /// Add more as your dataset grows; unknowns fall back to text only.
  static String? _iso2FromCountryName(String name) {
    final n = name.trim().toLowerCase();

    const map = {
      // MENA focus (matches screenshots)
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

      // Common fallbacks
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
      // add as needed…
    };

    return map[n];
  }
}
