import 'package:flutter/material.dart';

import '../../theme.dart';

class FavoriteHeartButton extends StatefulWidget {
  final bool isFavorite;
  final Function(bool) onTap;
  final bool enable;

  const FavoriteHeartButton({Key? key, required this.isFavorite, required this.onTap, required this.enable})
      : super(key: key);
  @override
  _FavoriteHeartButtonState createState() => _FavoriteHeartButtonState();
}

class _FavoriteHeartButtonState extends State<FavoriteHeartButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _sizeAnimation;

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: MyTheme.animationDuration);
    _colorAnimation = ColorTween(begin: MyTheme.scoopWhite, end: MyTheme.scoopRed).animate(_animationController);
    _sizeAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: Tween(begin: 22, end: 17), weight: 15),
      TweenSequenceItem<double>(tween: Tween(begin: 17, end: 22), weight: 15)
    ]).animate(_animationController);

    if (widget.isFavorite) {
      _animationController.forward();
      isFavorite = true;
    } else {
      isFavorite = false;
    }

    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        setState(() => isFavorite = true);
      } else if (_animationController.isDismissed) {
        setState(() => isFavorite = false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, snapshot) {
        return Container(
          width: 20,
          height: 20,
          child: InkWell(
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _colorAnimation.value,
                size: _sizeAnimation.value,
              ),
              onTapDown: widget.enable
                  ? (v) {
                      if (isFavorite) {
                        _animationController.reverse();
                      } else {
                        _animationController.forward();
                      }
                    }
                  : null,
              onTap: () async {
                widget.onTap(isFavorite);
              }),
        );
      },
    );
  }
}
