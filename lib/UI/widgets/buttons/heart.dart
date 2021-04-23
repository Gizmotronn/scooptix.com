import 'package:flutter/material.dart';

import '../../theme.dart';

class FavoriteHeartButton extends StatefulWidget {
  final bool isFavorite;
  final Function(bool) onTap;

  const FavoriteHeartButton({Key key, @required this.isFavorite, @required this.onTap}) : super(key: key);
  @override
  _FavoriteHeartButtonState createState() => _FavoriteHeartButtonState();
}

class _FavoriteHeartButtonState extends State<FavoriteHeartButton> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Color> _colorAnimation;
  Animation<double> _sizeAnimation;

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: MyTheme.animationDuration);
    _colorAnimation = ColorTween(begin: MyTheme.appolloWhite, end: MyTheme.appolloRed).animate(_animationController);
    _sizeAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: Tween(begin: 25, end: 20), weight: 15),
      TweenSequenceItem<double>(tween: Tween(begin: 20, end: 25), weight: 15)
    ]).animate(_animationController);

    if (widget.isFavorite) {
      _animationController.forward();
      isFavorite = true;
      widget.onTap(isFavorite);
    } else {
      isFavorite = false;
      widget.onTap(isFavorite);
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
          width: 30,
          height: 30,
          child: InkWell(
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _colorAnimation.value,
                size: _sizeAnimation.value,
              ),
              onTap: () async {
                if (isFavorite) {
                  _animationController.reverse();
                  widget.onTap(isFavorite);
                } else {
                  _animationController.forward();
                  widget.onTap(isFavorite);
                }
              }),
        );
      },
    );
  }
}
