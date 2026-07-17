import 'package:flutter/material.dart';

import '../data/model/api_response.dart';
import '../data/service/api_caller.dart';
import '../utils/urls.dart';
import '../widget/screen_bg.dart';
import 'main_nav_screen.dart';

class AddNewTaskScreen extends StatefulWidget {
  const AddNewTaskScreen({super.key});

  @override
  State<AddNewTaskScreen> createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();


  Future<void>createTask() async {




    final ApiResponse response = await ApiCaller.PostRequest(url: TMUrls.CreateTaskURL,
        body: {
          "title":titleController.text,
          "description": descriptionController.text,
          "status":"New"
        }

    );


    if(response.isSuccess){

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainNavScreen()));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign In success....!')));


    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.responseData['data'])));

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBG(child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80,),
              Text('Add New Task', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 30,),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Task Title',
                  prefixIcon: Icon(Icons.task_outlined)
                ),
              ),
              SizedBox(height: 16,),
              TextFormField(
                controller: descriptionController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Task Description',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Icon(Icons.description_outlined),
                  ),
                  alignLabelWithHint: true
                ),
              ),
              SizedBox(height: 32,),
              FilledButton(
                onPressed: (){
                  if(titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                    createTask();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all fields'))
                    );
                  }
                }, 
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 28),
                      SizedBox(width: 8),
                      Text('Add Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              ),
              SizedBox(height: 40,),
            ],
          ),
        ),
      )),
    );
  }
}
