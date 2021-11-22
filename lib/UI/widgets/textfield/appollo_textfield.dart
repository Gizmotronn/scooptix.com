import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../theme.dart';

enum AppolloTextFieldState { initial, hover, typing, filled, disabled, error }
enum TextFieldType { reactive, regular }

class AppolloTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String errorText;
  final TextFieldType? textFieldType;
  final TextInputType? keyboardType;
  final Map<String, String> Function(AbstractControl<dynamic>)? validationMessages;
  final List<TextInputFormatter>? inputFormatters;
  final FormControl? formControl;
  final FocusNode? focusNode;
  final Function? onChanged;
  final List<String>? autofillHints;
  final bool autofocus;
  final Function(String?)? onFieldSubmitted;
  final Function()? onFieldSubmittedReactive;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final AutovalidateMode? autovalidateMode;
  final bool obscureText;
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  final double? maxWidth;

  AppolloTextField._(
      {Key? key,
      this.controller,
      required this.labelText,
      this.errorText = '',
      required this.textFieldType,
      this.keyboardType,
      this.validationMessages,
      this.inputFormatters,
      this.formControl,
      this.autofillHints,
      this.autofocus = false,
      this.onFieldSubmitted,
      this.onFieldSubmittedReactive,
      this.validator,
      this.suffixIcon,
      this.autovalidateMode,
      this.obscureText = false,
      this.focusNode,
      this.onChanged,
      this.hintText,
      this.maxWidth})
      : super(key: key);

  factory AppolloTextField.reactive(
      {Key? key,
      required labelText,
      keyboardType,
      validationMessages,
      inputFormatters,
      required formControl,
      autofillHints,
      autofocus = false,
      Function()? onFieldSubmitted,
      suffixIcon,
      obscureText = false,
      focusNode,
      onChanged,
      hintText,
      maxWidth}) {
    AppolloTextField tf = AppolloTextField._(
      labelText: labelText,
      textFieldType: TextFieldType.reactive,
      validationMessages: validationMessages,
      inputFormatters: inputFormatters,
      formControl: formControl,
      autofillHints: autofillHints,
      autofocus: autofocus,
      onFieldSubmittedReactive: onFieldSubmitted,
      suffixIcon: suffixIcon,
      obscureText: obscureText,
      focusNode: focusNode,
      onChanged: onChanged,
      hintText: hintText,
      maxWidth: maxWidth,
      keyboardType: keyboardType,
    );

    return tf;
  }

  factory AppolloTextField.formField(
      {Key? key,
      required labelText,
      required controller,
      keyboardType,
      inputFormatters,
      autofillHints,
      autofocus,
      onFieldSubmitted,
      suffixIcon,
      obscureText = false,
      focusNode,
      onChanged,
      hintText,
      maxWidth}) {
    AppolloTextField tf = AppolloTextField._(
      labelText: labelText,
      controller: controller,
      textFieldType: TextFieldType.regular,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      autofocus: autofocus,
      onFieldSubmitted: onFieldSubmitted,
      suffixIcon: suffixIcon,
      obscureText: obscureText,
      focusNode: focusNode,
      onChanged: onChanged,
      hintText: hintText,
      maxWidth: maxWidth,
      keyboardType: keyboardType,
    );

    return tf;
  }

  @override
  _AppolloTextFieldState createState() => _AppolloTextFieldState();
}

class _AppolloTextFieldState extends State<AppolloTextField> {
  AppolloTextFieldState textFieldState = AppolloTextFieldState.initial;
  String _text = '';

  FocusNode? _focusNode;
  @override
  void initState() {
    if (widget.errorText.isNotEmpty) {
      textFieldState = AppolloTextFieldState.error;
    }

    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode!.addListener(() {
      setState(() {
        if (_focusNode!.hasFocus) {
          if (textFieldState != AppolloTextFieldState.error && textFieldState != AppolloTextFieldState.typing) {
            textFieldState = AppolloTextFieldState.typing;
          }
        } else {
          if (textFieldState != AppolloTextFieldState.error) {
            if (_text.isEmpty) {
              textFieldState = AppolloTextFieldState.initial;
            } else {
              textFieldState = AppolloTextFieldState.filled;
            }
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
        if (textFieldState != AppolloTextFieldState.error &&
            textFieldState != AppolloTextFieldState.typing &&
            textFieldState != AppolloTextFieldState.hover) {
          setState(() {
            textFieldState = AppolloTextFieldState.hover;
          });
        }
      },
      onExit: (v) {
        if (textFieldState != AppolloTextFieldState.error && !_focusNode!.hasFocus) {
          if (_text.isEmpty) {
            setState(() {
              if (_focusNode!.hasFocus) {
                if (textFieldState != AppolloTextFieldState.typing) {
                  textFieldState = AppolloTextFieldState.typing;
                }
              } else {
                textFieldState = AppolloTextFieldState.initial;
              }
            });
          } else {
            setState(() {
              textFieldState = AppolloTextFieldState.filled;
            });
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: MyTheme.animationDuration,
            width: widget.maxWidth ?? double.infinity,
            height: textFieldState == AppolloTextFieldState.error ? 68 : 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: textFieldState == AppolloTextFieldState.hover || textFieldState == AppolloTextFieldState.typing
                  ? MyTheme.appolloBackgroundColor
                  : textFieldState == AppolloTextFieldState.error
                      ? MyTheme.appolloBackgroundColor
                      : MyTheme.appolloTextFieldColor,
              border: Border.all(
                width: 1.8,
                color: _buildOutlineColor(),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Builder(builder: (context) {
                    if (widget.textFieldType == TextFieldType.reactive) {
                      return ReactiveTextField(
                        formControl: widget.formControl,
                        keyboardType: widget.keyboardType,
                        autofillHints: widget.autofillHints,
                        autofocus: widget.autofocus,
                        validationMessages: widget.validationMessages,
                        inputFormatters: widget.inputFormatters,
                        focusNode: _focusNode,
                        onSubmitted: () {
                          if (widget.onFieldSubmittedReactive != null) {
                            widget.onFieldSubmittedReactive!();
                          }
                        },
                        showErrors: (control) {
                          if (control.touched) {
                            if (control.invalid) {
                              if (textFieldState != AppolloTextFieldState.error) {
                                Future.delayed(Duration(milliseconds: 1)).then((value) {
                                  setState(() {
                                    textFieldState = AppolloTextFieldState.error;
                                  });
                                });
                              }
                              return true;
                            } else {
                              if (textFieldState != AppolloTextFieldState.typing) {
                                Future.delayed(Duration(milliseconds: 1)).then((value) {
                                  setState(() {
                                    textFieldState = AppolloTextFieldState.typing;
                                  });
                                });
                              }
                              return false;
                            }
                          }
                          return false;
                        },
                        obscureText: widget.obscureText,
                        style: MyTheme.mobileTextTheme.bodyText1,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: widget.hintText,
                          fillColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          contentPadding: const EdgeInsets.only(left: 8),
                          errorBorder: InputBorder.none,
                          isDense: true,
                          errorStyle: MyTheme.mobileTextTheme.caption!.copyWith(color: MyTheme.appolloDarkRed),
                          focusedBorder: InputBorder.none,
                          hintStyle: MyTheme.mobileTextTheme.button!.copyWith(
                              color: textFieldState == AppolloTextFieldState.initial
                                  ? MyTheme.appolloGrey
                                  : MyTheme.appolloGreen),
                          enabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          labelText: widget.labelText,
                          labelStyle: MyTheme.mobileTextTheme.bodyText1!
                              .copyWith(color: _buildLabelColor(), fontSize: 14, fontWeight: FontWeight.w500),
                          disabledBorder: InputBorder.none,
                        ),
                      );
                    }
                    return TextFormField(
                      key: widget.formState,
                      autofillHints: widget.autofillHints,
                      autofocus: widget.autofocus,
                      onFieldSubmitted: (v) {
                        if (widget.onFieldSubmitted != null) {
                          widget.onFieldSubmitted!(v);
                        }
                        if (widget.validator != null) {
                          if (widget.validator!(v) != null) {
                            setState(() {
                              textFieldState = AppolloTextFieldState.error;
                            });
                          }
                        }
                      },
                      autovalidateMode: widget.autovalidateMode,
                      validator: widget.validator,
                      obscureText: widget.obscureText,
                      onChanged: (v) {
                        if (widget.onChanged != null) {
                          widget.onChanged!(v);
                        }
                        setState(() => _text = v);
                      },
                      controller: widget.controller,
                      keyboardType: widget.keyboardType,
                      focusNode: _focusNode,
                      inputFormatters: widget.inputFormatters,
                      style: MyTheme.mobileTextTheme.bodyText1,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: widget.hintText,
                        suffix: widget.suffixIcon,
                        fillColor: Colors.transparent,
                        isDense: true,
                        hoverColor: Colors.transparent,
                        contentPadding: const EdgeInsets.only(left: 8, bottom: 4),
                        errorBorder: InputBorder.none,
                        errorStyle: MyTheme.mobileTextTheme.caption!.copyWith(color: MyTheme.appolloDarkRed),
                        focusedBorder: InputBorder.none,
                        hintStyle: MyTheme.mobileTextTheme.button!.copyWith(
                            color: textFieldState == AppolloTextFieldState.initial
                                ? MyTheme.appolloBlack
                                : MyTheme.appolloGrey),
                        enabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        labelText: widget.labelText,
                        labelStyle: MyTheme.mobileTextTheme.bodyText1!
                            .copyWith(color: _buildLabelColor(), fontSize: 16, fontWeight: FontWeight.w600),
                        disabledBorder: InputBorder.none,
                      ),
                    );
                  }).paddingAll(8),
                ),
                if (widget.suffixIcon != null) widget.suffixIcon!,
                if (widget.suffixIcon == null &&
                    (textFieldState == AppolloTextFieldState.typing || textFieldState == AppolloTextFieldState.error))
                  InkWell(
                      radius: 0,
                      onTap: () {
                        setState(() {
                          _text = "";
                          if (widget.textFieldType == TextFieldType.reactive) {
                            if (widget.formControl != null) {
                              widget.formControl!.reset();
                            }
                          } else {
                            if (widget.controller != null) {
                              widget.controller!.clear();
                            }
                          }
                        });
                      },
                      child: Icon(
                        Icons.close,
                        color: MyTheme.appolloGrey,
                      ).paddingRight(8))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _buildLabelColor() {
    if (textFieldState == AppolloTextFieldState.filled) {
      return MyTheme.appolloGreen;
    } else if (textFieldState == AppolloTextFieldState.error) {
      return MyTheme.appolloWhite;
    } else if (textFieldState == AppolloTextFieldState.initial) {
      return MyTheme.appolloWhite;
    }
    return MyTheme.appolloWhite;
  }

  Color _buildOutlineColor() {
    if (textFieldState == AppolloTextFieldState.typing) {
      return MyTheme.appolloGreen;
    } else if (textFieldState == AppolloTextFieldState.hover) {
      return MyTheme.appolloOrange;
    } else if (textFieldState == AppolloTextFieldState.error) {
      return MyTheme.appolloDarkRed;
    } else if (textFieldState == AppolloTextFieldState.filled) {
      return MyTheme.appolloGreen;
    } else {
      return Colors.transparent;
    }
  }
}
