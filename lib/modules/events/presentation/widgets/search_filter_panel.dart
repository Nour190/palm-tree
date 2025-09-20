import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import '../manger/search_cubit.dart';
import '../manger/search_state.dart';

class SearchFilterPanel extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback? onClose;

  const SearchFilterPanel({
    super.key,
    this.isDesktop = true,
    this.onClose,
  });

  static void showFilterBottomSheet(BuildContext context) {
    final searchCubit = context.read<SearchCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: searchCubit,
        child: Container(
          height: MediaQuery.of(bottomSheetContext).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: const SearchFilterPanel(isDesktop: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is! SearchLoaded) return const SizedBox.shrink();

        if (isDesktop) {
          return _buildDesktopFilter(context, state);
        } else {
          return _buildMobileFilter(context, state);
        }
      },
    );
  }

  Widget _buildDesktopFilter(BuildContext context, SearchLoaded state) {
    return Container(
      width: 300.sW,
      margin: EdgeInsets.all(16.sW),
      padding: EdgeInsets.all(16.sW),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildFilterContent(context, state),
    );
  }

  Widget _buildMobileFilter(BuildContext context, SearchLoaded state) {
    return Container(
      padding: EdgeInsets.all(20.sW),
      child: Column(
        children: [
          Container(
            width: 40.sW,
            height: 4.sH,
            decoration: BoxDecoration(
              color: AppColor.gray400,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.sH),
          Expanded(child: _buildFilterContent(context, state)),
        ],
      ),
    );
  }

  Widget _buildFilterContent(BuildContext context, SearchLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filter & Sort',
              style: TextStyleHelper.instance.title16BoldInter,
            ),
            IconButton(
              onPressed: () {
                if (isDesktop) {
                  context.read<SearchCubit>().toggleFilter();
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(
                Icons.close,
                size: 20.sW,
                color: AppColor.gray600,
              ),
            ),
          ],
        ),

        SizedBox(height: 16.sH),

        // Categories Section
        Text(
          'Categories',
          style: TextStyleHelper.instance.body14MediumInter,
        ),
        SizedBox(height: 8.sH),

        Wrap(
          spacing: 8.sW,
          runSpacing: 8.sH,
          children: [
            _buildCategoryChip(
              context,
              'Artist',
              FilterCategory.artist,
              state.selectedCategories.contains(FilterCategory.artist),
            ),
            _buildCategoryChip(
              context,
              'Artwork',
              FilterCategory.artwork,
              state.selectedCategories.contains(FilterCategory.artwork),
            ),
            _buildCategoryChip(
              context,
              'Gallery',
              FilterCategory.gallery,
              state.selectedCategories.contains(FilterCategory.gallery),
            ),
          ],
        ),

        SizedBox(height: 20.sH),

        // Sort Section
        Text(
          'Sort By',
          style: TextStyleHelper.instance.body14MediumInter,
        ),
        SizedBox(height: 8.sH),

        Wrap(
          spacing: 8.sW,
          runSpacing: 8.sH,
          children: [
            _buildSortChip(
              context,
              'Date (Newest)',
              SortOption.dateNewest,
              state.selectedSortOption == SortOption.dateNewest,
            ),
            _buildSortChip(
              context,
              'Date (Oldest)',
              SortOption.dateOldest,
              state.selectedSortOption == SortOption.dateOldest,
            ),
            _buildSortChip(
              context,
              'Name (A-Z)',
              SortOption.nameAZ,
              state.selectedSortOption == SortOption.nameAZ,
            ),
            _buildSortChip(
              context,
              'Name (Z-A)',
              SortOption.nameZA,
              state.selectedSortOption == SortOption.nameZA,
            ),
          ],
        ),

        SizedBox(height: 20.sH),

        // Clear filters button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              context.read<SearchCubit>().updateFilterCategories({
                FilterCategory.artist,
                FilterCategory.artwork,
                FilterCategory.gallery,
              });
              context.read<SearchCubit>().updateSortOption(SortOption.dateNewest);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColor.gray400),
              padding: EdgeInsets.symmetric(vertical: 12.sH),
            ),
            child: Text(
              'Reset Filters',
              style: TextStyleHelper.instance.body14MediumInter
                  .copyWith(color: AppColor.gray600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
      BuildContext context,
      String label,
      FilterCategory category,
      bool isSelected,
      ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyleHelper.instance.caption12RegularInter.copyWith(
          color: isSelected ? AppColor.white : AppColor.gray700,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        final currentCategories = (context.read<SearchCubit>().state as SearchLoaded).selectedCategories;
        final newCategories = Set<FilterCategory>.from(currentCategories);

        if (selected) {
          newCategories.add(category);
        } else {
          newCategories.remove(category);
        }

        // Ensure at least one category is selected
        if (newCategories.isNotEmpty) {
          context.read<SearchCubit>().updateFilterCategories(newCategories);
        }
      },
      selectedColor: AppColor.primaryColor,
      backgroundColor: AppColor.gray100,
      checkmarkColor: AppColor.white,
    );
  }

  Widget _buildSortChip(
      BuildContext context,
      String label,
      SortOption sortOption,
      bool isSelected,
      ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyleHelper.instance.caption12RegularInter.copyWith(
          color: isSelected ? AppColor.white : AppColor.gray700,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          context.read<SearchCubit>().updateSortOption(sortOption);
        }
      },
      selectedColor: AppColor.primaryColor,
      backgroundColor: AppColor.gray100,
      checkmarkColor: AppColor.white,
    );
  }
}
