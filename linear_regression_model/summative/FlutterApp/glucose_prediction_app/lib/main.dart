import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const GlucosePredictionApp());
}

class GlucosePredictionApp extends StatelessWidget {
  const GlucosePredictionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glucose Level Predictor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  String _result = '';
  bool _isLoading = false;

  // API endpoint
  static const String apiUrl = 'https://linear-regression-model2.onrender.com/predict';

  // Input fields with their constraints
  final Map<String, Map<String, dynamic>> inputFields = {
    'AGE': {'min': 10, 'max': 100, 'type': 'int', 'label': 'Age (years)'},
    'GENDER': {'min': 0, 'max': 1, 'type': 'int', 'label': 'Gender (0=Female, 1=Male)'},
    'WEIGHT': {'min': 20, 'max': 200, 'type': 'double', 'label': 'Weight (kg)'},
    'SKIN_COLOR': {'min': 1, 'max': 3, 'type': 'int', 'label': 'Skin Color (1-3)'},
    'NIR_Reading': {'min': 50, 'max': 1000, 'type': 'double', 'label': 'NIR Reading'},
    'HEARTRATE': {'min': 20, 'max': 200, 'type': 'double', 'label': 'Heart Rate (bpm)'},
    'HEIGHT': {'min': 4.0, 'max': 7.5, 'type': 'double', 'label': 'Height (feet)'},
    'LAST_EATEN': {'min': 0, 'max': 24, 'type': 'double', 'label': 'Hours Since Last Meal'},
    'DIABETIC': {'min': 0, 'max': 1, 'type': 'int', 'label': 'Diabetic (0=No, 1=Yes)'},
    'HR_IR': {'min': 10000, 'max': 120000, 'type': 'double', 'label': 'HR Infrared Reading'},
  };

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    for (String field in inputFields.keys) {
      _controllers[field] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _makePrediction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // Prepare request body
      Map<String, dynamic> requestBody = {};
      for (String field in inputFields.keys) {
        String value = _controllers[field]!.text.trim();
        if (inputFields[field]!['type'] == 'int') {
          requestBody[field] = int.parse(value);
        } else {
          requestBody[field] = double.parse(value);
        }
      }

      // Make API request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _result = 'Predicted Glucose Level: ${responseData['predicted_glucose_level']} mg/dL';
        });
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _result = 'Error: ${errorData['detail'] ?? 'Failed to get prediction'}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: Failed to connect to server. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearFields() {
    for (var controller in _controllers.values) {
      controller.clear();
    }
    setState(() {
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Glucose Level Predictor'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.health_and_safety, size: 40, color: Colors.teal),
                              SizedBox(height: 8),
                              Text(
                                'Enter Patient Information',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Fill all fields to predict glucose level',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...inputFields.entries.map((entry) => _buildInputField(entry.key, entry.value)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _makePrediction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Predicting...'),
                                      ],
                                    )
                                  : const Text(
                                      'Predict',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _clearFields,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_result.isNotEmpty)
                        Card(
                          color: _result.startsWith('Error') ? Colors.red[50] : Colors.green[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  _result.startsWith('Error') ? Icons.error : Icons.check_circle,
                                  size: 40,
                                  color: _result.startsWith('Error') ? Colors.red : Colors.green,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Result',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _result.startsWith('Error') ? Colors.red[700] : Colors.green[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _result,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _result.startsWith('Error') ? Colors.red[700] : Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String fieldName, Map<String, dynamic> fieldInfo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _controllers[fieldName],
        keyboardType: fieldInfo['type'] == 'int' 
            ? TextInputType.number 
            : const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: fieldInfo['label'],
          hintText: 'Range: ${fieldInfo['min']} - ${fieldInfo['max']}',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(_getIconForField(fieldName)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }

          try {
            double numValue;
            if (fieldInfo['type'] == 'int') {
              numValue = double.parse(value.trim());
              if (numValue != numValue.toInt()) {
                return 'Please enter a whole number';
              }
            } else {
              numValue = double.parse(value.trim());
            }

            if (numValue < fieldInfo['min'] || numValue > fieldInfo['max']) {
              return 'Value must be between ${fieldInfo['min']} and ${fieldInfo['max']}';
            }
          } catch (e) {
            return 'Please enter a valid number';
          }

          return null;
        },
      ),
    );
  }

  IconData _getIconForField(String fieldName) {
    switch (fieldName) {
      case 'AGE':
        return Icons.calendar_today;
      case 'GENDER':
        return Icons.person;
      case 'WEIGHT':
        return Icons.fitness_center;
      case 'SKIN_COLOR':
        return Icons.palette;
      case 'NIR_Reading':
        return Icons.sensors;
      case 'HEARTRATE':
        return Icons.favorite;
      case 'HEIGHT':
        return Icons.height;
      case 'LAST_EATEN':
        return Icons.restaurant;
      case 'DIABETIC':
        return Icons.medical_services;
      case 'HR_IR':
        return Icons.monitor_heart;
      default:
        return Icons.input;
    }
  }
}
