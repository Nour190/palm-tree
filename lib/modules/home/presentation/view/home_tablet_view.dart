import 'package:baseqat/modules/home/data/datasources/home_remote_data_source.dart';
import 'package:baseqat/modules/home/data/repositories/home_repository_impl.dart';
import 'package:baseqat/modules/home/presentation/manger/home_cubit.dart';
import 'package:baseqat/modules/home/presentation/manger/home_state.dart';
import 'package:baseqat/modules/home/presentation/view/artists_section.dart';
import 'package:baseqat/modules/home/presentation/view/artworks_section.dart';
import 'package:baseqat/modules/home/presentation/widgets/header_section_widget.dart';
import 'package:baseqat/modules/home/presentation/widgets/highlights_section.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeTabletView extends StatelessWidget {
  const HomeTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = HomeRepositoryImpl(
      HomeRemoteDataSourceImpl(Supabase.instance.client),
    );

    return BlocProvider(
      create: (_) => HomeCubit(repo)..loadAll(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(
              child: Text(
                'Error: ${state.failure.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final s = state as HomeLoaded;
          final info = s.info;
          final artists = s.artists;
          final artworks = s.artworks;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderSection(
                    title: info!.mainTitle,
                    subtitle: info.subTitle,
                    maxTextWidthFraction: 0.8,
                  ),
                  SizedBox(height: 32.h),
                  HighlightsSection(highlights: info),
                  SizedBox(height: 32.h),
                  ArtistsSection(artists: artists),
                  SizedBox(height: 32.h),
                  ArtworksSection(artworks: artworks),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
