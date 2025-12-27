import 'package:flutter/material.dart';

class ExpandableSearchBar extends StatefulWidget {
  final double availableWidth;
  final double iconSize;
  final VoidCallback onExpand;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onDismissKeyboard;

  const ExpandableSearchBar({
    super.key,
    required this.availableWidth,
    required this.iconSize,
    required this.onExpand,
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
          color: _isExpanded
              ? const Color(0xFF2A2A2A)
              : Colors.white.withOpacity(0.15),
        ),
        child: _isExpanded ? _buildExpandedContent() : _buildCollapsedContent(),
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return const Center(
      child: Icon(Icons.search, color: Colors.white70, size: 24),
    );
  }

  Widget _buildExpandedContent() {
    return Stack(
      children: [
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 12, right: 8),
              child: Icon(Icons.search, color: Color(0xFFB9E479), size: 24),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: widget.onSearchChanged,
                enableInteractiveSelection: false,
                style: const TextStyle(
                  color: Color(0xFFF2F2F2),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'TYPE TO FILTER',
                  hintStyle: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.only(
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
                  child: const Icon(Icons.close, color: Color(0xFFF2F2F2), size: 24),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
