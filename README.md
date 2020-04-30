# kchart Flutter

 纯Flutter开发的k线和深度图控件，实现了MA,BOLL, MACD, KDJ, RSI指标，欢迎issue

<img src="https://github.com/zzzmyfox/kline_flutter/blob/master/example.png" width="270" hegiht="400" align=center />

## k线

使用第三方库`dio`求网路数据，使用下面函数对k线数据进行加工
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


## 深度图

深度图现在还是半成品，现在还没有展示详细数据功能，但是不影响使用

使用很简单，直接把网络数据转成list，放到 `DepthView()`里即可

```dart 
DepthView(bidsList, asksList);
```






