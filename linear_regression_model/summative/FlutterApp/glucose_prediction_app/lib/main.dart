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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/about': (context) => const AboutPage(),
      },
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
  static const String apiUrl = 'https://linear-regression-model-klxi.onrender.com/predict';

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
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/about');
            },
            icon: const Icon(Icons.info, size: 18),
            label: const Text('About'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Glucose Predictor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'AI-Powered Health App',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.teal),
              title: const Text('Home'),
              subtitle: const Text('Prediction form'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.teal),
              title: const Text('About'),
              subtitle: const Text('App information'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
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
                                        SizedBox(width: 10),
                                        Text('Predicting...'),
                                      ],
                                    )
                                  : const Text('Predict Glucose Level', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _clearFields,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      if (_result.isNotEmpty)
                        Card(
                          margin: const EdgeInsets.only(top: 20),
                          color: _result.startsWith('Error') ? Colors.red[50] : Colors.green[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  _result.startsWith('Error') ? Icons.error : Icons.check_circle,
                                  size: 40,
                                  color: _result.startsWith('Error') ? Colors.red[700] : Colors.green[700],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _result,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _result.startsWith('Error') ? Colors.red[700] : Colors.green[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (!_result.startsWith('Error'))
                                  const Text(
                                    'Normal range: 70-100 mg/dL (fasting)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
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

  Widget _buildInputField(String fieldName, Map<String, dynamic> constraints) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _controllers[fieldName],
        decoration: InputDecoration(
          labelText: constraints['label'],
          prefixIcon: Icon(_getIconForField(fieldName)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          helperText: 'Range: ${constraints['min']} - ${constraints['max']}',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter ${constraints['label'].toLowerCase()}';
          }

          double? numValue;
          try {
            numValue = double.parse(value.trim());
          } catch (e) {
            return 'Please enter a valid number';
          }

          if (numValue < constraints['min'] || numValue > constraints['max']) {
            return 'Value must be between ${constraints['min']} and ${constraints['max']}';
          }

          return null;
        },
      ),
    );
  }

  IconData _getIconForField(String fieldName) {
    switch (fieldName) {
      case 'AGE':
        return Icons.person;
      case 'GENDER':
        return Icons.wc;
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

// About Page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.health_and_safety,
                    size: 80,
                    color: Colors.teal,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Glucose Level Predictor',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'About This App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This application uses advanced machine learning algorithms to predict glucose levels based on various patient parameters. The prediction model considers factors such as age, gender, weight, heart rate, and other physiological indicators to provide accurate glucose level estimations.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureItem(
                  icon: Icons.psychology,
                  text: 'AI-powered glucose level prediction',
                ),
                _buildFeatureItem(
                  icon: Icons.assignment,
                  text: 'Comprehensive patient parameter input',
                ),
                _buildFeatureItem(
                  icon: Icons.speed,
                  text: 'Real-time prediction results',
                ),
                _buildFeatureItem(
                  icon: Icons.security,
                  text: 'Secure and private data handling',
                ),
                _buildFeatureItem(
                  icon: Icons.phone_android,
                  text: 'User-friendly mobile interface',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'How It Works',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Enter patient information including age, gender, weight, and vital signs\n'
              '2. The app validates all input parameters\n'
              '3. Data is sent securely to our machine learning model\n'
              '4. The model processes the information and returns a glucose level prediction\n'
              '5. Results are displayed with contextual information',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Important Notice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'This application is for educational and research purposes only. Predictions should not be used as a substitute for professional medical advice, diagnosis, or treatment. Always consult with a healthcare professional for medical concerns.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Developer Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Developed by: Sheryl Atieno Otieno\n'
              'Technology Stack: Flutter, Dart, Python, Machine Learning\n'
              'Backend: FastAPI with scikit-learn\n'
              'Deployment: Render Cloud Platform',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.home, color: Colors.white),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
