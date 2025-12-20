import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../core/utils/snackbar_helper.dart';
import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_state.dart';

class OsagoSuccessScreen extends StatelessWidget {
  const OsagoSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OsagoBloc, OsagoState>(
      builder: (context, state) {
        final check = state.checkResponse;
        final calc = state.calcResponse;
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'insurance.osago.success.title'.tr(),
              style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
            ),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h),
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 72.w,
                ),
                SizedBox(height: 12.h),
                Text(
                  'insurance.osago.success.message'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 24.h),
                _buildInfoTile(context, 'insurance.osago.success.policy_number'.tr(), check?.policyNumber ?? '—'),
                _buildInfoTile(
                  context,
                  'insurance.osago.success.date'.tr(),
                  check?.issuedAt != null
                      ? '${check!.issuedAt!.day.toString().padLeft(2, '0')}.${check.issuedAt!.month.toString().padLeft(2, '0')}.${check.issuedAt!.year}'
                      : '—',
                ),
                _buildInfoTile(
                  context,
                  'insurance.osago.success.amount'.tr(),
                  calc == null
                      ? '—'
                      : '${calc.amount.toStringAsFixed(2)} ${calc.currency.toUpperCase()}',
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: check?.downloadUrl == null
                      ? null
                      : () => _openUrl(context, check!.downloadUrl!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text('insurance.osago.success.download'.tr()),
                ),
                SizedBox(height: 8.h),
                OutlinedButton(
                  onPressed: () => _share(context, check?.downloadUrl),
                  child: Text('insurance.osago.success.share'.tr()),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: Text('insurance.osago.success.close'.tr()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(BuildContext context, String title, String value) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color: Theme.of(context).cardColor,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
        ),
        subtitle: Text(
          value,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final success = await launchUrlString(url);
    if (!context.mounted) return;
    if (!success) {
      SnackbarHelper.showError(
        context,
        'insurance.osago.success.url_error'.tr(),
      );
    }
  }

  Future<void> _share(BuildContext context, String? url) async {
    if (url == null) {
      SnackbarHelper.showError(
        context,
        'insurance.osago.success.no_url'.tr(),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    SnackbarHelper.showSuccess(
      context,
      'insurance.osago.success.url_copied'.tr(),
    );
  }
}
