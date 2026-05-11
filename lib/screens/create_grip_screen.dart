import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/grip_models.dart';
import '../providers/grip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';

class CreateGripScreen extends ConsumerStatefulWidget {
  const CreateGripScreen({super.key});

  @override
  ConsumerState<CreateGripScreen> createState() => _CreateGripScreenState();
}

class _CreateGripScreenState extends ConsumerState<CreateGripScreen> {
  final _edgeDepthController = TextEditingController();

  ContractionType _contraction = ContractionType.passive;
  GripType _gripType = GripType.halfCrimp;
  Set<Finger> _selectedFingers = {Finger.indexFinger, Finger.middle, Finger.ring};

  bool _saving = false;

  @override
  void dispose() {
    _edgeDepthController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _edgeDepthController.text.trim().isNotEmpty &&
      _selectedFingers.isNotEmpty;

  String get _autoName {
    final depth = _edgeDepthController.text.trim();
    final grip = switch (_gripType) {
      GripType.halfCrimp => 'Half Crimp',
      GripType.fullCrimp => 'Full Crimp',
      GripType.openHand => 'Open Hand',
    };
    if (depth.isEmpty) return grip;
    return '$grip - ${depth}mm';
  }

  Future<void> _save() async {
    if (!_isValid || _saving) return;

    final depth = double.tryParse(_edgeDepthController.text.trim());
    if (depth == null || depth <= 0) return;

    setState(() => _saving = true);

    final grip = Grip(
      id: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
      name: _autoName,
      edgeDepthMm: depth,
      fingers: _selectedFingers,
      gripType: _gripType,
      contractionType: _contraction,
      createdAt: DateTime.now(),
    );

    final dao = await ref.read(gripDaoProvider.future);
    await dao.insertGrip(grip);
    ref.invalidate(gripListProvider);

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create Grip',
          style: tsInterW700S18.copyWith(
            color: isDark ? webText : lightText,
          ),
        ),
      ),
      body: BackgroundGradient(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Contraction type
            _SectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('Contraction Type', isDark: isDark),
                  const SizedBox(height: 12),
                  _ToggleRow<ContractionType>(
                    values: ContractionType.values,
                    selected: _contraction,
                    labels: const ['Passive', 'Active'],
                    onChanged: (v) => setState(() => _contraction = v),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Finger details
            _SectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('Edge Depth', isDark: isDark),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _edgeDepthController,
                    onChanged: (_) => setState(() {}),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.inter(
                      color: isDark ? webText : lightText,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter edge depth in mm',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle('Fingers', isDark: isDark),
                  const SizedBox(height: 4),
                  Text(
                    'Select fingers to use',
                    style: tsInterS12.copyWith(color: webMuted),
                  ),
                  const SizedBox(height: 10),
                  _FingerSelector(
                    selected: _selectedFingers,
                    onChanged: (s) => setState(() => _selectedFingers = s),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle('Grip Type', isDark: isDark),
                  const SizedBox(height: 8),
                  _GripTypeDropdown(
                    value: _gripType,
                    onChanged: (v) => setState(() => _gripType = v),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            // Auto-generated name preview
            if (_edgeDepthController.text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 4),
                child: Text(
                  _autoName,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: isDark ? webText : lightText,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Save button
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isValid ? _save : null,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────── Shared widgets ──────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? webPanel : lightPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? webBorder.withValues(alpha: 0.6)
              : lightBorder.withValues(alpha: 0.7),
        ),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.isDark});

  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: tsInterW700S16.copyWith(color: isDark ? webText : lightText),
    );
  }
}

class _ToggleRow<T> extends StatelessWidget {
  const _ToggleRow({
    required this.values,
    required this.selected,
    required this.labels,
    required this.onChanged,
    required this.isDark,
  });

  final List<T> values;
  final T selected;
  final List<String> labels;
  final ValueChanged<T> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: isDark ? webBgSoft : lightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? webBorder.withValues(alpha: 0.5)
              : lightBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: List.generate(values.length, (i) {
          final isSelected = values[i] == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(values[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? brandAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  labels[i],
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? webMuted : lightMuted),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FingerSelector extends StatelessWidget {
  const _FingerSelector({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  final Set<Finger> selected;
  final ValueChanged<Set<Finger>> onChanged;
  final bool isDark;

  static const _labels = ['Thumb', 'Index', 'Middle', 'Ring', 'Pinky'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(Finger.values.length, (i) {
        final finger = Finger.values[i];
        final isSelected = selected.contains(finger);
        return GestureDetector(
          onTap: () {
            final next = Set<Finger>.from(selected);
            if (isSelected) {
              next.remove(finger);
            } else {
              next.add(finger);
            }
            onChanged(next);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? brandAccent : (isDark ? webBgSoft : lightBg),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? brandAccent
                    : (isDark
                        ? webBorder.withValues(alpha: 0.5)
                        : lightBorder.withValues(alpha: 0.5)),
              ),
            ),
            child: Text(
              _labels[i],
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isSelected
                    ? Colors.white
                    : (isDark ? webText : lightText),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _GripTypeDropdown extends StatelessWidget {
  const _GripTypeDropdown({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  final GripType value;
  final ValueChanged<GripType> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? webBgSoft : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? webBorder.withValues(alpha: 0.6)
              : lightBorder.withValues(alpha: 0.7),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GripType>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? webPanel : lightPanel,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? webText : lightText,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? webMuted : lightMuted,
          ),
          items: GripType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_label(type)),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  String _label(GripType type) {
    switch (type) {
      case GripType.halfCrimp:
        return 'Half Crimp';
      case GripType.fullCrimp:
        return 'Full Crimp';
      case GripType.openHand:
        return 'Open Hand';
    }
  }
}
