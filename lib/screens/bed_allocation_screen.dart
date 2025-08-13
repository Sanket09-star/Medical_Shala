import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';

class BedAllocationScreen extends ConsumerStatefulWidget {
  const BedAllocationScreen({super.key});

  @override
  ConsumerState<BedAllocationScreen> createState() => _BedAllocationScreenState();
}

class _BedAllocationScreenState extends ConsumerState<BedAllocationScreen> {
  String selectedTimeframe = 'Weekly';

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
          'Bed Allocation Details',
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
                    radius: 16,
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const NetworkImage('https://img.freepik.com/free-icon/user_318-159711.jpg'),
                  );
                },
                loading: () => const CircleAvatar(radius: 16, child: CircularProgressIndicator()),
                error: (_, __) => const CircleAvatar(radius: 16, child: Icon(Icons.error)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          const Icon(Icons.search, color: Colors.black45, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search  by patient's name etc",
                                hintStyle: const TextStyle(fontSize: 15, color: Colors.black45),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black87, size: 20),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.file_upload_outlined, color: Colors.black87, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            // Overview of Patients Admitted
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview of Patients Admitted',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _overviewInfoBox(
                          icon: Icons.people,
                          label: 'Total Patients',
                          value: '120',
                        ),
                        const SizedBox(width: 12),
                        _overviewInfoBox(
                          icon: Icons.add_circle_outline,
                          label: 'New Admission',
                          value: '30',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _overviewInfoBox(
                          icon: Icons.check_circle_outline,
                          label: 'Discharged',
                          value: '25',
                        ),
                        const SizedBox(width: 12),
                        _overviewInfoBox(
                          icon: Icons.bed,
                          label: 'Remaining',
                          value: '95',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Revenue Analysis
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectedTimeframe,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 20, color: Colors.black87),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _legendDot(Colors.pink),
                      const SizedBox(width: 4),
                      const Text('ICU', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 16),
                      _legendDot(Colors.purple),
                      const SizedBox(width: 4),
                      const Text('General', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 16),
                      _legendDot(Colors.green),
                      const SizedBox(width: 4),
                      const Text('Private', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 16),
                      _legendDot(Colors.blue),
                      const SizedBox(width: 4),
                      const Text('Maternity', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      _revenueData(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FBFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Bed Occupancy',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _bedOccupancyRow('General Beds', 0.85),
                  const SizedBox(height: 12),
                  _bedOccupancyRow('ICU Beds', 0.83),
                  const SizedBox(height: 12),
                  _bedOccupancyRow('Private Beds', 0.80),
                  const SizedBox(height: 12),
                  _bedOccupancyRow('Isolation Beds', 0.70),
                  const SizedBox(height: 12),
                  _bedOccupancyRow('Special Care Beds', 0.36),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Total Bed Analysis',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16,),
            SizedBox(
              height: 200,
                    child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      _bedAnalysisData(),
                    ),
                  ),
                  SizedBox(width: 30,),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    
                      children: [
                        _buildLegendItem('Occupied (130)', Colors.red),
                        const SizedBox(height: 8),
                        _buildLegendItem('Available (60)', Colors.green),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          'Under Maintenance (10)',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildBedTable(),
          ],
        ),
      ),
    );
  }

  Widget _overviewInfoBox({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1976D2), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _bedOccupancyRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(
          '${(value * 100).toInt()}%',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
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
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBedTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Payment ID')),
            DataColumn(label: Text('Patient Name')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Ward')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Action')),
          ],
          rows: [
            _buildTableRow(
              'B001',
              'Ramesh',
              '12/01/25',
              'ICU',
              'Occupied',
              'Discharge',
            ),
            _buildTableRow(
              'B002',
              'Anjali',
              '10/01/25',
              'Maternity',
              'Occupied',
              'Discharge',
            ),
            _buildTableRow(
              'B003',
              '-',
              '-',
              'General',
              'Available',
              'Allocate',
            ),
            _buildTableRow(
              'B004',
              '-',
              '30/12/25',
              'General',
              'Maintenance',
              'Update',
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildTableRow(
    String id,
    String name,
    String date,
    String ward,
    String status,
    String action,
  ) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'occupied':
        statusColor = Colors.red;
        break;
      case 'available':
        statusColor = Colors.green;
        break;
      case 'maintenance':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.black87;
    }

    return DataRow(
      cells: [
        DataCell(Text(id)),
        DataCell(Text(name)),
        DataCell(Text(date)),
        DataCell(Text(ward)),
        DataCell(
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DataCell(
          TextButton(
            onPressed: () {},
            child: Text(
              action,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _revenueData() {
    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const days = ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat'];
              if (value >= 0 && value < days.length) {
                return Text(days[value.toInt()]);
              }
              return const Text('');
            },
            reservedSize: 30,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        _createLineBarsData(Colors.pink, [10, 8, 12, 7, 10, 12]),
        _createLineBarsData(Colors.purple, [2, 3, 2, 1, 2, 1]),
        _createLineBarsData(Colors.green, [4, 5, 6, 5, 7, 3]),
        _createLineBarsData(Colors.blue, [6, 4, 8, 6, 4, 5]),
      ],
    );
  }

  LineChartBarData _createLineBarsData(Color color, List<double> spots) {
    return LineChartBarData(
      spots: spots
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
    );
  }

  PieChartData _bedAnalysisData() {
    return PieChartData(
      sections: [
        PieChartSectionData(
          value: 130,
          color: Colors.red,
          radius: 50,
          showTitle: false,
        ),
        PieChartSectionData(
          value: 60,
          color: Colors.green,
          radius: 50,
          showTitle: false,
        ),
        PieChartSectionData(
          value: 10,
          color: Colors.orange,
          radius: 50,
          showTitle: false,
        ),
      ],
      centerSpaceRadius: 40,
      sectionsSpace: 2,
    );
  }
} 