import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// Đọc được nhưng mọi lần ghi đều hỏng — mô phỏng lỗi lưu trữ.
class _WriteFailsStore extends InMemorySharedPreferencesStore {
  _WriteFailsStore.withData(super.data) : super.withData();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    throw Exception('ổ đĩa đầy');
  }
}

/// Nạp dữ liệu như [SharedPreferences.setMockInitialValues] nhưng ghi sẽ lỗi.
void setMockValuesWithFailingWrites(Map<String, Object> values) {
  SharedPreferences.setMockInitialValues(values);
  SharedPreferencesStorePlatform.instance = _WriteFailsStore.withData(
    values.map((k, v) => MapEntry('flutter.$k', v)),
  );
}
