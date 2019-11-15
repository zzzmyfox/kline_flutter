import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kchart/dio_util.dart';

class DashboardWidget extends StatefulWidget {
  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  double _close = 0;
  double _open = 0;
  double _high = 0;
  double _low = 0;
  double _volume = 0;
  double _upDownRate = 0;
  int _pricePrecision = 0;
  int _volumePrecision = 0;
  Timer _timer;
  Color _riseColor = Color(0xFF03ad8f);
  Color _downColor = Color(0xFFff524a);
  Color text = Color(0xFF6d88a5);
  Color value = Color(0xFFd4d7eb);
  @override
  void initState() {
    super.initState();
    _startTimer();
  }
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _getTickerData();
    });
  }
  Future _getTickerData() async {
    Map data = await DioUtil.get("");
    setState(() {
      _close = data["close"].toDouble();
      _open = data["open"].toDouble();
      _high = data["high"].toDouble();
      _low = data["low"].toDouble();
      _volume = data["volume"].toDouble();
      _pricePrecision = data["pricePrecision"];
      _volumePrecision = data["volumePrecision"];
      _upDownRate = (_close - _open) / _open * 100;
    });
  }
  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
  String setPrecision(double num, int scale) {
    return num.toStringAsFixed(scale);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 125.0,
      color: Color(0xFF131e30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 28.0),
                  child:
                  _upDownRate > 0
                      ?Text(setPrecision(_close, _pricePrecision), style: TextStyle(color: _riseColor, fontSize: 30.0, fontWeight: FontWeight.bold))
                      :Text(setPrecision(_close, _pricePrecision), style: TextStyle(color: _downColor, fontSize: 30.0, fontWeight: FontWeight.bold))
                ),
                Container(
                  margin: EdgeInsets.only(top: 11.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Text("≈${_close * 1} CNY", style: TextStyle(color: text, fontSize: 12),),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 11.0),
                        child:
                        _upDownRate > 0
                            ?Text("+${setPrecision(_upDownRate, 2)}%", style:TextStyle(color: _riseColor, fontSize: 12))
                            :Text("${setPrecision(_upDownRate, 2)}%", style: TextStyle(color: _downColor, fontSize: 12))
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 28.0, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(child: Text("高",style: textStyle(fontSize: 12),)),
                    Container(margin: EdgeInsets.only(top: 15), child: Text("收", style: textStyle(fontSize: 12),)),
                    Container(margin: EdgeInsets.only(top: 15), child: Text("24H",style: textStyle(fontSize: 12),)),
                  ],
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(child: Text("${ setPrecision(_high, _pricePrecision)}", style: textStyle(color: value,fontSize: 12))),
                    Container(margin: EdgeInsets.only(top: 18), child: Text("${ setPrecision(_low, _pricePrecision)}", style: textStyle(color: value, fontSize: 12))),
                    Container(margin: EdgeInsets.only(top: 18), child: Text("${ setPrecision(_volume, _volumePrecision)}", style: textStyle(color: value, fontSize: 12))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 TextStyle textStyle({Color color, double fontSize, FontWeight fontWeight}) {
  return TextStyle(
    color: color ?? Color(0xFF6d88a5),
    fontSize: fontSize ?? 12.0,
    fontWeight: fontWeight ?? FontWeight.normal
  );
}

