import 'chart_model.dart';

class ChartCalculator {

  static int _day5 = 5;
  static int _day10 = 10;
  static int _day30 = 30;
//  double BEZIER_RATIO = 0.6;
  static List<ChartModel> _cacheList = List();

  ///MA
  static void calculateMa(List<ChartModel> dataList) {
    if (dataList == null || dataList.isEmpty) {
      return;
    }
    _cacheList.clear();
    _cacheList.addAll(dataList);
    for (int i = 0; i < dataList.length; i ++) {
      if (i + _day5 <= dataList.length) {
        //price ma5
        dataList[i + _day5 - 1].setPriceMA5(_getPriceMA(_cacheList.sublist(i, i + _day5)));
        //volume ma5
        dataList[i + _day5 - 1].setVolumeMA5(_getVolumeMA(_cacheList.sublist(i, i + _day5)));
      }
      if (i + _day10 <= dataList.length ) {
        //price ma10
        dataList[i + _day10 - 1].setPriceMA10(_getPriceMA(_cacheList.sublist(i, i + _day10)));
        //volume ma10
        dataList[i + _day10 - 1].setVolumeMA10(_getVolumeMA(_cacheList.sublist(i, i + _day10)));
      }
      if (i + _day30 <= dataList.length) {
        //price ma 30
        if (dataList[i + _day30 - 1].priceMA30 != 0) {
          break;
        } else {
          dataList[i + _day30 - 1].setPriceMA30(_getPriceMA(_cacheList.sublist(i, i + _day30)));
        }
      }
    }
  }



  static double _getPriceMA(List<ChartModel> dataList) {
    if (dataList == null || dataList.isEmpty) {
      return -1;
    }
    double total = 0;
    for (ChartModel data in dataList) {
      total += data.closePrice;
    }
    return total / dataList.length;
  }
  static double _getVolumeMA(List<ChartModel> dataList) {
    if (dataList == null || dataList.isEmpty) {
      return -1;
    }
    double total = 0;
    for (ChartModel data in dataList) {
      total += data.volume;
    }
    return total / dataList.length;
  }

  void calculateBoll() {}
  ///MACD
  ///
  void calculateMACD(List<ChartModel> dataList) {
    if (dataList == null || dataList.isEmpty) {
      return;
    }
  }















  void calculateRSI() {}
  void calculateKDJ() {}
}