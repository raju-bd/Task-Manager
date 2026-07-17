//import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/model/api_response.dart';
import '../data/model/task_model.dart';
import '../data/service/api_caller.dart';
import '../utils/urls.dart';
class TaskCard extends StatefulWidget {
  final TaskModel taskModel;
  final Color CardColor;
  final VoidCallback refreshParent;

  const TaskCard({

    super.key, required this.taskModel, required this.CardColor, required this.refreshParent,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {

  Future<void> changeStatus(String Status) async {
    final ApiResponse response = await ApiCaller.getRequest(url: TMUrls.updateTaskStatusURL(widget.taskModel.sId.toString(),Status));



    if(response.isSuccess){
      widget.refreshParent();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task updated successfully')));

    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.responseData['data'])));

    }
    Navigator.pop(context);

  }



  void ShowChnageDialog(){
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: Text('Change Status'),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Card(
            color: widget.taskModel.status =='New' ?  Colors.green : null,
            child: ListTile(title: Text('New',
            ),
            onTap: (){
              changeStatus('New');
            },
              trailing:widget.taskModel.status =='New' ? Icon(Icons.check_circle,color: Colors.white,) : null,
            ),
          ),

          Card(
            color: widget.taskModel.status =='Progress' ?  Colors.green : null,
            child: ListTile(title: Text('Progress',
            ),
            onTap: (){
              changeStatus('Progress');
            },
              trailing:widget.taskModel.status =='Progress' ? Icon(Icons.check_circle,color: Colors.white,) : null,
            ),
          ),


          Card(
            color: widget.taskModel.status =='Completed' ?  Colors.green : null,
            child: ListTile(title: Text('Completed',
            ),
            onTap: (){
              changeStatus('Completed');
            },
              trailing:widget.taskModel.status =='Completed' ? Icon(Icons.check_circle,color: Colors.white,) : null,
            ),
          ),


          Card(
            color: widget.taskModel.status =='Cancelled' ?  Colors.green : null,
            child: ListTile(title: Text('Cancelled',
            ),
            onTap: (){
              changeStatus('Cancelled');
            },
              trailing:widget.taskModel.status =='Cancelled' ? Icon(Icons.check_circle,color: Colors.white,) : null,
            ),
          ),





        ],
      ),

    ));
  }



  Future<void> deleteTask() async {
    final ApiResponse response = await ApiCaller.getRequest(url: TMUrls.deleteTaskURL(widget.taskModel.sId.toString()));



    if(response.isSuccess){
      widget.refreshParent();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task deleted successfully')));

    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.responseData['data'])));

    }

  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                widget.taskModel.title.toString(),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              
              // Description
              Text(
                widget.taskModel.description.toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              
              // Status and Action Buttons row
              Row(
                children: [
                  Chip(
                    label: Text(
                      widget.taskModel.status.toString(),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)
                    ),
                    backgroundColor: widget.CardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: (){
                      ShowChnageDialog();
                    },
                    icon: Icon(Icons.edit, color: Colors.orange, size: 20),
                    tooltip: 'Edit Task',
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(width: 4),
                  IconButton(
                    onPressed: (){
                      deleteTask();
                    },
                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                    tooltip: 'Delete Task',
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
