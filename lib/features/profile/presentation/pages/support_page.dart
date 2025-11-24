import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/navigation/app_router.dart';

const Color kScaffoldBgColor = Color(0xFFF0F0F0);
const Color kCardBgColor = Color(0xFFFFFFFF);
const Color kShadowColor = Color.fromARGB(25, 0, 0, 0);
const Color kTextColor = Color(0xFF212121);
const Color kIconColor = Color(0xFF212121);
const double kBorderRadius = 15.0;

@RoutePage()
class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          tr('support.title'),
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color ?? kTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color ?? kTextColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 25.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildSupportSection(context),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.only(left: 8.w, bottom: 10.h),
                child: Text(
                  tr('support.social_networks'),
                  style: TextStyle(
                    color:
                        Theme.of(context).textTheme.titleLarge?.color ??
                        kTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSocialSection(),
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildListItem(
          context: context,
          icon: Icons.chat_bubble_outline,
          title: tr('support.online_chat'),
          showTrailingIcon: true,
          onTap: () {
            context.router.push(const SupportChatRoute());
          },
        ),
        SizedBox(height: 10.h),
        _buildListItem(
          context: context,
          icon: Icons.phone_outlined,
          title: tr('support.phone'),
          onTap: () {},
        ),
        SizedBox(height: 10.h),
        _buildListItem(
          context: context,
          icon: Icons.send_outlined,
          title: tr('support.telegram'),
          showTrailingIcon: true,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Builder(
      builder: (context) => Column(
        children: [
          _buildListItem(
            context: context,
            icon: Icons.send_outlined,
            title: tr('support.telegram_social'),
            onTap: () {},
          ),
          SizedBox(height: 10.h),
          _buildListItem(
            context: context,
            icon: Icons.camera_alt_outlined,
            title: tr('support.instagram'),
            onTap: () {},
          ),
          SizedBox(height: 10.h),
          _buildListItem(
            context: context,
            icon: Icons.facebook,
            title: tr('support.facebook'),
            onTap: () {},
          ),
          SizedBox(height: 10.h),
          _buildListItem(
            context: context,
            icon: Icons.location_on_outlined,
            title: tr('support.address'),
            onTap: () {
              debugPrint("Manzil xaritada ochilmoqda...");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showTrailingIcon = false,
  }) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).iconTheme.color ?? kIconColor,
                  size: 24.sp,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          kTextColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (showTrailingIcon)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: const Color(0xFFC0C0C0),
                    size: 16.sp,
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
