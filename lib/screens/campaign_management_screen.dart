import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';

class CampaignManagementScreen extends ConsumerStatefulWidget {
  const CampaignManagementScreen({super.key});

  @override
  ConsumerState<CampaignManagementScreen> createState() =>
      _CampaignManagementScreenState();
}

class _CampaignManagementScreenState extends ConsumerState<CampaignManagementScreen> {
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
          'Campaign Management',
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 36.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Live Campaign',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '4',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '30 Dec, 2024 - 30 Jan, 2025',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Campaign Cards Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: [
                  _buildCampaignCard('Health Check-Up Promo', 0.70, 25),
                  _buildCampaignCard('Diabetic Care Awareness', 0.60, 18),
                  _buildCampaignCard('Free Dental Consulation', 0.80, 22),
                  _buildCampaignCard('Senior Health Package', 0.86, 30),
                ],
              ),
              const SizedBox(height: 24),

              // Campaign Analysis Chart
              Row(
                children: [
                  Text(
                    'Campaign Analysis',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      legendItem('Reach', Color(0xFF44DA22)),
                      SizedBox(width: 10),
                      legendItem('Budget', Color(0xFFCA1DB0)),
                      SizedBox(width: 10),
                      legendItem('Rate', Color(0xFFEB994C)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(height: 250, child: BarChart(_campaignAnalysisData())),
              const SizedBox(height: 5),

              // Visitors Profile
              Container(
                margin: EdgeInsets.fromLTRB(40, 10, 40, 10),
                padding: const EdgeInsets.fromLTRB(8, 15, 8, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.lightBlue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
                      child: Text(
                        'Visitors Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          height: 150,
                          width: 170,
                          child: Stack(
                            children: [
                              PieChart(_visitorsProfileData()),
                              Center(
                                child: Text(
                                  '55%\nMale',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            legendItem('Male', Color(0xFF2196F3)),
                            SizedBox(height: 18),
                            legendItem('Female', Color(0xFFE91E63)),
                            SizedBox(height: 18),
                            legendItem(
                              'Other',
                              Color(0xFF9C27B0).withOpacity(0.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Top Traffic Sources
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFE0F1FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Traffic Sources',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTrafficSource(
                      'Facebook',
                      '14 Jan, 2024',
                      '20K',
                      Icons.facebook,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildTrafficSource(
                      'Google Ads',
                      '14 Jan, 2024',
                      '15K',
                      Icons.ads_click,
                      Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildTrafficSource(
                      'Instagram',
                      '14 Jan, 2024',
                      '10K',
                      Icons.camera_alt,
                      Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _buildTrafficSource(
                      'Email Ads',
                      '14 Jan, 2024',
                      '8K',
                      Icons.email,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Ad Table
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF969696)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Recent Ad',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Ad No. & Ad Name')),
                          DataColumn(label: Text('Clicks')),
                          DataColumn(label: Text('Budget')),
                          DataColumn(label: Text('Impressions')),
                          DataColumn(label: Text('CTR')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: [
                          _buildAdTableRow(
                            'AD1 - Summer Sale',
                            '2k',
                            '₹5k',
                            '3k',
                            '20%',
                            true,
                          ),
                          _buildAdTableRow(
                            'AD1 - Health Tips',
                            '1.5k',
                            '₹3k',
                            '8.5k',
                            '18.6%',
                            true,
                          ),
                          _buildAdTableRow(
                            'AD1 - Free Checkup',
                            '1.2k',
                            '₹4k',
                            '7.5k',
                            '16%',
                            true,
                          ),
                          _buildAdTableRow(
                            'AD1 - Discount Ad',
                            '800',
                            '₹2.5k',
                            '5k',
                            '16%',
                            true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Add extra space at the bottom to prevent overflow
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignCard(String title, double progress, int impressions) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF969696)),
        color: const Color(0xFFE0F1FF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.left,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 80),
            child: SizedBox(
              height: 50,
              width: 50,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Color(0xFFEAF4FF),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF0078D4),
                        ),
                        strokeWidth: 8,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "$impressions"
                'K',
                style: TextStyle(
                  color: Color(0xFF0078D4),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 8),
              Text(
                "Impressions",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficSource(
    String platform,
    String date,
    String impressions,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                platform,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                date,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          '$impressions\nImpressions',
          textAlign: TextAlign.end,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  DataRow _buildAdTableRow(
    String name,
    String clicks,
    String budget,
    String impressions,
    String ctr,
    bool isOnline,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(clicks)),
        DataCell(Text(budget)),
        DataCell(Text(impressions)),
        DataCell(Text(ctr)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isOnline ? 'Online' : 'Offline',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  BarChartData _campaignAnalysisData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 35,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const titles = ['A', 'B', 'C', 'D'];
              return Text(
                'Campaign ${titles[value.toInt()]}',
                style: GoogleFonts.poppins(fontSize: 12),
              );
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 5,
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      barGroups: [
        _createBarGroup(0, [20, 12, 8]),
        _createBarGroup(1, [18, 14, 6]),
        _createBarGroup(2, [22, 15, 16]),
        _createBarGroup(3, [30, 10, 10]),
      ],
    );
  }

  BarChartGroupData _createBarGroup(int x, List<double> values) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: values[0],
          color: Color(0xFF44DA22), // Reach - match legend color
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: values[1],
          color: Color(0xFFCA1DB0), // Budget - match legend color
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: values[2],
          color: Color(0xFFEB994C), // Rate - match legend color
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  PieChartData _visitorsProfileData() {
    return PieChartData(
      sections: [
        PieChartSectionData(
          value: 55, // Male percentage
          color: Color(0xFF2196F3), // Consistent blue for male
          radius: 20,
          showTitle: false,
        ),
        PieChartSectionData(
          value: 35, // Female percentage
          color: Color(0xFFE91E63), // Consistent pink for female
          radius: 20,
          showTitle: false,
        ),
        PieChartSectionData(
          value: 10, // Other percentage
          color: Color(
            0xFF9C27B0,
          ).withOpacity(0.5), // Consistent purple for other
          radius: 20,
          showTitle: false,
        ),
      ],
      centerSpaceRadius: 50,
      sectionsSpace: 2,
    );
  }

  Widget legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: color),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
