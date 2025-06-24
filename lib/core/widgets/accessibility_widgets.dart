import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? tooltip;
  final ButtonStyle? style;

  const AccessibleButton({
    super.key,
    this.onPressed,
    required this.child,
    this.semanticLabel,
    this.tooltip,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: onPressed != null,
        child: button,
      );
    }

    return button;
  }
}

class AccessibleIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String semanticLabel;
  final String? tooltip;
  final double? iconSize;
  final Color? color;

  const AccessibleIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    required this.semanticLabel,
    this.tooltip,
    this.iconSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: iconSize,
      color: color,
      tooltip: tooltip ?? semanticLabel,
    );

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
  }
}

class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      margin: margin,
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: card,
      );
    }

    if (semanticLabel != null || semanticHint != null) {
      card = Semantics(
        label: semanticLabel,
        hint: semanticHint,
        button: onTap != null,
        child: card,
      );
    }

    return card;
  }
}

class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? semanticLabel;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final VoidCallback? onTap;

  const AccessibleTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.semanticLabel,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        textField: true,
        child: field,
      );
    }

    return field;
  }
}

class AccessibleImage extends StatelessWidget {
  final String imageUrl;
  final String semanticLabel;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  const AccessibleImage({
    super.key,
    required this.imageUrl,
    required this.semanticLabel,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return loadingWidget ??
              Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.error,
                  color: Colors.grey,
                ),
              );
        },
      ),
    );
  }
}

class AccessibleRating extends StatelessWidget {
  final double rating;
  final double maxRating;
  final String semanticLabel;
  final Widget Function(BuildContext, int, bool) itemBuilder;
  final int itemCount;

  const AccessibleRating({
    super.key,
    required this.rating,
    this.maxRating = 5.0,
    required this.semanticLabel,
    required this.itemBuilder,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      value: '$rating / $maxRating',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(itemCount, (index) {
          return itemBuilder(context, index, index < rating);
        }),
      ),
    );
  }
}

class AccessibleTabBar extends StatelessWidget {
  final TabController controller;
  final List<Tab> tabs;
  final String? semanticLabel;

  const AccessibleTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'タブバー',
      child: TabBar(
        controller: controller,
        tabs: tabs.map((tab) {
          return Semantics(
            label: tab.text ?? 'タブ',
            button: true,
            selected: controller.index == tabs.indexOf(tab),
            child: tab,
          );
        }).toList(),
      ),
    );
  }
}

class ScreenReaderText extends StatelessWidget {
  final String text;
  final Widget? child;

  const ScreenReaderText({
    super.key,
    required this.text,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      child: child ?? const SizedBox.shrink(),
    );
  }
}

class FocusableContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool autofocus;

  const FocusableContainer({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.autofocus = false,
  });

  @override
  State<FocusableContainer> createState() => _FocusableContainerState();
}

class _FocusableContainerState extends State<FocusableContainer> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      focusable: true,
      focused: _isFocused,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (event.logicalKey.keyLabel == 'Enter' ||
              event.logicalKey.keyLabel == 'Space') {
            widget.onTap?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
            widget.onTap?.call();
          },
          child: Container(
            decoration: _isFocused
                ? BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class AccessibilityHelper {
  static void announceToScreenReader(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static void focusOnWidget(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key.currentContext != null) {
        FocusScope.of(key.currentContext!).requestFocus();
      }
    });
  }

  static String formatRatingForScreenReader(double rating, double maxRating) {
    return '$rating / $maxRating 星評価';
  }

  static String formatDateForScreenReader(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  static String formatMovieInfo(String title, int? year, double? rating) {
    String info = '映画: $title';
    if (year != null) {
      info += ', 公開年: $year年';
    }
    if (rating != null) {
      info += ', 評価: ${rating.toStringAsFixed(1)}';
    }
    return info;
  }
}
