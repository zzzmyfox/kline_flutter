import 'package:flutter/cupertino.dart';

import 'Pointer.dart';
import 'chart_model.dart';

class ChartCalculator {

  static int _day5 = 5;
  static int _day10 = 10;
  static int _day30 = 30;
  double bezierRatio = 0.16;
  static List<ChartModel> _cacheList = List();
  /// MA
  void calculateMa(List<ChartModel> dataList, bool isEndData) {
    if (dataList == null || dataList.isEmpty) {
      return;
    }
    _cacheList.clear();
    _cacheList.addAll(dataList);
    for (int i = 0; i < dataList.length; i++) {
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
        if (dataList[i + _day30 - 1].priceMA30 != 0 && isEndData) {
          break;
        } else {
          dataList[i + _day30 - 1].setPriceMA30(_getPriceMA(_cacheList.sublist(i, i + _day30)));
        }
      }
    }
  }
  //
  double _getPriceMA(List<ChartModel> dataList) {
    if (dataList == null || dataList.isEmpty) {
      return -1;
    }
    double total = 0;
    for (ChartModel data in dataList) {
      total += data.closePrice;
    }
    return total / dataList.length;
  }
  //
  double _getVolumeMA(List<ChartModel> dataList) {
    if (dataList == null || dataList.isEmpty) {
      return -1;
    }
    double total = 0;
    for (ChartModel data in dataList) {
      total += data.volume;
    }
    return total / dataList.length;
  }
  /// BOLL
  void calculateBoll() {}
  /// MACD
  void calculateMACD(List<ChartModel> dataList) {
    if (dataList == null || dataList.isEmpty) {
      return;
    }
  }
  void calculateKDJ() {}
  void calculateRSI() {}
  /// third stage bezier path point
  void setBezierPath(List<Pointer> pointList, Path path) {
    path.reset();
    if (pointList == null || pointList.isEmpty) {
      return;
    }
    path.moveTo(pointList[0].x, pointList[0].y);
    Pointer leftControlPointer = Pointer();
    Pointer rightControlPointer = Pointer();

    for (int i = 0; i < pointList.length; i++) {
      if (i == 0 && pointList.length > 2) {
        leftControlPointer.setX(pointList[i].x + bezierRatio * (pointList[i + 1].x - pointList[0].x));
        leftControlPointer.setY(pointList[i].y + bezierRatio * (pointList[i + 1].y - pointList[0].y));
        rightControlPointer.setX(pointList[i + 1].x - bezierRatio * (pointList[i + 2].x - pointList[i].x));
        rightControlPointer.setY(pointList[i + 1].y - bezierRatio * (pointList[i + 2].y - pointList[i].y));

      } else if (i == pointList.length - 2 && i > 1) {
        leftControlPointer.setX(pointList[i].x + bezierRatio * (pointList[i + 1].x - pointList[i - 1].x));
        leftControlPointer.setY(pointList[i].y + bezierRatio * (pointList[i + 1].y - pointList[i - 1].y));
        rightControlPointer.setX(pointList[i + 1].x - bezierRatio * (pointList[i + 1].x - pointList[i].x));
        rightControlPointer.setY(pointList[i + 1].y - bezierRatio * (pointList[i + 1].y - pointList[i].y));

      } else if (i > 0 && i < pointList.length - 2){
        leftControlPointer.setX(pointList[i].x + bezierRatio * (pointList[i + 1].x - pointList[i - 1].x));
        leftControlPointer.setY(pointList[i].y + bezierRatio * (pointList[i + 1].y - pointList[i - 1].y));
        rightControlPointer.setX(pointList[i + 1].x - bezierRatio * (pointList[i + 2].x - pointList[i].x));
        rightControlPointer.setY(pointList[i + 1].y - bezierRatio * (pointList[i + 2].y - pointList[i].y));

      }
      if (i < pointList.length - 1) {
        path.cubicTo(
            leftControlPointer.x, leftControlPointer.y,
            rightControlPointer.x, rightControlPointer.y,
            pointList[i + 1].x, pointList[i + 1].y
        );
      }
    }
  }
}