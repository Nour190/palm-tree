// lib/modules/events/presentation/utils/events_ui_utils.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';

import 'package:flutter/services.dart';

typedef SearchFieldBuilder =
    Widget Function(
      BuildContext context,
      TextEditingController? controller,
      ValueChanged<String>? onChanged,
      ValueChanged<String>? onSubmitted,
      String hintText,
    );

/// Style "class" you can pass to control visuals & layout.
class SearchHeaderStyle {
  final double breakpoint; // width where layout switches to horizontal
  final EdgeInsetsGeometry padding;
  final double gap;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Color? fillColor; // header background
  final Color? borderColor; // search border
  final BorderRadiusGeometry borderRadius;
  final double elevation;
  final Widget? prefixIcon; // search prefix (e.g., your asset icon)
  final double? maxWidth; // cap header width on large screens

  const SearchHeaderStyle({
    this.breakpoint = 720,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 8),
    this.gap = 12,
    this.titleStyle,
    this.subtitleStyle,
    this.fillColor,
    this.borderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.elevation = 0,
    this.prefixIcon,
    this.maxWidth,
  });
}

/// Title + Search, responsive for mobile/web.
/// - Use [searchFieldBuilder] to plug in your existing CustomSearchView.
/// - Or let it fall back to a built-in, nicely-styled TextField.
class EventsSearchHeader extends StatelessWidget {
  const EventsSearchHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'What do you want to see today?',
    this.leading,
    this.actions,
    this.autofocus = false,
    this.searchFieldBuilder,
    this.style = const SearchHeaderStyle(),
  });

  final String title;
  final String? subtitle;

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;

  final Widget? leading;
  final List<Widget>? actions;
  final bool autofocus;

  final SearchFieldBuilder? searchFieldBuilder;
  final SearchHeaderStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle =
        style.titleStyle ??
        theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600);
    final subtitleStyle =
        style.subtitleStyle ??
        theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= style.breakpoint;

        final content = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: style.maxWidth ?? 1200),
          child: Padding(
            padding: style.padding,
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        SizedBox(width: style.gap),
                      ],
                      Expanded(
                        child: _TitleBlock(
                          title: title,
                          subtitle: subtitle,
                          titleStyle: titleStyle,
                          subtitleStyle: subtitleStyle,
                        ),
                      ),
                      SizedBox(width: style.gap),
                      Flexible(flex: 2, child: _buildSearch(context, theme)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        SizedBox(height: style.gap),
                      ],
                      _TitleBlock(
                        title: title,
                        subtitle: subtitle,
                        titleStyle: titleStyle,
                        subtitleStyle: subtitleStyle,
                      ),
                      SizedBox(height: style.gap),
                      _buildSearch(context, theme),
                    ],
                  ),
          ),
        );

        return Material(
          color: style.fillColor ?? Colors.transparent,
          elevation: style.elevation,
          borderRadius: style.borderRadius,
          child: content,
        );
      },
    );
  }

  Widget _buildSearch(BuildContext context, ThemeData theme) {
    if (searchFieldBuilder != null) {
      // Plug in your existing CustomSearchView here.
      return searchFieldBuilder!(
        context,
        controller,
        onChanged,
        onSubmitted,
        hintText,
      );
    }

    // Built-in search field fallback (no external deps).
    return _DefaultSearchField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      hintText: hintText,
      prefix: style.prefixIcon ?? const Icon(Icons.search),
      borderColor: style.borderColor ?? theme.colorScheme.outlineVariant,
      fillColor: theme.colorScheme.surface,
      autofocus: autofocus,
      borderRadius: style.borderRadius,
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
  });

  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(subtitle!, style: subtitleStyle),
          ),
      ],
    );
  }
}

class _DefaultSearchField extends StatefulWidget {
  const _DefaultSearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.hintText,
    required this.prefix,
    required this.borderColor,
    required this.fillColor,
    required this.borderRadius,
    required this.autofocus,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final Widget prefix;
  final Color borderColor;
  final Color fillColor;
  final BorderRadiusGeometry borderRadius;
  final bool autofocus;

  @override
  State<_DefaultSearchField> createState() => _DefaultSearchFieldState();
}

class _DefaultSearchFieldState extends State<_DefaultSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderSide: BorderSide(color: widget.borderColor),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    );

    return Shortcuts(
      shortcuts: {
        // Press "/" to focus the search (handy on web/desktop).
        LogicalKeySet(LogicalKeyboardKey.slash): const ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _focusNode.requestFocus();
              return null;
            },
          ),
        },
        child: Focus(
          onFocusChange: (_) => setState(() {}),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            textInputAction: TextInputAction.search,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefix,
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear',
                      onPressed: () {
                        _controller.clear();
                        widget.onChanged?.call('');
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
              filled: true,
              fillColor: widget.fillColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: baseBorder,
              enabledBorder: baseBorder,
              focusedBorder: baseBorder.copyWith(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EventsCategoryChips extends StatefulWidget {
  const EventsCategoryChips({
    super.key,
    required this.categories,
    required this.onTap,
    this.spacing,
    this.scrollPhysics,
    this.padding,
    this.height,
    this.enableScrollIndicators = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  final List<CategoryModel> categories;
  final ValueChanged<int> onTap;
  final double? spacing;
  final ScrollPhysics? scrollPhysics;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final bool enableScrollIndicators;
  final Duration animationDuration;

  @override
  State<EventsCategoryChips> createState() => _EventsCategoryChipsState();
}

class _EventsCategoryChipsState extends State<EventsCategoryChips>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _showLeftIndicator = false;
  bool _showRightIndicator = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollIndicators);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollIndicators();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!mounted || !widget.enableScrollIndicators) return;

    final bool showLeft =
        _scrollController.hasClients && _scrollController.offset > 0;
    final bool showRight =
        _scrollController.hasClients &&
        _scrollController.offset < _scrollController.position.maxScrollExtent;

    if (showLeft != _showLeftIndicator || showRight != _showRightIndicator) {
      setState(() {
        _showLeftIndicator = showLeft;
        _showRightIndicator = showRight;
      });
    }
  }

  double get _responsiveSpacing {
    if (widget.spacing != null) return widget.spacing!;
    return _isWeb ? 20.0 : 16.0;
  }

  EdgeInsetsGeometry get _responsivePadding {
    if (widget.padding != null) return widget.padding!;
    return EdgeInsets.symmetric(
      horizontal: _isWeb ? 24.0 : 16.0,
      vertical: 8.0,
    );
  }

  double get _responsiveHeight {
    if (widget.height != null) return widget.height!;
    return _isWeb ? 56.0 : 48.0;
  }

  bool get _isWeb => kIsWeb || MediaQuery.of(context).size.width > 768;

  Widget _buildScrollIndicator({required bool isLeft}) {
    return AnimatedOpacity(
      opacity: isLeft
          ? (_showLeftIndicator ? 1.0 : 0.0)
          : (_showRightIndicator ? 1.0 : 0.0),
      duration: widget.animationDuration,
      child: Container(
        width: 32,
        height: _responsiveHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
            colors: [AppColor.white, AppColor.white.withOpacity(0.0)],
          ),
        ),
        child: Icon(
          isLeft ? Icons.chevron_left : Icons.chevron_right,
          color: AppColor.gray.withOpacity(0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _responsiveHeight,
      child: Stack(
        children: [
          // Main scrollable content
          Scrollbar(
            controller: _scrollController,
            thumbVisibility: _isWeb,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics:
                  widget.scrollPhysics ??
                  const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
              padding: _responsivePadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  widget.categories.length * 2 - 1, // Include spacing
                  (index) {
                    if (index.isOdd) {
                      // Spacing between chips
                      return SizedBox(width: _responsiveSpacing);
                    }

                    final chipIndex = index ~/ 2;
                    final category = widget.categories[chipIndex];

                    return AnimatedScale(
                      scale: category.isSelected ? 1.05 : 1.0,
                      duration: widget.animationDuration,
                      child: EnhancedCategoryChip(
                        category: category,
                        onTap: () => widget.onTap(chipIndex),
                        isWeb: _isWeb,
                        animationDuration: widget.animationDuration,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Left scroll indicator
          if (widget.enableScrollIndicators)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildScrollIndicator(isLeft: true),
            ),

          // Right scroll indicator
          if (widget.enableScrollIndicators)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildScrollIndicator(isLeft: false),
            ),
        ],
      ),
    );
  }
}

/// Enhanced category chip widget with improved styling and animations using AppColor
class EnhancedCategoryChip extends StatefulWidget {
  const EnhancedCategoryChip({
    super.key,
    required this.category,
    required this.onTap,
    required this.isWeb,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  final CategoryModel category;
  final VoidCallback onTap;
  final bool isWeb;
  final Duration animationDuration;

  @override
  State<EnhancedCategoryChip> createState() => _EnhancedCategoryChipState();
}

class _EnhancedCategoryChipState extends State<EnhancedCategoryChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: widget.animationDuration,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isWeb ? 12 : 24),
          boxShadow: [
            if (widget.category.isSelected || _isHovered)
              BoxShadow(
                color: AppColor.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.isWeb ? 12 : 24),
            splashColor: AppColor.primaryColor.withOpacity(0.1),
            highlightColor: AppColor.primaryColor.withOpacity(0.05),
            child: AnimatedContainer(
              duration: widget.animationDuration,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isWeb ? 17 : 14,
                vertical: widget.isWeb ? 11 : 6,
              ),
              decoration: BoxDecoration(
                color: widget.category.isSelected
                    ? AppColor.primaryColor
                    : _isHovered
                    ? AppColor.gray200
                    : AppColor.white,
                borderRadius: BorderRadius.circular(widget.isWeb ? 12 : 24),
                border: Border.all(
                  color: widget.category.isSelected
                      ? AppColor.primaryColor
                      : AppColor.gray.withOpacity(0.3),
                  width: widget.category.isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                widget.category.title,
                style:widget.category.isSelected?TextStyleHelper.instance.body9MediumInter.copyWith(color: AppColor.white,)
               :TextStyleHelper.instance.caption9RegularInter.copyWith(color:AppColor.black )
                // TextStyle(
                //   color: widget.category.isSelected
                //       ? AppColor.white
                //       : AppColor.black,
                //   fontWeight: widget.category.isSelected
                //       ? FontWeight.w600
                //       : FontWeight.w500,
                //   fontSize: widget.isWeb ? 14 : 13,
                // ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Category model
class CategoryModel {
  final String title;
  final bool isSelected;

  const CategoryModel({required this.title, required this.isSelected});

  // Helper method to create a copy with updated selection state
  CategoryModel copyWith({String? title, bool? isSelected}) {
    return CategoryModel(
      title: title ?? this.title,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// Generic "Coming soon" placeholder.
class ComingSoon extends StatelessWidget {
  const ComingSoon(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title coming soon',
        style: TextStyleHelper.instance.title16BoldInter,
      ),
    );
  }
}
