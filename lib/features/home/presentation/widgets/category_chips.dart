import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../category/data/category_model.dart';

const Color _activeChipLight = Color(0xFF000000);
const Color _activeChipDark = Color(0xFFFFFFFF);

/// Indicateur qui glisse entre les catégories (noir en light mode, blanc en dark mode).
class CategoryChips extends StatefulWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedValue,
    required this.onSelected,
    this.categoryAllLabel,
  });

  final List<CategoryModel> categories;
  final String selectedValue;
  final ValueChanged<String> onSelected;
  final String? categoryAllLabel;

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _chipKeys = [];
  final GlobalKey _stackKey = GlobalKey();
  double _pillLeft = 0;
  double _pillWidth = 60;
  bool _pillInitialized = false;

  List<String> _buildValues() {
    final l10n = AppLocalizations.of(context)!;
    final allLabel = widget.categoryAllLabel ?? l10n.categoryAll;
    final allLabelNorm = allLabel.trim().toLowerCase();
    final bySlug = <String, CategoryModel>{};
    for (final c in widget.categories) {
      final slug = c.slug.trim().toLowerCase();
      final nameNorm = c.name.trim().toLowerCase();
      if (slug == 'all' || nameNorm == 'all' || nameNorm == allLabelNorm) continue;
      bySlug.putIfAbsent(slug, () => c);
    }
    final fromDb = bySlug.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    return ['All', ...fromDb.map((c) => c.slug)];
  }

  void _updatePillPosition() {
    final values = _buildValues();
    final index = values.indexOf(widget.selectedValue);
    if (index < 0 || index >= _chipKeys.length) return;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) return;
    final chipBox = _chipKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (chipBox == null || !chipBox.hasSize) return;
    final pos = chipBox.localToGlobal(Offset.zero, ancestor: stackBox);
    setState(() {
      _pillLeft = pos.dx;
      _pillWidth = chipBox.size.width;
      _pillInitialized = true;
    });
  }

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final values = _buildValues();
      final index = values.indexOf(widget.selectedValue);
      if (index < 0) return;
      final r = context.responsive;
      const chipMinWidth = 80.0;
      final gap = r.gap;
      final offset = (index * (chipMinWidth + gap) - 24).clamp(0.0, double.infinity);
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePillPosition());
  }

  @override
  void didUpdateWidget(CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updatePillPosition());
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final r = context.responsive;
    final colorScheme = Theme.of(context).colorScheme;
    final allLabel = widget.categoryAllLabel ?? l10n.categoryAll;
    final allLabelNorm = allLabel.trim().toLowerCase();
    final bySlug = <String, CategoryModel>{};
    for (final c in widget.categories) {
      final slug = c.slug.trim().toLowerCase();
      final nameNorm = c.name.trim().toLowerCase();
      if (slug == 'all' || nameNorm == 'all' || nameNorm == allLabelNorm) continue;
      bySlug.putIfAbsent(slug, () => c);
    }
    final fromDb = bySlug.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    final labels = [allLabel, ...fromDb.map((c) => c.name)];
    final values = ['All', ...fromDb.map((c) => c.slug)];
    const chipHeight = 36.0;

    while (_chipKeys.length < labels.length) {
      _chipKeys.add(GlobalKey());
    }
    while (_chipKeys.length > labels.length) {
      _chipKeys.removeLast();
    }

    return SizedBox(
      height: chipHeight,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Stack(
          key: _stackKey,
          alignment: Alignment.centerLeft,
          children: [
            if (_pillInitialized && _pillWidth > 0)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeInOutCubic,
                left: _pillLeft,
                top: 0,
                bottom: 0,
                width: _pillWidth,
                child: IgnorePointer(
                  child: Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? _activeChipDark : _activeChipLight,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppShadows.chip(context),
                        ),
                      );
                    },
                  ),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < labels.length; i++) ...[
                  if (i > 0) SizedBox(width: r.gap),
                  _ChipItem(
                    key: _chipKeys[i],
                    label: labels[i],
                    isSelected: values[i] == widget.selectedValue,
                    colorScheme: colorScheme,
                    r: r,
                    chipHeight: chipHeight,
                    onTap: () => widget.onSelected(values[i]),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipItem extends StatelessWidget {
  const _ChipItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.colorScheme,
    required this.r,
    required this.chipHeight,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final ColorScheme colorScheme;
  final dynamic r;
  final double chipHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isSelected
        ? Colors.transparent
        : (isDark ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.white);
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: chipHeight,
          padding: EdgeInsets.symmetric(horizontal: r.isCompactSmall ? 16 : 20),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: r.bodyFontSize,
            ),
          ),
        ),
      ),
    );
  }
}
