import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/pages/admin/configuration/fees/fees_config_form.dart';
import 'package:novacole/pages/admin/configuration/fees/fees_select_serie_page.dart';
import 'package:novacole/utils/constants.dart';

class FeesSelectLevelPage extends StatelessWidget {
  const FeesSelectLevelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultDataGrid(
      itemBuilder: (data) {
        return ListTile(
          title: Text(data['name']),
          onTap: (){
            if(data['degree'] == 'high_school'){
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context){
                    return FeesSelectSeriePage(level: data);
                  })
              );
            }else{
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context){
                    return FeesConfigForm(level: data);
                  })
              );
            }
          },
        );
      },
      dataModel: Entity.level,
      paginate: PaginationValue.none,
      optionVisible: false,
      canAdd: false,
      canDelete: (data) => false,
      canEdit: (data) => false,
      title: "Selectionner un niveau",
    );
  }
}
