import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import '../../../data/models/gallery_item.dart';

class GalleryGrid extends StatelessWidget {
  final List<GalleryItem> items;
  final void Function(GalleryItem item)? onTap;

  const GalleryGrid({super.key, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final spacing = constraints.maxWidth > 600 ? 16.0 : 12.0;

        return GridView.builder(
          padding: EdgeInsets.all(spacing),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 1.0,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _buildGalleryItem(context, items[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.h,
            height: 100.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50.h),
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 40.h,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No Images Yet',
            style: TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your gallery will appear here',
            style: TextStyle(fontSize: 14.h, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryItem(BuildContext context, GalleryItem item) {
    return GestureDetector(
      onTap: () => _showImageViewer(context, item),
      child: Hero(
        tag: 'gallery_${item.imageUrl}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.h),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.h),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildErrorWidget(),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return _buildLoadingWidget();
                  },
                ),

                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),

                // Artist name
                Positioned(
                  bottom: 12.h,
                  left: 12.h,
                  right: 12.h,
                  child: Text(
                    item.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.h,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // View icon
                Positioned(
                  top: 8.h,
                  right: 8.h,
                  child: Container(
                    padding: EdgeInsets.all(6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                    child: Icon(
                      Icons.fullscreen,
                      size: 16.h,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 32.h,
            color: Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          Text(
            'Image not available',
            style: TextStyle(fontSize: 12.h, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
        ),
      ),
    );
  }

  void _showImageViewer(BuildContext context, GalleryItem item) {
    onTap?.call(item);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => ImageViewer(item: item),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1000) return 4;
    if (width > 600) return 3;
    return 2;
  }
}

class ImageViewer extends StatefulWidget {
  final GalleryItem item;

  const ImageViewer({super.key, required this.item});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image viewer
          Center(
            child: Hero(
              tag: 'gallery_${widget.item.imageUrl}',
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  widget.item.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildImageError(),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return _buildImageLoading();
                  },
                ),
              ),
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10.h,
                left: 20.h,
                right: 20.h,
                bottom: 20.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(10.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25.h),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.h),
                  Expanded(
                    child: Text(
                      widget.item.artistName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.h,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 20.h,
                right: 20.h,
                bottom: MediaQuery.of(context).padding.bottom + 20.h,
                top: 20.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(icon: Icons.zoom_in, onTap: _zoomIn),
                  SizedBox(width: 20.h),
                  _buildControlButton(icon: Icons.zoom_out, onTap: _zoomOut),
                  SizedBox(width: 20.h),
                  _buildControlButton(icon: Icons.refresh, onTap: _resetZoom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20.h),
        ),
        child: Icon(icon, color: Colors.white, size: 20.h),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      width: double.infinity,
      height: 400.h,
      color: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 48.h, color: Colors.white54),
          SizedBox(height: 16.h),
          Text(
            'Failed to load image',
            style: TextStyle(color: Colors.white54, fontSize: 16.h),
          ),
        ],
      ),
    );
  }

  Widget _buildImageLoading() {
    return Container(
      width: double.infinity,
      height: 400.h,
      color: Colors.grey[800],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
            SizedBox(height: 16.h),
            Text(
              'Loading image...',
              style: TextStyle(color: Colors.white54, fontSize: 16.h),
            ),
          ],
        ),
      ),
    );
  }

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale < 3.0) {
      _transformationController.value = Matrix4.identity()
        ..scale(currentScale * 1.2);
    }
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 0.5) {
      _transformationController.value = Matrix4.identity()
        ..scale(currentScale / 1.2);
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }
}
