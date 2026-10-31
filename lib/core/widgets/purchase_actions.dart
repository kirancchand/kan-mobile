import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/cart_item.dart';
import '../../features/cart/cart_screen.dart';
import '../../state/cart_state.dart';
import '../theme/app_icons.dart';

/// Shared by every detail screen that offers an item for sale.
class PurchaseActions extends StatelessWidget {
  const PurchaseActions({super.key, required this.item, required this.contact});
  final CartItem item;
  final Widget contact;

  void _add(BuildContext context, {required bool openCart}) {
    try {
      context.read<CartState>().add(item);
      if (openCart) {
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => const CartScreen()));
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
              // Action snackbars persist by default in the installed Flutter SDK.
              persist: false,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.fixed,
              content: Text('${item.title} added to cart'),
              action: SnackBarAction(
                  label: 'View cart',
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const CartScreen())))));
      }
    } on StateError catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final addLabel = item.isAvailable ? 'Add to cart' : 'Unavailable';
    final add = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        shape: shape,
        textStyle: textStyle,
        iconSize: 20,
      ),
      icon: const Icon(AppIcons.shoppingCart),
      onPressed: item.isAvailable ? () => _add(context, openCart: false) : null,
      label: Text(addLabel, textAlign: TextAlign.center),
    );
    final buy = FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        shape: shape,
        textStyle: textStyle,
      ),
      onPressed: item.isAvailable ? () => _add(context, openCart: true) : null,
      child: const Text('Buy now', textAlign: TextAlign.center),
    );
    return LayoutBuilder(builder: (context, constraints) {
      // Measure the actual scaled label before choosing equal-width columns.
      final labelPainter = TextPainter(
        text: TextSpan(text: addLabel, style: textStyle),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final requiredWidth = (labelPainter.width + 20 + 8 + 24 + 4) * 2 + 12;
      labelPainter.dispose();
      final stack = constraints.maxWidth < requiredWidth;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stack) ...[
            add,
            const SizedBox(height: 12),
            buy,
          ] else
            Row(children: [
              Expanded(child: add),
              const SizedBox(width: 12),
              Expanded(child: buy),
            ]),
          const SizedBox(height: 8),
          TextButtonTheme(
            data: TextButtonThemeData(
                style: TextButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: shape,
              textStyle: textStyle,
              iconSize: 20,
            )),
            child: contact,
          ),
        ],
      );
    });
  }
}
