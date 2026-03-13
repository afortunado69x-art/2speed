import 'package:flutter/material.dart';
import '../services/scroll_reader_controller.dart';
import '../theme.dart';

/// Bottom sheet for adjusting scroll reader display settings
class ReaderSettingsSheet extends StatelessWidget {
  final ScrollReaderController ctrl;
  const ReaderSettingsSheet({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GrimTheme.deep,
        border: Border(top: BorderSide(color: GrimTheme.gold.withOpacity(0.2))),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 32),
      child: ListenableBuilder(
        listenable: ctrl,
        builder: (_, __) => Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle bar
          Center(child: Container(
            width: 36, height: 3,
            margin: const EdgeInsets.only(bottom: 20, top: 10),
            decoration: BoxDecoration(
              color: GrimTheme.mist.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2)),
          )),

          // Title
          Row(children: [
            Text('⚙', style: TextStyle(fontSize: 14, color: GrimTheme.tarnished)),
            const SizedBox(width: 8),
            Text('Reading Appearance',
              style: GrimTheme.cinzel(size: 11, spacing: 2, color: GrimTheme.tarnished)),
          ]),
          const SizedBox(height: 20),

          // Font size
          _SliderRow(
            label: 'Glyph Size',
            value: ctrl.fontSize,
            min: 12, max: 28,
            display: '${ctrl.fontSize.round()}pt',
            onChanged: ctrl.setFontSize,
          ),
          const SizedBox(height: 16),

          // Line height
          _SliderRow(
            label: 'Line Spacing',
            value: ctrl.lineHeight,
            min: 1.2, max: 2.5,
            display: ctrl.lineHeight.toStringAsFixed(1),
            onChanged: ctrl.setLineHeight,
          ),
          const SizedBox(height: 16),

          // Margins
          _SliderRow(
            label: 'Side Margins',
            value: ctrl.marginH,
            min: 10, max: 50,
            display: '${ctrl.marginH.round()}px',
            onChanged: ctrl.setMargin,
          ),
          const SizedBox(height: 20),

          // Font family cycle
          Row(children: [
            Text('Font', style: GrimTheme.cinzel(size: 9, spacing: 2, color: GrimTheme.dust)),
            const SizedBox(width: 16),
            Expanded(child: GestureDetector(
              onTap: ctrl.cycleFontFamily,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: GrimTheme.gold.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(3),
                  color: GrimTheme.gold.withOpacity(0.04),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(_fontLabel(ctrl.fontFamily),
                    style: TextStyle(
                      fontFamily: ctrl.fontFamily == 'serif' || ctrl.fontFamily == 'monospace'
                        ? ctrl.fontFamily : null,
                      fontSize: 14, color: GrimTheme.bone)),
                  Text('tap to change ›',
                    style: GrimTheme.cinzel(size: 8, spacing: 1, color: GrimTheme.mist)),
                ]),
              ),
            )),
          ]),
          const SizedBox(height: 16),

          // Preview text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GrimTheme.void_.withOpacity(0.8),
              border: Border.all(color: GrimTheme.gold.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'In the beginning was the Word, and the Word was with God...',
              style: TextStyle(
                fontFamily: ctrl.fontFamily,
                fontSize: ctrl.fontSize,
                height: ctrl.lineHeight,
                color: GrimTheme.bone,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ]),
      ),
    );
  }

  String _fontLabel(String f) => switch (f) {
    'im_fell_english' => 'IM Fell English (Gothic)',
    'cinzel'          => 'Cinzel (Classical)',
    'serif'         => 'Serif (System)',
    'monospace'     => 'Monospace',
    _               => f,
  };
}

class _SliderRow extends StatelessWidget {
  final String label, display;
  final double value, min, max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label, required this.value,
    required this.min, required this.max,
    required this.display, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(width: 90,
      child: Text(label, style: GrimTheme.cinzel(size: 9, spacing: 1, color: GrimTheme.dust))),
    Expanded(child: SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 1.5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        activeTrackColor: GrimTheme.gold,
        inactiveTrackColor: GrimTheme.ash,
        thumbColor: GrimTheme.gold,
        overlayColor: GrimTheme.gold.withOpacity(0.12),
      ),
      child: Slider(value: value, min: min, max: max, onChanged: onChanged),
    )),
    SizedBox(width: 44,
      child: Text(display,
        textAlign: TextAlign.right,
        style: GrimTheme.cinzel(size: 12, color: GrimTheme.gold))),
  ]);
}
