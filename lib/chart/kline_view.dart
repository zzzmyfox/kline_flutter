import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kchart/chart/chart_calculator.dart';
import 'package:kchart/chart/chart_model.dart';
import 'package:kchart/chart/chart_painter.dart';

class KlineView extends StatefulWidget {

  KlineView({
    this.dataList,
  });
  final List<ChartModel> dataList;

  @override
  _KlineViewState createState() => _KlineViewState();
}

class _KlineViewState extends State<KlineView> {

  List<ChartModel> _totalDataList = List();
  List<ChartModel> _viewDataList = List();
  int _maxViewDataNum = 30;
  int _startDataNum = 0;
  bool _isShowDetail = false;
  ChartModel _lastData;
  double _velocityX;
  ChartCalculator chartCalculator = ChartCalculator();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initDataList();
  }

  /// init data list
  void initDataList() {
    _totalDataList.clear();
    _totalDataList.addAll(widget.dataList);
    _startDataNum = _totalDataList.length - _maxViewDataNum;
    chartCalculator.calculateMa(_totalDataList, false);
    setState(() {
      _resetViewData();
    });
  }
  /// add single data
  void addSingleData() {}
  /// display data
  void _resetViewData() {
    _viewDataList.clear();
    int _currentViewDataNum = min(_maxViewDataNum, _totalDataList.length);
    if (_startDataNum >= 0) {
      for (int i = 0; i < _currentViewDataNum; i ++) {
        if (i + _startDataNum < _totalDataList.length) {
          _viewDataList.add(_totalDataList[i + _startDataNum]);
        }
      }
    } else {
      for (int i = 0; i < _currentViewDataNum; i++) {
        _viewDataList.add(_totalDataList[i]);
      }
    }
    if (_viewDataList.length > 0 && !_isShowDetail) {
      _lastData = _viewDataList[_viewDataList.length - 1];
    } else if (_viewDataList.isEmpty) {
      _lastData = null;
    }
  }
  /// gesture
  void moveGestureDetector(DragUpdateDetails details) {
    double _distanceX = details.delta.dx * -1;
    if ((_startDataNum == 0 && _distanceX < 0)
        || (_startDataNum == _totalDataList.length - 1 - _maxViewDataNum && _distanceX > 0)
        || _startDataNum < 0
        || _viewDataList.length < _maxViewDataNum) {
      if (_isShowDetail) {
        _isShowDetail = false;
        if (_viewDataList.isNotEmpty) {
          setState(() {
            _lastData = _viewDataList[_viewDataList.length - 1];
          });
        }
      }
    } else {
      _isShowDetail = false;
      if (_distanceX.abs() > 1) {
        setState(() {
          moveData(_distanceX);
        });
      }
    }
  }
  /// move data
  void moveData(double distanceX) {
    if (_maxViewDataNum < 60) {
      setSpeed(distanceX, 10);
    } else {
      setSpeed(distanceX, 3.5);
    }
    if (_startDataNum < 0) {
      _startDataNum = 0;
    }
    if (_startDataNum > _totalDataList.length - _maxViewDataNum) {
      _startDataNum = _totalDataList.length - _maxViewDataNum;
    }
    _resetViewData();
  }
  /// move speed
  void setSpeed(double distanceX, double num) {
    if (distanceX.abs() > 1 && distanceX.abs() < 2) {
      _startDataNum += ((distanceX * 20) % 2).round();
      print("aaaaaaa${((distanceX * 10) % 2)}");
    } else if (distanceX.abs() < 10) {
      _startDataNum += (distanceX * 20 % 2).round();
      print("bbbbbbb${(distanceX % 2).round()}");
    } else {
      _startDataNum += distanceX ~/ num;
      print("ccccccc${(distanceX / num).round()}");
    }
  }
  /// move velocity
  void moveVelocity(DragEndDetails details) {
    if (_startDataNum > 0 && _startDataNum < _totalDataList.length - 1 - _maxViewDataNum) {
      if (details.velocity.pixelsPerSecond.dx > 6000) {
        _velocityX = 8000;
      } else if (details.velocity.pixelsPerSecond.dx  < -6000) {
        _velocityX = -8000;
      } else {
        _velocityX = details.velocity.pixelsPerSecond.dx;
      }
      moveAnimation();
    }
  }
  /// move animation
  void moveAnimation() {
    if (_velocityX < -200) {
      if (_velocityX < -6000) {
        _startDataNum += 6;
      } else if (_velocityX < -4000) {
        _startDataNum += 5;
      } else if (_velocityX < -2500) {
        _startDataNum += 4;
      } else if (_velocityX < -1000) {
        _startDataNum += 3;
      } else {
        _startDataNum++;
      }
      _velocityX += 200;
      if (_startDataNum > _totalDataList.length - _maxViewDataNum - 1) {
        _startDataNum = _totalDataList.length - _maxViewDataNum - 1;
      }
    } else if (_velocityX > 200) {
      if (_velocityX > 6000) {
        _startDataNum -= 6;
      } else if (_velocityX > 4000) {
        _startDataNum -= 5;
      } else if (_velocityX > 2500) {
        _startDataNum -= 4;
      } else if (_velocityX > 1000) {
        _startDataNum -= 3;
      } else {
        _startDataNum--;
      }
      _velocityX -= 200;
      if (_startDataNum < 0) {
        _startDataNum = 0;
      }
    }
    // reset view data
    setState(() {
      _resetViewData();
    });
    // stop when velocity less than 200
    if (_velocityX.abs() > 200) {
      // recursion and delayed 15 milliseconds
      Future.delayed(Duration(milliseconds: 20), ()=> moveAnimation());
    }
  }
  ///
  @override
  Widget build(BuildContext context) {
    ///
    CustomPaint klineView = CustomPaint(painter: ChartPainter(
        viewDataList: _viewDataList,
        maxViewDataNum: _maxViewDataNum,
        lastData: _lastData
    ));
    ///
    return GestureDetector(
      onHorizontalDragUpdate: moveGestureDetector,
      onHorizontalDragEnd: moveVelocity,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 368.0,
        child: klineView,
      ),
    );
  }
}
