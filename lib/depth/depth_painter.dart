import 'dart:math';

import 'package:flutter/material.dart';
import 'depth_model.dart';

class DepthPainter extends CustomPainter{

  DepthPainter({
    this.buyDataList,
    this.sellDataList,
    this.pricePrecision:4,
  });
  final List<DepthModel> buyDataList;
  final List<DepthModel>  sellDataList;
  final int pricePrecision;
  ///
  Path _path = Path();
  Paint _paint = Paint();
  /// colors
  Color _textColor = Colors.grey;
  Color _buyLineColor = Color(0xFF2BB8AB);
  Color _buyBackgroundColor = Color(0x662BB8AB);
  Color _sellLineColor = Color(0xFFFF5442);
  Color _sellBackgroundColor = Color(0x66FF5442);
  ///
  double _maxVolume;
  double _avgVolumeSpace;
  double _avgOrinateSpace;
  String _rightPriceText;
  String _leftPriceText;
  ///
  double _bottomEnd;

  void _setLayout(Size size) {

    _bottomEnd = size.height - 10;
    // buy
    double maxBuyVolume;
    double minBuyVolume;
    if (buyDataList.isNotEmpty) {
      maxBuyVolume = buyDataList[0].volume;
      minBuyVolume = buyDataList[buyDataList.length - 1].volume;
    } else {
      maxBuyVolume = minBuyVolume = 0;
    }
    // sell
    double maxSellVolume;
    double minSellVolume;
    if (sellDataList.isNotEmpty) {
      maxSellVolume = sellDataList[sellDataList.length - 1].volume;
      minSellVolume = sellDataList[0].volume;
    } else {
      maxSellVolume = minSellVolume = 0;
    }
    _maxVolume = max(maxBuyVolume, maxSellVolume);
    double minVolume = min(minBuyVolume, minSellVolume);


    if (buyDataList.isNotEmpty) {
      _leftPriceText = setPrecision(buyDataList[0].price, pricePrecision);
    } else if (sellDataList.isNotEmpty) {
      _leftPriceText = setPrecision(sellDataList[0].price, pricePrecision);
    } else {
      _leftPriceText = "0.0";
    }

    if (sellDataList.isNotEmpty) {
      _rightPriceText = setPrecision(sellDataList[sellDataList.length - 1].price, pricePrecision);
    } else if (buyDataList.isNotEmpty) {
      _rightPriceText = setPrecision(buyDataList[buyDataList.length - 1].price, pricePrecision);
    } else {
      _rightPriceText = "0.0";
    }


    double perHeight = _bottomEnd / (_maxVolume - minVolume);
    double perWidth = size.width / (buyDataList.length + sellDataList.length);
    _avgVolumeSpace = _maxVolume / 5;
    _avgOrinateSpace = _bottomEnd / 5;
    // buy
    for (int i = 0; i < buyDataList.length; i++) {
      buyDataList[i].setX(perWidth * i);
      buyDataList[i].setY((_maxVolume - buyDataList[i].volume) * perHeight);
    }
    // sell
    for (int i = sellDataList.length - 1; i >= 0; i--) {
      sellDataList[i].setX(size.width - perWidth * (sellDataList.length - 1 - i));
      sellDataList[i].setY((_maxVolume - sellDataList[i].volume) * perHeight);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if(buyDataList.isEmpty && sellDataList.isEmpty) {
      return;
    }
    _setLayout(size);
    _drawDepthTitle(canvas, size);
    _drawLineAndBackground(canvas, size);
    _drawCoordinateText(canvas, size);
  }
  void _drawDepthTitle(Canvas canvas, Size size) {
    // buy
    String buyText = "买盘";
    double textWidth = _getTextBounds(buyText).width;
    Rect buyRect = Rect.fromLTRB(size.width / 2 - textWidth, 12, size.width / 2 - textWidth - 10,  textWidth + 2);
    _restPainter(_buyLineColor, 1, paintingStyle: PaintingStyle.fill);
    canvas.drawRect(buyRect, _paint);
    _drawText(canvas, buyText, _textColor, Offset(
        size.width / 2 - textWidth,
        10
    ));
    // sell
    String sellText = "卖盘";
    Rect sellRect = Rect.fromLTRB(size.width / 2 + textWidth, 12, size.width / 2 + textWidth - 10,  textWidth + 2);
    _restPainter(_sellLineColor, 1, paintingStyle: PaintingStyle.fill);
    canvas.drawRect(sellRect, _paint);
    _drawText(canvas, sellText, _textColor, Offset(
        size.width / 2 + textWidth,
        10
    ));
  }

  void _drawLineAndBackground(Canvas canvas, Size size) {
    // buy background
    if (buyDataList.isNotEmpty) {
      _path.reset();
      for (int i = 0; i < buyDataList.length; i++) {
        if (i == 0) {
          _path.moveTo(buyDataList[i].x, buyDataList[i].y);
        } else {
          _path.lineTo(buyDataList[i].x, buyDataList[i].y);
        }
      }
      if (buyDataList.isNotEmpty && buyDataList[buyDataList.length - 1].y < _bottomEnd.toInt()) {
        _path.lineTo(buyDataList[buyDataList.length - 1].x, _bottomEnd);
      }
      _path.lineTo(0, _bottomEnd);
      _path.close();
      _restPainter(_buyBackgroundColor, 1, paintingStyle: PaintingStyle.fill);
      canvas.drawPath(_path, _paint);
      // buy line
      _path.reset();
      for (int i = 0; i < buyDataList.length; i++) {
        if (i == 0) {
          _path.moveTo(buyDataList[i].x, buyDataList[i].y);
        } else {
          _path.lineTo(buyDataList[i].x, buyDataList[i].y);
        }
      }
      _restPainter(_buyLineColor, 1);
      canvas.drawPath(_path, _paint);
    }
    // sell background
    if (sellDataList.isNotEmpty) {
      _path.reset();
      for (int i = sellDataList.length - 1; i >= 0; i--) {
        if (i == sellDataList.length - 1) {
          _path.moveTo(sellDataList[i].x, sellDataList[i].y);
        } else {
          _path.lineTo(sellDataList[i].x, sellDataList[i].y);
        }
      }
      if (sellDataList.isNotEmpty && sellDataList[0].y < _bottomEnd) {
        _path.lineTo(sellDataList[0].x, _bottomEnd);
      }
      _path.lineTo(size.width, _bottomEnd);
      _path.close();
      _restPainter(_sellBackgroundColor, 1, paintingStyle: PaintingStyle.fill);
      canvas.drawPath(_path, _paint);
      // sell line
      _path.reset();
      for (int i = 0; i < sellDataList.length; i++) {
        if (i == 0) {
          _path.moveTo(sellDataList[i].x, sellDataList[i].y);
        } else {
          _path.lineTo(sellDataList[i].x, sellDataList[i].y);
        }
      }
      _restPainter(_sellLineColor, 1);
      canvas.drawPath(_path, _paint);
    }
  }

  /// scale text
  void _drawCoordinateText(Canvas canvas, Size size) {
    _drawText(canvas, _leftPriceText, _textColor, Offset(
        0,
        size.height - _getTextBounds(_leftPriceText).height
    ));
    _drawText(canvas, _rightPriceText, _textColor, Offset(
        size.width - _getTextBounds(_rightPriceText).width,
        size.height - _getTextBounds(_rightPriceText).height
    ));
    _drawText(canvas, (_leftPriceText), _textColor, Offset(
        size.width / 2 - _getTextBounds("0").width,
        size.height - _getTextBounds("0").height
    ));

    for (int i = 0; i < 5; i ++) {
      String ordinateStr = formatDataNum(_maxVolume - i * _avgVolumeSpace);
      _drawText(canvas, ordinateStr, _textColor, Offset(
          size.width - _getTextBounds(ordinateStr).width,
          _getTextBounds(ordinateStr).height + i * _avgOrinateSpace
      ));
    }
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

  /// size of text
  Size _getTextBounds(String text, {double fontSize}) {
    TextPainter _textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize ?? 10.0,
          ),
        ),
        textDirection: TextDirection.ltr
    );
    _textPainter.layout();
    return Size(_textPainter.width, _textPainter.height);
  }

  /// precision
  String setPrecision(double num, int scale) {
    return num.toStringAsFixed(scale);
  }

  String formatDataNum(double num) {
    if (num < 1) {
      return setPrecision(num, 6);
    } else if (num < 10) {
      return setPrecision(num, 5);
    } else if (num < 100) {
      return setPrecision(num, 4);
    } else {
      return setPrecision(num, 2);
    }
  }

  void _restPainter(Color color, double strokeWidth, {PaintingStyle paintingStyle}) {
    _paint..color = color
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth
      ..style = paintingStyle??PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}