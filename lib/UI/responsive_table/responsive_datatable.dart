import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import 'datatable_header.dart';

class ResponsiveDatatable extends StatefulWidget {
  final bool showSelect;
  final List<DatatableHeader> headers;
  final List<Map<String, dynamic>> source;
  final List<Map<String, dynamic>>? selecteds;
  final Widget? title;
  final List<Widget>? actions;
  final List<Widget>? footers;
  final Function(bool value)? onSelectAll;
  final Function(bool value, Map<String, dynamic> data)? onSelect;
  final Function(dynamic value)? onTabRow;
  final Function(dynamic value)? onSort;
  final String? sortColumn;
  final bool sortAscending;
  final bool isLoading;
  final bool autoHeight;
  final bool hideUnderline;
  final Decoration? headerDecoration;
  final Decoration? listDecoration;
  final EdgeInsets itemPadding;
  final EdgeInsets headerPadding;
  final bool useDesktopView;

  /// Space between rows
  final double? itemPaddingVertical;

  const ResponsiveDatatable(
      {Key? key,
      this.showSelect: false,
      this.onSelectAll,
      this.onSelect,
      this.onTabRow,
      this.onSort,
      required this.headers,
      required this.source,
      this.selecteds,
      this.title,
      this.actions,
      this.footers,
      this.sortColumn,
      this.sortAscending = true,
      this.isLoading: false,
      this.autoHeight: true,
      this.hideUnderline: true,
      this.headerDecoration,
      this.listDecoration,
      this.itemPadding = const EdgeInsets.all(0),
      this.itemPaddingVertical,
      this.headerPadding = const EdgeInsets.all(0),
      this.useDesktopView = false})
      : super(key: key);

  @override
  _ResponsiveDatatableState createState() => _ResponsiveDatatableState();
}

class _ResponsiveDatatableState extends State<ResponsiveDatatable> {
  Widget mobileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Checkbox(
            value: widget.selecteds!.length == widget.source.length && widget.source.length > 0,
            onChanged: (value) {
              if (widget.onSelectAll != null) widget.onSelectAll!(value!);
            }),
        PopupMenuButton(
            child: Container(
              padding: EdgeInsets.all(15),
              child: Text("SORT BY"),
            ),
            tooltip: "SORT BY",
            initialValue: widget.sortColumn,
            itemBuilder: (_) => widget.headers
                .where((header) => header.show == true && header.sortable == true)
                .toList()
                .map((header) => PopupMenuItem(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "${header.text}",
                            textAlign: header.textAlign,
                          ),
                          if (widget.sortColumn != null && widget.sortColumn == header.value)
                            widget.sortAscending
                                ? Icon(Icons.arrow_downward, size: 15)
                                : Icon(Icons.arrow_upward, size: 15)
                        ],
                      ),
                      value: header.value,
                    ))
                .toList(),
            onSelected: (value) {
              if (widget.onSort != null) widget.onSort!(value);
            })
      ],
    );
  }

  List<Widget> mobileList() {
    return widget.source.map((data) {
      return InkWell(
        onTap: widget.onTabRow != null
            ? () {
                widget.onTabRow!(data);
              }
            : null,
        child: Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  if (widget.showSelect && widget.selecteds != null)
                    Checkbox(
                        value: widget.selecteds!.indexOf(data) >= 0,
                        onChanged: (value) {
                          if (widget.onSelect != null) widget.onSelect!(value!, data);
                        }),
                ],
              ),
              ...widget.headers
                  .where((header) => header.show == true)
                  .toList()
                  .map(
                    (header) => Container(
                      padding: EdgeInsets.all(11),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          header.headerBuilder != null
                              ? header.headerBuilder!(header.value)
                              : Text(
                                  "${header.text}",
                                  overflow: TextOverflow.clip,
                                ),
                          Spacer(),
                          header.sourceBuilder != null
                              ? header.sourceBuilder!(data[header.value], data)
                              : header.editable
                                  ? editAbleWidget(
                                      data: data,
                                      header: header,
                                      textAlign: TextAlign.end,
                                    )
                                  : Text("${data[header.value]}")
                        ],
                      ),
                    ),
                  )
                  .toList()
            ],
          ),
        ),
      );
    }).toList();
  }

  Alignment headerAlignSwitch(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  Widget desktopHeader() {
    return Container(
      decoration: widget.headerDecoration ??
          BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showSelect && widget.selecteds != null)
            Checkbox(
                value: widget.selecteds!.length == widget.source.length && widget.source.length > 0,
                onChanged: (value) {
                  if (widget.onSelectAll != null) widget.onSelectAll!(value!);
                }),
          ...widget.headers
              .where((header) => header.show == true)
              .map(
                (header) => Expanded(
                    flex: header.flex ?? 1,
                    child: InkWell(
                      onTap: () {
                        if (widget.onSort != null && header.sortable) widget.onSort!(header.value);
                      },
                      child: header.headerBuilder != null
                          ? header.headerBuilder!(header.value)
                          : Container(
                              padding: widget.headerPadding,
                              alignment: headerAlignSwitch(header.textAlign),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  AutoSizeText(
                                    "${header.text}",
                                    maxLines: 1,
                                    style: MyTheme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w600),
                                    textAlign: header.textAlign,
                                  ),
                                  if (widget.sortColumn != null && widget.sortColumn == header.value)
                                    widget.sortAscending
                                        ? Icon(Icons.arrow_downward, size: 15)
                                        : Icon(Icons.arrow_upward, size: 15)
                                ],
                              ),
                            ),
                    )),
              )
              .toList()
        ],
      ),
    );
  }

  List<Widget> desktopList() {
    List<Widget> widgets = [];
    for (var index = 0; index < widget.source.length; index++) {
      final data = widget.source[index];
      widgets.add(Padding(
        padding: widget.itemPadding,
        child: Center(
          child: InkWell(
            onTap: widget.onTabRow != null
                ? () {
                    widget.onTabRow!(data);
                  }
                : null,
            child: Container(
                decoration: widget.listDecoration ??
                    BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showSelect && widget.selecteds != null)
                      Checkbox(
                          value: widget.selecteds!.indexOf(data) >= 0,
                          onChanged: (value) {
                            if (widget.onSelect != null) widget.onSelect!(value!, data);
                          }),
                    ...widget.headers
                        .where((header) => header.show == true)
                        .map(
                          (header) => Expanded(
                            flex: header.flex ?? 1,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: widget.itemPaddingVertical ?? 20, horizontal: 20),
                              child: header.sourceBuilder != null
                                  ? header.sourceBuilder!(data[header.value], data)
                                  : header.editable
                                      ? editAbleWidget(
                                          data: data,
                                          header: header,
                                          textAlign: header.textAlign,
                                        )
                                      : Container(
                                          child: Text(
                                            "${data[header.value]}",
                                            style: MyTheme.textTheme.bodyText2,
                                            textAlign: header.textAlign,
                                          ),
                                        ),
                            ),
                          ),
                        )
                        .toList()
                  ],
                )),
          ),
        ),
      ));
    }
    return widgets;
  }

  Widget editAbleWidget({
    required Map<String, dynamic> data,
    required DatatableHeader header,
    TextAlign textAlign: TextAlign.center,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: 150),
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.all(0),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          border: this.widget.hideUnderline ? InputBorder.none : UnderlineInputBorder(borderSide: BorderSide(width: 1)),
          alignLabelWithHint: true,
        ),
        textAlign: textAlign,
        controller: TextEditingController.fromValue(
          TextEditingValue(text: "${data[header.value]}"),
        ),
        onChanged: (newValue) => data[header.value!] = newValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width < 600 && !widget.useDesktopView
        ?
        /**
         * for small screen
         */
        Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //title and actions
                if (widget.title != null || widget.actions != null)
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.title != null) widget.title!,
                        if (widget.actions != null) ...widget.actions!
                      ],
                    ),
                  ),

                if (widget.autoHeight)
                  Column(
                    children: [
                      if (widget.showSelect && widget.selecteds != null) mobileHeader(),
                      if (widget.isLoading) LinearProgressIndicator(),
                      //mobileList
                      ...mobileList(),
                    ],
                  ),
                if (!widget.autoHeight)
                  Expanded(
                    child: Container(
                      child: ListView(
                        // itemCount: source.length,
                        children: [
                          if (widget.showSelect && widget.selecteds != null) mobileHeader(),
                          if (widget.isLoading) LinearProgressIndicator(),
                          //mobileList
                          ...mobileList(),
                        ],
                      ),
                    ),
                  ),
                //footer
                if (widget.footers != null)
                  Container(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [...widget.footers!],
                    ),
                  )
              ],
            ),
          )
        /**
          * for large screen
          */
        : Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //title and actions
                if (widget.title != null || widget.actions != null)
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.title != null) widget.title!,
                        if (widget.actions != null) ...widget.actions!
                      ],
                    ),
                  ),

                //desktopHeader
                if (widget.headers.isNotEmpty) desktopHeader(),

                if (widget.isLoading) LinearProgressIndicator(),

                if (widget.autoHeight) Flexible(fit: FlexFit.loose, child: Column(children: desktopList())),

                if (!widget.autoHeight)
                  // desktopList
                  if (widget.source.isNotEmpty) Expanded(child: ListView(children: desktopList())),

                //footer
                if (widget.footers != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [...widget.footers!],
                  )
              ],
            ),
          );
  }
}
