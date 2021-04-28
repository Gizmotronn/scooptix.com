import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../UI/event_overview/event_top_nav.dart';
import '../../UI/theme.dart';
import '../../UI/widgets/backgrounds/events_details_background.dart';
import '../error_page.dart';
import '../events_overview/bloc/events_overview_bloc.dart';
import 'sections/event_details.dart';
import 'sections/event_nav_bar.dart';

class EventDetailPage extends StatefulWidget {
  static const String routeName = '/event';
  final String id;
  static ValueNotifier<Widget> fab = ValueNotifier<Widget>(null);

  const EventDetailPage({Key key, this.id}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> with TickerProviderStateMixin {
  EventsOverviewBloc bloc;

  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    bloc = EventsOverviewBloc();
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    MyTheme.maxWidth = screenSize.width < 1050 ? screenSize.width : 1050;
    MyTheme.cardPadding = getValueForScreenType(context: context, watch: 8, mobile: 8, tablet: 20, desktop: 20);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ValueListenableBuilder(
          valueListenable: EventDetailPage.fab,
          builder: (context, value, child) {
            if (value != null) {
              return Padding(padding: EdgeInsets.only(bottom: 54), child: value);
            } else {
              return SizedBox.shrink();
            }
          }),
      body: UpdateEventDetail(
        init: () {
          bloc.add(LoadEventDetailEvent(widget.id));
        },
        child: BlocBuilder<EventsOverviewBloc, EventsOverviewState>(
          cubit: bloc,
          builder: (context, state) {
            if (state is ErrorEventDetailState) {
              return ErrorPage(state.message);
            }
            if (state is EventDetailState) {
              return Stack(
                children: [
                  EventDetailBackground(coverImageURL: state.event.coverImageURL),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding:
                          EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width - MyTheme.maxWidth) / 2),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: EventDetailInfo(
                          event: state.event,
                          organizer: state.organizer,
                          scrollController: _scrollController,
                          bloc: bloc,
                        ),
                      ),
                    ),
                  ),
                  EventDetailNavbar(event: state.event),
                  EventOverviewAppbar(color: MyTheme.appolloBackgroundColor),
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class UpdateEventDetail extends StatefulWidget {
  final Function init;
  final Widget child;

  const UpdateEventDetail({Key key, this.init, this.child}) : super(key: key);
  @override
  _UpdateEventDetailState createState() => _UpdateEventDetailState();
}

class _UpdateEventDetailState extends State<UpdateEventDetail> {
  @override
  void initState() {
    if (mounted) {
      widget.init();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
