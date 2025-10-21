import 'package:baseqat/core/components/custom_widgets/cached_network_image_widget.dart';
import 'package:baseqat/core/components/custom_widgets/custom_top_bar.dart';
import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/artwork_details_tabs_view.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart' hide DeviceType;
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

import '../../../../core/components/custom_widgets/desktop_top_bar.dart';
import '../../../../core/components/qr_scanner/qr_scanner_screen.dart';
import '../../../../core/resourses/constants_manager.dart';
import '../../../../core/resourses/style_manager.dart';
import '../../../../core/utils/rtl_helper.dart';
import '../../../tabs/presentation/manger/tabs_cubit.dart';
import '../../../tabs/presentation/manger/tabs_states.dart';

class ArtistDetailsView extends StatefulWidget {
  final Artist artist;
  final List<Artwork> artworks;

  const ArtistDetailsView({
    super.key,
    required this.artist,
    required this.artworks,
  });

  @override
  State<ArtistDetailsView> createState() => _ArtistDetailsViewState();
}

class _ArtistDetailsViewState extends State<ArtistDetailsView> {
  @override
  Widget build(BuildContext context) {
    final languageCode = context.locale.languageCode;
    final deviceType = Responsive.deviceTypeOf(context);
    final isMobile = deviceType == DeviceType.mobile;
    void _handleQRScan(BuildContext context) {
      navigateTo(
        context,
        QRScannerScreen(
          onCodeScanned: (String artworkId) {
            Navigator.pop(context);
            navigateTo(
              context,
              ArtWorkDetailsScreen(
                artworkId: artworkId,
                userId: AppConstants.userIdValue ?? "",
              ),
            );
          },
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColor.backgroundWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BlocBuilder<TabsCubit, TabsState>(
              builder: (context, state) {
                final selectedIndex = state is SelectedIndexChanged
                    ? state.selectedIndex
                    : context.read<TabsCubit>().selectedIndex;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    deviceType == DeviceType.desktop
                        ? DesktopTopBar(
                      items: [
                        "navigation.home".tr(),
                        "navigation.programs".tr(),
                        "navigation.virtual_tour".tr(),
                      ],
                      selectedIndex: selectedIndex,
                      onItemTap: (index) {
                        Navigator.of(context).pop();
                        context.read<TabsCubit>().changeSelectedIndex(index);
                      },
                      onLoginTap: () {},
                      showScanButton: true,
                      onScanTap: () => _handleQRScan(context),
                    )
                        : TopBar(
                      items: [
                        "navigation.home".tr(),
                        "navigation.programs".tr(),
                        "navigation.virtual_tour".tr(),
                      ],
                      selectedIndex: selectedIndex,
                      onItemTap: (index) {
                        Navigator.of(context).pop();
                        context.read<TabsCubit>().changeSelectedIndex(index);
                      },
                      onLoginTap: () {},
                      showScanButton: true,
                      onScanTap: () => _handleQRScan(context),
                    ),
                    if (deviceType != DeviceType.desktop)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                      ),
                  ],
                );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(languageCode, isMobile),

                    _buildHeaderImage(isMobile),

                    Padding(
                      padding: EdgeInsets.all(isMobile ? 16.h : 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Artist Info
                          _buildArtistInfo(languageCode, isMobile),

                          SizedBox(height: isMobile ? 20.h : 24.h),

                          // About Artist Section
                          if (widget.artist.localizedAbout(languageCode: languageCode) != null)
                            _buildAboutSection(languageCode, isMobile),

                          SizedBox(height: isMobile ? 24.h : 32.h),

                          // Artworks Section
                          _buildArtworksSection(languageCode, isMobile),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader(String languageCode, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.h),
      decoration: BoxDecoration(color: AppColor.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Iconify(
              RTLHelper.isRTL(context)
                  ? MaterialSymbols.arrow_forward_rounded
                  : MaterialSymbols.arrow_back_rounded,
              color: Colors.black,
              size: 32.sW,
            ),
          ),
          Text(
            widget.artist.localizedName(languageCode: languageCode),
            style:TextStyleHelper.instance.headline24BoldInter,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.h : 24.h,
        vertical: isMobile ? 12.h : 16.h,
      ),
      child: Container(
        height: isMobile ? 250.h : 350.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.backgroundGray,
          borderRadius: BorderRadius.circular(isMobile ? 24.h : 32.h),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 24.h : 32.h),
          child: widget.artist.profileImage != null
              ? OfflineCachedImage(
                  imageUrl: widget.artist.profileImage!,
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Icon(
                    Icons.person_outline,
                    size: isMobile ? 80.h : 120.h,
                    color: AppColor.gray600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildArtistInfo(String languageCode, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.artist.localizedCountry(languageCode: languageCode) !=
                null) ...[
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColor.gray600,
              ),
              SizedBox(width: 4.h),
              Text(
                widget.artist.localizedCountry(languageCode: languageCode)!,
                style: const TextStyle(fontSize: 14, color: AppColor.gray700),
              ),
            ],
            if (widget.artist.age != null) ...[
              if (widget.artist.localizedCountry(languageCode: languageCode) !=
                  null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.h),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColor.gray600,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Text(
                '${'age'.tr()}: ${widget.artist.age}',
                style: const TextStyle(fontSize: 14, color: AppColor.gray700),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection(String languageCode, bool isMobile) {
    final about = widget.artist.localizedAbout(languageCode: languageCode)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'about_artist'.tr(),
          style: TextStyle(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          about,
          style: const TextStyle(
            fontSize: 15,
            color: AppColor.gray700,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildArtworksSection(String languageCode, bool isMobile) {
    if (widget.artworks.isEmpty) {
      return _buildEmptyArtworks(isMobile);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'artists.artworks'.tr(),
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w700,
                color: AppColor.primaryColor,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.backgroundGray,
                borderRadius: BorderRadius.circular(16.h),
                border: Border.all(color: AppColor.gray200),
              ),
              child: Text(
                '${widget.artworks.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.gray700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: widget.artworks.length,
          itemBuilder: (context, index) {
            return _buildArtworkCard(
              widget.artworks[index],
              languageCode,
              isMobile,
            );
          },
        ),
      ],
    );
  }

  Widget _buildArtworkCard(
    Artwork artwork,
    String languageCode,
    bool isMobile,
  ) {
    final imageUrl = artwork.gallery.isNotEmpty ? artwork.gallery.first : null;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () {
          navigateTo(
            context,
            ArtWorkDetailsScreen(artworkId: artwork.id, userId: ""),
          );
        },
        borderRadius: BorderRadius.circular(isMobile ? 16.h : 20.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 16.h : 20.h),
            border: Border.all(color: AppColor.gray200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Artwork Image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobile ? 16.h : 20.h),
                  topRight: Radius.circular(isMobile ? 16.h : 20.h),
                ),
                child: Container(
                  height: isMobile ? 200.h : 300.h,
                  width: double.infinity,
                  color: AppColor.backgroundGray,
                  child: imageUrl != null
                      ? OfflineCachedImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: isMobile ? 48.h : 64.h,
                            color: AppColor.gray600,
                          ),
                        ),
                ),
              ),

              // Artwork Info
              Padding(
                padding: EdgeInsets.all(isMobile ? 12.h : 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artwork.localizedName(languageCode: languageCode),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (artwork.localizedDescription(
                          languageCode: languageCode,
                        ) !=
                        null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        artwork.localizedDescription(
                          languageCode: languageCode,
                        )!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColor.gray700,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyArtworks(bool isMobile) {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        color: AppColor.backgroundGray,
        borderRadius: BorderRadius.circular(isMobile ? 16.h : 20.h),
        border: Border.all(color: AppColor.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_outlined, size: 48, color: AppColor.gray600),
            const SizedBox(height: 8),
            Text(
              'no_artworks'.tr(),
              style: const TextStyle(fontSize: 14, color: AppColor.gray700),
            ),
          ],
        ),
      ),
    );
  }
}
