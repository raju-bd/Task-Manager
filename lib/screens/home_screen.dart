import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:task_manager/data/model/api_response.dart';
import 'package:task_manager/data/model/task_status_count_model.dart';
import 'package:task_manager/data/service/api_caller.dart';
import 'package:task_manager/utils/urls.dart';
import 'package:task_manager/widget/task_count_by_status.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskStatusCountModel> taskCounts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getAllTaskCounts();
  }

  Future<void> getAllTaskCounts() async {
    setState(() => isLoading = true);
    final ApiResponse response = await ApiCaller.getRequest(url: TMUrls.getTaskCountURL);

    List<TaskStatusCountModel> counts = [];

    if(response.isSuccess){
      for(Map<String , dynamic>jsonData in (response.responseData['data'])){
        counts.add(TaskStatusCountModel.fromJson(jsonData));
      }
      counts.removeWhere((e) => e.sId == null);
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonDecode(response.responseData['data'])))
      );
    }

    setState(() {
      taskCounts = counts;
      isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch(status) {
      case 'New':
        return Colors.blue;
      case 'Progress':
        return Colors.purple;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int getTotalTasks() {
    return taskCounts.fold(0, (sum, item) => sum + (item.sum ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: getAllTaskCounts,
        child: isLoading
          ? Center(
            child: CircularProgressIndicator(color: Colors.green),
          )
          : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track your task progress',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  SizedBox(height: 32),

                  // Total Tasks Summary
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Tasks',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            getTotalTasks().toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.trending_up, color: Colors.white.withOpacity(0.7), size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Keep working on your tasks',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Task Status Overview
                  Text(
                    'Task Status Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Status Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildStatusCard('New', Colors.blue),
                      _buildStatusCard('In Progress', Colors.purple),
                      _buildStatusCard('Completed', Colors.green),
                      _buildStatusCard('Cancelled', Colors.red),
                    ],
                  ),
                  SizedBox(height: 32),

                  // Detailed Statistics
                  Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  ..._buildStatisticsList(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildStatusCard(String label, Color color) {
    final taskCount = taskCounts.firstWhere(
      (e) => e.sId == (label == 'In Progress' ? 'Progress' : label) || 
             e.sId == (label == 'Cancelled' ? 'Cancelled' : label),
      orElse: () => TaskStatusCountModel(sId: label, sum: 0),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(top: BorderSide(color: color, width: 4)),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Text(
              (taskCount.sum ?? 0).toString(),
              style: TextStyle(
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatisticsList() {
    return taskCounts.map((task) {
      final percentage = getTotalTasks() == 0 ? 0 : ((task.sum ?? 0) / getTotalTasks() * 100).toStringAsFixed(1);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.sId ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: getTotalTasks() == 0 ? 0 : (task.sum ?? 0) / getTotalTasks(),
                          minHeight: 6,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(task.sId ?? ''),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${task.sum ?? 0}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _getStatusColor(task.sId ?? ''),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
