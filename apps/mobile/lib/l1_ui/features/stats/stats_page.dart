import 'package:flutter/material.dart';
import '../../shared/theme/app_colors.dart';
import 'views/today_view.dart';
import 'views/weekly_view.dart';
import 'views/log_view.dart';
import 'views/pr_view.dart';
import '../settings/settings_page.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key, this.initialSection = 1});

  final int initialSection;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late String _selectedSection;

  @override
  void initState() {
    super.initState();
    final sections = ['TODAY', 'WEEKLY', 'PR', 'LOG', 'SETTING'];
    _selectedSection = sections[widget.initialSection];
  }

  @override
  Widget build(BuildContext context) {
    final List<String> sections = ['TODAY', 'WEEKLY', 'PR', 'LOG', 'SETTING'];

    return Scaffold(
      backgroundColor: AppColors.deepCharcoal,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and section selector
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.boldGrey,
                        borderRadius: BorderRadius.zero,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pureBlack.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.offWhite,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'STATS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.offWhite,
                            letterSpacing: 1.5,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (selected) {
                            // Navigate to Settings instead of switching view
                            if (selected == 'SETTING') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsPage(),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _selectedSection = selected;
                            });
                          },
                          offset: const Offset(0, 50),
                          color: AppColors.boldGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          itemBuilder: (context) {
                            return sections.map((section) {
                              return PopupMenuItem<String>(
                                value: section,
                                child: Text(
                                  section,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: section == _selectedSection
                                        ? AppColors.limeGreen
                                        : AppColors.offWhite,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.boldGrey,
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedSection,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.limeGreen,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.limeGreen,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: _selectedSection == 'TODAY'
                  ? const TodayView()
                  : _selectedSection == 'WEEKLY'
                  ? const WeeklyView()
                  : _selectedSection == 'LOG'
                  ? const LogView()
                  : _selectedSection == 'PR'
                  ? const PRView()
                  : Center(
                      child: Text(
                        '$_selectedSection coming soon',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.offWhite.withOpacity(0.5),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
