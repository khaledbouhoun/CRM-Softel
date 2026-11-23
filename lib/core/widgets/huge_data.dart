import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

/// Icon data of the HugeIcons package (`HugeIcons.strokeRounded*`).
///
/// Unlike Material's `IconData`, these are not font glyphs: they are drawn by
/// the [HugeIcon] widget.
typedef HugeData = List<List<dynamic>>;

/// A [HugeIcon] for directional glyphs (back/forward arrows, chevrons, first
/// and last page).
///
/// Material mirrored those icons automatically in right-to-left locales;
/// [HugeIcon] does not, so this flips the icon horizontally in Arabic.
class MirroredHugeIcon extends StatelessWidget {
  const MirroredHugeIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 24,
  });

  final HugeData icon;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final icon = HugeIcon(icon: this.icon, color: color, size: size);
    return Directionality.of(context) == TextDirection.rtl
        ? Transform.flip(flipX: true, child: icon)
        : icon;
  }
}
