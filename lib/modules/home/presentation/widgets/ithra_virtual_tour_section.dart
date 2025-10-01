import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';

class IthraVirtualTourSection extends StatelessWidget {
  final VoidCallback? onTryNow;
  final String? virtualTourImage;
  final  String peopleImage;

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
            'Virtual Tour',
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
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                      'Step Inside the Exhibition',
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
                        'A 3D tour that lets you explore the exhibition as if you were inside walking through the sections and viewing products from every angle before your actual visit',
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
                        'Discover an exceptional journey\nalongside over 20+ people',
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
                      path:peopleImage,
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
                                  width: 80.sW,
                                  child: GestureDetector(
                                    onTap: onTryNow,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 14.sH),
                                      decoration: BoxDecoration(
                                        color: AppColor.black,
                                        borderRadius: BorderRadius.circular(15.sR),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Try Now',
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
                aspectRatio: isTablet ? 4 / 4 : 3 / 2,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Step Inside the Exhibition',
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
                    'A 3D tour that lets you explore the exhibition as if you were inside walking through the sections and viewing products from every angle before your actual visit',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isTablet ? 14.sSp : 16.sSp,
                      fontWeight: FontWeight.w400,
                      color: AppColor.gray600,
                      height: 1.6,
                    ),
                  ),

                  SizedBox(height: 24.sH),

                    Text(
                      'Discover an exceptional journey\nalongside over 20+ people',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: isTablet ? 13.sSp : 14.sSp,
                        fontWeight: FontWeight.w400,
                        color: AppColor.gray700,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 16.sH),

                    //_buildPeopleAvatars(deviceType),

                   // SizedBox(height: 28.sH),
                  Row(
                    children: [
                      HomeImage(
                        path:peopleImage!,
                        fit: BoxFit.cover,
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
                              'Try Now',
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

  // Widget _buildPeopleAvatars(DeviceType deviceType) {
  //   final bool isMobile = deviceType == DeviceType.mobile;
  //   final bool isTablet = deviceType == DeviceType.tablet;
  //
  //   final avatarSize = isMobile ? 36.sW : isTablet ? 40.sW : 44.sW;
  //   final displayCount = isMobile ? 5 : 6;
  //
  //   return Row(
  //     children: [
  //       ...peopleImages!
  //           .take(displayCount)
  //           .map((imagePath) => Container(
  //         margin: EdgeInsets.only(right: isMobile ? 6.sW : 8.sW),
  //         width: avatarSize,
  //         height: avatarSize,
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           border: Border.all(
  //             color: Colors.white,
  //             width: 2.5,
  //           ),
  //           boxShadow: [
  //             BoxShadow(
  //               color: AppColor.black.withOpacity(0.12),
  //               blurRadius: 6,
  //               offset: const Offset(0, 2),
  //             ),
  //           ],
  //         ),
  //         child: ClipOval(
  //           child: HomeImage(
  //             path: imagePath,
  //             fit: BoxFit.cover,
  //             errorChild: Container(
  //               color: AppColor.gray200,
  //               child: Icon(
  //                 Icons.person,
  //                 size: avatarSize * 0.5,
  //                 color: AppColor.gray600,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ))
  //           .toList(),
  //       if (peopleImages!.length > displayCount)
  //         Container(
  //           width: avatarSize,
  //           height: avatarSize,
  //           decoration: BoxDecoration(
  //             color: AppColor.gray200,
  //             shape: BoxShape.circle,
  //             border: Border.all(
  //               color: Colors.white,
  //               width: 2.5,
  //             ),
  //           ),
  //           child: Center(
  //             child: Text(
  //               '+${peopleImages!.length - displayCount}',
  //               style: TextStyle(
  //                 fontFamily: 'Inter',
  //                 fontSize: isMobile ? 11.sSp : 12.sSp,
  //                 fontWeight: FontWeight.w600,
  //                 color: AppColor.gray700,
  //               ),
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }

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
              'Virtual Gallery',
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

  Widget _buildDefaultPeopleImage(DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.gray200,
            AppColor.gray400,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.people_outline,
          size: isMobile ? 40.sW : 48.sW,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }
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
