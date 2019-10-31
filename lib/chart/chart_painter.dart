import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kchart/chart/chart_model.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.viewDataList,
  });
  ///data list
  final List<ChartModel> viewDataList;
  /// painter
  Paint _paint = Paint();
  ///show subview
  bool isShowSubView = true;
  ///xy value list from scale lines
  List<double> _verticalXList = List();
  List<double> _horizontalYList = List();
  double maxViewDataNum = 50;
  ///line start point
  double _leftStart;
  double _bottomEnd;
  ///colors
  Color riseColor = Color(0xFF03c086);
  Color fallColor = Color(0xFFff524a);
  Color ma5Color = Color(0xFFF6DC93);
  Color ma10Color = Color(0xFF61D1C0);
  Color ma30Color = Color(0xFFCB92FE);
  Color scaleTextColor = Colors.grey;
  Color scaleLineColor = Colors.black;
  ///
  /// main view variable
  ///
  ///
  double _maxPrice;
  double _minPrice;
  double _maxVolume;
  double _maxPriceX, _maxPriceY, _minPriceX, _minPriceY;
  ///candlestick
  double _perPriceRectWidth, _perPriceRectHeight ,_perVolumeRectHeight;
  double _subViewTopY;
  double _priceChartBottom, _volumeChartBottom;
  /// draw
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    if (viewDataList.isEmpty) return;
    _leftStart = 5.0;
    _bottomEnd = size.height - 20.0;
    _drawScaleLine(canvas, size);
    _drawMainChartView(canvas);
  }
  ///draw lines for the background which uses to measures the spaces
  /// width is size of device's width and height is so on
  void _drawScaleLine(Canvas canvas, Size size) {
    resetPaintStyle(color: scaleLineColor, strokeWidth: 0.2);
    //vertical scale line
    _verticalXList.clear();
    double _horizontalSpace = size.width / 5;
    for (int i = 0; i < 5; i++) {
      double dx = _horizontalSpace * i + _leftStart;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), _paint);
      _verticalXList.add(dx);
    }
    //horizontal scale line
    _horizontalYList.clear();
    double _verticalSpace = size.height / 5;
    double _horizontalRightEnd;
    for (int i = 0; i < 6; i++) {
      if (i == 0 || i == 5 || i == 4 || (isShowSubView && i == 3)) {
        _horizontalRightEnd = size.width;
      } else {
        _horizontalRightEnd = _verticalXList[_verticalXList.length - 1];
      }
      double dy = _verticalSpace * i;
      canvas.drawLine(Offset(_leftStart, dy), Offset(_horizontalRightEnd, dy), _paint);
      _horizontalYList.add(dy);
    }
    //subview's top line
    _subViewTopY = _horizontalYList[4];
    double dx = _verticalXList[_verticalXList.length - 1];
    double dy = _subViewTopY + _verticalSpace / 2;
    canvas.drawLine(Offset(_leftStart, dy), Offset(dx, dy), _paint);
    //value's middle scale line
    if (isShowSubView) {
      double dx = _verticalXList[_verticalXList.length - 1];
      double dy = _horizontalYList[3] + _verticalSpace / 2;
      canvas.drawLine(Offset(_leftStart, dy), Offset(dx, dy), _paint);
    }
  }
  /// main view
  void _drawMainChartView(Canvas canvas) {
    //perWidth =（leftStart - rightEnd） / maxViewData
     _perPriceRectWidth = (_verticalXList[_verticalXList.length - 1] - _verticalXList[0]) / maxViewDataNum;
    //max and min price
     _maxPrice = viewDataList[0].maxPrice;
     _minPrice = viewDataList[0].minPrice;
     _maxVolume = viewDataList[0].volume;
    for (int i = 0; i < viewDataList.length; i++) {
      viewDataList[i].setLeftStartX(_verticalXList[_verticalXList.length - 1] - (viewDataList.length - i) * _perPriceRectWidth);
      viewDataList[i].setRightEndX(_verticalXList[_verticalXList.length - 1] - (viewDataList.length - i - 1) * _perPriceRectWidth);
      // max price
      if (viewDataList[i].maxPrice >= _maxPrice) {
        _maxPrice = viewDataList[i].maxPrice;
        _maxPriceX = viewDataList[i].leftStartX + _perPriceRectWidth / 2;
      }
      // min price
      if(viewDataList[i].minPrice <= _minPrice) {
        _minPrice = viewDataList[i].minPrice;
        _minPriceX = viewDataList[i].leftStartX + _perPriceRectWidth / 2;
      }
      // max volume
      if (viewDataList[i].volume >= _maxVolume) {
        _maxVolume = viewDataList[i].volume;
      }
    }
     double _topPrice = _maxPrice + (_maxPrice - _minPrice) * 0.1;
     double _botPrice = _minPrice - (_maxPrice - _minPrice) * 0.1;
     //show the subview
     if (!isShowSubView) {
       _priceChartBottom = _horizontalYList[4];
       _volumeChartBottom = _horizontalYList[5];
     } else {
       _priceChartBottom = _horizontalYList[3];
       _volumeChartBottom = _horizontalYList[4];
     }
     //price data
     _perPriceRectHeight =  (_priceChartBottom - _horizontalYList[0]) / (_topPrice - _botPrice);
     _maxPriceY = (_horizontalYList[0] + (_topPrice - _maxPrice) * _perPriceRectHeight);
     _minPriceY = (_horizontalYList[0] + (_topPrice - _minPrice) * _perPriceRectHeight);
    //volume data
    _perVolumeRectHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / _maxVolume;
    for (int i = 0; i < viewDataList.length; i++) {
      double _openPrice = viewDataList[i].openPrice;
      double _closePrice = viewDataList[i].closePrice;
      double _higherPrice;
      double _lowerPrice;
      if (_openPrice >= _closePrice) {
        _higherPrice = _openPrice;
        _lowerPrice = _closePrice;
        resetPaintStyle(color: fallColor, paintingStyle: PaintingStyle.fill);
      } else {
        _higherPrice = _closePrice;
        _lowerPrice = _openPrice;
        resetPaintStyle(color: riseColor, paintingStyle: PaintingStyle.fill);
      }
      // price rect
      Rect priceRect = Rect.fromLTRB(
          viewDataList[i].leftStartX + dp2px(0.5),
          _maxPriceY + (_maxPrice - _higherPrice) * _perPriceRectHeight,
          viewDataList[i].rightEndX - dp2px(0.5),
          _maxPriceY + (_maxPrice - _lowerPrice) * _perPriceRectHeight
      );
      canvas.drawRect(priceRect, _paint);
      // price line
      canvas.drawLine(
          Offset(viewDataList[i].leftStartX + _perPriceRectWidth / 2, _maxPriceY + (_maxPrice - viewDataList[i].maxPrice) * _perPriceRectHeight),
          Offset(viewDataList[i].leftStartX + _perPriceRectWidth / 2, _maxPriceY + (_maxPrice - viewDataList[i].minPrice) * _perPriceRectHeight),
          _paint
      );
      // volume rect
      Rect volumeRect = Rect.fromLTRB(
          viewDataList[i].leftStartX + dp2px(0.5),
          _volumeChartBottom - viewDataList[i].volume * _perVolumeRectHeight,
          viewDataList[i].rightEndX - dp2px(0.5),
          _volumeChartBottom
      );
      canvas.drawRect(volumeRect, _paint);
    }
  }
  /// draw cross line


  ///draw style
  void resetPaintStyle({@required Color color, double strokeWidth, PaintingStyle paintingStyle}) {
    _paint..color = color
          ..strokeWidth = strokeWidth ?? 1.0
          ..isAntiAlias = true
          ..style = paintingStyle ?? PaintingStyle.stroke;
  }
  /// dp to px
  double dp2px(double dp){
    double scale = window.devicePixelRatio;
    return dp * scale;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}