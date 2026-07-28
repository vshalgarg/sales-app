import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants/graph_color_spotsNotation.dart';
import '../model_classes/monitoring_charts.dart';

class AmountChartData extends StatelessWidget {
  final String title;
  final ChartData chartData;

  const AmountChartData({
    super.key,
    required this.title,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final billData = chartData.datasets[0].data;
    final creditData = chartData.datasets[1].data;
    return Container(color:Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                LegendItem(
                  color: Colors.blue,
                  text: 'Bill Amount',
                ),
                SizedBox(width: 24),
                LegendItem(
                  color: Colors.orange,
                  text: 'Credit Amount',
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 350,
              child:BarChart(
                BarChartData(
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(
                        color: Colors.black54,
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: Colors.black54,
                        width: 1,
                      ),
                      top: BorderSide.none,
                      right: BorderSide.none,
                    ),
                  ),
                  gridData: const FlGridData(
                    drawVerticalLine: false,
                    show: true,
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 90,
                        getTitlesWidget: (value, meta) {

                          int index = value.toInt();

                          if (index >= chartData.labels.length) {
                            return const SizedBox();
                          }

                          return SideTitleWidget(
                            space: 20,
                            meta: meta,
                            child: Transform.rotate(
                              angle: -0.8,
                              child: SizedBox(
                                width: 80,
                                child: Text(
                                  chartData.labels[index],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  barGroups: List.generate(
                    billData.length,
                        (index) {
                      return BarChartGroupData(
                        x: index,
                        barsSpace: 4,
                        barRods: [

                          BarChartRodData(
                            toY: billData[index],
                            width: 8,
                            color: Colors.blue,
                            borderRadius: BorderRadius.zero,
                          ),

                          BarChartRodData(
                            toY: creditData[index],
                            width: 8,
                            color: Colors.orange,
                            borderRadius: BorderRadius.zero,
                          ),

                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}