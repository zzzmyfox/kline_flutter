import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kchart/chart/chart_calculator.dart';
import 'package:kchart/chart/chart_model.dart';
import 'package:kchart/chart/chart_painter.dart';
import 'package:kchart/chart/chart_utils.dart';

class KlineView extends StatefulWidget {
  KlineView({
    this.dataList,
    this.currentDataType,
    this.isShowSubview:false,
    this.viewType:0,
    this.subviewType:0,
  });
  final List<ChartModel> dataList;
  final bool isShowSubview;
  final int viewType;
  final int subviewType;
  final String currentDataType;
  @override
  _KlineViewState createState() => _KlineViewState();
}

class _KlineViewState extends State<KlineView> {
  int _startDataNum = 0;
  int _maxViewDataNum = 50;
  int _viewDataMin = 10;
  int _viewDataMax = 100;
  double _velocityX;
  bool _isShowDetail = false;
  ChartModel _lastData;
  ChartCalculator _chartCalculator = ChartCalculator();
  ChartUtils _chartUtils = ChartUtils();
  List<ChartModel> _totalDataList = List();
  List<ChartModel> _endDataList = List();
  List<ChartModel> _viewDataList = List();
  List<String> _detailDataList = List();
  String _currentData;

  @override
  void didUpdateWidget(KlineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    init();
  }

  void init(){
    if (_startDataNum >= _totalDataList.length -_maxViewDataNum){
      initDataList();
      _currentData = widget.currentDataType;
    } else {
      if (_currentData != widget.currentDataType){
        initDataList();
      }
    }
  }

  /// init data list
  Future initDataList() async {
    _totalDataList.clear();
    _totalDataList.addAll(widget.dataList);
    _startDataNum = _totalDataList.length - _maxViewDataNum;
    _calculateIndex (_totalDataList, false);
    setState(() {
      _resetViewData();
    });
  }
  /// add one data
  Future addSingleData() async {
    _endDataList.clear();
    int startIndex;
    if (_totalDataList.length >= _maxViewDataNum) {
      startIndex = _totalDataList.length - _maxViewDataNum;
    } else {
      startIndex = 0;
    }
    _endDataList.addAll(_totalDataList.sublist(startIndex, _totalDataList.length));
    _endDataList.add(widget.dataList[widget.dataList.length - 1]);
    _calculateIndex (_endDataList, true);
    _totalDataList.add(_endDataList[_endDataList.length - 1]);
    if (_totalDataList.length >= _maxViewDataNum && _startDataNum == _totalDataList.length - _maxViewDataNum - 1) {
      setState(() {
        _startDataNum++;
        _resetViewData();
      });
    } else {
      setState(() {
        _resetViewData();
      });
    }
  }

  /// calculate index
  Future _calculateIndex (List<ChartModel> dataList, bool isEndData) async {
    _chartCalculator.calculateMa(dataList, isEndData);
    _chartCalculator.calculateBoll(dataList, 26, 2, isEndData);
    _chartCalculator.calculateMACD(dataList, 12, 26, 9, isEndData);
    _chartCalculator.calculateKDJ(dataList, 9, 3, 3, isEndData);
    _chartCalculator.calculateRSI(dataList, 6, 12, 24, isEndData);
  }

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
  /// get click data
  void _getClickData(double clickX) {
    if (_isShowDetail) {
      _detailDataList.clear();
      for (int i = 0; i < _viewDataList.length; i++) {
        if (_viewDataList[i].leftStartX <= clickX && _viewDataList[i].rightEndX >= clickX) {
          _lastData = _viewDataList[i];
          _detailDataList.add(_chartUtils.dateFormat(_lastData.timestamp, year: true));
          _detailDataList.add(_lastData.openPrice.toString());
          _detailDataList.add(_lastData.maxPrice.toString());
          _detailDataList.add(_lastData.minPrice.toString());
          _detailDataList.add(_lastData.closePrice.toString());
          double upDownAmount = _lastData.closePrice - _lastData.openPrice;
          String upDownRate = _chartUtils.setPrecision(upDownAmount / _lastData.openPrice * 100, 2);
          if (upDownAmount > 0) {
            _detailDataList.add("+" + _chartUtils.formatDataNum(upDownAmount));
            _detailDataList.add("+"+upDownRate+"%");
          } else {
            _detailDataList.add(_chartUtils.formatDataNum(upDownAmount));
            _detailDataList.add(upDownRate+"%");
          }
          _detailDataList.add(_chartUtils.formatDataNum(_lastData.volume));
          break;
        } else {
          _lastData = null;
        }
      }
    } else {
      _lastData = _viewDataList[_viewDataList.length - 1];
    }
  }
  /// tap down
  void _onTapDown (TapDownDetails details) {
    double moveX = details.globalPosition.dx;
    if (_viewDataList[0].leftStartX <= moveX && _viewDataList[_viewDataList.length - 1].rightEndX >= moveX) {
      setState(() {
        _isShowDetail = true;
        _getClickData(moveX);
      });
    }
  }
  /// long press move
  void _onLongPress(LongPressMoveUpdateDetails details) {
    double moveX = details.globalPosition.dx;
    if (_viewDataList[0].leftStartX <= moveX && _viewDataList[_viewDataList.length - 1].rightEndX >= moveX) {
      setState(() {
        _isShowDetail = true;
        _getClickData(moveX);
      });
    }
  }
  /// scale
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale > 1) {
      if (_maxViewDataNum <= _viewDataMin) {
        _maxViewDataNum = _viewDataMin;
      } else if(_viewDataList.length < _maxViewDataNum) {
        _maxViewDataNum -= 2;
        _startDataNum = _totalDataList.length - _maxViewDataNum;
      } else {
        _maxViewDataNum -= 2;
        _startDataNum += 1;
      }
    } else if (details.scale < 1){
      if (_maxViewDataNum >= _viewDataMax) {
        _maxViewDataNum = _viewDataMax;
      } else if (_startDataNum + _maxViewDataNum >= _totalDataList.length) {
        _maxViewDataNum += 2;
        _startDataNum = _totalDataList.length - _maxViewDataNum;
      } else if (_startDataNum <= 0) {
        _startDataNum = 0;
        _maxViewDataNum += 2;
      } else {
        _maxViewDataNum += 2;
        _startDataNum -= 1;
      }
    }
    setState(() {
      _isShowDetail = false;
      _resetViewData();
     });
  }
  /// horizontal gesture
  void _moveHorizontal(DragUpdateDetails details) {
    double _distanceX = details.delta.dx * -1;
    if ((_startDataNum == 0 && _distanceX < 0)
        || (_startDataNum == _totalDataList.length - _maxViewDataNum && _distanceX > 0)
        || _startDataNum < 0
        || _viewDataList.length < _maxViewDataNum) {
      if (_isShowDetail) {
        setState(() {
          _isShowDetail = false;
          if (_viewDataList.isNotEmpty) {
            _lastData = _viewDataList[_viewDataList.length - 1];
          }
        });
      }
    } else {
      setState(() {
        _isShowDetail = false;
        if (_distanceX.abs() > 1) {
          _moveData(_distanceX);
        }
      });
    }
  }
  /// move data
  void _moveData(double distanceX) {
    if (_maxViewDataNum < 50) {
      _setSpeed(distanceX, 10);
    } else {
      _setSpeed(distanceX, 3.5);
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
  void _setSpeed(double distanceX, double num) {
  //  print(distanceX);
    if (distanceX.abs() > 1 && distanceX.abs() < 2) {
      _startDataNum += (distanceX * 10 - (distanceX * 10 ~/ 2) * 2).round();
    } else if (distanceX.abs() < 10) {
    _startDataNum += (distanceX - (distanceX ~/ 2) * 2).toInt();
    } else {
      _startDataNum += distanceX ~/ num;
    }
  }
  /// move velocity
  void _moveVelocity(DragEndDetails details) {
    if (_startDataNum > 0 && _startDataNum < _totalDataList.length - _maxViewDataNum) {
      if (details.velocity.pixelsPerSecond.dx > 6000) {
        _velocityX = 8000;
      } else if (details.velocity.pixelsPerSecond.dx  < -6000) {
        _velocityX = -8000;
      } else {
        _velocityX = details.velocity.pixelsPerSecond.dx;
      }
      _moveAnimation();
    }
  }
  /// move animation
  void _moveAnimation() {
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
      if (_startDataNum > _totalDataList.length - _maxViewDataNum) {
        _startDataNum = _totalDataList.length - _maxViewDataNum;
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
      Future.delayed(Duration(milliseconds: 15), ()=> _moveAnimation());
    }
  }
  /// painter
  CustomPaint _klineView() {
    return CustomPaint(
        painter: ChartPainter(
          viewDataList: _viewDataList,
          maxViewDataNum: _maxViewDataNum,
          lastData: _lastData,
          detailDataList: _detailDataList,
          isShowDetails: _isShowDetail,
          isShowSubview: widget.isShowSubview,
          viewType: widget.viewType,
          subviewType: widget.subviewType,
        )
    );
  }
  /// build kline chart
  @override
  Widget build(BuildContext context) {
    /// gestures
    return GestureDetector(
      onTapDown: _onTapDown,
      onLongPressMoveUpdate: _onLongPress,
      onHorizontalDragUpdate: _moveHorizontal,
      onHorizontalDragEnd: _moveVelocity,
      onScaleUpdate: _onScaleUpdate,
      child: Container(
        color: Color(0xFF101928),
        width: MediaQuery.of(context).size.width,
        height: 368.0,
        child: _klineView(),
      ),
    );
  }
}
