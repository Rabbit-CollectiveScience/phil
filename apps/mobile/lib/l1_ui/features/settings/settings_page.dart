import 'package:flutter/material.dart';
import '../../../l2_domain/use_cases/dev/add_mock_data_use_case.dart';
import '../../../l2_domain/use_cases/dev/clear_all_data_use_case.dart';
import '../../../main.dart';
import '../../shared/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isAddingMockData = false;
  bool _isClearingData = false;
  String? _statusMessage;

  Future<void> _addMockData() async {
    setState(() {
      _isAddingMockData = true;
      _statusMessage = null;
    });

    try {
      final useCase = getIt<AddMockDataUseCase>();
      final count = await useCase.execute();

      if (mounted) {
        setState(() {
          _isAddingMockData = false;
          _statusMessage = 'Successfully added $count workout sets!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAddingMockData = false;
          _statusMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _clearAllData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.boldGrey,
        title: const Text(
          'Clear All Data',
          style: TextStyle(color: AppColors.offWhite),
        ),
        content: const Text(
          'This will delete all your workout history and personal records. This cannot be undone.\n\nYour exercise library will be preserved.',
          style: TextStyle(color: AppColors.offWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.offWhite),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isClearingData = true;
      _statusMessage = null;
    });

    try {
      final clearDataUseCase = getIt<ClearAllDataUseCase>();
      final result = await clearDataUseCase.execute();

      if (mounted) {
        setState(() {
          _isClearingData = false;
          _statusMessage =
              'Deleted ${result['workoutSets']} sets and ${result['personalRecords']} PRs';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isClearingData = false;
          _statusMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepCharcoal,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
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
                  Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.offWhite,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _isAddingMockData ? null : _addMockData,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isAddingMockData
                              ? AppColors.boldGrey.withOpacity(0.5)
                              : AppColors.boldGrey,
                          borderRadius: BorderRadius.zero,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.pureBlack.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isAddingMockData
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.offWhite,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'ADD MOCK DATA',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.offWhite,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Clear All Data Button
                    GestureDetector(
                      onTap: _isClearingData ? null : _clearAllData,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isClearingData
                              ? AppColors.boldGrey.withOpacity(0.5)
                              : AppColors.boldGrey,
                          borderRadius: BorderRadius.zero,
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.pureBlack.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isClearingData
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.red,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'CLEAR ALL DATA',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.red,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    if (_statusMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.boldGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _statusMessage!.startsWith('Error')
                                ? Colors.red.shade300
                                : AppColors.limeGreen,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
