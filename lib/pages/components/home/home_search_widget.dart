import 'package:flutter/material.dart';

class HomeSearchWidget extends StatefulWidget {
  final Function(String)? onSearch;
  final String? value;

  const HomeSearchWidget({super.key, this.onSearch, this.value});

  @override
  HomeSearchWidgetState createState() => HomeSearchWidgetState();
}

class HomeSearchWidgetState extends State<HomeSearchWidget> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSearch() {
    if (widget.onSearch != null &&
        _controller.text.isNotEmpty &&
        _controller.text.length > 2) {
      widget.onSearch!(_controller.text);
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() => _isFocused = hasFocus);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha:0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _controller,
            onEditingComplete: _handleSearch,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              hintText: 'Rechercher...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _isFocused
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
                size: 24,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  setState(() => _controller.clear());
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}