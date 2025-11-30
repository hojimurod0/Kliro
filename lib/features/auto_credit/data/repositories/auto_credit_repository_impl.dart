import 'dart:developer' as developer;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/auto_credit.dart';
import '../../../../data/models/pagination_filter.dart';
import '../../../../data/services/auto_credit_service.dart';
import '../../domain/entities/auto_credit_filter.dart';
import '../../domain/entities/auto_credit_offer.dart';
import '../../domain/repositories/auto_credit_repository.dart';
import '../datasources/auto_credit_local_data_source.dart';

class AutoCreditRepositoryImpl implements AutoCreditRepository {
  AutoCreditRepositoryImpl({
    required AutoCreditLocalDataSource localDataSource,
    required AutoCreditService remoteService,
  })  : _localDataSource = localDataSource,
        _remoteService = remoteService;

  final AutoCreditLocalDataSource _localDataSource;
  final AutoCreditService _remoteService;

  @override
  Future<List<AutoCreditOffer>> getAutoCreditOffers({
    AutoCreditFilter filter = AutoCreditFilter.empty,
  }) async {
    try {
      final remote = await _remoteService.fetchAutoCredits(
        pagination: const PaginationFilter(page: 0, size: 20),
        bank: filter.bank,
        rateFrom: filter.rateFrom,
        termMonthsFrom: filter.termMonthsFrom,
        amountFrom: filter.amountFrom,
        opening: filter.opening,
        search: filter.search,
        sort: filter.sort,
        direction: filter.direction,
      );
      if (remote.isNotEmpty) {
        return remote.map(_mapRemoteOffer).toList();
      }
    } catch (error, stackTrace) {
      developer.log(
        'Failed to load auto credits from API, falling back to local data',
        name: 'AutoCreditRepositoryImpl',
        error: error,
        stackTrace: stackTrace,
      );
    }

    return _localDataSource.fetchAutoCreditOffers();
  }

  AutoCreditOffer _mapRemoteOffer(AutoCredit item) {
    final opening = _normalizeOpening(item.opening);
    return AutoCreditOffer(
      bankName: item.bank.isNotEmpty ? item.bank : 'Noma\'lum bank',
      rating: _calculateRating(item.rate),
      monthlyPayment: _calculateMonthlyPayment(item),
      interestRate: _formatRate(item.rate, fallback: item.rateText),
      term: _formatTerm(item.termMonths, fallback: item.termText),
      maxSum: _formatAmount(item.amount, fallback: item.amountText),
      applicationMethod: _openingLabel(opening),
      applicationIcon: _iconForOpening(opening),
      applicationColor: _colorForOpening(opening),
      advantages: _buildAdvantages(item),
    );
  }

  double _calculateRating(double? rate) {
    if (rate == null) return 4.2;
    final normalized = (20 - rate) / 5;
    return double.parse(
      normalized.clamp(3.5, 4.9).toStringAsFixed(1),
    );
  }

  String _calculateMonthlyPayment(AutoCredit item) {
    final amount = item.amount;
    final termMonths = item.termMonths;
    if (amount == null || termMonths == null || termMonths == 0) {
      return '—';
    }
    final monthly = amount / termMonths;
    return '${_formatAmount(monthly)} ${tr('auto_credit.per_month')}';
  }

  String _formatRate(double? rate, {String? fallback}) {
    if (rate != null) {
      final hasDecimal = rate % 1 != 0;
      return '${rate.toStringAsFixed(hasDecimal ? 1 : 0)}%';
    }
    return _fallbackText(fallback);
  }

  String _formatTerm(int? termMonths, {String? fallback}) {
    if (termMonths != null && termMonths > 0) {
      if (termMonths % 12 == 0) {
        final years = termMonths ~/ 12;
        return '$years ${tr('auto_credit.year')}';
      }
      return '$termMonths ${tr('auto_credit.month')}';
    }
    return _fallbackText(fallback);
  }

  String _formatAmount(double? amount, {String? fallback}) {
    if (amount != null && amount > 0) {
      if (amount >= 1e9) {
        return '${(amount / 1e9).toStringAsFixed(1)} ${tr('auto_credit.billion_soum')}';
      }
      if (amount >= 1e6) {
        return '${(amount / 1e6).toStringAsFixed(1)} ${tr('auto_credit.million_soum')}';
      }
      if (amount >= 1e3) {
        return '${(amount / 1e3).toStringAsFixed(1)} ${tr('auto_credit.thousand_soum')}';
      }
      return '${amount.toStringAsFixed(0)} ${tr('auto_credit.soum')}';
    }
    return _fallbackText(fallback);
  }

  String _fallbackText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return tr('auto_credit.not_specified');
    return trimmed;
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  String _normalizeOpening(String? opening) {
    final value = opening?.toLowerCase().trim();
    if (value == 'online' || value == 'digital') return 'online';
    if (value == 'bank' || value == 'branch') return 'bank';
    return 'other';
  }

  String _openingLabel(String opening) {
    // Import easy_localization at the top if not already imported
    switch (opening) {
      case 'online':
        return 'auto_credit.online'.tr();
      case 'bank':
        return 'auto_credit.bank_branch'.tr();
      default:
        return 'auto_credit.all_channels'.tr();
    }
  }

  IconData _iconForOpening(String opening) {
    switch (opening) {
      case 'online':
        return Icons.phone_iphone;
      case 'bank':
        return Icons.apartment;
      default:
        return Icons.check_circle;
    }
  }

  Color _colorForOpening(String opening) {
    switch (opening) {
      case 'online':
        return Colors.green;
      case 'bank':
        return Colors.blueGrey;
      default:
        return Colors.orange;
    }
  }

  List<String> _buildAdvantages(AutoCredit item) {
    final advantages = <String>[];
    final hasRateInfo = item.rate != null || _hasText(item.rateText);
    if (hasRateInfo) {
      advantages.add(
        '${tr('auto_credit.interest')} ${_formatRate(item.rate, fallback: item.rateText)}',
      );
    }
    final hasTermInfo =
        (item.termMonths != null && item.termMonths! > 0) ||
            _hasText(item.termText);
    if (hasTermInfo) {
      final termText = _formatTerm(item.termMonths, fallback: item.termText);
      advantages.add(
        '${tr('auto_credit.term')} $termText',
      );
    }
    final hasAmountInfo =
        (item.amount != null && item.amount! > 0) || _hasText(item.amountText);
    if (hasAmountInfo) {
      advantages.add(
        '${tr('auto_credit.max_amount')} ${_formatAmount(item.amount, fallback: item.amountText)}',
      );
    }
    if (item.opening != null && item.opening!.isNotEmpty) {
      advantages.add('${tr('auto_credit.application_method')} ${_openingLabel(_normalizeOpening(item.opening))}');
    }
    if (advantages.isEmpty) {
      advantages.add(tr('auto_credit.default_advantages'));
    }
    return advantages;
  }
}

