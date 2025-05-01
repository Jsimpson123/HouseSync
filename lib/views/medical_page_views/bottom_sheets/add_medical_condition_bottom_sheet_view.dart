import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/medical_model.dart';
import 'package:shared_accommodation_management_app/pages/medical_page.dart';
import 'package:shared_accommodation_management_app/view_models/medical_view_model.dart';

import '../../../global/common/AppColours.dart';

class AddMedicalConditionBottomSheetView extends StatefulWidget {
  const AddMedicalConditionBottomSheetView({super.key});

  @override
  State<AddMedicalConditionBottomSheetView> createState() {
    return _AddMedicalConditionBottomSheetView();
  }
}

final TextEditingController enteredMedicalConditionNameController = TextEditingController();
final TextEditingController enteredMedicalConditionDescController = TextEditingController();

List<TextEditingController> controllers = [];

User? user = FirebaseAuth.instance.currentUser;

bool isSubmitButtonEnabled() {
  return enteredMedicalConditionNameController.text.isNotEmpty
      &&
      enteredMedicalConditionDescController.text.isNotEmpty;
}

class _AddMedicalConditionBottomSheetView extends State<AddMedicalConditionBottomSheetView> {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Consumer<MedicalViewModel>(builder: (context, viewModel, child) {
      return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom), //Ensures the keyboard doesn't cover the textfields
          child: Container(
              height: 350,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      decoration: const InputDecoration(
                          hintText: "Condition",
                          border: OutlineInputBorder()),
                      controller: enteredMedicalConditionNameController,
                      onChanged: (_) => setState(() {})
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    decoration: const InputDecoration(
                      hintText: "Description",
                      border: OutlineInputBorder()),
                    controller: enteredMedicalConditionDescController,
                    maxLines: 4,
                    minLines: 3,
                    keyboardType: TextInputType.multiline,
                      onChanged: (_) => setState(() {})
                  ),
                  const SizedBox(height: 10),

                  //Submit Button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColours.colour3(brightness),
                          foregroundColor: AppColours.colour1(brightness),
                          fixedSize: const Size(150, 100)),
                      onPressed: !isSubmitButtonEnabled()
                          ? null
                          : ()  async {
                        //If the required fields have data then create the medical condition
                        if (enteredMedicalConditionNameController.text.isNotEmpty && enteredMedicalConditionDescController.text.isNotEmpty) {
                          MedicalCondition newMedicalCondition = MedicalCondition.newMedicalCondition(user!.uid, enteredMedicalConditionNameController.text, enteredMedicalConditionDescController.text);

                          await viewModel.createMedicalCondition(newMedicalCondition);

                          setState(() {
                            //Resets everything to ensure values don't remain when creating a new condition
                            Navigator.of(context).pop();
                            enteredMedicalConditionNameController.clear();
                            enteredMedicalConditionDescController.clear();
                          });
                        }

                        //Refreshes the page to allow users to be visible again when assigning
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MedicalPage()));
                      },
                      child: const Text("Submit"))
                ],
              )));
    });
  }
}