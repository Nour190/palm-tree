import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart' ;
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

class IthraVirtualTourSection extends StatelessWidget {
  final VoidCallback? onTryNow;
  final List<String>? previewImages;

  const IthraVirtualTourSection({
    super.key,
    this.onTryNow,
    this.previewImages,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;

    final double horizontalPadding = isDesktop
        ? 48.sW
        : isTablet
        ? 32.sW
        : 18.sW;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 24.sH : 32.sH,
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20.sW : 24.sW),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF8B4513), // Brown color matching the reference
              const Color(0xFF654321),
            ],
          ),
          borderRadius: BorderRadius.circular(16.sR),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isMobile 
            ? _buildMobileLayout(context, deviceType)
            : _buildDesktopTabletLayout(context, deviceType),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DeviceType deviceType) {
    return Column(
      children: [
        // 3D Cube icon
        _build3DCubeIcon(context, deviceType),
        
        SizedBox(height: 20.sH),
        
        // Content
        _buildContent(context, deviceType),
        
        SizedBox(height: 20.sH),
        
        // Preview images
        if (previewImages != null && previewImages!.isNotEmpty)
          _buildPreviewImages(context, deviceType),
      ],
    );
  }

  Widget _buildDesktopTabletLayout(BuildContext context, DeviceType deviceType) {
    return Row(
      children: [
        // Left side - 3D Cube and content
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _build3DCubeIcon(context, deviceType),
              SizedBox(height: 20.sH),
              _buildContent(context, deviceType),
            ],
          ),
        ),
        
        SizedBox(width: 32.sW),
        
        // Right side - Preview images
        if (previewImages != null && previewImages!.isNotEmpty)
          Expanded(
            flex: 2,
            child: _buildPreviewImages(context, deviceType),
          ),
      ],
    );
  }

  Widget _build3DCubeIcon(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    
    final double cubeSize = isMobile ? 60.sW : isTablet ? 70.sW : 80.sW;
    
    return Container(
      width: cubeSize,
      height: cubeSize,
      child: CustomPaint(
        painter: Cube3DPainter(),
        size: Size(cubeSize, cubeSize),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Step Inside the Exhibition',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 20.sSp : isTablet ? 24.sSp : 28.sSp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        
        SizedBox(height: 12.sH),
        
        // Description
        Text(
          'Experience our curated collection through an immersive virtual tour. Navigate through digital galleries and discover artworks from around the world.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 14.sSp : 15.sSp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.9),
            height: 1.5,
          ),
        ),
        
        SizedBox(height: 20.sH),
        
        // Try Now button
        if (onTryNow != null)
          GestureDetector(
            onTap: onTryNow,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20.sW : 24.sW,
                vertical: isMobile ? 12.sH : 14.sH,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.sR),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Try Now',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isMobile ? 14.sSp : 16.sSp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8B4513),
                    ),
                  ),
                  SizedBox(width: 8.sW),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: isMobile ? 16.sW : 18.sW,
                    color: const Color(0xFF8B4513),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPreviewImages(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    
    if (previewImages == null || previewImages!.isEmpty) {
      return _buildDefaultPreviewImages(context, deviceType);
    }
    
    return Column(
      children: [
        // Main preview image
        Container(
          height: isMobile ? 120.sH : 140.sH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.sR),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.sR),
            child: HomeImage(
              path: previewImages!.first,
              fit: BoxFit.cover,
              errorChild: _buildFallbackPreviewImage(context, deviceType),
            ),
          ),
        ),
        
        SizedBox(height: 12.sH),
        
        // Small preview avatars
        if (previewImages!.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: previewImages!
                .skip(1)
                .take(4)
                .map((imagePath) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.sW),
                      width: isMobile ? 32.sW : 36.sW,
                      height: isMobile ? 32.sW : 36.sW,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: HomeImage(
                          path: imagePath,
                          fit: BoxFit.cover,
                          errorChild: Container(
                            color: Colors.white.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              size: isMobile ? 16.sW : 18.sW,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildDefaultPreviewImages(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    
    return Column(
      children: [
        // Default preview
        Container(
          height: isMobile ? 120.sH : 140.sH,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.sR),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.view_in_ar_rounded,
                  size: isMobile ? 32.sW : 40.sW,
                  color: Colors.white.withOpacity(0.7),
                ),
                SizedBox(height: 8.sH),
                Text(
                  'Virtual Gallery',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isMobile ? 12.sSp : 14.sSp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 12.sH),
        
        // Default avatars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4.sW),
                width: isMobile ? 32.sW : 36.sW,
                height: isMobile ? 32.sW : 36.sW,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: isMobile ? 16.sW : 18.sW,
                  color: Colors.white.withOpacity(0.7),
                ),
              )),
        ),
      ],
    );
  }

  Widget _buildFallbackPreviewImage(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    
    return Container(
      color: Colors.white.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: isMobile ? 32.sW : 40.sW,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}

class Cube3DPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.8);

    final center = Offset(size.width / 2, size.height / 2);
    final cubeSize = size.width * 0.6;
    
    // Define cube vertices in 3D space
    final vertices = [
      [-1, -1, -1], // 0: back-bottom-left
      [1, -1, -1],  // 1: back-bottom-right
      [1, 1, -1],   // 2: back-top-right
      [-1, 1, -1],  // 3: back-top-left
      [-1, -1, 1],  // 4: front-bottom-left
      [1, -1, 1],   // 5: front-bottom-right
      [1, 1, 1],    // 6: front-top-right
      [-1, 1, 1],   // 7: front-top-left
    ];

    // Project 3D vertices to 2D
    final projectedVertices = vertices.map((vertex) {
      final x = vertex[0] * cubeSize * 0.3;
      final y = vertex[1] * cubeSize * 0.3;
      final z = vertex[2] * cubeSize * 0.3;
      
      // Simple isometric projection
      final projX = (x - z) * math.cos(math.pi / 6);
      final projY = (x + z) * math.sin(math.pi / 6) - y;
      
      return Offset(center.dx + projX, center.dy + projY);
    }).toList();

    // Define faces (each face is defined by 4 vertex indices)
    final faces = [
      [0, 1, 2, 3], // back face
      [4, 7, 6, 5], // front face
      [0, 4, 5, 1], // bottom face
      [2, 6, 7, 3], // top face
      [0, 3, 7, 4], // left face
      [1, 5, 6, 2], // right face
    ];

    final faceColors = [
      Colors.white.withOpacity(0.3), // back
      Colors.white.withOpacity(0.7), // front
      Colors.white.withOpacity(0.4), // bottom
      Colors.white.withOpacity(0.6), // top
      Colors.white.withOpacity(0.5), // left
      Colors.white.withOpacity(0.8), // right
    ];

    // Draw faces
    for (int i = 0; i < faces.length; i++) {
      final face = faces[i];
      final path = Path();
      
      path.moveTo(projectedVertices[face[0]].dx, projectedVertices[face[0]].dy);
      for (int j = 1; j < face.length; j++) {
        path.lineTo(projectedVertices[face[j]].dx, projectedVertices[face[j]].dy);
      }
      path.close();

      paint.color = faceColors[i];
      canvas.drawPath(path, paint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
