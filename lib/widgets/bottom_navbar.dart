import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:flutter/material.dart';
import 'package:sari/views/dealers/profile_view.dart';
import 'package:sari/views/products/home_view.dart';
import 'package:sari/views/transactions/buyer_view.dart';
import 'package:sari/views/transactions/seller_view.dart';

class BottomNavbar extends StatefulWidget {
  BottomNavbar({super.key, required this.page});
  int page = 0;

  @override
  BottomNavbarState createState() => BottomNavbarState();
}

class BottomNavbarState extends State<BottomNavbar> {
  @override
  Widget build(BuildContext context) {
    List<IconData> icons = [
      FontAwesomeIcons.house,
      FontAwesomeIcons.cartShopping,
      FontAwesomeIcons.box,
      FontAwesomeIcons.solidUser,
    ];

    List<Color> colors = [
      SariTheme.secondary,
      SariTheme.primary,
      SariTheme.tertiary,
      SariTheme.pink
    ];

    return AnimatedBottomNavigationBar.builder(
      itemCount: icons.length,
      activeIndex: widget.page,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      onTap: (index) {
        late String route;
        setState(() => widget.page = index);
        switch (widget.page) {
          case 0:
            route = HomeView.route;
            break;
          case 1:
            route = BuyerView.route;
            break;
          case 2:
            route = SellerView.route;
            break;
          case 3:
            route = ProfileView.route.replaceAll(
              ':id',
              context.read<DealerAuthProvider>().currentUser!.uid,
            );
            break;
        }

        // Push and redirect to the view.
        context.push(route);
      },
      tabBuilder: (int i, bool active) {
        return Icon(
          icons[i],
          size: 20,
          color: active ? colors[i] : Color(SariTheme.neutralPalette.get(80)),
        );
      },
    );
  }
}
