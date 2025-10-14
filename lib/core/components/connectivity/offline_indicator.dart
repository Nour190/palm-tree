import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:baseqat/core/network/connectivity_service.dart';

/// Widget that displays an offline indicator banner when no internet connection
class OfflineIndicator extends StatefulWidget {
  final Widget child;

  const OfflineIndicator({
    super.key,
    required this.child,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _listenToConnectivityChanges();
  }

  Future<void> _checkInitialConnection() async {
    final hasConnection = await _connectivityService.hasConnection();
    if (mounted) {
      setState(() {
        _isOnline = hasConnection;
      });
    }
  }

  void _listenToConnectivityChanges() {
    _connectivityService.onConnectivityChanged.listen((results) async {
      final hasConnection = await _connectivityService.hasConnection();
      if (mounted) {
        setState(() {
          _isOnline = hasConnection;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isOnline)
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          //   color: Colors.orange[700],
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       const Icon(
          //         Icons.cloud_off,
          //         color: Colors.white,
          //         size: 20,
          //       ),
          //       const SizedBox(width: 8),
          //       Text(
          //         'common.offline_mode'.tr(),
          //         style: const TextStyle(
          //           color: Colors.white,
          //           fontWeight: FontWeight.w600,
          //           fontSize: 14,
          //         ),
          //       ),
            //  ],
            //),
          //),
        Expanded(child: widget.child),
      ],
    );
  }
}
