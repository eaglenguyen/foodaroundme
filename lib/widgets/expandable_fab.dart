import 'package:flutter/material.dart';

@immutable
class ExpandableFab extends StatefulWidget {

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;
  final ValueChanged<bool>? onOpenChanged;  // callback for togglebutton



  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
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
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return IgnorePointer(
      ignoring: !_open,
      child: AnimatedOpacity(
        opacity: _open ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          width: 40,
          height: 80,
          child: Center(
            child: Material(
              shape: const CircleBorder(
                side: BorderSide(
                  color: Colors.blueGrey, // border color
                  width: 2,
                ),
              ),
              color: Colors.black54,
              clipBehavior: Clip.antiAlias,
              elevation: 4,
              child: InkWell(
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;

    for (var i = 0; i < count; i++) {
      children.add(
        _HorizontalExpandingActionButton(
          index: i,
          totalCount: count,
          spacing: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),

          /// ⭐ Updated — main FAB now extended with text
          child: FloatingActionButton.extended(
            onPressed: _toggle,
            label: const Text("FoodAroundMe"),
            foregroundColor: Colors.white, // text color
            backgroundColor: Colors.black87, // button color,
          ),
        ),
      ),
    );
  }
}

@immutable
class _HorizontalExpandingActionButton extends StatelessWidget {
  final int index;
  final int totalCount;
  final double spacing;
  final Animation<double> progress;
  final Widget child;

  const _HorizontalExpandingActionButton({
    required this.index,
    required this.totalCount,
    required this.spacing,
    required this.progress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        // Center items around FAB
        final dx = (chipOffsets[index] + 53.0) * progress.value;

        return Positioned(
          bottom: 0, // wont register if out of parent paint bounds aka negative
          left: MediaQuery.of(context).size.width / 2 - 24 + dx,
          child: FadeTransition(
            opacity: progress,
            child: child!,
          ),
        )
        ;
      },
      child: child,
    );
  }
}

final List<double> chipOffsets = [
  -120, // chip 0
  -40,  // chip 1 (closer to chip 0)
  40,   // chip 2 (larger gap)
  120,  // chip 3
];

