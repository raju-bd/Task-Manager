import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/model/api_response.dart';
import '../data/model/task_model.dart';
import '../data/service/api_caller.dart';
import '../utils/urls.dart';
import '../widget/task_card.dart';

class CompletedTaskScreen extends StatefulWidget {
  const CompletedTaskScreen({super.key});

  @override
  State<CompletedTaskScreen> createState() => _CompletedTaskScreenState();
}

class _CompletedTaskScreenState extends State<CompletedTaskScreen> {

  List<TaskModel>tasks = [];
  bool isLoading = false;

  Future<void> getAllTask() async {
    setState(() => isLoading = true);
    final ApiResponse response = await ApiCaller.getRequest(url: TMUrls.getTaskByStatusURL('Completed'));

    List<TaskModel> task = [];

    if(response.isSuccess){
      for(Map<String , dynamic>jsonData in (response.responseData['data'])){
        task.add(TaskModel.fromJson(jsonData));
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(response.responseData['data']))));
    }

    setState(() {
      tasks = task;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: getAllTask,
        child: tasks.isEmpty && !isLoading
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text(
                  'No Completed Tasks',
                  style: TextStyle(color: Colors.grey[600], fontSize: 18),
                )
              ],
            ),
          )
          : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index){
              final task = tasks[index];
              return TaskCard(
                taskModel: task,
                CardColor: Colors.green,
                refreshParent: getAllTask,
              );
            }
          ),
      ),
    );
  }
}