import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/airport_hint_model.dart';
import '../bloc/avia_bloc.dart';

class AirportInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final Function(AirportHintModel)? onAirportSelected;
  final VoidCallback? onClear;

  const AirportInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.onAirportSelected,
    this.onClear,
  });

  @override
  State<AirportInput> createState() => _AirportInputState();
}

class _AirportInputState extends State<AirportInput> {
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    // Rebuild to show/hide clear (X) button immediately
    if (mounted) setState(() {});

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final text = widget.controller.text.trim();
      if (text.length >= 2 && _focusNode.hasFocus) {
        if (mounted) {
          context.read<AviaBloc>().add(
                AirportHintsRequested(phrase: text, limit: 10),
              );
        }
      } else {
        _removeOverlay();
      }
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    } else {
      // Focus olganda, agar text bo'sh bo'lmasa va 2+ belgi bo'lsa, qidiruvni boshlash
      final text = widget.controller.text.trim();
      if (text.length >= 2) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 300), () {
          if (mounted && _focusNode.hasFocus) {
            context.read<AviaBloc>().add(
              AirportHintsRequested(phrase: text, limit: 10),
            );
          }
        });
      }
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay(List<AirportHintModel> airports) {
    if (!mounted) return;
    AppLogger.debug('_showOverlay called with ${airports.length} airports');
    _removeOverlay();

    if (airports.isEmpty) {
      AppLogger.warning('_showOverlay: airports list is empty');
      return;
    }

    _overlayEntry = _createOverlayEntry(airports);
    if (mounted && _overlayEntry != null) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  OverlayEntry _createOverlayEntry(List<AirportHintModel> airports) {
    if (!mounted) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }
    
    final theme = Theme.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 8.h),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxHeight: 300.h),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: airports.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final airport = airports[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    title: Text(
                      airport.displayName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    subtitle: airport.code != null
                        ? Text(
                            '${airport.code} • ${airport.countryIntl?.uz ?? airport.countryIntl?.en ?? airport.country ?? ""}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                          )
                        : null,
                    onTap: () {
                      // Исправление ошибки SpannableStringBuilder: очищаем selection перед изменением текста
                      widget.controller.selection = TextSelection.collapsed(offset: widget.controller.text.length);
                      widget.controller.value = TextEditingValue(
                        text: airport.displayName,
                        selection: TextSelection.collapsed(offset: airport.displayName.length),
                      );
                      widget.onAirportSelected?.call(airport);
                      _focusNode.unfocus();
                      _removeOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocListener<AviaBloc, AviaState>(
      bloc: context.read<AviaBloc>(),
      listener: (context, state) {
        if (!mounted) return;
        AppLogger.debug('AirportInput: State changed to ${state.runtimeType}');
        
        // Faqat focus bo'lgan input uchun overlay ko'rsatish
        if (!_focusNode.hasFocus) {
          return;
        }
        
        if (state is AviaAirportHintsSuccess) {
          AppLogger.success('AirportInput: Received ${state.airports.length} airports');
          // Faqat focus bo'lgan input uchun overlay ko'rsatish
          if (_focusNode.hasFocus) {
            _showOverlay(state.airports);
          }
        } else if (state is AviaAirportHintsFailure) {
          AppLogger.error('AirportInput: Error - ${state.message}');
          // Faqat focus bo'lgan input uchun overlay yopish
          if (_focusNode.hasFocus) {
            _removeOverlay();
          }
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              style: TextStyle(
                fontSize: 16.sp,
                color: theme.textTheme.titleLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5) ?? AppColors.grayText,
                ),
                prefixIcon: Icon(
                  widget.icon,
                  color: theme.iconTheme.color?.withValues(alpha: 0.7) ?? AppColors.grayText,
                  size: 20.sp,
                ),
                suffixIcon: widget.controller.text.trim().isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18.sp,
                          color: theme.iconTheme.color?.withValues(alpha: 0.6) ??
                              AppColors.grayText,
                        ),
                        onPressed: () {
                          // Keep it safe for spannable selection edge cases
                          widget.controller.selection =
                              const TextSelection.collapsed(offset: 0);
                          widget.controller.clear();
                          widget.onClear?.call();
                          _removeOverlay();
                          if (mounted) setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

