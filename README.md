# kchart Flutter

 纯Flutter开发的k线和深度图控件，实现了MA,BOLL, MACD, KDJ, RSI指标，欢迎issue

<img src="https://github.com/zzzmyfox/kline_flutter/blob/master/example.png" width="270" hegiht="400" align=center />

## k线

使用第三方库`dio`请求网路数据，使用下面函数对k线数据进行加工
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
拿到处理好对数据加入控件`KlineView()` 

```dart
  Container(
     child: KlineView(
       dataList: dataList,
       currentDataType: _currentDataType,
       isShowSubview: _isShowSubview,
       viewType: _viewTypeIndex,
       subviewType: _subviewTypeIndex,
  )),
```


## 深度图

深度图现在还是半成品，现在还没有展示详细数据功能，但是不影响使用

使用很简单，请求网路数据，然后使用下面函数对数据进行加工
```dart
  List<DepthModel> depthList(List dataList) {
    List<DepthModel> depthList = List();
    int length = 0;
    if (dataList.length > 12) {
      length = 12;
    } else {
      length = dataList.length;
    }
    for (int i = 0; i < length; i++) {
      double price = dataList[i][0].toDouble();
      double volume = dataList[i][1].toDouble();
      depthList.add(DepthModel(price, volume));
    }
    return depthList;
  }

```

拿到处理好对数据加入控件`DepthView()` 

```dart 
 DepthView(depthList(_bidsList), depthList(_asksList)),
```


###具体使用方法可以参考example.dart



