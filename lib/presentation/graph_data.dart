import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

class LineTitles {
  List data = [];

  static getTitleData() => FlTitlesData(
      show: true,
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, t) {
                switch (value.toInt()) {
                  case 1:
                    return const Text(
                      "1D",
                      style: TextStyle(
                          color: Color(0xff964F66),
                          fontWeight: FontWeight.w700),
                    );
                  case 3:
                    return const Text("1W",
                        style: TextStyle(
                            color: Color(0xff964F66),
                            fontWeight: FontWeight.w700));
                  case 6:
                    return const Text(
                      "1M",
                      style: TextStyle(
                          color: Color(0xff964F66),
                          fontWeight: FontWeight.w700),
                    );
                  case 9:
                    return const Text("3M",
                        style: TextStyle(
                            color: Color(0xff964F66),
                            fontWeight: FontWeight.w700));
                  case 12:
                    return const Text("1Y",
                        style: TextStyle(
                            color: Color(0xff964F66),
                            fontWeight: FontWeight.w700));
                }
                return const Text("");
              })));
}
