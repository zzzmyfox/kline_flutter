class ChartUtils {
  /// date format
  String dateFormat(int timestamp, {bool year}) {
    List<String> dateList =
        DateTime.fromMillisecondsSinceEpoch(timestamp).toString().split(" ");
    List<String> date = dateList[0].toString().split("-");
    List<String> time = dateList[1].toString().split(":");
    String format = "${date[1]}-${date[2]} ${time[0]}:${time[1]}";
    if (year ?? false) {
      format = "${date[0]}-${date[1]}-${date[2]} ${time[0]}:${time[1]}";
    }
    return format;
  }

  /// precision
  String setPrecision(double num, int scale) {
    return num.toStringAsFixed(scale);
  }

  String formatDataNum(double num) {
    if (num < 1) {
      return setPrecision(num, 6);
    } else if (num < 10) {
      return setPrecision(num, 5);
    } else if (num < 100) {
      return setPrecision(num, 4);
    } else {
      return setPrecision(num, 2);
    }
  }
}
