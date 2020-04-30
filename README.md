# kchart Flutter

Flutter 版本的 k线 和 深度图控件， 实现了 指标ma10 , ma15, m30


## Getting Started

请求后台数据然后处理
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

