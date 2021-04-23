import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:ticketapp/UI/event_details/widget/event_details.dart';
import 'package:ticketapp/UI/event_details/widget/event_nav_bar.dart';

import '../../UI/event_overview/event_top_nav.dart';
import '../../UI/theme.dart';
import '../../UI/widgets/backgrounds/events_details_background.dart';
import '../authentication/bloc/authentication_bloc.dart';
import '../error_page.dart';
import '../events_overview/bloc/events_overview_bloc.dart';

class EventDetailPage extends StatefulWidget {
  static const String routeName = '/event';
  final String id;

  const EventDetailPage({Key key, this.id}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> with TickerProviderStateMixin {
  AuthenticationBloc signUpBloc;
  EventsOverviewBloc bloc;

  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    bloc = EventsOverviewBloc();
    signUpBloc = AuthenticationBloc();
    signUpBloc.add(EventPageLoad());
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    signUpBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    MyTheme.maxWidth = screenSize.width < 1050 ? screenSize.width : 1050;
    MyTheme.cardPadding = getValueForScreenType(context: context, watch: 8, mobile: 8, tablet: 20, desktop: 20);

    return Scaffold(
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
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: MyTheme.maxWidth,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: EventDetailInfo(
                          event: state.event,
                          organizer: state.organizer,
                          scrollController: _scrollController,
                        ),
                      ),
                    ),
                  ),
                  EventDetailNavbar(event: state.event),
                  EventOverviewAppbar(bloc: signUpBloc, color: MyTheme.appolloBackgroundColor),
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
