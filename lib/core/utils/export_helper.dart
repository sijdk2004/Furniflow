import 'package:excel/excel.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';

class ExportHelper {
  static void downloadExcel(String filename, Excel excel) {
    var fileBytes = excel.encode();
    if (fileBytes != null) {
      final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$filename.xlsx')
        ..click();
        
      html.Url.revokeObjectUrl(url);
    }
  }

  static void exportDashboardReport({
    required Map<String, dynamic> data,
    required String dashboardName,
    required String filename,
  }) {
    var excel = Excel.createExcel();
    Sheet sheet = excel[dashboardName];
    excel.setDefaultSheet(dashboardName);
    excel.delete('Sheet1');

    // Title / "Logo" Area (Simulated Premium Logo text)
    var titleStyle = CellStyle(
      bold: true,
      italic: false,
      fontSize: 24,
      fontFamily: getFontFamily(FontFamily.Arial),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      fontColorHex: ExcelColor.fromHexString('#ffffff'),
      backgroundColorHex: ExcelColor.fromHexString('#1A365D'),
    );

    sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("D3"));
    var titleCell = sheet.cell(CellIndex.indexByString("A1"));
    titleCell.value = TextCellValue("Furniflow ERP Platform");
    titleCell.cellStyle = titleStyle;

    // Subtitle
    var subStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.fromHexString('#333333'),
    );
    sheet.merge(CellIndex.indexByString("A5"), CellIndex.indexByString("D5"));
    var subCell = sheet.cell(CellIndex.indexByString("A5"));
    subCell.value = TextCellValue(dashboardName);
    subCell.cellStyle = subStyle;

    // Date Generated
    var dateStyle = CellStyle(italic: true, fontColorHex: ExcelColor.fromHexString('#666666'));
    sheet.merge(CellIndex.indexByString("A6"), CellIndex.indexByString("D6"));
    var dateCell = sheet.cell(CellIndex.indexByString("A6"));
    dateCell.value = TextCellValue("Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}");
    dateCell.cellStyle = dateStyle;

    // Set column widths
    sheet.setColumnWidth(0, 25.0);
    sheet.setColumnWidth(1, 20.0);
    sheet.setColumnWidth(2, 20.0);
    sheet.setColumnWidth(3, 20.0);

    // KPI Header
    var headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#ffffff'),
      backgroundColorHex: ExcelColor.fromHexString('#2B6CB0'),
      horizontalAlign: HorizontalAlign.Center,
    );
    
    int currentRow = 8;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).value = TextCellValue("Metric");
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow)).value = TextCellValue("Value");
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow)).cellStyle = headerStyle;
    
    currentRow++;

    var kpiStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);
    var valueStyle = CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true);

    final kpis = data['kpis'] ?? {};
    kpis.forEach((key, value) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).value = TextCellValue(key.toString().replaceAll('_', ' ').toUpperCase());
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).cellStyle = kpiStyle;
      
      if (value is num) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow)).value = DoubleCellValue(value.toDouble());
      } else {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow)).value = TextCellValue(value.toString());
      }
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow)).cellStyle = valueStyle;
      currentRow++;
    });

    currentRow += 2;

    // Recent Orders
    final widgets = data['widgets'] ?? {};
    final recentOrders = widgets['recent_orders'] as List<dynamic>? ?? [];
    
    if (recentOrders.isNotEmpty) {
      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow), CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow));
      var ordersTitle = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      ordersTitle.value = TextCellValue("Recent Orders");
      ordersTitle.cellStyle = subStyle;
      currentRow++;

      List<String> headers = ['Order Number', 'Customer', 'Amount', 'Status'];
      for (int i = 0; i < headers.length; i++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }
      currentRow++;

      for (var order in recentOrders) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).value = TextCellValue(order['order_number']?.toString() ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow)).value = TextCellValue(order['customer']?.toString() ?? '');
        
        var amt = order['amount'];
        if (amt is num) {
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow)).value = DoubleCellValue(amt.toDouble());
        } else {
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow)).value = TextCellValue(amt?.toString() ?? '');
        }
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow)).value = TextCellValue(order['status']?.toString() ?? '');
        currentRow++;
      }
    }

    downloadExcel(filename, excel);
  }
}
