import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/pages/admin/configuration/fees/fees_config_form.dart';
import 'package:novacole/utils/constants.dart';

class FeesSelectSeriePage extends StatelessWidget {
  final Map<String, dynamic> level;
  const FeesSelectSeriePage({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return DefaultDataGrid(
      itemBuilder: (data) {
        return ListTile(
          title: Text(data['name']),
          onTap: (){
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context){
                  return FeesConfigForm(level: level, serie: data);
                })
            );
          },
        );
      },
      dataModel: Entity.serie,
      paginate: PaginationValue.none,
      optionVisible: false,
      canAdd: false,
      canDelete: (data) => false,
      canEdit: (data) => false,
      title: "Selectionner une serie",
    );
  }
}
