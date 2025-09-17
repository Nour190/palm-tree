import 'package:baseqat/modules/artist_details/presentation/view/artist_details_view.dart';
import 'package:baseqat/modules/artwork_details/data/datasources/artwork_details_remote_data_source.dart';
import 'package:baseqat/modules/artwork_details/data/repositories/artwork_repository.dart'
    show ArtworkDetailsRepositoryImpl;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    );
    return BlocProvider(
      create: (_) => ArtistCubit(repo)..getById(widget.artistId),
      child: BlocBuilder<ArtistCubit, ArtistState>(
        builder: (context, state) {
          switch (state.status) {
            case ArtistStatus.loading:
              return const _ArtistSkeleton();
            case ArtistStatus.error:
              return _ArtistError(
                message: state.error ?? 'Something went wrong',
              );
            case ArtistStatus.loaded:
              final a = state.artist!;
              return ArtistDetailsView(
                name: a.name,
                profileImage: a.profileImage,
                age: a.age,
                about: a.about,
                country: a.country,
                city: a.city,
                gallery: a.gallery,
              );
            case ArtistStatus.initial:
              return const _ArtistSkeleton();
          }
        },
      ),
    );
  }
}

class _ArtistSkeleton extends StatelessWidget {
  const _ArtistSkeleton();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}

class _ArtistError extends StatelessWidget {
  final String message;
  const _ArtistError({required this.message});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.maybePop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
