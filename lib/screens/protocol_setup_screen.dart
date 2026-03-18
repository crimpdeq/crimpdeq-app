import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/session_models.dart';
import '../providers/session_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';

// ──────────────────────────── Protocol presets ──────────────────────────

class ProtocolPreset {
  const ProtocolPreset({
    required this.name,
    required this.hangDuration,
    required this.restDuration,
    required this.sets,
    required this.repsPerSet,
    required this.restBetweenSets,
  });

  final String name;
  final int hangDuration;
  final int restDuration;
  final int sets;
  final int repsPerSet;
  final int restBetweenSets;
}

const _maxHangPresets = [
  ProtocolPreset(name: 'Beginner', hangDuration: 5, restDuration: 3, sets: 3, repsPerSet: 1, restBetweenSets: 180),
  ProtocolPreset(name: 'Standard', hangDuration: 7, restDuration: 3, sets: 5, repsPerSet: 1, restBetweenSets: 180),
  ProtocolPreset(name: 'Advanced', hangDuration: 10, restDuration: 3, sets: 5, repsPerSet: 1, restBetweenSets: 180),
];

const _repeaterPresets = [
  ProtocolPreset(name: 'Classic 7/3', hangDuration: 7, restDuration: 3, sets: 6, repsPerSet: 6, restBetweenSets: 120),
  ProtocolPreset(name: 'Eva Lopez', hangDuration: 10, restDuration: 5, sets: 4, repsPerSet: 4, restBetweenSets: 120),
  ProtocolPreset(name: 'Short 5/5', hangDuration: 5, restDuration: 5, sets: 3, repsPerSet: 5, restBetweenSets: 90),
];

const _protocolDescriptions = {
  ProtocolType.maxHang: 'One all-out hold per set',
  ProtocolType.repeater: 'Timed hang/rest intervals',
  ProtocolType.freeform: 'Open measurement',
};

// ──────────────────────────── Screen ────────────────────────────────────

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
  int? _selectedPresetIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final presets = _type == ProtocolType.maxHang
        ? _maxHangPresets
        : _type == ProtocolType.repeater
            ? _repeaterPresets
            : <ProtocolPreset>[];

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
                  // Protocol type cards
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
                  ..._buildProtocolCards(colorScheme, isDark),

                  if (_type != ProtocolType.freeform) ...[
                    // Presets
                    if (presets.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'PRESETS',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.8,
                          color: isDark ? webMuted : lightMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: presets.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final preset = presets[index];
                            final selected = _selectedPresetIndex == index;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _applyPreset(index, preset);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? brandAccent
                                      : isDark ? webPanel : lightPanel,
                                  borderRadius: BorderRadius.circular(18),
                                  border: selected
                                      ? null
                                      : Border.all(
                                          color: colorScheme.outline.withValues(alpha: 0.4),
                                        ),
                                ),
                                child: Text(
                                  preset.name,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: selected
                                        ? Colors.white
                                        : isDark ? webText : lightText,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // Visual timeline
                    const SizedBox(height: 20),
                    _ProtocolTimeline(
                      type: _type,
                      hangDuration: _hangDuration,
                      restDuration: _restDuration,
                      restBetweenSets: _restBetweenSets,
                      repsPerSet: _repsPerSet,
                      sets: _sets,
                    ),

                    // Timing section
                    const SizedBox(height: 24),
                    _CollapsibleSection(
                      title: 'TIMING',
                      summary: _type == ProtocolType.repeater
                          ? '${_hangDuration}s hang / ${_restDuration}s rest / ${_restBetweenSets}s set rest'
                          : '${_restBetweenSets}s set rest',
                      isDark: isDark,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            children: [
                              if (_type == ProtocolType.repeater) ...[
                                _StepperRow(
                                  label: 'Hang',
                                  value: _hangDuration,
                                  unit: 's',
                                  onChanged: (v) => _onValueChanged(() => _hangDuration = v),
                                ),
                                _divider(colorScheme),
                                _StepperRow(
                                  label: 'Rest',
                                  value: _restDuration,
                                  unit: 's',
                                  onChanged: (v) => _onValueChanged(() => _restDuration = v),
                                ),
                                _divider(colorScheme),
                              ],
                              _StepperRow(
                                label: 'Set Rest',
                                value: _restBetweenSets,
                                unit: 's',
                                step: 10,
                                onChanged: (v) => _onValueChanged(() => _restBetweenSets = v),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Volume section
                    const SizedBox(height: 20),
                    _CollapsibleSection(
                      title: 'VOLUME',
                      summary: _type == ProtocolType.repeater
                          ? '$_sets sets \u00D7 $_repsPerSet reps'
                          : '$_sets sets',
                      isDark: isDark,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            children: [
                              _StepperRow(
                                label: 'Sets',
                                value: _sets,
                                onChanged: (v) => _onValueChanged(() => _sets = v),
                              ),
                              if (_type == ProtocolType.repeater) ...[
                                _divider(colorScheme),
                                _StepperRow(
                                  label: 'Reps / Set',
                                  value: _repsPerSet,
                                  onChanged: (v) => _onValueChanged(() => _repsPerSet = v),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Load section
                  const SizedBox(height: 20),
                  _CollapsibleSection(
                    title: 'LOAD',
                    summary: _targetWeight > 0
                        ? '${_targetWeight.round()} kg target / ${_hangThreshold.round()} kg threshold'
                        : '${_hangThreshold.round()} kg threshold',
                    isDark: isDark,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            _StepperRow(
                              label: 'Target',
                              value: _targetWeight.round(),
                              unit: 'kg',
                              onChanged: (v) => _onValueChanged(() => _targetWeight = v.toDouble()),
                            ),
                            _divider(colorScheme),
                            _StepperRow(
                              label: 'Threshold',
                              value: _hangThreshold.round(),
                              unit: 'kg',
                              onChanged: (v) => _onValueChanged(() => _hangThreshold = v.toDouble()),
                            ),
                          ],
                        ),
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

  List<Widget> _buildProtocolCards(ColorScheme colorScheme, bool isDark) {
    return ProtocolType.values.map((type) {
      final selected = _type == type;
      final icon = type == ProtocolType.maxHang
          ? Icons.fitness_center
          : type == ProtocolType.repeater
              ? Icons.repeat
              : Icons.explore;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _selectProtocol(type);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? brandAccent.withValues(alpha: 0.08)
                  : isDark ? webPanel : lightPanel,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? brandAccent
                    : colorScheme.outline.withValues(alpha: 0.4),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? brandAccent : webMuted,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _protocolLabel(type),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: selected
                              ? (isDark ? webText : lightText)
                              : (isDark ? webText : lightText),
                        ),
                      ),
                      Text(
                        _protocolDescriptions[type] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: webMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? brandAccent : webMuted.withValues(alpha: 0.5),
                      width: selected ? 6 : 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
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
      _selectedPresetIndex = null;
      _applyDefaults();
    });
  }

  void _applyPreset(int index, ProtocolPreset preset) {
    setState(() {
      _selectedPresetIndex = index;
      _hangDuration = preset.hangDuration;
      _restDuration = preset.restDuration;
      _sets = preset.sets;
      _repsPerSet = preset.repsPerSet;
      _restBetweenSets = preset.restBetweenSets;
    });
  }

  void _onValueChanged(VoidCallback setter) {
    setState(() {
      setter();
      _selectedPresetIndex = null; // deselect preset on manual change
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
    HapticFeedback.heavyImpact();
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

  String _protocolLabel(ProtocolType type) {
    switch (type) {
      case ProtocolType.maxHang:
        return 'Max Hang';
      case ProtocolType.repeater:
        return 'Repeater';
      case ProtocolType.freeform:
        return 'Freeform';
    }
  }
}

// ──────────────────────────── Visual timeline ───────────────────────────

class _ProtocolTimeline extends StatelessWidget {
  const _ProtocolTimeline({
    required this.type,
    required this.hangDuration,
    required this.restDuration,
    required this.restBetweenSets,
    required this.repsPerSet,
    required this.sets,
  });

  final ProtocolType type;
  final int hangDuration;
  final int restDuration;
  final int restBetweenSets;
  final int repsPerSet;
  final int sets;

  @override
  Widget build(BuildContext context) {
    // Calculate proportional blocks for one set
    final blocks = <_TimelineBlock>[];
    final reps = type == ProtocolType.maxHang ? 1 : repsPerSet;

    for (var s = 0; s < sets && s < 4; s++) {
      for (var r = 0; r < reps; r++) {
        blocks.add(_TimelineBlock(duration: hangDuration, type: _BlockType.hang));
        if (r < reps - 1) {
          blocks.add(_TimelineBlock(duration: restDuration, type: _BlockType.rest));
        }
      }
      if (s < sets - 1) {
        blocks.add(_TimelineBlock(duration: restBetweenSets, type: _BlockType.setRest));
      }
    }
    if (sets > 4) {
      blocks.add(const _TimelineBlock(duration: 0, type: _BlockType.ellipsis));
    }

    final totalDuration = blocks
        .where((b) => b.type != _BlockType.ellipsis)
        .fold<int>(0, (sum, b) => sum + b.duration);
    if (totalDuration == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 6,
      child: Row(
        children: blocks.map((block) {
          if (block.type == _BlockType.ellipsis) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '\u2026',
                style: GoogleFonts.inter(fontSize: 10, color: webMuted, height: 0.5),
              ),
            );
          }
          final flex = (block.duration * 100 / totalDuration).round().clamp(1, 100);
          return Expanded(
            flex: flex,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: BoxDecoration(
                color: block.type == _BlockType.hang
                    ? brandAccent
                    : block.type == _BlockType.rest
                        ? webMuted.withValues(alpha: 0.3)
                        : webPanelDeep,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

enum _BlockType { hang, rest, setRest, ellipsis }

class _TimelineBlock {
  const _TimelineBlock({required this.duration, required this.type});
  final int duration;
  final _BlockType type;
}

// ──────────────────────────── Collapsible section ───────────────────────

class _CollapsibleSection extends StatefulWidget {
  const _CollapsibleSection({
    required this.title,
    required this.summary,
    required this.isDark,
    required this.child,
  });

  final String title;
  final String summary;
  final bool isDark;
  final Widget child;

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.8,
                  color: widget.isDark ? webMuted : lightMuted,
                ),
              ),
              const SizedBox(width: 8),
              if (!_expanded)
                Expanded(
                  child: Text(
                    widget.summary,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: webMuted.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (!_expanded) const SizedBox(width: 4),
              Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 18,
                color: webMuted,
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: widget.child,
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
      ],
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

class _StepperButton extends StatefulWidget {
  const _StepperButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  Timer? _timer;
  int _tickCount = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    widget.onTap!();
  }

  void _startRepeating() {
    if (widget.onTap == null) return;
    _tickCount = 0;
    _scheduleNextTick();
  }

  void _scheduleNextTick() {
    final interval = _tickCount < 5
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 50);
    _timer = Timer(interval, () {
      if (!mounted || widget.onTap == null) return;
      HapticFeedback.selectionClick();
      widget.onTap!();
      _tickCount++;
      _scheduleNextTick();
    });
  }

  void _stopRepeating() {
    _timer?.cancel();
    _timer = null;
    _tickCount = 0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabled = widget.onTap == null;

    return GestureDetector(
      onTap: _handleTap,
      onLongPressStart: (_) => _startRepeating(),
      onLongPressEnd: (_) => _stopRepeating(),
      onLongPressCancel: _stopRepeating,
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
          widget.icon,
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
