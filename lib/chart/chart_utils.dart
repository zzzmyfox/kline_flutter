class ChartUtils {
  /// date format
  String dateFormat(int timestamp, {bool year}) {
    List<String> dateList = DateTime.fromMillisecondsSinceEpoch(timestamp).toString().split(" ");
    List<String> date = dateList[0].toString().split("-");
    List<String> time = dateList[1].toString().split(":");
    String format = "${date[1]}-${date[2]} ${time[0]}:${time[1]}";
    if (year??false) {
      format = "${date[0]}-${date[1]}-${date[2]} ${time[0]}:${time[1]}";
    }
    return format;
  }
  /// precision
  String setPrecision(double num, int scale) {
    return num.toStringAsFixed(scale);
  }
}
