# Glucose Level Prediction with Linear Regression – Health Focused 🩺

**Mission**: Diabetes and other blood sugar disorders pose a growing global health challenge, often going undetected until serious complications arise. This project leverages a simple linear regression model to predict blood glucose levels from health and lifestyle factors, providing a data-driven approach to early detection, preventive care, and public health awareness.

## � GitHub Repository
All source files are hosted here:
➡️ https://github.com/MichaelMusembi/linear_regression_model2

Contents include:
- **linear_regression/**: Jupyter notebook for data analysis, preprocessing, and model training
- **API/**: FastAPI backend for serving predictions  
- **FlutterApp/**: Flutter mobile app to consume and visualize API predictions

## 📡 Public API Endpoint (Live)
🔗 **Base URL**: https://linear-regression-model2.onrender.com/

📘 **Swagger UI Docs**: https://linear-regression-model2.onrender.com/docs

**YouTube Demo Video URL**: https://youtu.be/vaVTie3-xiU

## ➕ Example API Request
```json
POST /predict
{
  "AGE": 25,
  "GENDER": 1,
  "WEIGHT": 70.5,
  "SKIN_COLOR": 2,
  "NIR_Reading": 125.8,
  "HEARTRATE": 75.0,
  "HEIGHT": 5.8,
  "LAST_EATEN": 3.5,
  "DIABETIC": 0,
  "HR_IR": 85000.0
}
```

## ✔️ Example Response
```json
{
  "predicted_glucose_level": 98.75
}
```

## 🧠 Dataset Source
We use real-world data sourced from Kaggle:
📊 [Glucose Level Estimation Dataset](https://www.kaggle.com/datasets/fatimaafzaal/glucose-level-estimation?utm_source=chatgpt.com)

## 📱 How to Run the Mobile App (Flutter)
The Flutter app consumes the API and provides a mobile interface to enter inputs and view glucose predictions.

### 🚀 Prerequisites
- Flutter SDK (version ≥ 3.10)
- Android Studio or Visual Studio Code
- Internet access to connect to the public API

### 🛠️ Installation Steps

1. **Clone the repository**
```bash
git clone https://github.com/MichaelMusembi/linear_regression_model2.git
cd linear_regression_model2/linear_regression_model/summative/FlutterApp/glucose_prediction_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

On emulator or real device, input your health values and hit **Predict** to view glucose level predictions via API.

*Make sure your emulator/device is connected to the internet to access the public API.*

## Contributors
**Michael Musembi** – @MichaelMusembi

## License
MIT License © 2025 Michael Musembi
