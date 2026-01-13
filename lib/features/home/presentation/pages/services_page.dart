import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('home.services'.tr()),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 110.h),
        children: [
          _buildServiceCard(
            context,
            tr('bank.services'),
            Icons.account_balance,
            () => context.router.push(BankServicesRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            tr('insurance.title'),
            Icons.shield,
            () => context.router.push(InsuranceServicesRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            tr('bank.currency'),
            Icons.currency_exchange,
            () => context.router.push(CurrencyDetailRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            tr('bank.cards'),
            Icons.credit_card,
            () => context.router.push(const CardsRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            tr('bank.deposit'),
            Icons.savings,
            () => context.router.push(DepositRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            tr('bank.auto_credit'),
            Icons.directions_car,
            () => context.router.push(const AutoCreditRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            tr('bank.mortgage'),
            Icons.home,
            () => context.router.push(const MortgageRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            tr('bank.micro_loan'),
            Icons.money,
            () => context.router.push(MicroLoanRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            tr('transfers.title'),
            Icons.swap_horiz,
            () => context.router.push(const TransferAppsRoute()),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.cardColor,
      child: ListTile(
        leading: Icon(
          icon, 
          size: 28.sp,
          color: theme.iconTheme.color,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp, 
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.iconTheme.color,
        ),
        onTap: onTap,
      ),
    );
  }
}

