import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/shopping_view_model.dart';

import '../../global/common/AppColours.dart';

class ShoppingListInfoView extends StatelessWidget {
  const ShoppingListInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
      return Container(
        margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
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
                          "${viewModel.numShoppingLists}",
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
                        child: Text("Total Shopping Lists", style: TextStyle(
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
