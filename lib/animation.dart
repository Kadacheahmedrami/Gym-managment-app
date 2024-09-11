import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hamza_gym/drawer.dart';
import 'package:hamza_gym/main.dart';

class Draweranimation extends StatefulWidget {
  final email;
  final password;
  final bool? fix;
  final int? index;
  const Draweranimation({required  this.email , required this.password,required this.index,this.fix,super.key});

  @override
  _DraweranimationState createState() => _DraweranimationState();
}

class _DraweranimationState extends State<Draweranimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _numAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _leftAnimation;
  late Animation<double> _rotateanimation;
    late Animation<double> _curveanimation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    // Apply a curve to the animations
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn, // You can choose any curve you like
    );

    // Define animations for offset, scale, and left margin with curve applied
    _numAnimation = Tween<double>(begin: 0, end: 240).animate(curvedAnimation);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(curvedAnimation);
    _leftAnimation = Tween<double>(begin: 15, end: 220).animate(curvedAnimation);
    _rotateanimation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
        _curveanimation = Tween<double>(begin: 0, end: 24).animate(curvedAnimation);
    // Add a listener to update the UI on each tick of the animation
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
   bool pressed = false;
  void _toggleDrawer() {
       setState(() {
        pressed = !pressed;
      });
    // Toggle the drawer animation
    if (_controller.isDismissed) {
   
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          gradient:theme ? LinearGradient(
            colors: [Colors.white, Color(0xffe0e0e0), Color(0xffc8c8c8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) :LinearGradient(
            colors: [Colors.black, Color(0xff1d1e22), Color(0xff393f4d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) ,
        ),
        child: GestureDetector(
          onPanUpdate: (details) {
            // Detect a left swipe
            if (details.delta.dx < -10 && pressed) {

                   _toggleDrawer();

            }
            if(details.delta.dx > 10 && !pressed){
              _toggleDrawer();
            }
          },
          child: Stack(
            children: [
              Positioned(child: CustomDrawer(email: widget.email,password: widget.password,fix: widget.fix,)),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..setEntry(3,2,0.001)..rotateY(_rotateanimation.value- 30* _rotateanimation.value * pi / 180),
                child:  Transform.translate(
                offset: Offset(_numAnimation.value, 0),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(_curveanimation.value)),
                    child: Navigation(fix: widget.fix,index: widget.index,),
                  ),
                ),
              ) ,
                ),

              Container(
                decoration: BoxDecoration(
                  color: shadow,
                  shape: BoxShape.circle,
                ),
                margin: EdgeInsets.only( top: 41,left: _leftAnimation.value),
                child: IconButton(
                  onPressed: _toggleDrawer,
                  icon: Icon(!pressed ? Icons.menu : Icons.cancel  , color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
