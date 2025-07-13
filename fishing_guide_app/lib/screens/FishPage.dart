import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fishing_guide_app/provider/fish_provider.dart';

class FishPage extends StatefulWidget {
  @override
  _FishPageState createState() => _FishPageState();
}

class _FishPageState extends State<FishPage> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final fishProvider = Provider.of<FishProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.set_meal, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'ปลาแต่ละชนิด',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              // Fish list content
              Expanded(
                child: _buildFishList(context, fishProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFishList(BuildContext context, FishProvider fishProvider) {
    if (fishProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (fishProvider.error != null) {
      return Center(child: Text(fishProvider.error!));
    }

    if (fishProvider.fishList == null || fishProvider.fishList!.isEmpty) {
      return Center(child: Text('ไม่พบข้อมูลปลา'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: fishProvider.fishList!.length,
      itemBuilder: (context, index) {
        final fish = fishProvider.fishList![index].data() as Map<String, dynamic>;
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        fish['imageUrl'] ?? 'https://via.placeholder.com/60'),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fish['nameTH'] ?? 'ไม่มีชื่อ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800]),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              _buildMeasurementChip(
                                icon: Icons.straighten,
                                value: '${fish['average length'] ?? 'N/A'} cm',
                                color: Colors.blue[100]!,
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                          Row(children: [
                            _buildMeasurementChip(
                              icon: Icons.monitor_weight,
                              value: '${fish['average weight'] ?? 'N/A'} kg',
                            color: Colors.green[100]!,
                              ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(fish['more'] ?? 'ไม่มีคำอธิบาย'),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'ถิ่นอาศัย: ${fish['habitat'] ?? 'ไม่ระบุ'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'ฤดู: ${fish['seasons']?.join(', ') ?? 'ตลอดปี'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeasurementChip({required IconData icon, required String value, required Color color}) {
    return Chip(
      backgroundColor: color,
      avatar: Icon(icon, size: 16),
      label: Text(
        value,
        style: TextStyle(fontSize: 12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}