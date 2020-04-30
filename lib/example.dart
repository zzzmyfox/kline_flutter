import 'package:flutter/material.dart';
import 'package:kchart/chart/chart_model.dart';
import 'package:kchart/chart/kline_view.dart';
import 'package:kchart/depth/depth_view.dart';
import 'package:kchart/kline_datas.dart';

import 'depth/depth_model.dart';
import 'dio_util.dart';
import 'dio_util.dart';

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> with TickerProviderStateMixin {
  List<String> _timeIndex = [
    "1min",
    "5min",
    "15min",
    "30min",
    "60min",
    "1day",
    "1week",
    "1mon"
  ];
  List<ChartModel> dataList = List();
  Color text = Color(0xFF6d88a5);
  TabController _tabController;
  bool _isShowMenu = false;
  bool _isShowView = false;
  bool _isShowSubview = false;
  int _viewTypeIndex = 0;
  int _subviewTypeIndex = 0;

  ///  k线实时请求，防止刷新之后返回到最右边
  String _currentDataType;

  /// 深度图
  List _bidsList = List();
  List _asksList = List();

  ///
  List lines = List();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this, initialIndex: 0);
    getKDataList(0);
    getDepthList();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  /// 最后一条数据需要实时展示的话
  /// 时间不相同就更新
//  int oldTime = 0;
//  List lastKlineData = List();
//  Future updateLastData() async {
//    Map parsedData = await DioUtil.get("https://-----------------------");
//    lastKlineData.add(parsedData);
//    int currentTime = parsedData["timestamp"];
//    if (currentTime != oldTime) {
//      oldTime = parsedData["timestamp"];
//      getKDataList(0);
//    } else {
//      if (dataList.isNotEmpty && lastKlineData.isNotEmpty) {
//        dataList.last.openPrice = getKlineDataList(lastKlineData)[0].openPrice;
//        dataList.last.closePrice =
//            getKlineDataList(lastKlineData)[0].closePrice;
//        dataList.last.maxPrice = getKlineDataList(lastKlineData)[0].maxPrice;
//        dataList.last.minPrice = getKlineDataList(lastKlineData)[0].minPrice;
//        dataList.last.volume = getKlineDataList(lastKlineData)[0].volume;
//      }
//    }
//  }

  /// kline request  请求网路数据
  Future getKDataList(int index) async {
    // 网路数据
    Map data = await DioUtil.get("/m/kline/btcusdt/${_timeIndex[index]}/1000");
    lines.addAll(data["data"]["lines"].reversed);
    dataList = getKlineDataList(lines);
    _currentDataType = _timeIndex[index] + "btcusdt";
    setState(() {});
  }

  // k线返回数据模型
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

  ///depth request
  Future getDepthList() async {
    Map data = await DioUtil.get("/m/depth/btcusdt");

    setState(() {
      _bidsList = data["bids"];
      _asksList = data["asks"];
    });
  }

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

  void viewType(int type) {
    switch (type) {
      case 0:
        _viewTypeIndex = 0;
        break;
      case 1:
        _viewTypeIndex = 1;
        break;
      case 2:
        _viewTypeIndex = 2;
        break;
    }
  }

  void subviewType(int type) {
    switch (type) {
      case 0:
        _subviewTypeIndex = 0;
        break;
      case 1:
        _subviewTypeIndex = 1;
        break;
      case 2:
        _subviewTypeIndex = 2;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF131e30),
        appBar: AppBar(
          title: Text("BTC/USDT"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width - 100,
                    child: TabBar(
                      isScrollable: true,
                      controller: _tabController,
                      labelStyle: TextStyle(fontSize: 10),
                      tabs: <Widget>[
                        Tab(text: "1分"),
                        Tab(text: "5分"),
                        Tab(text: "15分"),
                        Tab(text: "30分"),
                        Tab(text: "1小时"),
                        Tab(text: "1日"),
                        Tab(text: "1周"),
                        Tab(text: "1月"),
                      ],
                      onTap: (index) {
                        setState(() {
                          getKDataList(index);
                        });
                      },
                    ),
                  ),
                  Container(
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          if (_isShowMenu) {
                            _isShowMenu = false;
                          } else {
                            _isShowMenu = true;
                          }
                        });
                      },
                      child: Icon(
                        Icons.menu,
                        color: text,
                      ),
                    ),
                  )
                ],
              ),
              _isShowMenu
                  ? Container(
                      height: 100,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                "主图",
                                style: TextStyle(color: text),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text("|", style: TextStyle(color: Colors.white)),
                              SizedBox(
                                width: 20,
                              ),
                              InkWell(
                                child: Text(
                                  "MA",
                                  style: TextStyle(color: text),
                                ),
                                onTap: () {
                                  setState(() {
                                    _isShowView = true;
                                    viewType(0);
                                  });
                                },
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              InkWell(
                                child: Text(
                                  "BOLL",
                                  style: TextStyle(color: text),
                                ),
                                onTap: () {
                                  setState(() {
                                    _isShowView = true;
                                    viewType(1);
                                  });
                                },
                              ),
                              IconButton(
                                iconSize: 16,
                                icon: _isShowView
                                    ? Icon(Icons.visibility, color: Colors.grey)
                                    : Icon(Icons.visibility_off,
                                        color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    viewType(2);
                                    if (_isShowView) {
                                      _isShowView = false;
                                    }
                                  });
                                },
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "副图",
                                style: TextStyle(color: text),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text("|", style: TextStyle(color: Colors.white)),
                              SizedBox(
                                width: 20,
                              ),
                              InkWell(
                                child: Text(
                                  "MACD",
                                  style: TextStyle(color: text),
                                ),
                                onTap: () {
                                  setState(() {
                                    setState(() {
                                      _isShowSubview = true;
                                      subviewType(0);
                                    });
                                  });
                                },
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              InkWell(
                                child: Text(
                                  "KDJ",
                                  style: TextStyle(color: text),
                                ),
                                onTap: () {
                                  setState(() {
                                    _isShowSubview = true;
                                    subviewType(1);
                                  });
                                },
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              InkWell(
                                child: Text(
                                  "RSI",
                                  style: TextStyle(color: text),
                                ),
                                onTap: () {
                                  setState(() {
                                    _isShowSubview = true;
                                    subviewType(2);
                                  });
                                },
                              ),
                              IconButton(
                                iconSize: 16,
                                icon: _isShowSubview
                                    ? Icon(Icons.visibility, color: Colors.grey)
                                    : Icon(Icons.visibility_off,
                                        color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    if (_isShowSubview) {
                                      _isShowSubview = false;
                                    }
                                  });
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container(),
              Container(
                  child: KlineView(
                dataList: dataList,
                currentDataType: _currentDataType,
                isShowSubview: _isShowSubview,
                viewType: _viewTypeIndex,
                subviewType: _subviewTypeIndex,
              )),
              DepthView(depthList(_bidsList), depthList(_asksList)),
            ],
          ),
        ));
  }
}
