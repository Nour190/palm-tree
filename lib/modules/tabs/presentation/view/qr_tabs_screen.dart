import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/components/qr_scanner/qr_scanner_screen.dart';
import 'package:baseqat/modules/qr_generator/view/qr_generator_screen.dart';
import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/artwork_details_tabs_view.dart';
import 'package:baseqat/core/resourses/constants_manager.dart';

/// QR Tabs Screen with Scan and Generate tabs
class QRTabsScreen extends StatefulWidget {
  const QRTabsScreen({
    super.key,
    this.initialTab = 0,
  });

  final int initialTab;

  @override
  State<QRTabsScreen> createState() => _QRTabsScreenState();
}

class _QRTabsScreenState extends State<QRTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleQRScan(String artworkId) {
    // Close scanner and navigate to artwork details
    Navigator.pop(context);

    navigateTo(
      context,
      ArtWorkDetailsScreen(
        artworkId: artworkId,
        userId: AppConstants.userIdValue ?? "",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        title: Text(
          'qr.title'.tr(),
          style: TextStyleHelper.instance.headline20BoldInter,
        ),
        backgroundColor: AppColor.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.sH),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColor.gray400,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColor.primaryColor,
              indicatorWeight: 3,
              labelColor: AppColor.primaryColor,
              unselectedLabelColor: AppColor.gray600,
              labelStyle: TextStyleHelper.instance.title16BoldInter,
              unselectedLabelStyle:
                  TextStyleHelper.instance.title16RegularInter,
              tabs: [
                Tab(
                  icon: Icon(Icons.qr_code_scanner, size: 24.sW),
                  text: 'qr.scan_tab'.tr(),
                ),
                Tab(
                  icon: Icon(Icons.qr_code_2, size: 24.sW),
                  text: 'qr.generate_tab'.tr(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Scan QR Tab
          QRScannerScreen(
            onCodeScanned: _handleQRScan,
            title: 'qr.scan_title'.tr(),
            subtitle: 'qr.scan_subtitle'.tr(),
          ),
          // Generate QR Tab
          const QRGeneratorScreen(),
        ],
      ),
    );
  }
}
