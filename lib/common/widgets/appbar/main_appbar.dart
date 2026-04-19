import 'package:flutter/material.dart';
import 'package:sajadah/common/helpers/is_dark_mode.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  const MainAppbar({super.key, this.title});

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: title ?? const Text(''),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: context.isDarkMode
                ? Color.fromRGBO(0, 0, 0, 0.5)
                : Color.fromRGBO(255, 255, 255, 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.menu,
            size: 15,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
