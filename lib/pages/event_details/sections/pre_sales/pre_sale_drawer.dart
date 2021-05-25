import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/event_details/sections/pre_sales/pre_sale_page.dart';
import '../../../../main.dart';
import 'bloc/pre_sale_bloc.dart';

class PreSaleDrawer extends StatefulWidget {
  final PreSaleBloc bloc;
  final Event event;

  const PreSaleDrawer({Key key, this.bloc, @required this.event}) : super(key: key);

  @override
  _PreSaleDrawerState createState() => _PreSaleDrawerState();
}

class _PreSaleDrawerState extends State<PreSaleDrawer> {
  PreSaleBloc bloc;

  @override
  void initState() {
    if (widget.bloc == null) {
      bloc = PreSaleBloc();
      bloc.add(EventCheckStatus(widget.event));
    } else {
      bloc = widget.bloc;
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.bloc == null) {
      bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Container(
      width: MyTheme.drawerSize,
      height: screenSize.height,
      decoration: ShapeDecoration(
          color: MyTheme.appolloBackgroundColorLight,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Navigator.pop(WrapperPage.mainScaffold.currentContext);
              },
              child: Icon(
                Icons.close,
                size: 34,
                color: MyTheme.appolloRed,
              ),
            ),
          ).paddingTop(8),
          Expanded(
            child: PreSalePage(
              bloc: bloc,
              event: widget.event,
            ).paddingHorizontal(MyTheme.elementSpacing),
          ),
        ],
      ),
    );
  }
}
