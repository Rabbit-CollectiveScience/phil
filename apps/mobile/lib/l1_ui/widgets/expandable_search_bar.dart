import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ExpandableSearchBar extends StatefulWidget {
  final double availableWidth;
  final double iconSize;
  final VoidCallback onExpand;
  final VoidCallback? onCollapse;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onDismissKeyboard;

  const ExpandableSearchBar({
    super.key,
    required this.availableWidth,
    required this.iconSize,
    required this.onExpand,
    this.onCollapse,
    required this.onSearchChanged,
    this.onDismissKeyboard,
  });

  @override
  State<ExpandableSearchBar> createState() => ExpandableSearchBarState();
}

class ExpandableSearchBarState extends State<ExpandableSearchBar> {
  static const Duration _animationDuration = Duration(milliseconds: 300);

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSearchOverlay = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isExpanded {
    return _showSearchOverlay || _controller.text.isNotEmpty;
  }

  String get searchText => _controller.text;

  void expand() {
    setState(() {
      _showSearchOverlay = true;
    });
    _focusNode.requestFocus();
    widget.onExpand();
  }

  void collapse() {
    _focusNode.unfocus();
    if (_controller.text.isEmpty) {
      setState(() {
        _showSearchOverlay = false;
      });
      widget.onCollapse?.call();
    }
    widget.onDismissKeyboard?.call();
  }

  void clearSearch() {
    setState(() {
      _controller.clear();
      widget.onSearchChanged('');

      // Context-aware behavior
      if (_focusNode.hasFocus) {
        _showSearchOverlay = true; // Keep expanded, keyboard stays
      } else {
        _showSearchOverlay = false; // Collapse completely
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isExpanded) {
          expand();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeOutCubic,
        width: _isExpanded ? widget.availableWidth : widget.iconSize,
        height: widget.iconSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: _isExpanded ? AppColors.darkGrey : AppColors.offWhite15,
        ),
        child: _isExpanded ? _buildExpandedContent() : _buildCollapsedContent(),
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Center(
      child: Icon(Icons.search, color: AppColors.offWhite70, size: 24),
    );
  }

  Widget _buildExpandedContent() {
    return Stack(
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 12, right: 8),
              child: Icon(Icons.search, color: AppColors.limeGreen, size: 24),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: widget.onSearchChanged,
                enableInteractiveSelection: false,
                style: TextStyle(
                  color: AppColors.offWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'TYPE TO FILTER',
                  hintStyle: TextStyle(
                    color: AppColors.offWhite38,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(
                    top: 12,
                    bottom: 12,
                    right: 48,
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return GestureDetector(
                onTap: clearSearch,
                child: Container(
                  width: 48,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close,
                    color: AppColors.offWhite,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
