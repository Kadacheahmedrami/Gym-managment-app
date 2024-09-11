import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:hamza_gym/main.dart';

Color primaryColor = back;
Color accentColor = gren;
Color cardColor = shadow;
Color textColor = Colors.white;
Color shadowColor = Colors.white10;

class StatisticsPage extends StatelessWidget {
  final List<Client> clients;

  StatisticsPage({required this.clients, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int positiveBalanceCount = clients.where((c) => c.balance > 0).length;
    final int negativeBalanceCount = clients.where((c) => c.balance < 0).length;
    final int zeroBalanceCount = clients.where((c) => c.balance == 0).length;
    final int totalClients = clients.length;

    final double totalPositiveBalance = clients.where((c) => c.balance > 0).fold(0.0, (sum, c) => sum + c.balance);
    final double totalNegativeBalance = clients.where((c) => c.balance < 0).fold(0.0, (sum, c) => sum + c.balance);

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics',style: TextStyle(color: theme ? Colors.black : Colors.white),),
        backgroundColor: gren,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: back,
        padding: const EdgeInsets.only(left: 20 ,right: 20),
        child: SingleChildScrollView(  // Added this to handle overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: 20),
              Text(
                'Client Statistics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: gren,
                ),
              ),
              SizedBox(height: 60),
              Container(
                height: 200,  // Set a fixed height for the PieChart
                child: _buildPieChart(positiveBalanceCount, negativeBalanceCount, zeroBalanceCount),
              ),
              SizedBox(height: 65),
              _buildStatisticCard(
                title: 'Total Clients',
                value: totalClients.toString(),
                color: gren,
              ),
              SizedBox(height: 15),
              _buildStatisticCard(
                title: 'Positive Balance Clients',
                value: positiveBalanceCount.toString(),
                color: gren,
              ),
              SizedBox(height: 15),
              _buildStatisticCard(
                title: 'Negative Balance Clients',
                value: negativeBalanceCount.toString(),
                color: gren,
              ),
              SizedBox(height: 15),
              _buildStatisticCard(
                title: 'Zero Balance Clients',
                value: zeroBalanceCount.toString(),
                color: gren,
              ),
              SizedBox(height: 15),
              _buildStatisticCard(
                title: 'Total Positive Balance',
                value: totalPositiveBalance.toStringAsFixed(2),
                color: Colors.green,
              ),
              SizedBox(height: 15),
              _buildStatisticCard(
                title: 'Total Negative Balance',
                value: totalNegativeBalance.toStringAsFixed(2),
                color: Colors.red,
              ),
               SizedBox(height: 45),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4  ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: shadow,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 5,
            offset: Offset(-2, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(int positive, int negative, int zero) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: positive.toDouble(),
            title: 'Positive',
            color: Colors.green,
            radius: 100,
            titleStyle: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: negative.toDouble(),
            title: 'Negative',
            color: Colors.red,
            radius: 100,
            titleStyle: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: zero.toDouble(),
            title: 'Zero',
            color: Colors.grey,
            radius: 100,
            titleStyle: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
        borderData: FlBorderData(show: false),
        centerSpaceRadius: 50,
        sectionsSpace: 5,

      ),
    );
  }

  Widget _buildBarChart(int positive, int negative, int zero) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: shadowColor,
            width: 1,
          ),
        ),
        gridData: FlGridData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: positive.toDouble(),
                color: Colors.green,
                width: 20,
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: negative.toDouble(),
                color: Colors.red,
                width: 20,
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: zero.toDouble(),
                color: Colors.grey,
                width: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
