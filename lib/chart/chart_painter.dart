import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kchart/chart/chart_calculator.dart';
import 'package:kchart/chart/chart_model.dart';
import 'package:kchart/main.dart';

import 'Pointer.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.viewDataList,
    this.maxViewDataNum,
    this.lastData,
  });
  ///data list
  final List<ChartModel> viewDataList;
  final int maxViewDataNum;
  final ChartModel lastData;
  /// painter
  Paint _paint = Paint();
  ///show subview
  bool isShowSubView = false;
  ///xy value list from scale lines
  List<double> _verticalXList = List();
  List<double> _horizontalYList = List();
  ///line start point
  double _leftStart;
  double _rightEnd;
  double _bottomEnd;
  double _topStart;
  ///colors
  Color scaleTextColor = Colors.grey;
  Color scaleLineColor = Colors.grey;
  Color riseColor = Color(0xFF03c086);
  Color fallColor = Color(0xFFff524a);
  Color ma5Color = Color(0xFFF6DC93);
  Color ma10Color = Color(0xFF61D1C0);
  Color ma30Color = Color(0xFFCB92FE);
  ///detail text
  /// cn
  List detailTitleCN = ["时间", "开", "高", "收", "低", "涨跌额", "涨跌幅", "成交量"];
  /// en
  List detailTitleEN = ["time", "open", "hign", "close", "low", "up or down amount", "up or down rate", "volume"];
  /// main view variable
  double _maxPrice;
  double _minPrice;
  double _maxVolume;
  double _maxPriceX, _maxPriceY, _minPriceX, _minPriceY;
  double _verticalSpace;
  ///candlestick
  double _perPriceRectWidth, _perPriceRectHeight ,_perVolumeRectHeight;
  double _subViewTopY;
  double _priceChartBottom, _volumeChartBottom;
  double _topPrice;
  double _botPrice;
  /// draw
  @override
  void paint(Canvas canvas, Size size) {
    if (viewDataList.isEmpty) return;
    _leftStart = 5.0;
    _topStart = 20.0;
    _rightEnd = size.width;
    _bottomEnd = size.height;
    ///view
    _drawScaleLine(canvas);
    _drawMainChartView(canvas);
    ///curve
    _drawBezierCurve(canvas);

    ///text
    _drawMaxAndMinPriceText(canvas);
    _drawAbscissaText(canvas);
    _drawOrdinateText(canvas);
    _drawTopText(canvas);
    _drawVolumeText(canvas);
  }
  ///draw lines for the background which uses to measures the spaces
  /// width is size of device's width and height is so on
  void _drawScaleLine(Canvas canvas) {
    resetPaintStyle(color: scaleLineColor, strokeWidth: 0.2, paintingStyle: PaintingStyle.fill);
    //vertical scale line
    _verticalXList.clear();
    double _horizontalSpace = (_rightEnd - _leftStart - dp2px(28.0)) / 4;
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
          Offset(
              _leftStart + _horizontalSpace * i,
              _topStart
          ),
          Offset(
              _leftStart + _horizontalSpace * i,
              _bottomEnd - dp2px(10.0)
          ),
          _paint
      );
      _verticalXList.add(_leftStart + _horizontalSpace * i);
    }
    //horizontal scale line
    _horizontalYList.clear();
    _verticalSpace = (_bottomEnd - _topStart - dp2px(10.0)) / 5;
    double _horizontalRightEnd;
    for (int i = 0; i < 6; i++) {
      if (i == 0 || i == 5 || i == 4 || (isShowSubView && i == 3)) {
        _horizontalRightEnd = _rightEnd;
      } else {
        _horizontalRightEnd = _verticalXList[_verticalXList.length - 1];
      }
      canvas.drawLine(
          Offset(
              _leftStart,
              _topStart + _verticalSpace * i
          ),
          Offset(
              _horizontalRightEnd,
              _topStart+ _verticalSpace * i
          ),
          _paint
      );
      _horizontalYList.add(_topStart+ _verticalSpace * i);
    }
    //subview's top line
    _subViewTopY = _horizontalYList[4] + dp2px(12.0);
    double dx = _verticalXList[_verticalXList.length - 1];
    double dy =  _horizontalYList[4] + _verticalSpace / 2;
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
    _topPrice = _maxPrice + (_maxPrice - _minPrice) * 0.1;
    _botPrice = _minPrice - (_maxPrice - _minPrice) * 0.1;
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
     _maxPriceY = _horizontalYList[0] + (_topPrice - _maxPrice) * _perPriceRectHeight;
     _minPriceY = _horizontalYList[0] + (_topPrice - _minPrice) * _perPriceRectHeight;
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
          Offset(
              viewDataList[i].leftStartX + _perPriceRectWidth / 2,
              _maxPriceY + (_maxPrice - viewDataList[i].maxPrice) * _perPriceRectHeight
          ),
          Offset(
              viewDataList[i].leftStartX + _perPriceRectWidth / 2,
              _maxPriceY + (_maxPrice - viewDataList[i].minPrice) * _perPriceRectHeight
          ),
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

   ChartCalculator chartCalculator = ChartCalculator();
   List<Pointer> mainMa5PointList = List();
  List<Pointer> mainMa10PointList = List();
  List<Pointer> mainMa30PointList = List();
   Path path = Path();

  /// draw bezier line
  void _drawBezierCurve(Canvas canvas) {
    mainMa5PointList.clear();
    for (int i = 0; i < viewDataList.length; i++) {
      Pointer priceMa5Pointer = Pointer();
      print(viewDataList[i].priceMA5);
      if (viewDataList[i].priceMA5 != null) {
        priceMa5Pointer.setX(viewDataList[i].leftStartX + _perPriceRectWidth / 2);
        priceMa5Pointer.setY(_maxPriceY + (_maxPrice - viewDataList[i].priceMA5) * _perPriceRectHeight);
        mainMa5PointList.add(priceMa5Pointer);
      }

      Pointer priceMa10Pointer = Pointer();
      if (viewDataList[i].priceMA10 != null) {
        priceMa10Pointer.setX(viewDataList[i].leftStartX + _perPriceRectWidth / 2);
        priceMa10Pointer.setY(_maxPriceY + (_maxPrice - viewDataList[i].priceMA10) * _perPriceRectHeight);
        mainMa10PointList.add(priceMa10Pointer);
      }

      Pointer priceMa30Pointer = Pointer();
      if (viewDataList[i].priceMA30 != null) {
        priceMa30Pointer.setX(viewDataList[i].leftStartX + _perPriceRectWidth / 2);
        priceMa30Pointer.setY(_maxPriceY + (_maxPrice - viewDataList[i].priceMA30) * _perPriceRectHeight);
        mainMa30PointList.add(priceMa30Pointer);
      }
    }
    _drawMainBezierCurve(canvas);
  }
  void _drawMainBezierCurve(Canvas canvas) {
    ///ma5
    chartCalculator.setBezierPath(mainMa5PointList, path);
    resetPaintStyle(color: ma5Color, strokeWidth: 1);
    canvas.drawPath(path, _paint);
    ///ma10
    chartCalculator.setBezierPath(mainMa10PointList, path);
    resetPaintStyle(color: ma10Color, strokeWidth: 1);
    canvas.drawPath(path, _paint);
    ///ma30
    chartCalculator.setBezierPath(mainMa30PointList, path);
    resetPaintStyle(color: ma30Color, strokeWidth: 1);
    canvas.drawPath(path, _paint);
  }

  /// draw max and min price text
  void _drawMaxAndMinPriceText(Canvas canvas) {
    resetPaintStyle(color: Colors.white);
    // max price text
    String _maxPriceText = setPrecision(_maxPrice, 2);
    double _maxPriceTextX;
    if (_maxPriceX + _getTextBounds(_maxPriceText).width + dp2px(5.0) < _verticalXList[_verticalXList.length - 1]) {
      _maxPriceTextX = _maxPriceX + dp2px(5.0);
      canvas.drawLine(Offset(_maxPriceX, _maxPriceY), Offset(_maxPriceTextX, _maxPriceY), _paint);
    } else {
      _maxPriceTextX = _maxPriceX - _getTextBounds(_maxPriceText).width - dp2px(5);
      canvas.drawLine(Offset(_maxPriceX - dp2px(5.0), _maxPriceY), Offset(_maxPriceX, _maxPriceY), _paint);
    }
    // max text
    _drawText(canvas, _maxPriceText, Colors.white, Offset(
      _maxPriceTextX,
      _maxPriceY - _getTextBounds(_maxPriceText).height / 2
    ));
    // min price text
    String _minPriceText = setPrecision(_minPrice, 2);
    double _minPriceTextX;
    if (_minPriceX + _getTextBounds(_minPriceText).width + dp2px(5.0) < _verticalXList[_verticalXList.length - 1]) {
      _minPriceTextX = _minPriceX + dp2px(5.0);
      canvas.drawLine(Offset(_minPriceTextX - dp2px(5.0) , _minPriceY), Offset(_minPriceTextX, _minPriceY), _paint);
    } else {
      _minPriceTextX = _minPriceX - _getTextBounds(_minPriceText).width - dp2px(5.0);
      canvas.drawLine(Offset(_minPriceX - dp2px(5.0), _minPriceY), Offset(_minPriceX, _minPriceY), _paint);
    }
    // min text
    _drawText(canvas, _minPriceText, Colors.white, Offset(
        _minPriceTextX,
        _minPriceY - _getTextBounds(_minPriceText).height / 2
    ));
  }
  /// draw abscissa scale text
  void _drawAbscissaText(Canvas canvas) {
    for (int i = 0; i < _verticalXList.length; i++) {
      if (i == 0 && viewDataList[0].leftStartX <= _verticalXList[0] + _perPriceRectWidth / 2 && viewDataList[0].rightEndX > _verticalXList[0]) {
        String timestamp = dateFormat(viewDataList[0].timestamp);
        _drawText(canvas, timestamp, scaleTextColor, Offset(
          _leftStart,
          _horizontalYList[_horizontalYList.length - 1]
        ));
      } else if (i == _verticalXList.length - 1){
        String dateTime = dateFormat(viewDataList[viewDataList.length - 1].timestamp);
        _drawText(canvas, dateTime, scaleTextColor, Offset(
          _verticalXList[_verticalXList.length - 1],
         _horizontalYList[_horizontalYList.length - 1]
        ));
      } else {
        for (ChartModel data in viewDataList) {
          if (data.leftStartX <= _verticalXList[i] && data.rightEndX >= _verticalXList[i]) {
            String dateTime = dateFormat(data.timestamp);
            _drawText(canvas, dateTime, scaleTextColor, Offset(
                _verticalXList[i],
                _horizontalYList[_horizontalYList.length - 1]
            ));
            break;
          }
        }
      }
    }
  }
  /// draw ordinate scale text
  void _drawOrdinateText(Canvas canvas) {
    // text start x point
    double _rightX = _verticalXList[_verticalXList.length - 1] + dp2px(1.0);
    /// price scale text
    // max price
    String _maxPriceText = setPrecision(_topPrice, 2);
    _drawText(canvas, _maxPriceText, scaleTextColor, Offset(
      _rightX,
      _horizontalYList[0]
    ));
    // min price
    String _minPriceText = setPrecision(_botPrice, 2);
    _drawText(canvas, _minPriceText, scaleTextColor, Offset(
      _rightX,
      _priceChartBottom - _getTextBounds(_minPriceText).height
    ));
    // average price
    if (!isShowSubView) {
      double avgPrice = (_topPrice - _botPrice) / 4;
      for (int i = 0; i  < 3; i++) {
        String price = setPrecision(_topPrice - avgPrice * (i + 1), 2);
        _drawText(canvas, price, scaleTextColor, Offset(
          _rightX,
          _horizontalYList[i + 1] - _getTextBounds(price).height / 2
        ));
      }
    } else {
      double avgPrice = (_topPrice - _botPrice) / 3;
      for (int i = 0; i  < 2; i++) {
        String price = setPrecision(_topPrice - avgPrice * (i + 1), 2);
        _drawText(canvas, price, scaleTextColor, Offset(
          _rightX,
          _horizontalYList[i + 1] - _getTextBounds(price).height / 2
        ));
      }
    }
    /// volume scale text
    // max volume
    String _maxVolumeText = setPrecision(_maxVolume, 2);
    _drawText(canvas, _maxVolumeText, scaleTextColor, Offset(
      _rightX,
      _priceChartBottom,
    ));
    // middle volume
    String _middleVolume = setPrecision(_maxVolume / 2, 2);
    _drawText(canvas, _middleVolume, scaleTextColor, Offset(
      _rightX,
      _volumeChartBottom - _verticalSpace / 2 - _getTextBounds(_middleVolume).height / 2
    ));
    // bottom volume
    String _bottomVolume = "0.00";
    _drawText(canvas, _bottomVolume, scaleTextColor, Offset(
      _rightX,
      _volumeChartBottom - _getTextBounds(_bottomVolume).height
    ));
  }
  /// draw top text
  void _drawTopText(Canvas canvas) {
    String _indexTopTextOne = "MA5:${lastData.priceMA5}";
    _drawText(canvas, _indexTopTextOne, ma5Color, Offset(
      _leftStart,
      _topStart - _getTextBounds(_indexTopTextOne).height - 1
    ));
    String _indexTopTextTwo = "MA10:${lastData.priceMA10}";
    _drawText(canvas, _indexTopTextTwo, ma10Color, Offset(
      _leftStart + _getTextBounds(_indexTopTextOne).width + dp2px(5.0),
      _topStart - _getTextBounds(_indexTopTextOne).height - 1
    ));
    String _indexTopTextThree = "MA30:${lastData.priceMA30}";
    _drawText(canvas, _indexTopTextThree, ma30Color, Offset(
      _leftStart + _getTextBounds(_indexTopTextOne).width + _getTextBounds(_indexTopTextTwo).width + dp2px(10.0),
      _topStart - _getTextBounds(_indexTopTextOne).height - 1
    ));
  }
  /// draw volume text
  void _drawVolumeText(Canvas canvas) {
    String _volumeText = "VOL:${lastData.volume}";
    _drawText(canvas, _volumeText, ma30Color, Offset(
      _verticalXList[0],
      _priceChartBottom
    ));
    String _volumeMA5 = "MA5:${lastData.volumeMA5}";
    _drawText(canvas, _volumeMA5, ma5Color, Offset(
      _verticalXList[0] + _getTextBounds(_volumeText).width + dp2px(5.0),
      _priceChartBottom
    ));
    String _volumeMA10 = "MA10:${lastData.volumeMA10}";
    _drawText(canvas, _volumeMA10, ma10Color, Offset(
      _verticalXList[0] + _getTextBounds(_volumeText).width + _getTextBounds(_volumeMA5).width + dp2px(10.0),
      _priceChartBottom
    ));
  }
  /// draw text
  void _drawText(Canvas canvas, String text, Color textColor, Offset offset) {
    TextPainter _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 10.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();
    _textPainter.paint(canvas, offset);
  }
  ///draw style
  void resetPaintStyle({@required Color color, double strokeWidth, PaintingStyle paintingStyle}) {
    _paint..color = color
          ..strokeWidth = strokeWidth ?? 1.0
          ..isAntiAlias = true
          ..style = paintingStyle ?? PaintingStyle.stroke;
  }
  /// precision
  String setPrecision(double num, int scale) {
    return num.toStringAsFixed(scale);
  }
  /// date format
  String dateFormat(int timestamp) {
    List<String> dateList = DateTime.fromMillisecondsSinceEpoch(timestamp).toString().split(" ");
    List<String> date = dateList[0].toString().split("-");
    List<String> time = dateList[1].toString().split(":");
    String format = "${date[1]}-${date[2]} ${time[0]}:${time[1]}";
    return format;
  }
  /// size of text
  Size _getTextBounds(String text) {
    TextPainter _textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 10.0,
          ),
        ),
        textDirection: TextDirection.ltr
    );
    _textPainter.layout();
    return Size(_textPainter.width, _textPainter.height);
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