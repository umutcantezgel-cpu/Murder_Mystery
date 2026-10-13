import 'package:flutter/material.dart';

import '../mappe/blatt.dart';
import '../tokens.dart';

/// Aktenblatt in Schreibmaschinenschrift auf gealtertem Papier ([MBlatt]).
/// Mit [stempel] liegt ein abgenutzter roter Stempel auf der rechten oberen Ecke.
class MPapier extends StatelessWidget {
  const MPapier({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(MMass.s16),
    this.stempel,
    this.neigung = 0,
  });

  final Widget child;
  final EdgeInsets padding;

  /// Text des Stempels (wird als Stempel gemalt; der Bildschirmleser liest ihn unverändert).
  final String? stempel;

  /// Drehung des ganzen Blatts in Bogenmaß (klein halten, z. B. −0,02).
  final double neigung;

  @override
  Widget build(BuildContext context) => MBlatt(
        padding: stempel == null ? padding : padding.copyWith(top: padding.top + 14),
        stempel: stempel,
        neigung: neigung,
        child: DefaultTextStyle.merge(
          style: MPapierSchrift.maschine.copyWith(fontSize: 16, height: 1.45),
          child: child,
        ),
      );
}
