import 'package:auto_route/auto_route.dart';
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
        title: const Text('Xizmatlar'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 110.h),
        children: [
          _buildServiceCard(
            context,
            'Bank xizmatlari',
            Icons.account_balance,
            () => context.router.push(BankServicesRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            'Sug\'urta xizmatlari',
            Icons.shield,
            () => context.router.push(InsuranceServicesRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            'Valyuta kurslari',
            Icons.currency_exchange,
            () => context.router.push(CurrencyRatesRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            'Kartalar',
            Icons.credit_card,
            () => context.router.push(const CardsRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            'Depozitlar',
            Icons.savings,
            () => context.router.push(DepositRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            'Avtokredit',
            Icons.directions_car,
            () => context.router.push(const AutoCreditRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            'Ipoteka',
            Icons.home,
            () => context.router.push(const MortgageRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            'Mikrokredit',
            Icons.money,
            () => context.router.push(MicroLoanRoute()),
          ),
          SizedBox(height: 16.h),
          _buildServiceCard(
            context,
            'Pul o\'tkazmalar',
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
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 28.sp),
        title: Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

