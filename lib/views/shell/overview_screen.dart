import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:promosells_flutter/controllers/overview_controller.dart';
import 'package:promosells_flutter/models/admin_dashboard.dart';
import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

const _pieColors = [Color(0xFFFF6384), Color(0xFF36A2EB), Color(0xFFFFCE56), Color(0xFF4BC0C0), Color(0xFF9966FF), Color(0xFFFF9F40)];
const _barColor = Color(0xFF36A2EB);

/// Port of Overview.jsx — admin dashboard cards, charts, and tables fed by
/// the 8 AdminDashboard endpoints.
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OverviewController>()) {
      Get.put(OverviewController());
    }
    final controller = Get.find<OverviewController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.error.value != null) {
        return Center(child: MyText.bodyMedium(controller.error.value!, color: Theme.of(context).colorScheme.error));
      }
      final data = controller.data.value;
      if (data == null) return const SizedBox.shrink();

      return SingleChildScrollView(
        padding: MySpacing.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final cards = [
                _StockCard(card: data.stockCard),
                _CustomerCard(card: data.customerCard),
                _SalesCard(card: data.salesCard),
              ];
              return isWide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: cards.map((c) => Expanded(child: c)).toList())
                  : Column(children: cards);
            }),
            MySpacing.height(16),
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final charts = [
                _ChartCard(
                  title: 'Top 5 Customers with Samples',
                  icon: Icons.bar_chart,
                  child: data.topCustomers.isEmpty ? _noData() : _TopCustomersBarChart(items: data.topCustomers),
                ),
                _ChartCard(
                  title: 'Samples Pie Chart',
                  icon: Icons.pie_chart,
                  child: data.samplesPieChart.isEmpty ? _noData() : _SamplesPieChart(items: data.samplesPieChart),
                ),
                _ChartCard(
                  title: 'Top 5 Years with Sales',
                  icon: Icons.calendar_month,
                  child: data.top5YearsWithSales.isEmpty ? _noData() : _YearsBarChart(items: data.top5YearsWithSales),
                ),
              ];
              return isWide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: charts.map((c) => Expanded(child: c)).toList())
                  : Column(children: charts);
            }),
            MySpacing.height(16),
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final tables = [
                _SamplesPickupTable(items: data.samplesPickup),
                _UpcomingRecoTable(items: data.upcomingSaleReturnReco),
              ];
              return isWide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: tables.map((t) => Expanded(child: t)).toList())
                  : Column(children: tables);
            }),
          ],
        ),
      );
    });
  }

  Widget _noData() => Padding(padding: MySpacing.all(16), child: MyText.bodySmall('No data available', muted: true));
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.card});
  final AdminStockCard card;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MySpacing.all(4),
      child: MyCard(
        paddingAll: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.inventory_2, size: 18), MySpacing.width(8), MyText.titleSmall('Stock Card')]),
            MySpacing.height(8),
            MyText.bodySmall('Total Stock Categories: ${card.totalStockCategories}'),
            MyText.bodySmall('Total Stock Items: ${card.totalStockItems}'),
            MyText.bodySmall('Total Stock Quantity: ${card.totalStockQuantity}'),
            MyText.bodySmall('Total Stock Value: ${card.totalStockValue}'),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.card});
  final AdminCustomerCard card;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MySpacing.all(4),
      child: MyCard(
        paddingAll: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.people, size: 18), MySpacing.width(8), MyText.titleSmall('Customer Card')]),
            MySpacing.height(8),
            MyText.bodySmall('Total Customers: ${card.totalCustomers}'),
            MyText.bodySmall('Customers with Stock: ${card.totalCustomersWithStock}'),
            MyText.bodySmall('Customers Who Generated Sales: ${card.totalCustomersWhoGeneratedSales}'),
          ],
        ),
      ),
    );
  }
}

class _SalesCard extends StatelessWidget {
  const _SalesCard({required this.card});
  final AdminSalesCard card;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MySpacing.all(4),
      child: MyCard(
        paddingAll: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.attach_money, size: 18), MySpacing.width(8), MyText.titleSmall('Sales Card')]),
            MySpacing.height(8),
            MyText.bodySmall('Sales To Date: ${card.salesToDate}'),
            MyText.bodySmall('Sales This Year: ${card.salesThisYear}'),
            MyText.bodySmall('Sales This Month: ${card.salesThisMonth}'),
            MyText.bodySmall('Sales This Week: ${card.salesThisWeek}'),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MySpacing.all(4),
      child: MyCard(
        paddingAll: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, size: 18), MySpacing.width(8), Expanded(child: MyText.titleSmall(title))]),
            MySpacing.height(12),
            SizedBox(height: 220, child: child),
          ],
        ),
      ),
    );
  }
}

class _SamplesPieChart extends StatelessWidget {
  const _SamplesPieChart({required this.items});
  final List<StockGroupSample> items;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          for (var i = 0; i < items.length; i++)
            PieChartSectionData(
              value: items[i].quantity,
              title: items[i].stockGroup,
              color: _pieColors[i % _pieColors.length],
              radius: 80,
              titleStyle: const TextStyle(fontSize: 9, color: Colors.white),
            ),
        ],
        sectionsSpace: 2,
      ),
    );
  }
}

class _TopCustomersBarChart extends StatelessWidget {
  const _TopCustomersBarChart({required this.items});
  final List<TopCustomerSample> items;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: [
          for (var i = 0; i < items.length; i++)
            BarChartGroupData(x: i, barRods: [BarChartRodData(toY: items[i].total, color: _barColor, width: 18)]),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= items.length) return const SizedBox.shrink();
                return Padding(
                  padding: MySpacing.top(4),
                  child: Text(items[i].customerName, style: const TextStyle(fontSize: 8)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}

class _YearsBarChart extends StatelessWidget {
  const _YearsBarChart({required this.items});
  final List<YearSales> items;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: [
          for (var i = 0; i < items.length; i++)
            BarChartGroupData(x: i, barRods: [BarChartRodData(toY: items[i].sales, color: _barColor, width: 18)]),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= items.length) return const SizedBox.shrink();
                return Padding(padding: MySpacing.top(4), child: Text(items[i].year, style: const TextStyle(fontSize: 9)));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}

class _SamplesPickupTable extends StatelessWidget {
  const _SamplesPickupTable({required this.items});
  final List<SamplePickupDue> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MySpacing.all(4),
      child: MyCard(
        paddingAll: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.checklist, size: 18), MySpacing.width(8), MyText.titleSmall('Samples Due for Pickup')]),
            MySpacing.height(8),
            if (items.isEmpty)
              MyText.bodySmall('No data available', muted: true)
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Tel')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Quantity')),
                  ],
                  rows: items
                      .take(100)
                      .map((item) => DataRow(cells: [
                            DataCell(Text(item.customerName)),
                            DataCell(
                              Text(item.telephone, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                              onTap: item.telephone.isEmpty ? null : () => launchUrl(Uri.parse('tel:${item.telephone}')),
                            ),
                            DataCell(Text(item.stockDescription)),
                            DataCell(Text(item.quantity.toStringAsFixed(0))),
                          ]))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingRecoTable extends StatelessWidget {
  const _UpcomingRecoTable({required this.items});
  final List<UpcomingSaleReturnReco> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MySpacing.all(4),
      child: MyCard(
        paddingAll: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.calendar_month, size: 18),
              MySpacing.width(8),
              Expanded(child: MyText.titleSmall('Upcoming Sale or Return Reconciliation')),
            ]),
            MySpacing.height(8),
            if (items.isEmpty)
              MyText.bodySmall('No data available', muted: true)
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Telephone')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Total Value')),
                  ],
                  rows: items
                      .map((item) => DataRow(cells: [
                            DataCell(Text(item.customer)),
                            DataCell(
                              Text(item.telNo, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                              onTap: item.telNo.isEmpty ? null : () => launchUrl(Uri.parse('tel:${item.telNo}')),
                            ),
                            DataCell(Text(item.recoDate != null
                                ? '${item.recoDate!.year}-${item.recoDate!.month.toString().padLeft(2, '0')}-${item.recoDate!.day.toString().padLeft(2, '0')}'
                                : '-')),
                            DataCell(Text('GHC${item.value}')),
                          ]))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
