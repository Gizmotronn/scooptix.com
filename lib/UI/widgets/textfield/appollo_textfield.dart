import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

enum AppolloTextfieldState { initial, hover, typing, filled, diabled, error }

class AppolloTextfield extends StatefulWidget {
  final TextEditingController controller;

  final String labelText;

  final String errorText;

  const AppolloTextfield({Key key, this.controller, this.labelText, this.errorText = ''}) : super(key: key);
  @override
  _AppolloTextfieldState createState() => _AppolloTextfieldState();
}

class _AppolloTextfieldState extends State<AppolloTextfield> {
  AppolloTextfieldState textFieldState = AppolloTextfieldState.initial;
  String _text = '';

  FocusNode _focusNode;
  @override
  void initState() {
    if (widget.errorText.isNotEmpty) {
      textFieldState = AppolloTextfieldState.error;
    }
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() {
          if (_focusNode.hasFocus) {
            if (widget.errorText.isNotEmpty) {
              textFieldState = AppolloTextfieldState.error;
            } else {
              textFieldState = AppolloTextfieldState.typing;
            }
          } else if (_text.isNotEmpty) {
            if (widget.errorText.isNotEmpty) {
              textFieldState = AppolloTextfieldState.error;
            } else {
              textFieldState = AppolloTextfieldState.filled;
            }
          } else if (widget.errorText.isNotEmpty) {
            textFieldState = AppolloTextfieldState.error;
          } else {
            textFieldState = AppolloTextfieldState.initial;
          }
        });
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (isHover) {
        if (widget.errorText.isNotEmpty) {
          setState(() {
            textFieldState = AppolloTextfieldState.error;
          });
        } else if (_text.isEmpty) {
          setState(() {
            textFieldState = AppolloTextfieldState.hover;
          });
        }
      },
      onExit: (v) {
        if (widget.errorText.isNotEmpty) {
          setState(() {
            textFieldState = AppolloTextfieldState.error;
          });
        } else if (_text.isEmpty) {
          setState(() {
            if (_focusNode.hasFocus) {
              textFieldState = AppolloTextfieldState.typing;
            } else {
              textFieldState = AppolloTextfieldState.initial;
            }
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: MyTheme.animationDuration,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: textFieldState == AppolloTextfieldState.hover ||
                      textFieldState == AppolloTextfieldState.typing ||
                      textFieldState == AppolloTextfieldState.error
                  ? MyTheme.appolloBackgroundColor
                  : MyTheme.appolloTextFieldColor,
              border: Border.all(
                width: 0.8,
                color: _buildOutlineColor(),
              ),
            ),
            child: Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _text = v),
                controller: widget.controller,
                focusNode: _focusNode,
                style: Theme.of(context).textTheme.button,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.only(left: 8),
                  errorBorder: InputBorder.none,
                  errorStyle: Theme.of(context).textTheme.caption.copyWith(color: MyTheme.appolloRed),
                  focusedBorder: InputBorder.none,
                  hintStyle: Theme.of(context).textTheme.button.copyWith(
                      color:
                          textFieldState == AppolloTextfieldState.initial ? MyTheme.appolloGrey : MyTheme.appolloWhite),
                  enabledBorder: InputBorder.none,
                  labelText: widget.labelText,
                  labelStyle: Theme.of(context).textTheme.button.copyWith(color: _buildLabelColor()),
                  disabledBorder: InputBorder.none,
                ),
              ),
            ).paddingAll(4),
          ),
          widget.errorText.isEmpty
              ? SizedBox()
              : AutoSizeText(widget.errorText,
                  style: Theme.of(context).textTheme.caption.copyWith(color: MyTheme.appolloRed, fontSize: 6)),
        ],
      ),
    );
  }

  Color _buildLabelColor() {
    if (textFieldState == AppolloTextfieldState.filled) {
      return MyTheme.appolloGreen;
    } else if (textFieldState == AppolloTextfieldState.error) {
      return MyTheme.appolloRed;
    } else if (textFieldState == AppolloTextfieldState.initial) {
      return MyTheme.appolloGrey;
    }
    return MyTheme.appolloWhite;
  }

  Color _buildOutlineColor() {
    if (textFieldState == AppolloTextfieldState.hover || textFieldState == AppolloTextfieldState.typing) {
      return MyTheme.appolloWhite;
    } else if (textFieldState == AppolloTextfieldState.error) {
      return MyTheme.appolloRed;
    } else if (textFieldState == AppolloTextfieldState.filled) {
      return MyTheme.appolloGreen;
    } else {
      return Colors.transparent;
    }
  }
}
