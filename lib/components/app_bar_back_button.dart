import 'package:flutter/material.dart';

class AppBarBackButton extends StatefulWidget {
  final Function? onTap;

  const AppBarBackButton({super.key, this.onTap});

  @override
  AppBarBackButtonState createState() {
    return AppBarBackButtonState();
  }
}

class AppBarBackButtonState extends State<AppBarBackButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: (){
          if(widget.onTap != null){
            widget.onTap!();
          }else{
            Navigator.of(context).pop();
          }
        },
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}