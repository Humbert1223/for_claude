import 'package:flutter/material.dart';

class ReportDownloadWidget extends StatelessWidget {
  final String title;
  final Widget? icon;
  final Function? onTap;
  const ReportDownloadWidget({super.key, required this.title, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: icon ?? const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(title),
        onTap: (){
          if(onTap != null){
            onTap!();
          }
        },
        trailing: const Icon(Icons.cloud_download_outlined),
      ),
    );
  }
}
