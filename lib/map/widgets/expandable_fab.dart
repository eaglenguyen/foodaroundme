import 'package:flutter/material.dart';

@immutable
class ExpandableFab extends StatefulWidget {

  final bool? initialOpen;
  final Widget sliderChild;
  final ValueChanged<bool>? onOpenChanged;  // callback for togglebutton



  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.sliderChild,
    this.onOpenChanged,
  });



  @override
  State<ExpandableFab> createState() => _ExpandableFabState();   // object from ExpandableFabState
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      //call callback
      widget.onOpenChanged?.call(_open);

      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
     child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FadeTransition(
          opacity: _expandAnimation,
          child: SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Padding(padding: const EdgeInsets.only(bottom: 12),
            child: IgnorePointer(
              ignoring: !_open,
              child: widget.sliderChild,
            ),
            ),
        ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _open ? _buildTapToCloseFab() : _buildTapToOpenFab(),
        )
      ],
    ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        shape: const CircleBorder(
          side: BorderSide(color: Colors.blueGrey, width: 2),
        ),
        color: Colors.black54,
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: InkWell(
          onTap: _toggle,
          child: const Icon(Icons.close, color: Colors.white),
        ),
      ),
    );
  }


  Widget _buildTapToOpenFab() {
    return FloatingActionButton.extended(
      onPressed: _toggle,
      label: const Icon(Icons.directions_walk),
      foregroundColor: Colors.white,
      backgroundColor: Colors.black87,
    );
  }

}


