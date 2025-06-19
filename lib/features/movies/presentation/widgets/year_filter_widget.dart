import 'package:flutter/material.dart';

/// 年代フィルター機能を提供するウィジェット
/// 
/// MovieSearchDelegateから複雑な年代選択ロジックを分離し、
/// 再利用可能で保守しやすい形にする。
class YearFilterWidget extends StatelessWidget {
  final String? selectedYear;
  final ValueChanged<String?> onYearChanged;
  final Color? iconColor;
  final String tooltip;

  const YearFilterWidget({
    super.key,
    required this.selectedYear,
    required this.onYearChanged,
    this.iconColor,
    this.tooltip = '公開年で絞り込み',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.date_range,
          color: selectedYear != null 
              ? (iconColor ?? theme.colorScheme.primary)
              : null,
        ),
        tooltip: tooltip,
        onSelected: (year) {
          onYearChanged(year == YearFilterOptions.allYears ? null : year);
        },
        itemBuilder: (context) => _buildYearMenuItems(context),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildYearMenuItems(BuildContext context) {
    final theme = Theme.of(context);
    final yearOptions = YearFilterOptions.getYearOptions();
    
    return yearOptions.map((yearOption) {
      final isSelected = selectedYear == yearOption.value || 
          (selectedYear == null && yearOption.value == YearFilterOptions.allYears);
      
      return PopupMenuItem<String>(
        value: yearOption.value,
        child: Row(
          children: [
            Icon(
              yearOption.icon,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(yearOption.label),
            if (isSelected) ...[
              const Spacer(),
              Icon(
                Icons.check,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      );
    }).toList();
  }
}

/// 年代フィルターの選択肢を表すクラス
class YearFilterOption {
  final String value;
  final String label;
  final IconData icon;

  const YearFilterOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

/// 年代フィルターのオプション管理クラス
class YearFilterOptions {
  static const String allYears = 'all';
  
  /// 年代フィルターの選択肢を生成
  static List<YearFilterOption> getYearOptions() {
    final currentYear = DateTime.now().year;
    final options = <YearFilterOption>[
      const YearFilterOption(
        value: allYears,
        label: '全ての年',
        icon: Icons.clear,
      ),
    ];
    
    // 現在の年から1900年まで5年間隔で生成
    for (int year = currentYear; year >= 1900; year -= 5) {
      options.add(
        YearFilterOption(
          value: year.toString(),
          label: '$year年代',
          icon: Icons.calendar_today,
        ),
      );
    }
    
    return options;
  }
  
  /// 選択された年から範囲の開始年と終了年を取得
  static YearRange? getYearRange(String? selectedYear) {
    if (selectedYear == null || selectedYear == allYears) {
      return null;
    }
    
    final year = int.tryParse(selectedYear);
    if (year == null) {
      return null;
    }
    
    return YearRange(
      start: year,
      end: year + 4, // 5年間隔なので+4
    );
  }
  
  /// 映画の公開年が選択された年代範囲に含まれるかチェック
  static bool isInYearRange(String? movieReleaseDate, String? selectedYear) {
    if (selectedYear == null || selectedYear == allYears) {
      return true;
    }
    
    if (movieReleaseDate?.isEmpty != false) {
      return false;
    }
    
    final yearRange = getYearRange(selectedYear);
    if (yearRange == null) {
      return false;
    }
    
    try {
      final movieYear = int.parse(movieReleaseDate!.substring(0, 4));
      return movieYear >= yearRange.start && movieYear <= yearRange.end;
    } catch (e) {
      return false;
    }
  }
}

/// 年代範囲を表すクラス
class YearRange {
  final int start;
  final int end;

  const YearRange({
    required this.start,
    required this.end,
  });
  
  bool contains(int year) {
    return year >= start && year <= end;
  }
  
  @override
  String toString() => '$start年-$end年';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

/// 年代フィルター状態表示ウィジェット
class YearFilterIndicator extends StatelessWidget {
  final String? selectedYear;
  final int? resultCount;
  final VoidCallback? onClear;

  const YearFilterIndicator({
    super.key,
    required this.selectedYear,
    this.resultCount,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedYear == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              resultCount != null
                  ? '$selectedYear年代で絞り込み中 ($resultCount件)'
                  : '$selectedYear年代で絞り込み中',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onClear != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClear,
              child: Icon(
                Icons.close,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 年代フィルターのミックスイン
mixin YearFilterMixin {
  String? _selectedYear;
  
  String? get selectedYear => _selectedYear;
  
  void setSelectedYear(String? year) {
    _selectedYear = year;
  }
  
  void clearYearFilter() {
    _selectedYear = null;
  }
  
  bool isMovieInYearRange(String? movieReleaseDate) {
    return YearFilterOptions.isInYearRange(movieReleaseDate, _selectedYear);
  }
  
  List<T> filterMoviesByYear<T>(
    List<T> movies,
    String? Function(T movie) getReleaseDateFunc,
  ) {
    if (_selectedYear == null) {
      return movies;
    }
    
    return movies.where((movie) {
      final releaseDate = getReleaseDateFunc(movie);
      return YearFilterOptions.isInYearRange(releaseDate, _selectedYear);
    }).toList();
  }
}