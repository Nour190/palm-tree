
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/modules/qr_generator/presentation/manger/qr_generator_cubit.dart';
import 'package:baseqat/modules/qr_generator/presentation/manger/qr_generator_state.dart';
import 'package:baseqat/modules/home/data/repositories/home_repository_impl.dart';
import 'package:baseqat/modules/home/data/datasources/home_remote_data_source.dart';
import 'package:baseqat/core/network/remote/supabase_config.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:easy_localization/easy_localization.dart';

import 'qr_generator_web_stub.dart'
if (dart.library.html) 'qr_generator_web.dart' as web;
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:baseqat/core/utils/qr_code_generator.dart';
import 'qr_share_mobile.dart'
if (dart.library.html) 'qr_share_web.dart' as qr_share;




class QRGeneratorScreen extends StatelessWidget {
  const QRGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QRGeneratorCubit(
        HomeRepositoryImpl(
          HomeRemoteDataSourceImpl(SupabaseConfig.client),
        ),
      )..loadArtists(),
      child: const _QRGeneratorBody(),
    );
  }
}

class _QRGeneratorBody extends StatelessWidget {
  const _QRGeneratorBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        title: Text('qr_generator.title'.tr()),
        backgroundColor: AppColor.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<QRGeneratorCubit, QRGeneratorState>(
          builder: (context, state) {
            if (state is QRGeneratorLoading) {
              return  Center(child: CircularProgressIndicator(color:AppColor.primaryColor));
            }

            if (state is QRGeneratorError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sW,
                      color: AppColor.red,
                    ),
                    SizedBox(height: 16.sH),
                    Text(
                      state.message,
                      style: TextStyleHelper.instance.title16RegularInter,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.sH),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<QRGeneratorCubit>().loadArtists(),
                      child: Text('qr_generator.retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            if (state is QRGeneratorArtistsLoaded) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(24.sW),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Instructions
                    Container(
                      padding: EdgeInsets.all(16.sW),
                      decoration: BoxDecoration(
                        color: AppColor.backgroundGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColor.primaryColor,
                            size: 24.sW,
                          ),
                          SizedBox(width: 12.sW),
                          Expanded(
                            child: Text(
                              'qr_generator.instructions'.tr(),
                              style: TextStyleHelper.instance.body14RegularInter
                                  .copyWith(color: AppColor.gray600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.sH),

                    // Artist Selection
                    Text(
                      'qr_generator.select_artist'.tr(),
                      style: TextStyleHelper.instance.title18BoldInter,
                    ),
                    SizedBox(height: 12.sH),
                    _ArtistDropdown(
                      key: ValueKey(state.selectedArtist),
                      artists: state.artists,
                      selectedArtistId: state.selectedArtist,
                      onChanged: (artistId) {
                        if (artistId != null) {
                          context
                              .read<QRGeneratorCubit>()
                              .loadArtworksByArtist(artistId);
                        }
                      },
                    ),
                    SizedBox(height: 32.sH),

                    // Artwork Selection
                    if (state.selectedArtist != null) ...[
                      Text(
                        'qr_generator.select_artwork'.tr(),
                        style: TextStyleHelper.instance.title18BoldInter,
                      ),
                      SizedBox(height: 12.sH),
                      if (state.isLoadingArtworks)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(color:AppColor.primaryColor),
                          ),
                        )
                      else if (state.artworks.isEmpty)
                        Container(
                          padding: EdgeInsets.all(24.sW),
                          decoration: BoxDecoration(
                            color: AppColor.backgroundGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'qr_generator.no_artworks'.tr(),
                            style: TextStyleHelper.instance.body14RegularInter
                                .copyWith(color: AppColor.gray600),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        _ArtworkDropdown(
                          key: ValueKey('${state.selectedArtist}_${state.artworks.length}'),
                          artworks: state.artworks,
                          selectedArtworkId: state.selectedArtwork,
                          onChanged: (artworkId) {
                            if (artworkId != null) {
                              context
                                  .read<QRGeneratorCubit>()
                                  .selectArtwork(artworkId);
                            }
                          },
                        ),
                      SizedBox(height: 32.sH),
                    ],

                    // QR Code Display
                    if (state.selectedArtwork != null) ...[
                      Builder(
                        builder: (context) {
                          // Safely find the artwork, return null if not found
                          final artwork = state.artworks.cast<dynamic>().firstWhere(
                                (a) => a?.id == state.selectedArtwork,
                            orElse: () => null,
                          );

                          // If artwork not found in current list, don't show QR
                          if (artwork == null) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            children: [
                              Text(
                                'qr_generator.generated_qr'.tr(),
                                style: TextStyleHelper.instance.title18BoldInter,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24.sH),
                              Center(
                                child: _QRCodeDisplay(
                                  artworkId: state.selectedArtwork!,
                                  artwork: artwork,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ArtistDropdown extends StatelessWidget {
  const _ArtistDropdown({
    required this.artists,
    required this.selectedArtistId,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final List artists;
  final String? selectedArtistId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sW, vertical: 4.sH),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.gray600),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedArtistId,
          hint: Text(
            'qr_generator.choose_artist'.tr(),
            style: TextStyleHelper.instance.title16Inter

          ),
          items: artists.map((artist) {
            return DropdownMenuItem<String>(
              value: artist.id,
              child: Text(
                artist.name,
                style: TextStyleHelper.instance.title16Inter,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ArtworkDropdown extends StatelessWidget {
  const _ArtworkDropdown({
    required this.artworks,
    required this.selectedArtworkId,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final List artworks;
  final String? selectedArtworkId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool valueExists = artworks.any((a) => a.id == selectedArtworkId);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sW, vertical: 4.sH),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.gray600),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: valueExists ? selectedArtworkId : null,
          hint: Text(
            'qr_generator.choose_artwork'.tr(),
            style: TextStyleHelper.instance.title16Inter
          ),
          items: artworks.map((artwork) {
            return DropdownMenuItem<String>(
              value: artwork.id,
              child: Text(
                artwork.name,
                style: TextStyleHelper.instance.title16Inter,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _QRCodeDisplay extends StatelessWidget {
  const _QRCodeDisplay({
    required this.artworkId,
    required this.artwork,
  });

  final String artworkId;
  final artwork;

  Future<void> _downloadQRCode() async {
    // preserve original behavior: only download on web
    if (!kIsWeb) return;

    try {
      final qrData = QRCodeGenerator.generateArtworkQRData(artworkId);

      final qrPainter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
        color: Colors.black,
        emptyColor: Colors.white,
      );

      final image = await qrPainter.toImage(512);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();


      final url = web.createObjectUrl(bytes);
      web.triggerDownload(url, 'artwork_${artworkId}_qr.png');
      web.revokeObjectUrl(url);
    } catch (e) {
      print('Error downloading QR code: $e');
    }
  }

  // Future<void> _shareQRCode(BuildContext context) async {
  //   try {
  //     final shareMessage = QRCodeGenerator.generateShareMessage(
  //       artworkId,
  //       artwork.name,
  //     );
  //
  //     await Share.share(
  //       shareMessage,
  //       subject: 'qr.share_subject'.tr(args: [artwork.name]),
  //     );
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('qr.share_error'.tr()),
  //           backgroundColor: AppColor.red,
  //         ),
  //       );
  //     }
  //   }
  // }
  // Future<void> _shareQRCode(BuildContext context) async {
  //   try {
  //     if (kIsWeb) {
  //       final shareMessage = QRCodeGenerator.generateShareMessage(
  //         artworkId,
  //         artwork.name,
  //       );
  //       await Share.share(
  //         shareMessage,
  //         subject: 'qr.share_subject'.tr(args: [artwork.name]),
  //       );
  //       return;
  //     }
  //
  //
  //     final qrData = QRCodeGenerator.generateArtworkQRData(artworkId);
  //     final qrPainter = QrPainter(
  //       data: qrData,
  //       version: QrVersions.auto,
  //       errorCorrectionLevel: QrErrorCorrectLevel.H,
  //       color: Colors.black,
  //       emptyColor: Colors.white,
  //     );
  //
  //     final image = await qrPainter.toImage(512);
  //     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //     final bytes = byteData!.buffer.asUint8List();
  //
  //     final tempDir = await getTemporaryDirectory();
  //     final file = await File('${tempDir.path}/artwork_${artworkId}_qr.png').create();
  //     await file.writeAsBytes(bytes);
  //
  //     // مشاركة الصورة باستخدام Share Plus
  //     await Share.shareXFiles(
  //       [XFile(file.path)],
  //       text: 'qr.share_subject'.tr(args: [artwork.name]),
  //     );
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('qr.share_error'.tr()),
  //           backgroundColor: AppColor.red,
  //         ),
  //       );
  //     }
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QRCodeGenerator.buildQRCodeWidget(
          artworkId: artworkId,
          size: 280,
          showLabel: true,
        ),
        SizedBox(height: 24.sH),
        if (artwork.gallery.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              artwork.gallery.first,
              width: 200.sW,
              height: 200.sH,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200.sW,
                  height: 200.sH,
                  color: AppColor.gray200,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48.sW,
                    color: AppColor.gray400,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.sH),
        ],
        Text(
          artwork.name,
          style: TextStyleHelper.instance.headline20BoldInter,
          textAlign: TextAlign.center,
        ),
        if (artwork.artistName != null) ...[
          SizedBox(height: 8.sH),
          Text(
            artwork.artistName!,
            style: TextStyleHelper.instance.body14RegularInter
                .copyWith(color: AppColor.gray600),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: 24.sH),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final qrData = QRCodeGenerator.generateArtworkQRData(artworkId);
                await qr_share.shareQRCode(qrData, context);
              },
              icon: Icon(Icons.share, size: 20.sW),
              label: Text('qr.share'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.sW,
                  vertical: 16.sH,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (kIsWeb) ...[
              SizedBox(width: 12.sW),
              ElevatedButton.icon(
                onPressed: _downloadQRCode,
                icon: Icon(Icons.download, size: 20.sW),
                label: Text('qr.download'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColor.primaryColor,
                  side: BorderSide(color: AppColor.primaryColor, width: 2),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.sW,
                    vertical: 16.sH,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}



