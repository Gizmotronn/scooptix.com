import "dart:async";
import 'package:flutter/material.dart';
import 'package:ticketapp/UI/theme.dart';
import 'package:ticketapp/UI/widgets/appollo/appollo_progress_indicator.dart';
import 'package:ticketapp/model/event.dart';
import 'package:ticketapp/pages/order_summary/bloc/ticket_bloc.dart';

enum DiscountTextfieldState { initial, hover, typing, filled, invalid, applied, loading, error }

class DiscountTextField extends StatefulWidget {
  const DiscountTextField({
    Key key,
    @required TextEditingController discountController,
    @required this.bloc,
    @required this.state,
    @required this.width,
    @required this.event,
  })  : _discountController = discountController,
        super(key: key);

  final TextEditingController _discountController;
  final TicketBloc bloc;
  final TicketState state;
  final Event event;
  final double width;

  @override
  _DiscountTextFieldState createState() => _DiscountTextFieldState();
}

class _DiscountTextFieldState extends State<DiscountTextField> {
  DiscountTextfieldState textFieldState = DiscountTextfieldState.initial;
  String _text = '';
  FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode()
      ..addListener(() {
        if (_focusNode.hasFocus) {
          if (textFieldState != DiscountTextfieldState.error) {
            setState(() => textFieldState = DiscountTextfieldState.typing);
          }
        } else {
          if (_text.isNotEmpty) {
            if (textFieldState != DiscountTextfieldState.error) {
              setState(() => textFieldState = DiscountTextfieldState.typing);
            }
          } else {
            setState(() => textFieldState = DiscountTextfieldState.initial);
          }
        }
      });

    super.initState();
  }

  Future<void> _changeAppliedErrorState(DiscountTextfieldState state) async {
    switch (state) {
      case DiscountTextfieldState.applied:
        setState(() => textFieldState = DiscountTextfieldState.applied);
        await Future.delayed(Duration(milliseconds: 2000));
        setState(() => textFieldState = DiscountTextfieldState.initial);
        break;
      case DiscountTextfieldState.invalid:
        setState(() => textFieldState = DiscountTextfieldState.invalid);
        await Future.delayed(Duration(milliseconds: 2000));
        setState(() => textFieldState = DiscountTextfieldState.error);
        break;
      default:
    }
  }

  void _listenToStateChanges() {
    Timer.periodic(Duration(milliseconds: 300), (timer) async {
      if (widget.state is StateDiscountApplied) {
        await _changeAppliedErrorState(DiscountTextfieldState.applied);
        timer.cancel();
      } else if (widget.state is StateDiscountCodeInvalid) {
        await _changeAppliedErrorState(DiscountTextfieldState.invalid);
        timer.cancel();
      } else if (widget.state is StateDiscountCodeLoading) {
        setState(() => textFieldState = DiscountTextfieldState.loading);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (isHover) {
        if (textFieldState != DiscountTextfieldState.applied && textFieldState != DiscountTextfieldState.invalid) {
          if (_focusNode.hasFocus) {
            if (textFieldState != DiscountTextfieldState.error) {
              setState(() => textFieldState = DiscountTextfieldState.typing);
            }
          } else if (_text.isEmpty) {
            if (textFieldState != DiscountTextfieldState.error) {
              setState(() => textFieldState = DiscountTextfieldState.hover);
            }
          }
        }
      },
      onExit: (v) {
        if (textFieldState != DiscountTextfieldState.applied &&
            textFieldState != DiscountTextfieldState.invalid &&
            textFieldState != DiscountTextfieldState.loading) {
          if (_focusNode.hasFocus) {
            if (textFieldState != DiscountTextfieldState.error) {
              setState(() => textFieldState = DiscountTextfieldState.typing);
            }
          } else if (_text.isEmpty) {
            if (textFieldState != DiscountTextfieldState.error) {
              setState(() => textFieldState = DiscountTextfieldState.initial);
            }
          }
        }
      },
      child: AnimatedContainer(
        duration: MyTheme.animationDuration,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: _buildInputLabelColor(),
          border: Border.all(
            width: 0.8,
            color: _buildOutlineColor(),
          ),
        ),
        child: SizedBox(
          height: 38,
          width: widget.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  focusNode: _focusNode,
                  onChanged: (v) => setState(() => _text = v),
                  decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                      labelText:
                          "Discount Code ${textFieldState == DiscountTextfieldState.applied ? "- " + _text.toUpperCase() : ''}",
                      labelStyle: Theme.of(context).textTheme.bodyText1,
                      isDense: true),
                  controller: textFieldState == DiscountTextfieldState.applied ||
                          textFieldState == DiscountTextfieldState.invalid
                      ? TextEditingController(
                          text: textFieldState == DiscountTextfieldState.applied ? 'CODE APPLIED' : 'INVALID CODE')
                      : widget._discountController,
                ).paddingRight(8),
              ),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        primary: _buildActionColor(),
                        backgroundColor: _buildActionColor(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                    onPressed: () {
                      if (widget._discountController.text != "") {
                        setState(() => textFieldState = DiscountTextfieldState.loading);
                        _listenToStateChanges();
                        widget.bloc.add(EventApplyDiscount(widget.event, widget._discountController.text));
                        widget._discountController.text = "";
                      }
                    },
                    child: _buildAction(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Color _buildOutlineColor() {
    if (textFieldState == DiscountTextfieldState.hover ||
        textFieldState == DiscountTextfieldState.loading ||
        textFieldState == DiscountTextfieldState.typing) {
      return MyTheme.appolloGreen;
    } else if (textFieldState == DiscountTextfieldState.error) {
      return MyTheme.appolloRed;
    } else if (textFieldState == DiscountTextfieldState.applied) {
      return MyTheme.appolloWhite;
    } else {
      return Colors.transparent;
    }
  }

  Widget _buildAction() {
    if (textFieldState == DiscountTextfieldState.loading) {
      return Transform.scale(
        scale: 0.5,
        child: AppolloButtonProgressIndicator(),
      );
    } else if (textFieldState == DiscountTextfieldState.applied || textFieldState == DiscountTextfieldState.invalid) {
      return Icon(Icons.close, color: MyTheme.appolloWhite, size: 18);
    } else if (textFieldState == DiscountTextfieldState.typing ||
        textFieldState == DiscountTextfieldState.error ||
        textFieldState == DiscountTextfieldState.filled) {
      return Icon(Icons.add, color: MyTheme.appolloWhite, size: 18);
    } else {
      return SizedBox.shrink();
    }
  }

  Color _buildActionColor() {
    if (textFieldState == DiscountTextfieldState.typing ||
        textFieldState == DiscountTextfieldState.loading ||
        textFieldState == DiscountTextfieldState.applied) {
      return MyTheme.appolloGreen;
    } else if (textFieldState == DiscountTextfieldState.error || textFieldState == DiscountTextfieldState.invalid) {
      return MyTheme.appolloRed;
    } else if (textFieldState == DiscountTextfieldState.loading) {
      return MyTheme.appolloGreen;
    } else {
      return MyTheme.appolloLightCardColor;
    }
  }

  Color _buildInputLabelColor() {
    if (textFieldState == DiscountTextfieldState.applied) {
      return MyTheme.appolloGreen;
    } else if (textFieldState == DiscountTextfieldState.invalid) {
      return MyTheme.appolloRed;
    } else if (textFieldState == DiscountTextfieldState.hover ||
        textFieldState == DiscountTextfieldState.initial ||
        textFieldState == DiscountTextfieldState.filled ||
        textFieldState == DiscountTextfieldState.loading ||
        textFieldState == DiscountTextfieldState.loading) {
      if (textFieldState == DiscountTextfieldState.applied) {
        return MyTheme.appolloGreen;
      } else if (textFieldState == DiscountTextfieldState.invalid) {
        return MyTheme.appolloRed;
      } else {
        return MyTheme.appolloLightCardColor;
      }
    } else {
      return MyTheme.appolloLightCardColor;
    }
  }
}
