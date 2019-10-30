import 'package:flutter/material.dart';
import 'package:kchart/chart/chart_model.dart';
import 'package:kchart/chart/chart_painter.dart';

class ChartView extends StatefulWidget {

  ChartView({
    this.dataList,
  });

  final List<ChartModel> dataList;

  @override
  _ChartViewState createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {

  @override
  Widget build(BuildContext context) {
    CustomPaint klineView = CustomPaint(painter: ChartPainter(viewDataList: widget.dataList));
    debugPrint("${widget.dataList[0].closePrice}");
    return Container(
      margin: EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width,
      height: 400.0,
      child: klineView,
    );
  }
}
