import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:task_manager/data/model/api_response.dart';
import 'package:task_manager/data/model/task_model.dart';
import 'package:task_manager/data/model/task_status_count_model.dart';
import 'package:task_manager/data/service/api_caller.dart';
import 'package:task_manager/utils/urls.dart';
import 'package:task_manager/widget/task_card.dart';
import 'package:task_manager/widget/task_count_by_status.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  List<TaskStatusCountModel> taskCount = [];
  List<TaskModel> allTasks = [];
  List<TaskModel> filteredTasks = [];
  int selectedTabIndex = 0;
  bool isLoading = false;

  final List<String> tabs = ['All', 'Pending', 'In Progress', 'Completed', 'Cancel'];
  final List<String> statusMap = ['', 'New', 'Progress', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    getAllTaskCount();
    getAllTasks();
  }

  Future<void> getAllTaskCount() async {
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
      taskCount = counts;
    });
  }

  Future<void> getAllTasks() async {
    setState(() => isLoading = true);
    
    List<TaskModel> allTasksList = [];
    
    // Fetch tasks from all statuses
    for(String status in ['New', 'Progress', 'Completed', 'Cancelled']) {
      final ApiResponse response = await ApiCaller.getRequest(url: TMUrls.getTaskByStatusURL(status));
      
      if(response.isSuccess){
        for(Map<String , dynamic>jsonData in (response.responseData['data'])){
          allTasksList.add(TaskModel.fromJson(jsonData));
        }
      }
    }

    setState(() {
      allTasks = allTasksList;
      filterTasks();
      isLoading = false;
    });
  }

  void filterTasks() {
    if(selectedTabIndex == 0) {
      // All tasks
      filteredTasks = allTasks;
    } else {
      // Filter by status
      String status = statusMap[selectedTabIndex];
      filteredTasks = allTasks.where((task) => task.status == status).toList();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Task Count Cards
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ['New', 'Progress', 'Completed', 'Cancelled'].length,
                itemBuilder: (context, index){
                  final status = ['New', 'Progress', 'Completed', 'Cancelled'][index];
                  final task = taskCount.firstWhere(
                    (e)=>e.sId == status, 
                    orElse: ()=> TaskStatusCountModel(sId: status, sum: 0)
                  );
                  return TaskCountByStatus(
                    title: task.sId.toString(), 
                    count: task.sum ?? 0,
                  );
                },
                separatorBuilder: (BuildContext context, int index) => SizedBox(width: 12),
              ),
            ),
          ),

          // Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabs.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTabIndex = index;
                        filterTasks();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selectedTabIndex == index ? Colors.green : Colors.transparent,
                            width: 3
                          )
                        )
                      ),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          color: selectedTabIndex == index ? Colors.green : Colors.grey[600],
                          fontWeight: selectedTabIndex == index ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          SizedBox(height: 8),

          // Task List
          Expanded(
            child: isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
              : filteredTasks.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_outlined, size: 64, color: Colors.grey[300]),
                      SizedBox(height: 16),
                      Text(
                        'No ${tabs[selectedTabIndex]} Tasks',
                        style: TextStyle(color: Colors.grey[600], fontSize: 18),
                      )
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: () async {
                    await getAllTaskCount();
                    await getAllTasks();
                  },
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index){
                      final task = filteredTasks[index];
                      return TaskCard(
                        taskModel: task,
                        CardColor: _getStatusColor(task.status ?? 'New'),
                        refreshParent: () async {
                          await getAllTaskCount();
                          await getAllTasks();
                        },
                      );
                    }
                  ),
                ),
          )
        ],
      ),
    );
  }
}
