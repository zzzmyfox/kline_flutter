
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kchart/depth/depth_model.dart';

class DepthPainter extends CustomPainter{
  DepthPainter(
      this.dataListBuy,
      this.dataListSell
      );
  final List<DepthModel> dataListBuy;
  final List<DepthModel> dataListSell;

  List<DepthModel> _buyDataList = List();
  List<DepthModel>  _sellDataList = List();
  Path _path = Path();
  Paint _paint = Paint();

  double _maxVolume;
  /// colors
  Color _textColor = Colors.grey;
  Color _buyLineColor = Color(0xFF2BB8AB);
  Color _buyBackgroundColor = Color(0x662BB8AB);
  Color _sellLineColor = Color(0xFFFF5442);
  Color _sellBackgroundColor = Color(0x66FF5442);


  void setBuyDataList(List<DepthModel> bidsList) {
    _buyDataList.clear();
    _buyDataList.addAll(bidsList);
    _buyDataList.sort();
    for (int i = _buyDataList.length - 1; i >= 0; i--) {
      if (i < _buyDataList.length - 1) {
        _buyDataList[i].setVolume(_buyDataList[i].volume + _buyDataList[i + 1].volume);
      }
    }
  }
  void setSellDataList(List<DepthModel> asksList) {
    _sellDataList.clear();
    _sellDataList.addAll(asksList);
    _sellDataList.sort();
    for (int i = 0; i < _sellDataList.length; i++) {
      if (i > 0) {
        _sellDataList[i].setVolume(_sellDataList[i].volume + _sellDataList[i - 1].volume);
      }
    }
  }

  void setLayout(Size size) {
    // buy
    double maxBuyVolume;
    double minBuyVolume;
    if (_buyDataList.isNotEmpty) {
      maxBuyVolume = _buyDataList[0].volume;
      minBuyVolume = _buyDataList[_buyDataList.length - 1].volume;
    } else {
      maxBuyVolume = minBuyVolume = 0;
    }
    // sell
    double maxSellVolume;
    double minSellVolume;
    if (_sellDataList.isNotEmpty) {
      maxSellVolume = _sellDataList[_sellDataList.length - 1].volume;
      minSellVolume = _sellDataList[0].volume;
    } else {
      maxSellVolume = minSellVolume = 0;
    }
    _maxVolume = max(maxBuyVolume, maxSellVolume);
    double minVolume = min(minBuyVolume, minSellVolume);
    double perHeight = size.height / (_maxVolume - minVolume);
    double perWidth = size.width / (_buyDataList.length + _sellDataList.length);
    // buy
    for (int i = 0; i < _buyDataList.length; i++) {
      _buyDataList[i].setX(perWidth * i);
      _buyDataList[i].setY((_maxVolume - _buyDataList[i].volume) * perHeight);
    }
    // sell
    for (int i = _sellDataList.length - 1; i >= 0; i--) {
      _sellDataList[i].setX(size.width - perWidth * (_sellDataList.length - 1 - i));
      _sellDataList[i].setY((_maxVolume - _sellDataList[i].volume) * perHeight);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    setBuyDataList(dataListBuy);
    setSellDataList(dataListSell);
    setLayout(size);
    _drawDepthTitle(canvas, size);
    _drawLineAndBackground(canvas, size);
  }
  void _drawDepthTitle(Canvas canvas, Size size) {
    // buy
    String buyText = "买盘";
    double textWidth = _getTextBounds(buyText).width;
    Rect buyRect = Rect.fromLTRB(size.width / 2 - textWidth, 10, size.width / 2 - textWidth - 10,  textWidth);
    _restPainter(_buyLineColor, 1, paintingStyle: PaintingStyle.fill);
    canvas.drawRect(buyRect, _paint);
    _drawText(canvas, buyText, _textColor, Offset(
      size.width / 2 - textWidth,
      10
    ));
    // sell
    String sellText = "卖盘";
    Rect sellRect = Rect.fromLTRB(size.width / 2 + textWidth, 10, size.width / 2 + textWidth - 10,  textWidth);
    _restPainter(_sellLineColor, 1, paintingStyle: PaintingStyle.fill);
    canvas.drawRect(sellRect, _paint);
    _drawText(canvas, sellText, _textColor, Offset(
      size.width / 2 + textWidth,
      10
    ));
  }

  void _drawLineAndBackground(Canvas canvas, Size size) {
    // buy background
    if (_buyDataList.isNotEmpty) {
      _path.reset();
      for (int i = 0; i < _buyDataList.length; i++) {
        if (i == 0) {
          _path.moveTo(_buyDataList[i].x, _buyDataList[i].y);
          print(_buyDataList[i].y);
        } else {
          _path.lineTo(_buyDataList[i].x, _buyDataList[i].y);
        }
      }
      if (_buyDataList.isNotEmpty && _buyDataList[_buyDataList.length - 1].y < size.height) {
        _path.lineTo(_buyDataList[_buyDataList.length - 1].x, size.height);
      }
      _path.lineTo(0, size.height);
      _path.close();
      _restPainter(_buyBackgroundColor, 1, paintingStyle: PaintingStyle.fill);
      canvas.drawPath(_path, _paint);
      // buy line
      _path.reset();
      for (int i = 0; i < _buyDataList.length - 1; i++) {
        if (i == 0) {
          _path.moveTo(_buyDataList[i].x, _buyDataList[i].y);
        } else {
          _path.lineTo(_buyDataList[i].x, _buyDataList[i].y);
        }
      }
      _restPainter(_buyLineColor, 1);
      canvas.drawPath(_path, _paint);
    }
    // sell background
    if (_sellDataList.isNotEmpty) {
      _path.reset();
      for (int i = _sellDataList.length - 1; i >= 0; i--) {
        if (i == _sellDataList.length - 1) {
          _path.moveTo(_sellDataList[i].x, _sellDataList[i].y);
        } else {
          _path.lineTo(_sellDataList[i].x, _sellDataList[i].y);
        }
      }
      if (_sellDataList.isNotEmpty && _sellDataList[0].y < size.height) {
        _path.lineTo(_sellDataList[0].x, size.height);
      }
      _path.lineTo(size.width, size.height);
      _path.close();
      _restPainter(_sellBackgroundColor, 1, paintingStyle: PaintingStyle.fill);
      canvas.drawPath(_path, _paint);
      // sell line
      _path.reset();
      for (int i = 0; i < _sellDataList.length; i++) {
        if (i == 0) {
          _path.moveTo(_sellDataList[i].x, _sellDataList[i].y);
        } else {
          _path.lineTo(_sellDataList[i].x, _sellDataList[i].y);
        }
      }
      _restPainter(_sellLineColor, 1);
      canvas.drawPath(_path, _paint);
    }
  }

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


  void _restPainter(Color color, double strokeWidth, {PaintingStyle paintingStyle}) {
    _paint..color = color
          ..isAntiAlias = true
          ..strokeWidth = strokeWidth
          ..style = paintingStyle??PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}