import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';
import 'package:easy_localization/easy_localization.dart';

class IthraVirtualTourSection extends StatelessWidget {
  final VoidCallback? onTryNow;
  final String? virtualTourImage;
  final String peopleImage;

  const IthraVirtualTourSection({
    super.key,
    this.onTryNow,
    this.virtualTourImage,
    required this.peopleImage,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;

    final double horizontalPadding = isDesktop
        ? 18.sW
        : isTablet
        ? 12.sW
        : 8.sW;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 24.sH : 32.sH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.virtual_tour'.tr(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isDesktop
                  ? 32.sSp
                  : isTablet
                  ? 28.sSp
                  : 24.sSp,
              fontWeight: FontWeight.w700,
              color: AppColor.black,
            ),
          ),

          SizedBox(height: isMobile ? 20.sH : 24.sH),

          isMobile
              ? _buildMobileLayout(context, deviceType)
              : _buildDesktopTabletLayout(context, deviceType),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    final avatarSize = isMobile ? 36.sW : isTablet ? 40.sW : 44.sW;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.sR)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: virtualTourImage != null
                  ? HomeImage(
                path: virtualTourImage!,
                fit: BoxFit.cover,
                errorChild: _buildDefaultVirtualTourImage(deviceType),
              )
                  : _buildDefaultVirtualTourImage(deviceType),
            ),
          ),
          Padding(
              padding: EdgeInsets.all(10.sW),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'home.virtual_tour_title'.tr(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20.sSp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.black,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 12.sH),
                  Text(
                    'home.virtual_tour_description'.tr(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sSp,
                      fontWeight: FontWeight.w400,
                      color: AppColor.gray600,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20.sH),
                  Text(
                    'home.virtual_tour_journey'.tr(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.sSp,
                      fontWeight: FontWeight.w400,
                      color: AppColor.gray700,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 12.sH),
                  Row(
                    children: [
                      HomeImage(
                        path: peopleImage,
                        fit: BoxFit.contain,
                        height: 40.sH,
                        errorChild: Container(
                          color: AppColor.gray200,
                          child: Icon(
                            Icons.person,
                            size: avatarSize * 0.5,
                            color: AppColor.gray600,
                          ),
                        ),
                      ),
                      Spacer(),
                      if (onTryNow != null)
                        SizedBox(
                          width: 120.sW,
                          child: GestureDetector(
                            onTap: onTryNow,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.sH),
                              decoration: BoxDecoration(
                                color: AppColor.black,
                                borderRadius: BorderRadius.circular(10.sR),
                              ),
                              child: Center(
                                child: Text(
                                  'home.try_now'.tr(),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16.sSp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTabletLayout(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    final avatarSize = isMobile ? 36.sW : isTablet ? 40.sW : 44.sW;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.sR),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: isTablet ? 3 : 4,
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(20.sR)),
              child: AspectRatio(
                aspectRatio: isTablet ? 4 / 4 : 4 / 2,
                child: virtualTourImage != null
                    ? HomeImage(
                  path: virtualTourImage!,
                  fit: BoxFit.cover,
                  errorChild: _buildDefaultVirtualTourImage(deviceType),
                )
                    : _buildDefaultVirtualTourImage(deviceType),
              ),
            ),
          ),
          Expanded(
            flex: isTablet ? 5 : 6,
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 28.sW : 36.sW),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'home.virtual_tour_title'.tr(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isTablet ? 24.sSp : 28.sSp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.black,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16.sH),
                  Text(
                    'home.virtual_tour_description'.tr(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isTablet ? 14.sSp : 16.sSp,
                      fontWeight: FontWeight.w400,
                      color: AppColor.gray600,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 80.sH),
                  Text(
                    'home.virtual_tour_journey'.tr(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isTablet ? 13.sSp : 14.sSp,
                      fontWeight: FontWeight.w400,
                      color: AppColor.gray700,
                      height: 1.5,
                    ),
                  ),
                 //Spacer(),
                  SizedBox(height: 8.sH),
                  Row(
                    children: [
                      HomeImage(
                        path: peopleImage,
                        fit: BoxFit.cover,width:120.sW,height:40.sH,
                        errorChild: Container(
                          color: AppColor.gray200,
                          child: Icon(
                            Icons.person,
                            size: avatarSize * 0.5,
                            color: AppColor.gray600,
                          ),
                        ),
                      ),
                      Spacer(),
                      if (onTryNow != null)
                        GestureDetector(
                          onTap: onTryNow,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 32.sW : 40.sW,
                              vertical: isTablet ? 14.sH : 16.sH,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.black,
                              borderRadius: BorderRadius.circular(15.sR),
                            ),
                            child: Text(
                              'home.try_now'.tr(),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: isTablet ? 15.sSp : 16.sSp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultVirtualTourImage(DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B4513),
            const Color(0xFF654321),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_in_ar_rounded,
              size: isMobile ? 40.sW : 48.sW,
              color: Colors.white.withOpacity(0.9),
            ),
            SizedBox(height: 8.sH),
            Text(
              'home.virtual_gallery'.tr(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 14.sSp : 16.sSp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildDefaultPeopleImage(DeviceType deviceType) {
  //   final bool isMobile = deviceType == DeviceType.mobile;
  //
  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           AppColor.gray200,
  //           AppColor.gray400,
  //         ],
  //       ),
  //     ),
  //     child: Center(
  //       child: Icon(
  //         Icons.people_outline,
  //         size: isMobile ? 40.sW : 48.sW,
  //         color: Colors.white.withOpacity(0.9),
  //       ),
  //     ),
  //   );
  // }
}

class _FavoriteButton extends StatefulWidget {
  final bool isMobile;
  final VoidCallback onTap;

  const _FavoriteButton({
    required this.isMobile,
    required this.onTap,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isFavorite = !_isFavorite);
        widget.onTap();
      },
      child: Container(
        padding: EdgeInsets.all(widget.isMobile ? 8.sW : 10.sW),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          size: widget.isMobile ? 18.sW : 20.sW,
          color: _isFavorite ? Colors.red : AppColor.gray700,
        ),
      ),
    );
  }
}
