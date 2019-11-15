import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kchart/chart/chart_model.dart';
import 'package:kchart/chart/kline_view.dart';
import 'package:kchart/dashboard_widget.dart';
import 'package:kchart/depth/depth_view.dart';
import 'package:kchart/dio_util.dart';

import 'depth/depth_model.dart';

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> with TickerProviderStateMixin{

  String _dspName = "ethzc";
  List<String> _timeIndex = ["1min","5min","15min","30min","60min","1day","1week","1mon"];
  List<ChartModel> dataList = List();
  List lines = List();
  Dio dio = Dio();
  Color text = Color(0xFF6d88a5);
  TabController _tabController;
  bool _isShowMenu = false;
  bool _isShowView = false;
  bool _isShowSubview = false;
  int _viewTypeIndex = 0;
  int _subviewTypeIndex = 0;
  List _bidsList = List();
  List _asksList = List();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    getKDataList(3);
    getDepthList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
  }

  Future getKDataList(int index) async{
    Response response = await dio.get("");
    setState(() {
      lines.clear();
      Map data = response.data;
      lines.addAll(data["data"]["lines"].reversed);
      getKlineDataList(lines);
      print(data["data"]["lines"].length);
    });
  }
  // lines data model
  List<ChartModel> getKlineDataList(List data) {
    dataList.clear();
    for (int i = 0; i < data.length; i++) {
      int timestamp = data[i][0].toInt();  ///timestamp
      double openPrice = data[i][1].toDouble(); /// open
      double closePrice = data[i][4].toDouble(); /// close
      double maxPrice = data[i][2].toDouble(); /// max
      double minPrice = data[i][3].toDouble(); /// min
      double volume =  data[i][5].toDouble(); /// volume
      ///
      if(volume > 0) {
        dataList.add(ChartModel(timestamp, openPrice, closePrice, maxPrice, minPrice, volume));
      }
    }
    return dataList;
  }
  // depth
  Future getDepthList() async {
    Map data = await DioUtil.get("");
    setState(() {
      _bidsList = data["bids"];
      _asksList = data["asks"];
    });
  }
  List<DepthModel> depthList(List dataList) {
    List<DepthModel> depthList = List();
    for (int i = 0; i < dataList.length; i++) {
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
        title: Text("ETH/ZC"),
      ),
      body: SingleChildScrollView(
        child:  Column(
          children: <Widget>[
            DashboardWidget(),
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
                  child:  FlatButton(
                    onPressed: () {
                      setState(() {
                        if (_isShowMenu) {
                          _isShowMenu = false;
                        } else {
                          _isShowMenu = true;
                        }
                      });
                    },
                    child: Icon(Icons.menu, color: text,),
                  ),
                )
              ],
            ),
            _isShowMenu ? Container(
              height: 100,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text("主图", style: TextStyle(color: text),),
                      SizedBox(width: 20,),
                      Text("|", style: TextStyle(color: Colors.white)),
                      SizedBox(width: 20,),
                      InkWell(child: Text("MA", style: TextStyle(color: text),), onTap: () {
                        setState(() {
                          _isShowView = true;
                          viewType(0);
                        });
                      },),
                      SizedBox(width: 20,),
                      InkWell(child: Text("BOLL", style: TextStyle(color: text),), onTap: () {
                        setState(() {
                          _isShowView = true;
                          viewType(1);
                        });
                      },),
                      IconButton(
                        iconSize: 16,
                        icon: _isShowView
                            ? Icon(Icons.visibility, color: Colors.grey)
                            : Icon(Icons.visibility_off, color: Colors.grey),
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
                      Text("副图", style: TextStyle(color:text),),
                      SizedBox(width: 20,),
                      Text("|", style: TextStyle(color: Colors.white)),
                      SizedBox(width: 20,),
                      InkWell(child: Text("MACD", style: TextStyle(color: text),),
                        onTap: () {
                          setState(() {
                            setState(() {
                              _isShowSubview = true;
                              subviewType(0);
                            });
                          });
                        },
                      ),
                      SizedBox(width: 20,),
                      InkWell(child: Text("KDJ", style: TextStyle(color: text),),
                        onTap: () {
                          setState(() {
                            _isShowSubview = true;
                            subviewType(1);
                          });
                        },
                      ),
                      SizedBox(width: 20,),
                      InkWell(child: Text("RSI", style: TextStyle(color: text),),
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
                            : Icon(Icons.visibility_off, color: Colors.grey),
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
            ) : Container(),
            Container(
                child: KlineView(dataList: dataList, isShowSubview: _isShowSubview, viewType: _viewTypeIndex, subviewType: _subviewTypeIndex,)
            ),
            DepthView(depthList(_bidsList), depthList(_asksList)),
          ],
        ),
      )
    );
  }
}

