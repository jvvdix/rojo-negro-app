import 'package:flutter/material.dart';
import '../main.dart';
import 'primary_button.dart';

void showComingSoonSheet(BuildContext context, String modeName) {
  showModalBottomSheet(
    context: context,
    backgroundColor: kSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_top_rounded, color: kGold, size: 40),
            const SizedBox(height: 14),
            Text(
              modeName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Este modo está en camino. ¡Muy pronto podrás jugarlo!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            PrimaryButton(label: 'ENTENDIDO', onTap: () => Navigator.pop(context)),
          ],
        ),
      );
    },
  );
}
