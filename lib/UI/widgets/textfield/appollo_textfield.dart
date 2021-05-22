import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../theme.dart';

enum AppolloTextfieldState { initial, hover, typing, filled, diabled, error }
enum TextFieldType { reactive, regular }

class AppolloTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String errorText;
  final TextFieldType textfieldType;
  final TextInputType keyboardType;
  final Map<String, String> Function(AbstractControl<dynamic>) validationMessages;
  final List<TextInputFormatter> inputFormatters;
  final String formControlName;
  final FocusNode focusNode;
  final Function onChanged;

  final List<String> autofillHints;

  final bool autofocus;

  final Function(String) onFieldSubmitted;

  final Function(String) validator;

  final Widget suffixIcon;

  final AutovalidateMode autovalidateMode;

  final bool obscureText;

  const AppolloTextfield(
      {Key key,
      this.controller,
      @required this.labelText,
      this.errorText = '',
      @required this.textfieldType,
      this.keyboardType,
      this.validationMessages,
      this.inputFormatters,
      this.formControlName,
      this.autofillHints,
      this.autofocus,
      this.onFieldSubmitted,
      this.validator,
      this.suffixIcon,
      this.autovalidateMode,
      this.obscureText,
      this.focusNode,
      this.onChanged,
      this.hintText})
      : super(key: key);
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

    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
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
            height: 48,
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
            child: Builder(builder: (context) {
              if (widget.textfieldType == TextFieldType.reactive) {
                return ReactiveTextField(
                  formControlName: widget.formControlName,
                  keyboardType: widget.keyboardType,
                  validationMessages: widget.validationMessages,
                  inputFormatters: widget.inputFormatters,
                  focusNode: _focusNode,
                  style: Theme.of(context).textTheme.bodyText1,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: widget.hintText,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.only(left: 8),
                    errorBorder: InputBorder.none,
                    errorStyle: Theme.of(context).textTheme.caption.copyWith(color: MyTheme.appolloRed),
                    focusedBorder: InputBorder.none,
                    hintStyle: Theme.of(context).textTheme.button.copyWith(
                        color: textFieldState == AppolloTextfieldState.initial
                            ? MyTheme.appolloGrey
                            : MyTheme.appolloWhite),
                    enabledBorder: InputBorder.none,
                    labelText: widget.labelText,
                    labelStyle: Theme.of(context).textTheme.bodyText1.copyWith(color: _buildLabelColor()),
                    disabledBorder: InputBorder.none,
                  ),
                );
              }
              return TextFormField(
                autofillHints: widget.autofillHints,
                autofocus: widget.autofocus ?? false,
                onFieldSubmitted: widget.onFieldSubmitted,
                autovalidateMode: widget.autovalidateMode,
                validator: widget.validator,
                obscureText: widget.obscureText ?? false,
                onChanged: (v) {
                  if (widget.onChanged != null) {
                    widget.onChanged(v);
                  }
                  setState(() => _text = v);
                },
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                focusNode: _focusNode,
                inputFormatters: widget.inputFormatters,
                style: MyTheme.textTheme.bodyText1,
                decoration: InputDecoration(
                  filled: true,
                  hintText: widget.hintText,
                  suffix: widget.suffixIcon,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.only(left: 8, bottom: 4),
                  errorBorder: InputBorder.none,
                  errorStyle: MyTheme.textTheme.caption.copyWith(color: MyTheme.appolloRed),
                  focusedBorder: InputBorder.none,
                  hintStyle: MyTheme.textTheme.button.copyWith(
                      color:
                          textFieldState == AppolloTextfieldState.initial ? MyTheme.appolloGrey : MyTheme.appolloWhite),
                  enabledBorder: InputBorder.none,
                  labelText: widget.labelText,
                  labelStyle: MyTheme.textTheme.bodyText1.copyWith(color: _buildLabelColor()),
                  disabledBorder: InputBorder.none,
                ),
              );
            }).paddingAll(4),
          ),
          widget.errorText.isEmpty
              ? SizedBox()
              : AutoSizeText(widget.errorText,
                  style: MyTheme.textTheme.caption.copyWith(color: MyTheme.appolloRed, fontSize: 6)),
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
