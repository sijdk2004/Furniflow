import 'package:excel/excel.dart';
void main() {
  var excel = Excel.createExcel();
  var bytes = excel.encode();
  if (bytes != null) {
    print("Encode successful, length: ${bytes.length}");
  } else {
    print("Encode failed");
  }
}
