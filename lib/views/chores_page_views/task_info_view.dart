import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';

import '../../global/common/AppColours.dart';

class TaskInfoView extends StatelessWidget {
  const TaskInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Consumer<TaskViewModel>(builder: (context, viewModel, child) {
      return Container(
        margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Row(
          children: [
            //Total Tasks
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                    color: AppColours.colour2(brightness), borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Text(
                          "${viewModel.numTasks}",
                          style: TextStyle(
                              fontSize: 28,
                              color: AppColours.colour3(brightness),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FittedBox(
                        child: Text("Total Tasks", style: TextStyle(
                          color: AppColours.colour4(brightness), fontWeight: FontWeight.w600
                        ),),
                      ),
                    ),
                  )
                ]),
              ),
            ),

            SizedBox(width: 20),

            //Remaining Tasks
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                    color: AppColours.colour2(brightness), borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Text(
                          "${viewModel.numTasksRemaining}",
                          style: TextStyle(
                              fontSize: 28,
                              color: AppColours.colour3(brightness),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FittedBox(
                        child: Text("Remaining Tasks", style: TextStyle(
                            color: AppColours.colour4(brightness), fontWeight: FontWeight.w600
                        ),),
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}
