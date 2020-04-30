import 'dart:math';

import 'package:flutter/material.dart';

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
        dataList[i + _day5 - 1]
            .setPriceMA5(_getPriceMA(_cacheList.sublist(i, i + _day5)));
        //volume ma5
        dataList[i + _day5 - 1]
            .setVolumeMA5(_getVolumeMA(_cacheList.sublist(i, i + _day5)));
      }
      if (i + _day10 <= dataList.length) {
        //price ma10
        dataList[i + _day10 - 1]
            .setPriceMA10(_getPriceMA(_cacheList.sublist(i, i + _day10)));
        //volume ma10
        dataList[i + _day10 - 1]
            .setVolumeMA10(_getVolumeMA(_cacheList.sublist(i, i + _day10)));
      }
      if (i + _day30 <= dataList.length) {
        //price ma 30
        if (dataList[i + _day30 - 1].priceMA30 != 0 && isEndData) {
          break;
        } else {
          dataList[i + _day30 - 1]
              .setPriceMA30(_getPriceMA(_cacheList.sublist(i, i + _day30)));
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
  void calculateBoll(
      List<ChartModel> dataList, int period, int k, bool isEndData) {
    if (dataList == null ||
        dataList.isEmpty ||
        period < 0 ||
        period > dataList.length - 1) {
      return;
    }
    double mb;
    double up;
    double dn;

    double sum = 0;
    double sum2 = 0;
    double ma;
    double ma2;
    double md;

    for (int i = 0; i < dataList.length; i++) {
      if (dataList[i].bollMB != 0 && isEndData) {
        break;
      }
      ChartModel data = dataList[i];
      sum += data.closePrice;
      sum2 += data.closePrice;
      if (i > period - 1) {
        sum -= dataList[i - period].closePrice;
      }
      if (i > period - 2) {
        sum2 -= dataList[i - period + 1].closePrice;
      }

      if (i < period - 1) {
        continue;
      }

      ma = sum / period;
      ma2 = sum2 / (period - 1);
      md = 0;
      for (int j = i + 1 - period; j <= i; j++) {
        md += pow(dataList[j].closePrice - ma, 2);
      }
      md = sqrt(md / period);
      mb = ma2;
      up = mb + k * md;
      dn = mb - k * md;

      data.setBollMB(mb);
      data.setBollUP(up);
      data.setBollDN(dn);
    }
  }

  /// MACD
  void calculateMACD(List<ChartModel> dataList, int fastPeriod, int slowPeriod,
      int signalPeriod, bool isEndData) {
    if (dataList == null || dataList.isEmpty) {
      return;
    }
    double preEma_12 = 0;
    double preEma_26 = 0;
    double preDEA = 0;

    double ema_12 = 0;
    double ema_26 = 0;

    double dea = 0;
    double dif = 0;
    double macd = 0;

    for (int i = 0; i < dataList.length; i++) {
      if (dataList[i].macd != 0 && isEndData) {
        break;
      }

      ema_12 = preEma_12 * (fastPeriod - 1) / (fastPeriod + 1) +
          dataList[i].closePrice * 2 / (fastPeriod + 1);
      ema_26 = preEma_26 * (slowPeriod - 1) / (slowPeriod + 1) +
          dataList[i].closePrice * 2 / (slowPeriod + 1);

      dif = ema_12 - ema_26;
      dea = preDEA * (signalPeriod - 1) / (signalPeriod + 1) +
          dif * 2 / (signalPeriod + 1);
      macd = 2 * (dif - dea);

      preEma_12 = ema_12;
      preEma_26 = ema_26;
      preDEA = dea;

      dataList[i].setMACD(macd);
      dataList[i].setDEA(dea);
      dataList[i].setDIF(dif);
    }
  }

  /// KDJ
  void calculateKDJ(
      List<ChartModel> dataList, int n1, int n2, int n3, bool isEndData) {
    if (dataList == null || dataList.isEmpty) {
      return;
    }
    List<double> mK = List();
    List<double> mD = List();
    double jValue;
    double highValue = dataList[0].maxPrice;
    double lowValue = dataList[0].minPrice;
    int highPosition = 0;
    int lowPosition = 0;
    double rsv = 0.0;
    for (int i = 0; i < dataList.length; i++) {
      if (dataList[i].k != 0 && isEndData) {
        break;
      }
      if (i == 0) {
        mK.insert(0, 50);
        mD.insert(0, 50);
        jValue = 50;
      } else {
        if (highValue <= dataList[i].maxPrice) {
          highValue = dataList[i].maxPrice;
          highPosition = i;
        }
        if (lowValue >= dataList[i].minPrice) {
          lowValue = dataList[i].minPrice;
          lowPosition = i;
        }
        if (i > (n1 - 1)) {
          if (highValue > dataList[i].maxPrice) {
            if (highPosition < (i - (n1 - 1))) {
              highValue = dataList[i - (n1 - 1)].maxPrice;
              for (int j = (i - (n1 - 2)); j <= i; j++) {
                if (highValue <= dataList[j].maxPrice) {
                  highValue = dataList[j].maxPrice;
                  highPosition = j;
                }
              }
            }
          }
          if (lowValue < dataList[i].minPrice) {
            if (lowPosition < i - (n1 - 1)) {
              lowValue = dataList[i].minPrice;
              for (int k = (i - (n1 - 2)); k <= i; k++) {
                if (lowValue >= dataList[k].minPrice) {
                  lowValue = dataList[k].minPrice;
                  lowPosition = k;
                }
              }
            }
          }
        }
        if (highValue != lowValue) {
          rsv = (dataList[i].closePrice - lowValue) /
              (highValue - lowValue) *
              100;
        }
        mK.insert(i, (mK[i - 1] * (n2 - 1) + rsv) / n2);
        mD.insert(i, (mD[i - 1] * (n3 - 1) + mK[i]) / n3);
        jValue = 3 * mK[i] - 2 * mD[i];
      }

      dataList[i].setK(mK[i]);
      dataList[i].setD(mD[i]);
      dataList[i].setJ(jValue);
    }
  }

  /// RSI
  void calculateRSI(List<ChartModel> dataList, int period1, int period2,
      int period3, bool isEndData) {
    if (dataList == null || dataList.isEmpty) {
      return;
    }
    double upRateSum;
    double upRateCount;
    double dnRateSum;
    int dnRateCount;
    for (int i = 0; i < dataList.length; i++) {
      if (dataList[i].rs3 != 0 && isEndData) {
        break;
      }
      upRateSum = 0;
      upRateCount = 0;
      dnRateSum = 0;
      dnRateCount = 0;
      if (i >= period1 - 1) {
        for (int x = i; x >= i + 1 - period1; x--) {
          if (dataList[x].closePrice - dataList[x].openPrice >= 0) {
            upRateSum += (dataList[x].closePrice - dataList[x].openPrice) /
                dataList[x].openPrice;
            upRateCount++;
          } else {
            dnRateSum += (dataList[x].closePrice - dataList[x].openPrice) /
                dataList[x].openPrice;
            dnRateCount++;
          }
        }
        double avgUpRate = 0;
        double avgDnRate = 0;
        if (upRateSum > 0) {
          avgUpRate = upRateSum / upRateCount;
        }
        if (dnRateSum < 0) {
          avgDnRate = dnRateSum / dnRateCount;
        }
        dataList[i].setRS1(avgUpRate / (avgUpRate + avgDnRate.abs()) * 100);
      }
      upRateSum = 0;
      upRateCount = 0;
      dnRateSum = 0;
      dnRateCount = 0;
      if (i >= period2 - 1) {
        for (int x = i; x >= i + 1 - period2; x--) {
          if (dataList[x].closePrice - dataList[x].openPrice >= 0) {
            upRateSum += (dataList[x].closePrice - dataList[x].openPrice) /
                dataList[x].openPrice;
            upRateCount++;
          } else {
            dnRateSum += (dataList[x].closePrice - dataList[x].openPrice) /
                dataList[x].openPrice;
            dnRateCount++;
          }
        }
        double avgUpRate = 0;
        double avgDnRate = 0;
        if (upRateSum > 0) {
          avgUpRate = upRateSum / upRateCount;
        }
        if (dnRateSum < 0) {
          avgDnRate = dnRateSum / dnRateCount;
        }
        dataList[i].setRS2(avgUpRate / (avgUpRate + avgDnRate.abs()) * 100);
      }
      upRateSum = 0;
      upRateCount = 0;
      dnRateSum = 0;
      dnRateCount = 0;
      if (i >= period3 - 1) {
        for (int x = i; x >= i + 1 - period3; x--) {
          if (dataList[x].closePrice - dataList[x].openPrice >= 0) {
            upRateSum += (dataList[x].closePrice - dataList[x].openPrice) /
                dataList[x].openPrice;
            upRateCount++;
          } else {
            dnRateSum += (dataList[x].closePrice - dataList[x].openPrice) /
                dataList[x].openPrice;
            dnRateCount++;
          }
        }
        double avgUpRate = 0;
        double avgDnRate = 0;
        if (upRateSum > 0) {
          avgUpRate = upRateSum / upRateCount;
        }
        if (dnRateSum < 0) {
          avgDnRate = dnRateSum / dnRateCount;
        }
        dataList[i].setRS3(avgUpRate / (avgUpRate + avgDnRate.abs()) * 100);
      }
    }
  }

  /// third stage bezier path point
  void setBezierPath(List<Pointer> pointList, Path path) {
    path.reset();
    if (pointList == null || pointList.isEmpty) {
      return;
    }
    path.moveTo(pointList[0].x, pointList[0].y);
    Pointer _leftControlPointer = Pointer();
    Pointer _rightControlPointer = Pointer();

    for (int i = 0; i < pointList.length; i++) {
      if (i == 0 && pointList.length > 2) {
        _leftControlPointer.setX(pointList[i].x +
            bezierRatio * (pointList[i + 1].x - pointList[0].x));
        _leftControlPointer.setY(pointList[i].y +
            bezierRatio * (pointList[i + 1].y - pointList[0].y));
        _rightControlPointer.setX(pointList[i + 1].x -
            bezierRatio * (pointList[i + 2].x - pointList[i].x));
        _rightControlPointer.setY(pointList[i + 1].y -
            bezierRatio * (pointList[i + 2].y - pointList[i].y));
      } else if (i == pointList.length - 2 && i > 1) {
        _leftControlPointer.setX(pointList[i].x +
            bezierRatio * (pointList[i + 1].x - pointList[i - 1].x));
        _leftControlPointer.setY(pointList[i].y +
            bezierRatio * (pointList[i + 1].y - pointList[i - 1].y));
        _rightControlPointer.setX(pointList[i + 1].x -
            bezierRatio * (pointList[i + 1].x - pointList[i].x));
        _rightControlPointer.setY(pointList[i + 1].y -
            bezierRatio * (pointList[i + 1].y - pointList[i].y));
      } else if (i > 0 && i < pointList.length - 2) {
        _leftControlPointer.setX(pointList[i].x +
            bezierRatio * (pointList[i + 1].x - pointList[i - 1].x));
        _leftControlPointer.setY(pointList[i].y +
            bezierRatio * (pointList[i + 1].y - pointList[i - 1].y));
        _rightControlPointer.setX(pointList[i + 1].x -
            bezierRatio * (pointList[i + 2].x - pointList[i].x));
        _rightControlPointer.setY(pointList[i + 1].y -
            bezierRatio * (pointList[i + 2].y - pointList[i].y));
      }
      if (i < pointList.length - 1) {
        path.cubicTo(
            _leftControlPointer.x,
            _leftControlPointer.y,
            _rightControlPointer.x,
            _rightControlPointer.y,
            pointList[i + 1].x,
            pointList[i + 1].y);
      }
    }
  }

  void setLinePath(List<Pointer> pointerList, Path path) {
    path.reset();
    if (pointerList == null || pointerList.isEmpty) {
      return;
    }
    path.moveTo(pointerList[0].x, pointerList[0].y);
    for (int i = 1; i < pointerList.length; i++) {
      path.lineTo(pointerList[i].x, pointerList[i].y);
    }
  }
}
