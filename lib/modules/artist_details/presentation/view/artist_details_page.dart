import 'package:baseqat/core/components/alerts/custom_loading.dart';
import 'package:baseqat/core/components/connectivity/offline_indicator.dart';
import 'package:baseqat/core/network/connectivity_service.dart';
import 'package:baseqat/modules/artist_details/presentation/view/artist_details_view.dart';
import 'package:baseqat/modules/artwork_details/data/datasources/artwork_details_local_data_source.dart';
import 'package:baseqat/modules/artwork_details/data/datasources/artwork_details_remote_data_source.dart';
import 'package:baseqat/modules/artwork_details/data/repositories/artwork_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

import '../manger/artist_cubit.dart';
import '../manger/artist_states.dart';

class ArtistDetailsPage extends StatefulWidget {
  final String artistId;
  const ArtistDetailsPage({super.key, required this.artistId});

  @override
  State<ArtistDetailsPage> createState() => _ArtistDetailsPageState();
}

class _ArtistDetailsPageState extends State<ArtistDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final repo = ArtworkDetailsRepositoryImpl(
      remote: ArtworkDetailsRemoteDataSourceImpl(client),
      local: ArtworkDetailsLocalDataSourceImpl(),
      connectivity: ConnectivityService(),
    );

    return BlocProvider(
      create: (_) => ArtistCubit(repo)..getById(widget.artistId),
      child: OfflineIndicator(
        child: Scaffold(
          backgroundColor: AppColor.backgroundWhite,
          body: BlocBuilder<ArtistCubit, ArtistState>(
            builder: (context, state) {
              switch (state.status) {
                case ArtistStatus.loading:
                  return const _ArtistLoading();
                case ArtistStatus.error:
                  return _ArtistError(
                    message: state.error ?? 'errors.something_went_wrong'.tr(),
                    onRetry: () => context.read<ArtistCubit>().getById(widget.artistId),
                  );
                case ArtistStatus.loaded:
                  final artist = state.artist!;
                  return ArtistDetailsView(
                    artist: artist,
                    artworks: state.artworks,
                  );
                case ArtistStatus.initial:
                  return const _ArtistLoading();
              }
            },
          ),
        ),
      ),
    );
  }
}

class _ArtistLoading extends StatelessWidget {
  const _ArtistLoading();

  @override
  Widget build(BuildContext context) {
    return LoadingPage(
      message: 'home.curating_experience'.tr(),
      subtitle: 'home.curating_subtitle'.tr(),
    );
  }
}

class _ArtistError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ArtistError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.backgroundGray,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColor.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColor.gray700,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text('retry'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
