import 'package:excel/excel.dart';
import 'dart:io';

void main() {
  var excel = Excel.createExcel();
  var sheet = excel['Sheet1'];
  
  var cell = sheet.cell(CellIndex.indexByString("A1"));
  cell.value = TextCellValue("Furniflow ERP");
  cell.cellStyle = CellStyle(
    bold: true,
    fontColorHex: ExcelColor.fromHexString('#ffffff'),
    backgroundColorHex: ExcelColor.fromHexString('#1A365D'),
  );
  
  var fileBytes = excel.save();
  File("test.xlsx").writeAsBytesSync(fileBytes!);
  print("Excel saved successfully");
}
