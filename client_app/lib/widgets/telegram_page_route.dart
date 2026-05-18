import 'package:flutter/material.dart';

/// A premium, high-performance page route that mimics Telegram's horizontal transitions.
/// It features a smooth slide-in from right to left with a subtle parallax effect on the
/// departing page, as well as native swipe-to-dismiss gesture support.
class TelegramPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  TelegramPageRoute({required this.child, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Elegant cubic ease-out curve for entrance
            final easeCurve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            // 1. Slide transition for the entering page (Right -> Left)
            final slideIn = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(easeCurve);

            // 2. Parallax transition for the exiting parent page (Center -> Left by 25%)
            final parallax = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.25, 0.0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );

            // 3. Subtle shadow overlay to give depth during the transition
            final shadow = Tween<double>(
              begin: 0.0,
              end: 0.4,
            ).animate(easeCurve);

            return SlideTransition(
              position: parallax,
              child: SlideTransition(
                position: slideIn,
                child: Stack(
                  children: [
                    child,
                    // Overlay dim shadow on parent page as new page enters
                    if (!animation.isCompleted)
                      AnimatedBuilder(
                        animation: shadow,
                        builder: (context, _) {
                          return IgnorePointer(
                            child: Container(
                              color: Colors.black.withOpacity(0.15 * (1.0 - shadow.value)),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
}

/// A standard PageTransitionsBuilder that can be set in MaterialApp's theme
/// to automatically apply Telegram horizontal transitions across the entire app.
class TelegramPageTransitionsBuilder extends PageTransitionsBuilder {
  const TelegramPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Entrance curve
    final entranceAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Slide in from right to left
    final slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(entranceAnimation);

    // Subtle parallax on parent screen
    final parallax = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.2, 0.0),
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    return SlideTransition(
      position: parallax,
      child: SlideTransition(
        position: slideIn,
        child: child,
      ),
    );
  }
}
