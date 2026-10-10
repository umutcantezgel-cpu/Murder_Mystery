import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../haptics.dart';

enum NoirButtonStyle { primary, secondary, danger, ghost }

/// Knopftext: schrumpft höchstens auf 80 %, sonst bricht er zweizeilig in kleinerer Schrift um –
/// statt in schmalen Knöpfen auf unlesbare Größe zu schrumpfen.
class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.text, required this.style});

  final String text;
  final TextStyle style;

  static const double _minScale = 0.8;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final single = Text(text, maxLines: 1, style: style);
        if (!box.hasBoundedWidth) return single;
        final tp = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final natural = tp.width;
        tp.dispose();
        if (natural * _minScale <= box.maxWidth) return FittedBox(fit: BoxFit.scaleDown, child: single);
        final small = style.copyWith(
          fontSize: (style.fontSize ?? 18) * 0.82,
          letterSpacing: (style.letterSpacing ?? 0) * 0.4,
          height: 1.05,
        );
        return Text(text, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: small);
      },
    );
  }
}

/// Hauptknopf im Akten-Stil.
class NoirButton extends StatefulWidget {
  const NoirButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.style = NoirButtonStyle.primary,
    this.accent = Noir.brass,
    this.height = 54,
    this.expand = true,
    this.subtitle,
    this.busy = false,
  });

  final String label;
  final String? subtitle;
  final VoidCallback? onPressed;
  final IconData? icon;
  final NoirButtonStyle style;
  final Color accent;
  final double height;
  final bool expand;
  final bool busy;

  @override
  State<NoirButton> createState() => _NoirButtonState();
}

class _NoirButtonState extends State<NoirButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.busy;
    final (Color bg, Color fg, Color border, Gradient? grad) = switch (widget.style) {
      NoirButtonStyle.primary => (
        widget.accent,
        Noir.night,
        Color.lerp(widget.accent, Colors.white, 0.35)!,
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(widget.accent, Colors.white, 0.18)!,
            widget.accent,
            Color.lerp(widget.accent, Colors.black, 0.28)!,
          ],
        ),
      ),
      NoirButtonStyle.danger => (
        Noir.blood,
        Noir.cream,
        Noir.bloodBright,
        const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Noir.bloodLight, Noir.blood, Noir.bloodDark],
        ),
      ),
      NoirButtonStyle.secondary => (Noir.night2.withValues(alpha: 0.75), Noir.cream, Noir.line, null),
      NoirButtonStyle.ghost => (Colors.transparent, Noir.smoke, Colors.transparent, null),
    };
    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.busy)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: fg)),
          )
        else if (widget.icon != null)
          Padding(
            padding: EdgeInsets.only(right: widget.height < 46 ? 6 : 10),
            child: Icon(widget.icon, color: fg, size: widget.height < 46 ? 17 : 20),
          ),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ButtonLabel(
                text: widget.label,
                style: Noir.title(widget.height < 46 ? 15 : 18, color: fg, spacing: widget.height < 46 ? 0.8 : 1.6),
              ),
              if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Noir.text(11.5, color: fg.withValues(alpha: 0.75), height: 1.2),
                ),
            ],
          ),
        ),
      ],
    );
    return AnimatedScale(
      scale: _down ? 0.97 : 1,
      duration: const Duration(milliseconds: 90),
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.45,
        duration: const Duration(milliseconds: 150),
        child: Container(
          // Feste, aber mit der Schrift wachsende Höhe: bleibt auch innerhalb
          // von IntrinsicHeight messbar (der Knopftext nutzt LayoutBuilder).
          height: widget.height * (MediaQuery.textScalerOf(context).scale(18) / 18).clamp(1.0, double.infinity),
          decoration: BoxDecoration(
            color: grad == null ? bg : null,
            gradient: grad,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border, width: 1),
            boxShadow: widget.style == NoirButtonStyle.ghost
                ? null
                : const [BoxShadow(color: Noir.shadow, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: enabled
                  ? () {
                      Haptics.selection();
                      widget.onPressed!();
                    }
                  : null,
              onHighlightChanged: (v) => setState(() => _down = v),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.height < 46 ? 10 : 18),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Runder Glas-Knopf (HUD) mit optionalem Zähler.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 46,
    this.badge = 0,
    this.tooltip,
    this.color = Noir.cream,
    this.active = false,
    this.accent = Noir.brass,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final int badge;
  final String? tooltip;
  final Color color;
  final bool active;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    Widget b = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? accent.withValues(alpha: 0.9) : Noir.glass,
            border: Border.all(color: active ? accent : Noir.lineStrong, width: 1.2),
            boxShadow: const [BoxShadow(color: Noir.shadow, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed == null
                  ? null
                  : () {
                      Haptics.selection();
                      onPressed!();
                    },
              child: Icon(icon, color: active ? Noir.night : color, size: size * 0.48),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(
            right: -3,
            top: -3,
            child: Container(
              constraints: const BoxConstraints(minWidth: 19),
              height: 19,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Noir.bloodBright,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Noir.night, width: 1.5),
              ),
              child: Text(
                '$badge',
                style: Noir.label(10.5, color: Colors.white, weight: FontWeight.w700, spacing: 0),
              ),
            ),
          ),
      ],
    );
    if (tooltip != null) b = Tooltip(message: tooltip, child: b);
    return b;
  }
}

/// Zurück-Leiste oben auf Menü-Bildschirmen.
class NoirTopBar extends StatelessWidget {
  const NoirTopBar({super.key, required this.title, this.onBack, this.trailing, this.subtitle});

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Noir.cream),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Noir.title(24), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitle != null) Text(subtitle!, style: Noir.text(12.5, color: Noir.smoke, height: 1.3)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Kleine Abschnittsüberschrift mit Linie.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color = Noir.brass, this.trailing});

  final String text;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: Noir.label(11.5, color: color, spacing: 2.2, weight: FontWeight.w700),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.25))),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

/// Kleines Etikett (Tag).
class TagChip extends StatelessWidget {
  const TagChip(this.text, {super.key, this.color = Noir.smoke, this.icon, this.filled = false});

  final String text;
  final Color color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: filled ? 1 : 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: filled ? Noir.night : color), const SizedBox(width: 4)],
          Text(
            text.toUpperCase(),
            style: Noir.label(10, color: filled ? Noir.night : color, spacing: 1.2, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
