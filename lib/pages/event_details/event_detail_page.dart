import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/model/organizer.dart';
import 'package:ticketapp/pages/event_details/mobile_view.dart';

import '../../UI/event_overview/event_top_nav.dart';
import '../../UI/theme.dart';
import '../../UI/widgets/backgrounds/events_details_background.dart';
import '../error_page.dart';
import '../events_overview/bloc/events_overview_bloc.dart';
import 'sections/event_details.dart';

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
    bloc.add(LoadEventDetailEvent(widget.id));
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
      body: BlocBuilder<EventsOverviewBloc, EventsOverviewState>(
        cubit: bloc,
        builder: (context, state) {
          if (state is ErrorEventDetailState) {
            return ErrorPage(state.message);
          }
          if (state is EventDetailState) {
            return ResponsiveBuilder(
              builder: (context, SizingInformation size) {
                if (size.isTablet || size.isDesktop) {
                  return EventPageDesktopView(
                    scrollController: _scrollController,
                    bloc: bloc,
                    event: state.event,
                    organizer: state.organizer,
                  );
                } else {
                  return EventDetailsMobilePage(
                    event: state.event,
                    organizer: state.organizer,
                    scrollController: _scrollController,
                    bloc: bloc,
                  );
                }
              },
            );
          }
          return Center(child: AppolloProgressIndicator());
        },
      ),
    );
  }
}

class EventPageDesktopView extends StatelessWidget {
  const EventPageDesktopView({
    Key key,
    @required ScrollController scrollController,
    @required this.bloc,
    @required this.event,
    @required this.organizer,
  })  : _scrollController = scrollController,
        super(key: key);

  final ScrollController _scrollController;
  final EventsOverviewBloc bloc;
  final Event event;
  final Organizer organizer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        EventDetailBackground(coverImageURL: event.coverImageURL),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Align(
            alignment: Alignment.topCenter,
            child: EventData(
              event: event,
              organizer: organizer,
              scrollController: _scrollController,
              bloc: bloc,
            ),
          ),
        ),
        EventOverviewAppbar(color: MyTheme.appolloBackgroundColor),
      ],
    );
  }
}
