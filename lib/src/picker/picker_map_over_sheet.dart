/// The map, and the cart under it.
library;

import 'package:flutter/widgets.dart';

enum _Part { map, sheet }

/// Gives the cart the height it wants and the map the rest. On a screen too
/// short for the two, the cart is told so and its list gives way.
class PickerMapOverSheet extends StatelessWidget {
  /// Creates the two.
  const PickerMapOverSheet({super.key, required this.map, this.sheet});

  /// What fills the room the cart leaves.
  final Widget map;

  /// The cart, if there is one.
  final Widget? sheet;

  @override
  Widget build(BuildContext context) => CustomMultiChildLayout(
        delegate: _Delegate(),
        children: <Widget>[
          LayoutId(id: _Part.map, child: map),
          if (sheet case final cart?) LayoutId(id: _Part.sheet, child: cart),
        ],
      );
}

class _Delegate extends MultiChildLayoutDelegate {
  _Delegate();

  @override
  void performLayout(Size size) {
    var under = 0.0;
    if (hasChild(_Part.sheet)) {
      under = layoutChild(
        _Part.sheet,
        BoxConstraints(
          minWidth: size.width,
          maxWidth: size.width,
          maxHeight: size.height,
        ),
      ).height;
      positionChild(_Part.sheet, Offset(0, size.height - under));
    }
    layoutChild(
      _Part.map,
      BoxConstraints.tight(Size(size.width, size.height - under)),
    );
    positionChild(_Part.map, Offset.zero);
  }

  @override
  bool shouldRelayout(_Delegate old) => false;
}
