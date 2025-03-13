import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/shopping_view_model.dart';

class MedicalInfoView extends StatelessWidget {
  const MedicalInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
      return Container(
        margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Row(
          children: [
            //Note
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                    color: viewModel.colour2, borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Text(
                          "Note",
                          style: TextStyle(
                              fontSize: 28,
                              color: viewModel.colour4,
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
                        child: Text("Adding Medical Conditions Is An Optional Choice",
                          style: TextStyle(
                            fontSize: 20,
                            color: viewModel.colour3,
                              fontWeight: FontWeight.w600
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
