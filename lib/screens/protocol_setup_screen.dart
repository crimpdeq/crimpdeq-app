import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/grip_models.dart';
import '../models/session_models.dart';
import '../models/template_models.dart';
import '../providers/grip_provider.dart';
import '../providers/progressor_provider.dart';
import '../providers/session_provider.dart';
import '../providers/template_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';

// ──────────────────────────── Mode ──────────────────────────────────────

enum SetupMode { train, manage }

// ──────────────────────────── Screen ────────────────────────────────────

class ProtocolSetupScreen extends ConsumerStatefulWidget {
  const ProtocolSetupScreen({super.key, this.mode = SetupMode.train});

  final SetupMode mode;

  @override
  ConsumerState<ProtocolSetupScreen> createState() =>
      _ProtocolSetupScreenState();
}

class _ProtocolSetupScreenState extends ConsumerState<ProtocolSetupScreen> {
  // Wizard step
  int _step = 0;
  late final PageController _pageController;

  // Protocol config state
  ProtocolType _type = ProtocolType.repeater;
  int _hangDuration = 7;
  int _restDuration = 3;
  int _sets = 6;
  int _repsPerSet = 6;
  int _restBetweenSets = 120;
  double _targetWeight = 0.0;
  double _hangThreshold = 2.0;
  String? _selectedGripId;
  HandMode _handMode = HandMode.alternatePerRep;
  bool _perSetCustomization = false;
  List<SetConfig> _setConfigs = [];

  // Manage mode: track which template is being edited (null = creating new)
  String? _editingTemplateId;
  String? _editingTemplateName;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Pre-select most recently used grip
    Future.microtask(() async {
      final gripId = await ref.read(lastUsedGripIdProvider.future);
      if (gripId != null && mounted) {
        setState(() => _selectedGripId = gripId);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    setState(() => _step = 1);
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToStep1() {
    setState(() => _step = 0);
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool get _isConnected =>
      ref.watch(progressorProvider).connection.isConnected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToStep1();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: _step == 0 ? () => context.go('/') : _goToStep1,
          ),
          title: Text(
            _step == 0
                ? (widget.mode == SetupMode.manage ? 'Workouts' : 'Choose Workout')
                : widget.mode == SetupMode.manage
                    ? (_editingTemplateId != null ? 'Edit Workout' : 'New Workout')
                    : 'Configure',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          actions: [
            if (_step == 1 && widget.mode == SetupMode.train)
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                tooltip: 'Save as Template',
                onPressed: _showSaveTemplateDialog,
              ),
          ],
        ),
        body: BackgroundGradient(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep1(isDark),
              _buildStep2(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────── Step 1: Choose Workout ───────────────────

  Widget _buildStep1(bool isDark) {
    final templatesAsync = ref.watch(templateListProvider);

    return templatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
      data: (templates) {
        if (templates.isEmpty && widget.mode == SetupMode.train) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center, size: 48,
                      color: webMuted.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No workouts yet',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: webMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create one from the Workouts section',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: webMuted.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            ListView(
              padding: EdgeInsets.fromLTRB(
                20, 8, 20,
                widget.mode == SetupMode.manage ? 80 : 24,
              ),
              children: [
                ...templates.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TemplateCard(
                        template: t,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (widget.mode == SetupMode.manage) {
                            _editingTemplateId = t.id;
                            _editingTemplateName = t.name;
                          }
                          _loadTemplate(t);
                        },
                        onLongPress: widget.mode == SetupMode.manage
                            ? () => _showDeleteTemplateDialog(t)
                            : null,
                      ),
                    )),
              ],
            ),
            if (widget.mode == SetupMode.manage)
              Positioned(
                left: 20,
                right: 20,
                bottom: 32,
                child: _CreateNewCard(isDark: isDark, onTap: _onCreateNew),
              ),
          ],
        );
      },
    );
  }

  // ────────────────────────── Step 2: Configure ───────────────────────

  Widget _buildStep2(bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              // Protocol type
              _sectionLabel('PROTOCOL', isDark),
              const SizedBox(height: 10),
              _ProtocolTypeSelector(
                selected: _type,
                onChanged: (type) {
                  setState(() {
                    _type = type;
                    _applyDefaults();
                  });
                },
                isDark: isDark,
              ),

              // Grip field
              const SizedBox(height: 24),
              _sectionLabel('GRIP', isDark),
              const SizedBox(height: 10),
              _GripField(
                selectedGripId: _selectedGripId,
                onChanged: (id) => setState(() => _selectedGripId = id),
                isDark: isDark,
              ),

              // Hand mode
              const SizedBox(height: 24),
              _sectionLabel('HAND MODE', isDark),
              const SizedBox(height: 10),
              _HandModeSelector(
                handMode: _handMode,
                protocolType: _type,
                onChanged: (mode) => setState(() => _handMode = mode),
                isDark: isDark,
              ),

              if (_type != ProtocolType.freeform) ...[
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

                // Per-set customization toggle
                if (_type == ProtocolType.repeater) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'CUSTOMIZE PER SET',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.8,
                          color: isDark ? webMuted : lightMuted,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 24,
                        child: Switch(
                          value: _perSetCustomization,
                          onChanged: (v) {
                            setState(() {
                              _perSetCustomization = v;
                              if (v && _setConfigs.isEmpty) {
                                _setConfigs = List.generate(
                                  _sets,
                                  (_) => SetConfig(
                                    hangDurationSec: _hangDuration,
                                    restDurationSec: _restDuration,
                                    repsPerSet: _repsPerSet,
                                  ),
                                );
                              }
                                                    });
                          },
                        ),
                      ),
                    ],
                  ),
                ],

                if (_perSetCustomization && _type == ProtocolType.repeater) ...[
                  // Per-set table
                  const SizedBox(height: 16),
                  _PerSetTable(
                    setConfigs: _setConfigs,
                    onConfigsChanged: (configs) {
                      setState(() {
                        _setConfigs = configs;
                                        });
                    },
                    isDark: isDark,
                  ),
                  // Set rest (still uniform)
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _StepperRow(
                        label: 'Set Rest',
                        value: _restBetweenSets,
                        unit: 's',
                        step: 10,
                        onChanged: (v) => _onValueChanged(() => _restBetweenSets = v),
                      ),
                    ),
                  ),
                ] else ...[
                  // Timing section (uniform)
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

                  // Volume section (uniform)
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
              // Estimated duration
              if (_type != ProtocolType.freeform) ...[
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _formatEstimatedDuration(_estimatedDurationSeconds()),
                    key: ValueKey(_estimatedDurationSeconds()),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? webMuted : lightMuted,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),

        // Bottom button pinned
        Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: widget.mode == SetupMode.manage
              ? FilledButton(
                  onPressed: _saveWorkout,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    textStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  child: Text(
                      _editingTemplateId != null ? 'Save Changes' : 'Save Workout'),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: _isConnected ? _startSession : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        textStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('Start Session'),
                    ),
                    if (!_isConnected)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Connect a device to start',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: webMuted,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  // ────────────────────────── Helpers ─────────────────────────────────

  Widget _sectionLabel(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.8,
        color: isDark ? webMuted : lightMuted,
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

  void _onCreateNew() {
    HapticFeedback.lightImpact();
    setState(() {
      _editingTemplateId = null;
      _editingTemplateName = null;
      _type = ProtocolType.repeater;
      _applyDefaults();
    });
    _goToStep2();
  }

  void _saveWorkout() async {
    if (_editingTemplateId != null) {
      final template = SessionTemplate(
        id: _editingTemplateId!,
        name: _editingTemplateName!,
        protocolConfig: _buildConfig(),
        createdAt: DateTime.now(),
      );
      final dao = await ref.read(templateDaoProvider.future);
      await dao.updateTemplate(template);
      ref.invalidate(templateListProvider);
      _goToStep1();
    } else {
      _showSaveTemplateDialog(onSaved: _goToStep1);
    }
  }

  void _onValueChanged(VoidCallback setter) {
    setState(() {
      setter();
    });
  }

  void _applyDefaults() {
    _perSetCustomization = false;
    _setConfigs = [];
    // Max hang has 1 rep/set, so alternatePerRep is unavailable
    if (_type == ProtocolType.maxHang &&
        _handMode == HandMode.alternatePerRep) {
      _handMode = HandMode.alternatePerSet;
    }
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

  ProtocolConfig _buildConfig() {
    return ProtocolConfig(
      type: _type,
      hangDurationSec: _hangDuration,
      restDurationSec: _restDuration,
      sets: _sets,
      repsPerSet: _repsPerSet,
      restBetweenSetsSec: _restBetweenSets,
      targetWeightKg: _targetWeight,
      hangThresholdKg: _hangThreshold,
      gripId: _selectedGripId,
      handMode: _handMode,
      setConfigs: _perSetCustomization && _setConfigs.isNotEmpty
          ? _setConfigs
          : null,
    );
  }

  void _startSession() {
    HapticFeedback.heavyImpact();
    ref.read(sessionProvider.notifier).startSession(_buildConfig());
    context.go('/session/active');
  }

  void _loadTemplate(SessionTemplate template) {
    final c = template.protocolConfig;
    setState(() {
      _type = c.type;
      _hangDuration = c.hangDurationSec;
      _restDuration = c.restDurationSec;
      _sets = c.sets;
      _repsPerSet = c.repsPerSet;
      _restBetweenSets = c.restBetweenSetsSec;
      _targetWeight = c.targetWeightKg;
      _hangThreshold = c.hangThresholdKg;
      _selectedGripId = c.gripId;
      _handMode = c.handMode;
      // Fix legacy "both" and unavailable "perRep" for max hang
      if (_handMode == HandMode.both) {
        _handMode = _type == ProtocolType.maxHang
            ? HandMode.alternatePerSet
            : HandMode.alternatePerRep;
      } else if (_type == ProtocolType.maxHang &&
          _handMode == HandMode.alternatePerRep) {
        _handMode = HandMode.alternatePerSet;
      }
      if (c.setConfigs != null && c.setConfigs!.isNotEmpty) {
        _perSetCustomization = true;
        _setConfigs = List.of(c.setConfigs!);
      } else {
        _perSetCustomization = false;
        _setConfigs = [];
      }
    });
    _goToStep2();
  }

  void _showSaveTemplateDialog({VoidCallback? onSaved}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Save as Template',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Template name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final template = SessionTemplate(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                protocolConfig: _buildConfig(),
                createdAt: DateTime.now(),
              );
              final dao = await ref.read(templateDaoProvider.future);
              await dao.insertTemplate(template);
              ref.invalidate(templateListProvider);
              if (ctx.mounted) Navigator.pop(ctx);
              onSaved?.call();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTemplateDialog(SessionTemplate t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete template?'),
        content: Text('Remove "${t.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: paleRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final dao = await ref.read(templateDaoProvider.future);
      await dao.deleteTemplate(t.id);
      ref.invalidate(templateListProvider);
    }
  }

  int _estimatedDurationSeconds() {
    const countdownPerSet = 3;
    switch (_type) {
      case ProtocolType.maxHang:
        return _hangDuration * _sets +
            _restBetweenSets * (_sets - 1) +
            countdownPerSet * _sets;
      case ProtocolType.repeater:
        if (_perSetCustomization && _setConfigs.isNotEmpty) {
          var total = 0;
          for (var i = 0; i < _setConfigs.length; i++) {
            final sc = _setConfigs[i];
            total += sc.hangDurationSec * sc.repsPerSet +
                sc.restDurationSec * (sc.repsPerSet - 1) +
                countdownPerSet;
            if (i < _setConfigs.length - 1) total += _restBetweenSets;
          }
          return total;
        }
        final setDuration =
            _hangDuration * _repsPerSet + _restDuration * (_repsPerSet - 1);
        return setDuration * _sets +
            _restBetweenSets * (_sets - 1) +
            countdownPerSet * _sets;
      case ProtocolType.freeform:
        return 0;
    }
  }

  String _formatEstimatedDuration(int seconds) {
    if (seconds <= 0) return '';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return 'Est. ${s}s';
    if (s == 0) return 'Est. ${m}m';
    return 'Est. ${m}m ${s}s';
  }

}

// ──────────────────────────── Grip field (tappable → bottom sheet) ────

class _GripField extends ConsumerWidget {
  const _GripField({
    required this.selectedGripId,
    required this.onChanged,
    required this.isDark,
  });

  final String? selectedGripId;
  final ValueChanged<String?> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gripsAsync = ref.watch(gripListProvider);

    return gripsAsync.when(
      loading: () => const SizedBox(height: 48),
      error: (_, _) => const SizedBox.shrink(),
      data: (grips) {
        final selectedGrip = selectedGripId != null
            ? grips.where((g) => g.id == selectedGripId).firstOrNull
            : null;

        return GestureDetector(
          onTap: () => _showGripBottomSheet(context, ref, grips),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? webPanel : lightPanel,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedGrip != null
                    ? brandAccent.withValues(alpha: 0.5)
                    : isDark
                        ? webBorder.withValues(alpha: 0.4)
                        : lightBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.pan_tool_alt_outlined,
                  size: 18,
                  color: selectedGrip != null ? brandAccent : webMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: selectedGrip != null
                      ? Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: selectedGrip.gripTypeLabel,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: isDark ? webText : lightText,
                              ),
                            ),
                            TextSpan(
                              text: '  ${selectedGrip.edgeDepthMm.toStringAsFixed(0)}mm',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: webMuted,
                              ),
                            ),
                          ]),
                        )
                      : Text(
                          'Select grip',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: webMuted,
                          ),
                        ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: webMuted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGripBottomSheet(
      BuildContext context, WidgetRef ref, List<Grip> grips) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? webPanel : lightPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Select Grip',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark ? webText : lightText,
                ),
              ),
            ),
            if (selectedGripId != null)
              ListTile(
                leading: Icon(Icons.close, size: 20, color: webMuted),
                title: Text(
                  'Clear selection',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: webMuted,
                  ),
                ),
                onTap: () {
                  onChanged(null);
                  Navigator.pop(ctx);
                },
              ),
            ...grips.map((grip) => ListTile(
              leading: Icon(
                Icons.pan_tool_alt_outlined,
                size: 20,
                color: grip.id == selectedGripId ? brandAccent : webMuted,
              ),
              title: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: grip.gripTypeLabel,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: grip.id == selectedGripId
                          ? brandAccent
                          : isDark ? webText : lightText,
                    ),
                  ),
                  TextSpan(
                    text: '  ${grip.edgeDepthMm.toStringAsFixed(0)}mm',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: webMuted,
                    ),
                  ),
                ]),
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(grip.id);
                Navigator.pop(ctx);
              },
            )),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.add, size: 20, color: brandAccent),
              title: Text(
                'Create new grip',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: brandAccent,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/grips/create');
              },
            ),
          ],
        ),
      ),
    );
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

// ──────────────────────────── Hand mode selector ─────────────────────────

class _HandModeSelector extends StatelessWidget {
  const _HandModeSelector({
    required this.handMode,
    required this.protocolType,
    required this.onChanged,
    required this.isDark,
  });

  final HandMode handMode;
  final ProtocolType protocolType;
  final ValueChanged<HandMode> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Order: alternatePerRep (if available), alternatePerSet, left, right
    final modes = [
      if (protocolType != ProtocolType.maxHang) HandMode.alternatePerRep,
      HandMode.alternatePerSet,
      HandMode.left,
      HandMode.right,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 36,
          child: Row(
            children: modes.map((mode) {
              final selected = handMode == mode;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onChanged(mode);
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
                              color: isDark
                                  ? webBorder.withValues(alpha: 0.4)
                                  : lightBorder.withValues(alpha: 0.5),
                            ),
                    ),
                    child: Text(
                      _handModeLabel(mode),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: selected
                            ? Colors.white
                            : isDark ? webText : lightText,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _handModeDescription(handMode),
          style: GoogleFonts.inter(
            fontSize: 11,
            color: webMuted.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  static String _handModeLabel(HandMode mode) {
    switch (mode) {
      case HandMode.both:
        return 'Both';
      case HandMode.alternatePerSet:
        return 'Per Set';
      case HandMode.alternatePerRep:
        return 'Per Rep';
      case HandMode.left:
        return 'Left';
      case HandMode.right:
        return 'Right';
    }
  }

  static String _handModeDescription(HandMode mode) {
    switch (mode) {
      case HandMode.both:
        return 'Train both hands simultaneously';
      case HandMode.alternatePerSet:
        return 'Alternate left/right each set';
      case HandMode.alternatePerRep:
        return 'Alternate left/right each rep';
      case HandMode.left:
        return 'Left hand only';
      case HandMode.right:
        return 'Right hand only';
    }
  }
}

// ──────────────────────────── Per-set table ──────────────────────────────

class _PerSetTable extends StatelessWidget {
  const _PerSetTable({
    required this.setConfigs,
    required this.onConfigsChanged,
    required this.isDark,
  });

  final List<SetConfig> setConfigs;
  final ValueChanged<List<SetConfig>> onConfigsChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text('Set',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: webMuted)),
                ),
                Expanded(
                  child: Text('Hang(s)',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: webMuted)),
                ),
                Expanded(
                  child: Text('Rest(s)',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: webMuted)),
                ),
                Expanded(
                  child: Text('Reps',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: webMuted)),
                ),
                const SizedBox(width: 32),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(setConfigs.length, (i) {
              final sc = setConfigs[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${i + 1}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? webText : lightText,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _MiniStepper(
                        value: sc.hangDurationSec,
                        onChanged: (v) {
                          final updated = List.of(setConfigs);
                          updated[i] = sc.copyWith(hangDurationSec: v);
                          onConfigsChanged(updated);
                        },
                      ),
                    ),
                    Expanded(
                      child: _MiniStepper(
                        value: sc.restDurationSec,
                        onChanged: (v) {
                          final updated = List.of(setConfigs);
                          updated[i] = sc.copyWith(restDurationSec: v);
                          onConfigsChanged(updated);
                        },
                      ),
                    ),
                    Expanded(
                      child: _MiniStepper(
                        value: sc.repsPerSet,
                        onChanged: (v) {
                          final updated = List.of(setConfigs);
                          updated[i] = sc.copyWith(repsPerSet: v);
                          onConfigsChanged(updated);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: setConfigs.length > 1
                          ? GestureDetector(
                              onTap: () {
                                final updated = List.of(setConfigs)
                                  ..removeAt(i);
                                onConfigsChanged(updated);
                              },
                              child: Icon(Icons.close,
                                  size: 16,
                                  color: webMuted.withValues(alpha: 0.6)),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                final last =
                    setConfigs.isNotEmpty ? setConfigs.last : const SetConfig();
                onConfigsChanged([...setConfigs, last]);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? webBorder.withValues(alpha: 0.4)
                        : lightBorder.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: brandAccent),
                    const SizedBox(width: 6),
                    Text(
                      'Add Set',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: brandAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: value > 1 ? () => onChanged(value - 1) : null,
          child: Icon(Icons.remove,
              size: 14,
              color: value > 1
                  ? (isDark ? webMuted : lightMuted)
                  : webMuted.withValues(alpha: 0.3)),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? webText : lightText,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(value + 1),
          child: Icon(Icons.add,
              size: 14, color: isDark ? webMuted : lightMuted),
        ),
      ],
    );
  }
}

// ──────────────────────────── Protocol type selector ─────────────────────

class _ProtocolTypeSelector extends StatelessWidget {
  const _ProtocolTypeSelector({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  final ProtocolType selected;
  final ValueChanged<ProtocolType> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [ProtocolType.repeater, ProtocolType.maxHang, ProtocolType.freeform].map((type) {
        final isSelected = type == selected;
        final icon = type == ProtocolType.maxHang
            ? Icons.timer
            : type == ProtocolType.repeater
                ? Icons.repeat
                : Icons.explore;
        final label = type == ProtocolType.maxHang
            ? 'Max Hang'
            : type == ProtocolType.repeater
                ? 'Repeater'
                : 'Freeform';

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type != ProtocolType.freeform ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(type);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? brandAccent.withValues(alpha: 0.12)
                      : (isDark ? webPanel : lightPanel),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? brandAccent.withValues(alpha: 0.5)
                        : (isDark
                            ? webBorder.withValues(alpha: 0.4)
                            : lightBorder.withValues(alpha: 0.5)),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon, size: 18,
                        color: isSelected ? brandAccent : webMuted),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: isSelected
                            ? brandAccent
                            : (isDark ? webText : lightText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────── Template card ──────────────────────────────

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.isDark,
    required this.onTap,
    this.onLongPress,
  });

  final SessionTemplate template;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final config = template.protocolConfig;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? webPanel : lightPanel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? webBorder.withValues(alpha: 0.6)
                : lightBorder.withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: brandAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _typeIcon(config.type),
                size: 18,
                color: brandAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? webText : lightText,
                    ),
                  ),
                  Text(
                    _configSummary(config),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: webMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: webMuted),
          ],
        ),
      ),
    );
  }

  static IconData _typeIcon(ProtocolType type) {
    switch (type) {
      case ProtocolType.maxHang:
        return Icons.timer;
      case ProtocolType.repeater:
        return Icons.repeat;
      case ProtocolType.freeform:
        return Icons.explore;
    }
  }

  static String _configSummary(ProtocolConfig config) {
    switch (config.type) {
      case ProtocolType.maxHang:
        return 'Max Hang \u00B7 ${config.sets} sets \u00B7 ${config.hangDurationSec}s';
      case ProtocolType.repeater:
        return 'Repeater \u00B7 ${config.sets}\u00D7${config.repsPerSet} \u00B7 ${config.hangDurationSec}/${config.restDurationSec}s';
      case ProtocolType.freeform:
        return 'Freeform';
    }
  }
}

// ──────────────────────────── Create new card ────────────────────────────

class _CreateNewCard extends StatelessWidget {
  const _CreateNewCard({required this.isDark, required this.onTap});

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? webPanel : lightPanel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: brandAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 18, color: brandAccent),
            const SizedBox(width: 8),
            Text(
              'Create New Workout',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: brandAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
