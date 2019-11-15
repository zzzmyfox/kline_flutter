
import 'dart:math';

import 'package:flutter/material.dart';
import 'depth_model.dart';

class DepthPainter extends CustomPainter{

  DepthPainter({
    this.buyDataList,
    this.sellDataList,
  });
  final List<DepthModel> buyDataList;
  final List<DepthModel>  sellDataList;
  ///
  Path _path = Path();
  Paint _paint = Paint();
  double _maxVolume;
  /// colors
  Color _textColor = Colors.grey;
  Color _buyLineColor = Color(0xFF2BB8AB);
  Color _buyBackgroundColor = Color(0x662BB8AB);
  Color _sellLineColor = Color(0xFFFF5442);
  Color _sellBackgroundColor = Color(0x66FF5442);

  void _setLayout(Size size) {
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

    double perHeight = size.height / (_maxVolume - minVolume);
    double perWidth = size.width / (buyDataList.length + sellDataList.length);
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
    if (buyDataList.isNotEmpty) {
      _path.reset();
      for (int i = 0; i < buyDataList.length; i++) {
        if (i == 0) {
          _path.moveTo(buyDataList[i].x, buyDataList[i].y);
        } else {
          _path.lineTo(buyDataList[i].x, buyDataList[i].y);
        }
      }
      if (buyDataList.isNotEmpty && buyDataList[buyDataList.length - 1].y < size.height.toInt()) {
        _path.lineTo(buyDataList[buyDataList.length - 1].x, size.height);
      }
      _path.lineTo(0, size.height);
      _path.close();
      _restPainter(_buyBackgroundColor, 1, paintingStyle: PaintingStyle.fill);
      canvas.drawPath(_path, _paint);
      // buy line
      _path.reset();
      for (int i = 0; i < buyDataList.length - 1; i++) {
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
      if (sellDataList.isNotEmpty && sellDataList[0].y < size.height) {
        _path.lineTo(sellDataList[0].x, size.height);
      }
      _path.lineTo(size.width, size.height);
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