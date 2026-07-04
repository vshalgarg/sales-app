import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../model_classes/staff_analytics_model.dart';

class StaffDonutChart extends StatefulWidget {
  final String title;
  final ChartData chartData;

  const StaffDonutChart({
    super.key,
    required this.title,
    required this.chartData,
  });

  @override
  State<StaffDonutChart> createState() => _StaffDonutChartState();
}

class _StaffDonutChartState extends State<StaffDonutChart> {
  @override
  Widget build(BuildContext context) {
    final values = widget.chartData.datasets.first.data;

    final total = values.fold<int>(0, (sum, item) => sum + item);

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.cyan,
      Colors.pink,
      Colors.amber,
    ];

    return Card(color: Colors.white,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.grey),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                      PieChartData(
                        centerSpaceRadius: 60,
                        sectionsSpace: 2,

                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {},
                        ),

                        sections: List.generate(
                          values.length,
                              (index) => PieChartSectionData(
                            value: values[index].toDouble(),
                            color: colors[index % colors.length],
                            radius: 50,

                            title: values[index].toString(),

                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                  ),Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        total.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: List.generate(
                widget.chartData.labels.length,
                    (index) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.chartData.labels[index],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
