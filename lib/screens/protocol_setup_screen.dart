import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/session_models.dart';
import '../providers/session_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';

class ProtocolSetupScreen extends ConsumerStatefulWidget {
  const ProtocolSetupScreen({super.key});

  @override
  ConsumerState<ProtocolSetupScreen> createState() =>
      _ProtocolSetupScreenState();
}

class _ProtocolSetupScreenState extends ConsumerState<ProtocolSetupScreen> {
  ProtocolType _type = ProtocolType.maxHang;
  int _hangDuration = 7;
  int _restDuration = 3;
  int _sets = 3;
  int _repsPerSet = 1;
  int _restBetweenSets = 180;
  double _targetWeight = 0.0;
  double _hangThreshold = 2.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Session Setup',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: BackgroundGradient(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // Protocol type selector
                  Text(
                    'PROTOCOL',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.8,
                      color: isDark ? webMuted : lightMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ProtocolChip(
                        label: 'Max Hang',
                        icon: Icons.fitness_center,
                        selected: _type == ProtocolType.maxHang,
                        onTap: () => _selectProtocol(ProtocolType.maxHang),
                      ),
                      const SizedBox(width: 8),
                      _ProtocolChip(
                        label: 'Repeater',
                        icon: Icons.repeat,
                        selected: _type == ProtocolType.repeater,
                        onTap: () => _selectProtocol(ProtocolType.repeater),
                      ),
                      const SizedBox(width: 8),
                      _ProtocolChip(
                        label: 'Freeform',
                        icon: Icons.explore,
                        selected: _type == ProtocolType.freeform,
                        onTap: () => _selectProtocol(ProtocolType.freeform),
                      ),
                    ],
                  ),

                  if (_type != ProtocolType.freeform) ...[
                    const SizedBox(height: 28),
                    Text(
                      'TIMING',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.8,
                        color: isDark ? webMuted : lightMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            if (_type == ProtocolType.repeater) ...[
                              _StepperRow(
                                label: 'Hang',
                                value: _hangDuration,
                                unit: 's',
                                onChanged: (v) =>
                                    setState(() => _hangDuration = v),
                              ),
                              _divider(colorScheme),
                              _StepperRow(
                                label: 'Rest',
                                value: _restDuration,
                                unit: 's',
                                onChanged: (v) =>
                                    setState(() => _restDuration = v),
                              ),
                              _divider(colorScheme),
                            ],
                            _StepperRow(
                              label: 'Set Rest',
                              value: _restBetweenSets,
                              unit: 's',
                              step: 10,
                              onChanged: (v) =>
                                  setState(() => _restBetweenSets = v),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    Text(
                      'VOLUME',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.8,
                        color: isDark ? webMuted : lightMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            _StepperRow(
                              label: 'Sets',
                              value: _sets,
                              onChanged: (v) => setState(() => _sets = v),
                            ),
                            if (_type == ProtocolType.repeater) ...[
                              _divider(colorScheme),
                              _StepperRow(
                                label: 'Reps / Set',
                                value: _repsPerSet,
                                onChanged: (v) =>
                                    setState(() => _repsPerSet = v),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),
                  Text(
                    'LOAD',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.8,
                      color: isDark ? webMuted : lightMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          _StepperRow(
                            label: 'Target',
                            value: _targetWeight.round(),
                            unit: 'kg',
                            onChanged: (v) =>
                                setState(() => _targetWeight = v.toDouble()),
                          ),
                          _divider(colorScheme),
                          _StepperRow(
                            label: 'Threshold',
                            value: _hangThreshold.round(),
                            unit: 'kg',
                            onChanged: (v) =>
                                setState(() => _hangThreshold = v.toDouble()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Start button pinned at bottom
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: FilledButton(
                onPressed: _startSession,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  textStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                child: const Text('Start Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: colorScheme.outline.withValues(alpha: 0.3),
    );
  }

  void _selectProtocol(ProtocolType type) {
    setState(() {
      _type = type;
      _applyDefaults();
    });
  }

  void _applyDefaults() {
    switch (_type) {
      case ProtocolType.maxHang:
        _hangDuration = 7;
        _restDuration = 3;
        _sets = 3;
        _repsPerSet = 1;
        _restBetweenSets = 180;
      case ProtocolType.repeater:
        _hangDuration = 7;
        _restDuration = 3;
        _sets = 6;
        _repsPerSet = 6;
        _restBetweenSets = 120;
      case ProtocolType.freeform:
        break;
    }
  }

  void _startSession() {
    final config = ProtocolConfig(
      type: _type,
      hangDurationSec: _hangDuration,
      restDurationSec: _restDuration,
      sets: _sets,
      repsPerSet: _repsPerSet,
      restBetweenSetsSec: _restBetweenSets,
      targetWeightKg: _targetWeight,
      hangThresholdKg: _hangThreshold,
    );

    ref.read(sessionProvider.notifier).startSession(config);
    context.go('/session/active');
  }
}

// ──────────────────────────── Protocol chip ─────────────────────────────

class _ProtocolChip extends StatelessWidget {
  const _ProtocolChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary
                : isDark
                    ? webPanel
                    : lightPanel,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? null
                : Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.4),
                  ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? colorScheme.onPrimary
                    : isDark
                        ? webMuted
                        : lightMuted,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────── Stepper row ───────────────────────────────

class _StepperRow extends StatefulWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.unit,
    this.step = 1,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final String? unit;
  final int step;

  @override
  State<_StepperRow> createState() => _StepperRowState();
}

class _StepperRowState extends State<_StepperRow> {
  bool _editing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _editing) {
        _commitEdit();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    _controller.text = widget.value.toString();
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _commitEdit() {
    final parsed = int.tryParse(_controller.text);
    if (parsed != null && parsed >= 0) {
      widget.onChanged(parsed);
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.remove,
            onTap: widget.value > 0
                ? () => widget.onChanged(
                    (widget.value - widget.step).clamp(0, 9999))
                : null,
          ),
          GestureDetector(
            onTap: _editing ? null : _startEditing,
            child: SizedBox(
              width: 60,
              height: 32,
              child: _editing
                  ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark ? webText : lightText,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onSubmitted: (_) => _commitEdit(),
                    )
                  : Center(
                      child: Text(
                        widget.unit != null
                            ? '${widget.value}${widget.unit}'
                            : '${widget.value}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? webText : lightText,
                        ),
                      ),
                    ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: () => widget.onChanged(widget.value + widget.step),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark
              ? webBgSoft
              : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: disabled
              ? colorScheme.outline.withValues(alpha: 0.4)
              : isDark
                  ? webMuted
                  : lightMuted,
        ),
      ),
    );
  }
}
