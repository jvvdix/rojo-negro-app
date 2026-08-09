import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import 'tap_scale.dart';

const Map<int, List<List<bool>>> _pipLayouts = {
  1: [
    [false, false, false],
    [false, true, false],
    [false, false, false],
  ],
  2: [
    [true, false, false],
    [false, false, false],
    [false, false, true],
  ],
  3: [
    [true, false, false],
    [false, true, false],
    [false, false, true],
  ],
  4: [
    [true, false, true],
    [false, false, false],
    [true, false, true],
  ],
  5: [
    [true, false, true],
    [false, true, false],
    [true, false, true],
  ],
  6: [
    [true, false, true],
    [true, false, true],
    [true, false, true],
  ],
};

class DiceWidget extends StatefulWidget {
  final bool enabled;
  final ValueChanged<int> onRolled;

  const DiceWidget({super.key, required this.enabled, required this.onRolled});

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> {
  final _random = Random();
  int _face = 1;
  bool _rolling = false;

  Future<void> _roll() async {
    if (_rolling || !widget.enabled) return;
    setState(() => _rolling = true);
    const shuffleDuration = Duration(milliseconds: 600);
    const tick = Duration(milliseconds: 80);
    final ticks = shuffleDuration.inMilliseconds ~/ tick.inMilliseconds;
    for (var i = 0; i < ticks; i++) {
      await Future.delayed(tick);
      if (!mounted) return;
      setState(() => _face = _random.nextInt(6) + 1);
    }
    final finalValue = _random.nextInt(6) + 1;
    if (!mounted) return;
    setState(() {
      _face = finalValue;
      _rolling = false;
    });
    HapticFeedback.mediumImpact();
    widget.onRolled(finalValue);
  }

  @override
  Widget build(BuildContext context) {
    final layout = _pipLayouts[_face]!;
    return Opacity(
      opacity: widget.enabled ? 1 : 0.4,
      child: TapScale(
        onTap: widget.enabled ? _roll : null,
        pressedScale: 0.94,
        child: Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final row in layout)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final on in row)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: on ? kTableBlack : Colors.transparent,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
