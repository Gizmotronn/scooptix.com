import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/event_overview/event_overview_bottom_info.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/cards/event_card.dart';
import 'package:ticketapp/UI/widgets/icons/svgicon.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/utilities/images/images.dart';
import 'package:ticketapp/utilities/svg/icon.dart';

class MoreEventsFliterMapPage extends StatelessWidget {
  const MoreEventsFliterMapPage({
    Key key,
    this.events,
  }) : super(key: key);
  final List<Event> events;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: kToolbarHeight + 20),
          Container(
            width: screenSize.width,
            color: MyTheme.appolloWhite,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFliters(),
                _buildEvents(),
                _buildMap(context),
              ],
            ),
          ),
          EventOverviewFooter(),
        ],
      ),
    );
  }

  Widget _buildFliters() => SizedBox(
        width: 300,
        child: EventSearchFliter(),
      );

  Widget _buildEvents() => Container(
        child: Column(
          children: List.generate(events.length, (index) {
            return EventCard2(
              event: events[index],
            );
          }),
        ),
      );

  Widget _buildMap(context) => SizedBox(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(AppolloImages.map),
          )),
        ),
      );

  _buildEventSearch() => SizedBox(child: MoreEventSearch());
}

class EventSearchFliter extends StatelessWidget {
  const EventSearchFliter({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          'Fliters',
          style: Theme.of(context).textTheme.caption.copyWith(fontSize: 16, color: MyTheme.appolloGrey),
        ).paddingBottom(16),
        _buildLocation(context),
        _buildPriceRange(context),
        _buildDateRange(context),
        _buildEventType(context),
        _buildEventCategory(context),
      ],
    ).paddingAll(16);
  }

  Widget _buildLocation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textFieldTitle(context, 'Location'),
        FliterTextField(
          title: 'Perth, Australie',
          prefixIcon: SvgIcon(
            AppolloSvgIcon.perthGps,
            size: 16,
            color: MyTheme.appolloGrey,
          ),
        ).paddingBottom(16),
      ],
    );
  }

  Widget _buildDateRange(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textFieldTitle(context, 'Date Range'),
        Row(
          children: [
            Expanded(
                child: FliterTextField(
              title: 'From',
              suffixIcon: SvgIcon(
                AppolloSvgIcon.calenderOutline,
                size: 16,
                color: MyTheme.appolloGrey,
              ),
            ).paddingRight(8)),
            Expanded(
                child: FliterTextField(
                    title: 'To',
                    suffixIcon: SvgIcon(
                      AppolloSvgIcon.calenderOutline,
                      size: 16,
                      color: MyTheme.appolloGrey,
                    )).paddingLeft(8)),
          ],
        ).paddingBottom(16),
      ],
    );
  }

  Widget _buildPriceRange(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textFieldTitle(context, 'Price Range'),
        Row(
          children: [
            Expanded(child: FliterTextField(title: 'From(\$)').paddingRight(18)),
            Container(height: 1.1, width: 5, color: MyTheme.appolloGrey),
            Expanded(child: FliterTextField(title: 'To(\$)').paddingLeft(18)),
          ],
        ).paddingBottom(16),
      ],
    );
  }

  Widget _textFieldTitle(BuildContext context, String title) {
    return AutoSizeText(title,
            style:
                Theme.of(context).textTheme.caption.copyWith(color: MyTheme.appolloBlack, fontWeight: FontWeight.w500))
        .paddingBottom(12);
  }

  Widget _buildEventType(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textFieldTitle(context, 'Type'),
          Container(
            height: 40,
            decoration: BoxDecoration(color: MyTheme.appolloGrey.withAlpha(40), borderRadius: BorderRadius.circular(4)),
            child: DropdownButton(
              isExpanded: true,
              hint: AutoSizeText('Select',
                  style: Theme.of(context).textTheme.caption.copyWith(color: MyTheme.appolloGrey, fontSize: 14)),
              onChanged: (v) {},
              items: [
                DropdownMenuItem(child: Text('Type'), value: 'Type'),
              ],
              underline: Container(),
            ).paddingHorizontal(8),
          )
        ],
      ).paddingBottom(16);

  Widget _buildEventCategory(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textFieldTitle(context, 'Category'),
          Container(
            height: 40,
            decoration: BoxDecoration(color: MyTheme.appolloGrey.withAlpha(40), borderRadius: BorderRadius.circular(4)),
            child: DropdownButton(
              isExpanded: true,
              hint: AutoSizeText('Select',
                  style: Theme.of(context).textTheme.caption.copyWith(color: MyTheme.appolloGrey, fontSize: 14)),
              onChanged: (v) {},
              items: [
                DropdownMenuItem(child: Text('Category1'), value: 'Category1'),
              ],
              underline: Container(),
            ).paddingHorizontal(8),
          )
        ],
      );
}

class FliterTextField extends StatelessWidget {
  final String title;
  final Widget prefixIcon;
  final Widget suffixIcon;

  const FliterTextField({Key key, this.title, this.prefixIcon, this.suffixIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        decoration: InputDecoration(
          fillColor: MyTheme.appolloGrey.withAlpha(40),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          hintText: title,
          hintStyle: Theme.of(context).textTheme.caption.copyWith(color: MyTheme.appolloGrey, fontSize: 14),
        ),
      ),
    );
  }
}

class MoreEventSearch extends StatelessWidget {
  const MoreEventSearch({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          height: 30,
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: MyTheme.appolloWhite.withOpacity(.4),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(4)),
              color: MyTheme.appolloWhite.withOpacity(.5)),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(height: 22, child: SvgIcon(AppolloSvgIcon.searchOutline, color: MyTheme.appolloBlack)),
                  Container(
                    child: Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.only(bottom: 14, left: 12),
                          focusedBorder: InputBorder.none,
                          hintText: 'Search Events',
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ).paddingBottom(8),
                    ),
                  ),
                ],
              ).paddingHorizontal(4),
            ],
          ),
        ),
      ),
    );
  }
}
