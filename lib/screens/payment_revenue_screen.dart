import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';

class PaymentRevenueScreen extends ConsumerStatefulWidget {
  const PaymentRevenueScreen({super.key});

  @override
  ConsumerState<PaymentRevenueScreen> createState() => _PaymentRevenueScreenState();
}

class _PaymentRevenueScreenState extends ConsumerState<PaymentRevenueScreen> {
  String selectedTimeframe = 'Last 30 days';
  String selectedChartTimeframe = 'Weekly';

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Payment & Revenue',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: profileAsync.when(
                data: (profile) {
                  final avatarUrl = profile?['avatarUrl'] as String?;
                  return CircleAvatar(
                    radius: 18,
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const NetworkImage('https://img.freepik.com/free-icon/user_318-159711.jpg'),
                  );
                },
                loading: () => const CircleAvatar(radius: 18, child: CircularProgressIndicator()),
                error: (_, __) => const CircleAvatar(radius: 18, child: Icon(Icons.error)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRevenueHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'NET PROFIT',
                          '₹1,50,000',
                          '+25%',
                          Colors.blue[50]!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          'PATIENTS',
                          '30756',
                          '+15%',
                          Colors.blue[50]!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Completed Payment',
                          '₹1,50,000',
                          Colors.green[50]!,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Pending Payment',
                          '₹30,000',
                          Colors.red[50]!,
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Refunded Amount',
                          '₹10,000',
                          Colors.orange[50]!,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildRevenueAnalysis(),
                  const SizedBox(height: 24),
                  _buildPaymentModes(),
                  const SizedBox(height: 24),
                  _buildRevenueCategories(),
                  const SizedBox(height: 24),
                  _buildTransactionDetails(),
                  const SizedBox(height: 24),
                  _buildRefundDetails(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL REVENUE',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      selectedTimeframe,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹2,50,000',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'vs last ₹2,00,000',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '25%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String growth,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 12,
                      color: Colors.green[700],
                    ),
                    Text(
                      growth,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Revenue Analysis',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedChartTimeframe,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 40,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat', 'Sun'];
                      if (value >= 0 && value < days.length) {
                        return Text(
                          days[value.toInt()],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}k',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      );
                    },
                    interval: 10,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 10,
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                _createBarGroup(0, 30),
                _createBarGroup(1, 27),
                _createBarGroup(2, 35),
                _createBarGroup(3, 25),
                _createBarGroup(4, 33),
                _createBarGroup(5, 20),
                _createBarGroup(6, 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _createBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue,
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentModes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode of Payment',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildProgressBar('Cash Payment', 0.22),
        const SizedBox(height: 12),
        _buildProgressBar('Credit/Debit Card', 0.28),
        const SizedBox(height: 12),
        _buildProgressBar('UPI Payment', 0.37),
        const SizedBox(height: 12),
        _buildProgressBar('Net Banking', 0.10),
        const SizedBox(height: 12),
        _buildProgressBar('Insurance', 0.12),
      ],
    );
  }

  Widget _buildProgressBar(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.blue[50],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildRevenueCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revenue by Category',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 30,
                        color: Colors.blue,
                        title: '',
                        radius: 50,
                      ),
                      PieChartSectionData(
                        value: 22,
                        color: Colors.pink,
                        title: '',
                        radius: 50,
                      ),
                      PieChartSectionData(
                        value: 20,
                        color: Colors.purple,
                        title: '',
                        radius: 50,
                      ),
                      PieChartSectionData(
                        value: 18,
                        color: Colors.red,
                        title: '',
                        radius: 50,
                      ),
                      PieChartSectionData(
                        value: 10,
                        color: Colors.orange,
                        title: '',
                        radius: 50,
                      ),
                    ],
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Consultations', Colors.blue, '30%'),
                    const SizedBox(height: 8),
                    _buildLegendItem('Surgeries', Colors.pink, '22%'),
                    const SizedBox(height: 8),
                    _buildLegendItem('Lab Tests', Colors.purple, '20%'),
                    const SizedBox(height: 8),
                    _buildLegendItem('Pharmacy', Colors.red, '18%'),
                    const SizedBox(height: 8),
                    _buildLegendItem('Others', Colors.orange, '10%'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String percentage) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaction Details',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.blue),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Payment ID')),
              DataColumn(label: Text('Patient Name')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Mode')),
              DataColumn(label: Text('Action')),
            ],
            rows: [
              _buildTransactionRow(
                'TN001',
                'Rakshita',
                '10/01/25',
                '₹5k',
                'Paid',
                'UPI',
              ),
              _buildTransactionRow(
                'TN072',
                'Harish',
                '9/01/25',
                '₹75k',
                'Paid',
                'Credit',
              ),
              _buildTransactionRow(
                '-',
                'Jessica',
                '-',
                '₹8k',
                'Pending',
                '-',
              ),
              _buildTransactionRow(
                'TN023',
                'Nithya',
                '30/12/25',
                '₹4.2k',
                'Paid',
                'Cash',
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildTransactionRow(
    String id,
    String name,
    String date,
    String amount,
    String status,
    String mode,
  ) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'paid':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.black87;
    }

    return DataRow(
      cells: [
        DataCell(Text(id)),
        DataCell(Text(name)),
        DataCell(Text(date)),
        DataCell(Text(amount)),
        DataCell(
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DataCell(Text(mode)),
        DataCell(
          TextButton(
            onPressed: () {},
            child: const Text(
              'Receipt',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefundDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Refund Details',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.blue),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Refund ID')),
              DataColumn(label: Text('Patient Name')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Mode')),
              DataColumn(label: Text('Action')),
            ],
            rows: [
              _buildRefundRow(
                'RFD01',
                'Ananya',
                '10/01/25',
                '₹13k',
                'Cancellation',
                'UPI',
              ),
              _buildRefundRow(
                'RFD02',
                'Rahul',
                '10/01/25',
                '₹2.5k',
                'Duplication',
                'Credit',
              ),
              _buildRefundRow(
                'RFD03',
                'Priya',
                '28/12/25',
                '₹1k',
                'Not Available',
                'UPI',
              ),
              _buildRefundRow(
                'RFD04',
                'Karthik',
                '07/12/25',
                '₹2k',
                'Duplication',
                'Cash',
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildRefundRow(
    String id,
    String name,
    String date,
    String amount,
    String status,
    String mode,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(id)),
        DataCell(Text(name)),
        DataCell(Text(date)),
        DataCell(Text(amount)),
        DataCell(Text(status)),
        DataCell(Text(mode)),
        DataCell(
          TextButton(
            onPressed: () {},
            child: const Text(
              'More',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 