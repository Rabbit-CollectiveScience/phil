import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final String category;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  Map<String, dynamic>? _schema;
  bool _isLoading = true;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _booleanValues = {};

  @override
  void initState() {
    super.initState();
    _loadSchema();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSchema() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/exercises/schemas/${widget.category}/${widget.exerciseId}.json',
      );
      final data = json.decode(response);

      setState(() {
        _schema = data;
        _isLoading = false;
      });

      // Initialize controllers and boolean values
      if (data['parameters'] != null) {
        for (var param in data['parameters']) {
          final name = param['key'] as String;
          if (param['type'] == 'boolean') {
            _booleanValues[name] = false;
          } else {
            _controllers[name] = TextEditingController();
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading exercise: $e')));
      }
    }
  }

  void _addExercise() {
    // Validate required fields
    final parameters = _schema?['parameters'] as List?;
    if (parameters != null) {
      for (var param in parameters) {
        if (param['required'] == true) {
          final name = param['key'] as String;
          if (param['type'] == 'boolean') {
            // Booleans always have a value
            continue;
          } else {
            final value = _controllers[name]?.text.trim() ?? '';
            if (value.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${param['label']} is required'),
                  backgroundColor: Colors.red[700],
                ),
              );
              return;
            }
          }
        }
      }
    }

    // Build exercise data
    final Map<String, dynamic> parameterValues = {};

    // Add parameter values
    for (var entry in _controllers.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) {
        parameterValues[entry.key] = value;
      }
    }

    for (var entry in _booleanValues.entries) {
      parameterValues[entry.key] = entry.value;
    }

    final exerciseData = {
      'exerciseId': widget.exerciseId,
      'exerciseName': widget.exerciseName,
      'category': widget.category,
      'timestamp': DateTime.now().toIso8601String(),
      'parameters': parameterValues,
    };

    // TODO: Save to workout session
    // For now, just show success and navigate back
    debugPrint('Exercise data: $exerciseData');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exercise added successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to dashboard
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.exerciseName,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _schema == null
          ? const Center(
              child: Text(
                'Exercise not found',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Exercise Description
                          if (_schema!['description'] != null) ...[
                            Text(
                              _schema!['description'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Parameters Section
                          const Text(
                            'Enter Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Parameter Fields
                          if (_schema!['parameters'] != null)
                            ..._buildParameterFields(
                              _schema!['parameters'] as List,
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Add Button
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      border: Border(
                        top: BorderSide(color: Colors.grey[800]!, width: 1),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Exercise',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildParameterFields(List<dynamic> parameters) {
    return parameters.map<Widget>((param) {
      final name = param['key'] as String;
      final label = param['label'] as String;
      final type = param['type'] as String;
      final required = param['required'] == true;
      final unit = param['unit'] as String?;

      switch (type) {
        case 'boolean':
          return _buildBooleanField(name, label, required);
        case 'text':
          return _buildTextField(name, label, required, unit, false);
        case 'duration':
        case 'number':
          return _buildTextField(name, label, required, unit, true);
        default:
          return _buildTextField(name, label, required, unit, false);
      }
    }).toList();
  }

  Widget _buildTextField(
    String name,
    String label,
    bool required,
    String? unit,
    bool isNumeric,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _controllers[name],
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          labelStyle: const TextStyle(color: Colors.white70),
          suffixText: unit,
          suffixStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[800]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildBooleanField(String name, String label, bool required) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              required ? '$label *' : label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Switch(
              value: _booleanValues[name] ?? false,
              onChanged: (value) {
                setState(() {
                  _booleanValues[name] = value;
                });
              },
              activeColor: Colors.blue[700],
            ),
          ],
        ),
      ),
    );
  }
}
