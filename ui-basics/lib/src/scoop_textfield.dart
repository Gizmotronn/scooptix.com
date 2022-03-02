import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'theme.dart';

enum ScoopTextFieldState { initial, hover, typing, filled, disabled, error }
enum TextFieldType { reactive, regular }

class ScoopTextField extends StatefulWidget {
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
  final Function(dynamic)? onFieldSubmitted;
  final Function()? onFieldSubmittedReactive;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final AutovalidateMode? autovalidateMode;
  final bool obscureText;
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  final double? maxWidth;
  final TextCapitalization? textCapitalization;
  final bool enabled;
  final int minLines;
  final int maxLines;

  ScoopTextField._(
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
      this.maxWidth,
      this.textCapitalization,
      this.enabled = true,
      this.minLines = 1,
      this.maxLines = 1})
      : super(key: key);

  factory ScoopTextField.reactive(
      {Key? key,
      required labelText,
      keyboardType,
      validationMessages,
      inputFormatters,
      required formControl,
      autofillHints,
      autofocus = false,
      onFieldSubmitted,
      suffixIcon,
      obscureText = false,
      focusNode,
      onChanged,
      hintText,
      maxWidth,
      textCapitalization,
      enabled = true,
      minLines = 1,
      maxLines = 1}) {
    ScoopTextField tf = ScoopTextField._(
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
      textCapitalization: textCapitalization,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
    );

    return tf;
  }

  factory ScoopTextField.formField(
      {Key? key,
      required labelText,
      required controller,
      keyboardType,
      inputFormatters,
      autofillHints,
      autofocus = false,
      onFieldSubmitted,
      suffixIcon,
      obscureText = false,
      focusNode,
      onChanged,
      hintText,
      maxWidth,
      textCapitalization}) {
    ScoopTextField tf = ScoopTextField._(
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
      textCapitalization: textCapitalization,
    );

    return tf;
  }

  @override
  _ScoopTextFieldState createState() => _ScoopTextFieldState();
}

class _ScoopTextFieldState extends State<ScoopTextField> {
  ScoopTextFieldState textFieldState = ScoopTextFieldState.initial;
  String _text = '';

  String get currentText =>
      widget.textFieldType == TextFieldType.reactive ? (widget.formControl!.value ?? "").toString() : _text;

  late FocusNode _focusNode;
  @override
  void initState() {
    if (widget.errorText.isNotEmpty) {
      textFieldState = ScoopTextFieldState.error;
    } else if (currentText.isNotEmpty) {
      textFieldState = ScoopTextFieldState.filled;
    }

    _focusNode = widget.focusNode ?? FocusNode();

    document.addEventListener('keydown', (dynamic event) {
      {
        if (event.code == 'Tab' && _focusNode.hasFocus) {
          _focusNode.consumeKeyboardToken();
          _focusNode.nextFocus();
        }
      }
    });

    _focusNode.addListener(() {
      if (!widget.enabled) {
        return;
      }
      setState(() {
        if (_focusNode.hasFocus) {
          if (textFieldState != ScoopTextFieldState.error && textFieldState != ScoopTextFieldState.typing) {
            textFieldState = ScoopTextFieldState.typing;
          }
        } else {
          if (textFieldState != ScoopTextFieldState.error) {
            if (currentText.isEmpty) {
              textFieldState = ScoopTextFieldState.initial;
            } else {
              textFieldState = ScoopTextFieldState.filled;
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
        if (!widget.enabled) {
          return;
        }
        if (textFieldState != ScoopTextFieldState.error &&
            textFieldState != ScoopTextFieldState.typing &&
            textFieldState != ScoopTextFieldState.hover) {
          setState(() {
            textFieldState = ScoopTextFieldState.hover;
          });
        }
      },
      onExit: (v) {
        if (!widget.enabled) {
          return;
        }
        if (textFieldState != ScoopTextFieldState.error && !_focusNode.hasFocus) {
          if (currentText.isEmpty) {
            setState(() {
              if (_focusNode.hasFocus) {
                if (textFieldState != ScoopTextFieldState.typing) {
                  textFieldState = ScoopTextFieldState.typing;
                }
              } else {
                textFieldState = ScoopTextFieldState.initial;
              }
            });
          } else {
            setState(() {
              textFieldState = ScoopTextFieldState.filled;
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
            //height: textFieldState == AppolloTextFieldState.error ? widget.maxLines == 1 ? 68 : widget.maxLines * 14 + 44 :  widget.maxLines == 1 ? 52 : widget.maxLines * 14 + 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: textFieldState == ScoopTextFieldState.hover || textFieldState == ScoopTextFieldState.typing
                  ? MyTheme.background
                  : textFieldState == ScoopTextFieldState.error
                      ? MyTheme.background
                      : MyTheme.lightBackground,
              border: Border.all(
                width: 1.8,
                color: _buildOutlineColor(),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: widget.maxLines == 1 ? Alignment.centerLeft : Alignment.topLeft,
                    child: Builder(builder: (context) {
                      if (widget.textFieldType == TextFieldType.reactive) {
                        return ReactiveTextField(
                          textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
                          formControl: widget.formControl,
                          keyboardType: widget.keyboardType,
                          autofillHints: widget.autofillHints,
                          autofocus: widget.autofocus,
                          validationMessages: widget.validationMessages,
                          inputFormatters: widget.inputFormatters,
                          focusNode: _focusNode,
                          readOnly: !widget.enabled,
                          minLines: widget.minLines,
                          maxLines: widget.maxLines,
                          onSubmitted: () {
                            if (widget.onFieldSubmittedReactive != null) {
                              widget.onFieldSubmittedReactive!();
                            }
                          },
                          showErrors: (control) {
                            if (!widget.enabled) {
                              return false;
                            }
                            if (control.touched || (control.dirty && !control.pristine)) {
                              if (control.invalid && !_focusNode.hasFocus) {
                                if (textFieldState != ScoopTextFieldState.error) {
                                  Future.delayed(const Duration(milliseconds: 1)).then((value) {
                                    setState(() {
                                      textFieldState = ScoopTextFieldState.error;
                                    });
                                  });
                                }
                                return true;
                              } else {
                                if (_focusNode.hasFocus && textFieldState != ScoopTextFieldState.typing) {
                                  Future.delayed(const Duration(milliseconds: 1)).then((value) {
                                    setState(() {
                                      textFieldState = ScoopTextFieldState.typing;
                                    });
                                  });
                                }
                                return false;
                              }
                            }
                            return false;
                          },
                          obscureText: widget.obscureText,
                          style: MyTheme.label,
                          decoration: InputDecoration(
                            filled: true,
                            hintText: widget.hintText,
                            fillColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            errorBorder: InputBorder.none,
                            isDense: true,
                            errorStyle: MyTheme.error,
                            focusedBorder: InputBorder.none,
                            hintStyle: MyTheme.hint.copyWith(
                                color: textFieldState == ScoopTextFieldState.initial
                                    ? MyTheme.grey
                                    : MyTheme.secondaryMain),
                            enabledBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            labelText: widget.labelText,
                            labelStyle: MyTheme.label
                                .copyWith(color: _buildLabelColor(), fontSize: 14, fontWeight: FontWeight.w500),
                            disabledBorder: InputBorder.none,
                            enabled: widget.enabled,
                          ),
                        );
                      }
                      return TextFormField(
                        textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
                        key: widget.formState,
                        autofillHints: widget.autofillHints,
                        autofocus: widget.autofocus,
                        onFieldSubmitted: (v) {
                          if (!widget.enabled) {
                            return;
                          }
                          if (widget.onFieldSubmitted != null) {
                            widget.onFieldSubmitted!(v);
                          }
                          if (widget.validator != null) {
                            if (widget.validator!(v) != null) {
                              setState(() {
                                textFieldState = ScoopTextFieldState.error;
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
                        style: MyTheme.label,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: widget.hintText,
                          fillColor: Colors.transparent,
                          isDense: true,
                          hoverColor: Colors.transparent,
                          contentPadding: const EdgeInsets.only(left: 8, bottom: 4),
                          errorBorder: InputBorder.none,
                          errorStyle: MyTheme.error,
                          focusedBorder: InputBorder.none,
                          hintStyle: MyTheme.hint.copyWith(
                              color: textFieldState == ScoopTextFieldState.initial ? MyTheme.black : MyTheme.grey),
                          enabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          labelText: widget.labelText,
                          labelStyle: MyTheme.label
                              .copyWith(color: _buildLabelColor(), fontSize: 14, fontWeight: FontWeight.w500),
                          disabledBorder: InputBorder.none,
                        ),
                      );
                    }).paddingAll(8),
                  ),
                ),
                if (widget.suffixIcon != null) widget.suffixIcon!,
                if (widget.suffixIcon == null &&
                    (textFieldState == ScoopTextFieldState.typing ||
                        textFieldState == ScoopTextFieldState.error ||
                        textFieldState == ScoopTextFieldState.filled))
                  InkWell(
                      radius: 0,
                      onTap: () {
                        setState(() {
                          _text = "";
                          if (widget.textFieldType == TextFieldType.reactive) {
                            if (widget.formControl != null) {
                              if (widget.formControl!.value is String) widget.formControl!.value = "";
                            }
                          } else {
                            if (widget.controller != null) {
                              widget.controller!.clear();
                            }
                          }
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: MyTheme.grey,
                      ).paddingRight(8))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _buildLabelColor() {
    if (textFieldState == ScoopTextFieldState.filled) {
      return MyTheme.secondaryMain;
    } else if (textFieldState == ScoopTextFieldState.error) {
      return MyTheme.dimGrey;
    } else if (textFieldState == ScoopTextFieldState.initial) {
      return MyTheme.dimGrey;
    }
    return MyTheme.dimGrey;
  }

  Color _buildOutlineColor() {
    if (textFieldState == ScoopTextFieldState.typing) {
      return MyTheme.secondaryMain;
    } else if (textFieldState == ScoopTextFieldState.hover) {
      return MyTheme.primaryMain;
    } else if (textFieldState == ScoopTextFieldState.error) {
      return MyTheme.darkRed;
    } else if (textFieldState == ScoopTextFieldState.filled) {
      return Colors.transparent;
    } else {
      return Colors.transparent;
    }
  }
}
