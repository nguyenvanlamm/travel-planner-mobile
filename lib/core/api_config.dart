/// URL backend — đổi 1 dòng này khi có URL Render chính thức,
/// hoặc build với: flutter build apk --dart-define=API_BASE_URL=https://...
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://travel-planner-server-k4i6.onrender.com',
);
