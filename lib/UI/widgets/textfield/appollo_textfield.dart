import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../theme.dart';

enum AppolloTextFieldState { initial, hover, typing, filled, disabled, error }
enum TextFieldType { reactive, regular }

class AppolloTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String errorText;
  final TextFieldType textFieldType;
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

  const AppolloTextField(
      {Key key,
      this.controller,
      @required this.labelText,
      this.errorText = '',
      @required this.textFieldType,
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
      this.obscureText = false,
      this.focusNode,
      this.onChanged,
      this.hintText})
      : super(key: key);
  @override
  _AppolloTextFieldState createState() => _AppolloTextFieldState();
}

class _AppolloTextFieldState extends State<AppolloTextField> {
  AppolloTextFieldState textFieldState = AppolloTextFieldState.initial;
  String _text = '';

  FocusNode _focusNode;
  @override
  void initState() {
    if (widget.errorText.isNotEmpty) {
      textFieldState = AppolloTextFieldState.error;
    }

    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {
        if (_focusNode.hasFocus) {
          if (textFieldState != AppolloTextFieldState.error) {
            textFieldState = AppolloTextFieldState.typing;
          }
        } else {
          if (textFieldState != AppolloTextFieldState.error) {
            textFieldState = AppolloTextFieldState.initial;
          }
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (isHover) {
        if (textFieldState != AppolloTextFieldState.error) {
          setState(() {
            textFieldState = AppolloTextFieldState.hover;
          });
        }
      },
      onExit: (v) {
        if (textFieldState != AppolloTextFieldState.error) {
          if (_text.isEmpty) {
            setState(() {
              if (_focusNode.hasFocus) {
                textFieldState = AppolloTextFieldState.typing;
              } else {
                textFieldState = AppolloTextFieldState.initial;
              }
            });
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: MyTheme.animationDuration,
            height: textFieldState == AppolloTextFieldState.error ? 64 : 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: textFieldState == AppolloTextFieldState.hover ||
                      textFieldState == AppolloTextFieldState.typing ||
                      textFieldState == AppolloTextFieldState.error
                  ? MyTheme.appolloBackgroundColor
                  : MyTheme.appolloTextFieldColor,
              border: Border.all(
                width: 0.8,
                color: _buildOutlineColor(),
              ),
            ),
            child: Builder(builder: (context) {
              if (widget.textFieldType == TextFieldType.reactive) {
                return ReactiveTextField(
                  formControlName: widget.formControlName,
                  keyboardType: widget.keyboardType,
                  validationMessages: widget.validationMessages,
                  inputFormatters: widget.inputFormatters,
                  focusNode: _focusNode,
                  onSubmitted: () {
                    if (widget.onFieldSubmitted != null) {
                      widget.onFieldSubmitted("");
                    }
                  },
                  showErrors: (control) {
                    if (control.invalid && control.touched) {
                      Future.delayed(Duration(milliseconds: 1)).then((value) {
                        setState(() {
                          textFieldState = AppolloTextFieldState.error;
                        });
                      });
                      return true;
                    } else {
                      Future.delayed(Duration(milliseconds: 1)).then((value) {
                        setState(() {
                          textFieldState = AppolloTextFieldState.typing;
                        });
                      });
                      return false;
                    }
                  },
                  obscureText: widget.obscureText,
                  style: MyTheme.textTheme.bodyText1,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: widget.hintText,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.only(left: 8),
                    errorBorder: InputBorder.none,
                    errorStyle: MyTheme.textTheme.caption.copyWith(color: MyTheme.appolloRed),
                    focusedBorder: InputBorder.none,
                    hintStyle: MyTheme.textTheme.button.copyWith(
                        color: textFieldState == AppolloTextFieldState.initial
                            ? MyTheme.appolloGrey
                            : MyTheme.appolloWhite),
                    enabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    labelText: widget.labelText,
                    labelStyle: MyTheme.textTheme.bodyText1.copyWith(color: _buildLabelColor()),
                    disabledBorder: InputBorder.none,
                  ),
                );
              }
              return TextFormField(
                autofillHints: widget.autofillHints,
                autofocus: widget.autofocus ?? false,
                onFieldSubmitted: (v) {
                  if (widget.onFieldSubmitted != null) {
                    widget.onFieldSubmitted(v);
                  }
                  if (widget.validator != null) {
                    if (widget.validator(v) != null) {
                      setState(() {
                        textFieldState = AppolloTextFieldState.error;
                      });
                    }
                  }
                },
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
                          textFieldState == AppolloTextFieldState.initial ? MyTheme.appolloGrey : MyTheme.appolloWhite),
                  enabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  labelText: widget.labelText,
                  labelStyle: MyTheme.textTheme.bodyText1.copyWith(color: _buildLabelColor()),
                  disabledBorder: InputBorder.none,
                ),
              );
            }).paddingAll(4),
          ),
        ],
      ),
    );
  }

  Color _buildLabelColor() {
    if (textFieldState == AppolloTextFieldState.filled) {
      return MyTheme.appolloGreen;
    } else if (textFieldState == AppolloTextFieldState.error) {
      return MyTheme.appolloRed;
    } else if (textFieldState == AppolloTextFieldState.initial) {
      return MyTheme.appolloGrey;
    }
    return MyTheme.appolloWhite;
  }

  Color _buildOutlineColor() {
    if (textFieldState == AppolloTextFieldState.hover || textFieldState == AppolloTextFieldState.typing) {
      return MyTheme.appolloWhite;
    } else if (textFieldState == AppolloTextFieldState.error) {
      return MyTheme.appolloRed;
    } else if (textFieldState == AppolloTextFieldState.filled) {
      return MyTheme.appolloGreen;
    } else {
      return Colors.transparent;
    }
  }
}
