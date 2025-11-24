import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/datasources/transfer_app_local_data_source.dart';
import '../../data/repositories/transfer_app_repository_impl.dart';
import '../../domain/entities/transfer_app.dart';
import '../../domain/usecases/get_transfer_apps.dart';
import '../widgets/app_card.dart';

@RoutePage()
class TransferAppsPage extends StatefulWidget {
  const TransferAppsPage({super.key});

  @override
  State<TransferAppsPage> createState() => _TransferAppsPageState();
}

class _TransferAppsPageState extends State<TransferAppsPage> {
  late final GetTransferApps _getTransferApps;
  List<TransferApp> _apps = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _getTransferApps = GetTransferApps(
      TransferAppRepositoryImpl(
        localDataSource: const TransferAppLocalDataSource(),
      ),
    );
    _loadApps();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadApps() async {
    if (!mounted) return;

    try {
      final apps = await _getTransferApps();
      if (mounted) {
        setState(() {
          _apps = apps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik yuz berdi: $e')),
        );
      }
    }
  }

  List<TransferApp> get _filteredApps {
    if (_searchQuery.isEmpty) return _apps;
    return _apps.where((app) {
      return app.name.toLowerCase().contains(_searchQuery) ||
          app.bank.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredApps.isEmpty
                      ? Center(
                          child: Text(
                            'Hech narsa topilmadi',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 20.h,
                          ),
                          itemCount: _filteredApps.length,
                          separatorBuilder: (_, __) => SizedBox(height: 16.h),
                          itemBuilder: (context, index) {
                            return AppCard(app: _filteredApps[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB);
    final searchBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FB);
    final hintColor = isDark ? Colors.grey[600] : const Color(0xFF9CA3AF);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Column(
        children: [
          // Top Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircleBtn(
                Icons.arrow_back_rounded,
                () => context.router.pop(),
                isDark,
                borderColor,
              ),
              Text(
                "O'tkazma ilovalar",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              SizedBox(width: 44.w), // Balanslash uchun bo'sh joy
            ],
          ),
          SizedBox(height: 20.h),

          // Search Bar & Filter
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: searchBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Bank nomini qidiring...",
                      hintStyle: TextStyle(
                        color: hintColor,
                        fontSize: 14.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: const Color(0xFF0085FF),
                        size: 20.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      isCollapsed: true,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: borderColor),
                  color: cardBg,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    color: const Color(0xFF0085FF),
                    size: 20.sp,
                  ),
                  onPressed: () {},
                  splashRadius: 24.r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn(
    IconData icon,
    VoidCallback onTap,
    bool isDark,
    Color borderColor,
  ) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final iconColor = isDark ? Colors.white : const Color(0xFF374151);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(14.r),
          color: cardBg,
        ),
        child: Icon(icon, color: iconColor, size: 22.sp),
      ),
    );
  }
}

