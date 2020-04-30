# kchart Flutter

 纯Flutter开发的k线和深度图控件，实现了MA,BOLL, MACD, KDJ, RSI指标，欢迎issue

![示例图片](https://github.com/zzzmyfox/kline_flutter/blob/master/example.png)

## Getting Started

请求网路数据

```dart 
  // k线数据模型
  List<ChartModel> getKlineDataList(List data) {
    List<ChartModel> kDataList = List();
    for (int i = 0; i < data.length; i++) {
      int timestamp = data[i][0].toInt();
      //timestamp
      double openPrice = data[i][1].toDouble();
      // open
      double closePrice = data[i][4].toDouble();
      // close
      double maxPrice = data[i][2].toDouble();
      // max
      double minPrice = data[i][3].toDouble();
      // min
      double volume = data[i][5].toDouble();
      if (volume > 0) {
        kDataList.add(ChartModel(
            timestamp, openPrice, closePrice, maxPrice, minPrice, volume));
      }
    }
    return kDataList;
  }
```
