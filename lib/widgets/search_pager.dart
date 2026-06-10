import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchPager extends StatelessWidget {
  final int page;
  final int totalPage;
  final int totalCount;
  final int size;
  final List<int> pageSizes;
  final void Function(int page) onPageChange;
  final void Function(int size) onSizeChange;

  const SearchPager({
    super.key,
    required this.page,
    required this.totalPage,
    required this.totalCount,
    required this.size,
    required this.pageSizes,
    required this.onPageChange,
    required this.onSizeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$totalCount件',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(width: 8),
          _pageBtn(Icons.first_page, page > 1, () => onPageChange(1)),
          _pageBtn(Icons.chevron_left, page > 1, () => onPageChange(page - 1)),
          Text(
            '$page / $totalPage',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
          ),
          _pageBtn(Icons.chevron_right, page < totalPage, () => onPageChange(page + 1)),
          _pageBtn(Icons.last_page, page < totalPage, () => onPageChange(totalPage)),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: pageSizes.contains(size) ? size : pageSizes.first,
            isDense: true,
            dropdownColor: AppColors.surfaceVariant,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
            underline: const SizedBox(),
            items: pageSizes
                .map((s) => DropdownMenuItem(value: s, child: Text('$s件')))
                .toList(),
            onChanged: (v) {
              if (v != null) onSizeChange(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _pageBtn(IconData icon, bool enabled, VoidCallback onTap) => InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      );
}
