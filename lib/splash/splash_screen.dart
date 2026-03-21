import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/bottombar/bottom_bind.dart';
import 'package:gutrgoopro/bottombar/bottom_binding.dart';
import 'package:gutrgoopro/profile/screen/auth/otp.dart';
import 'package:gutrgoopro/uitls/local_store.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _hasNavigated = false;
  bool _showSwipeUI = false;
  bool _isFirstTime = true;

  int _currentPage = 0;
  double _sliderValue = 0.0;
  bool _isUnlocking = false;

  Timer? _autoScrollTimer; // ✅ timer variable

  late PageController _pageController;
  late AnimationController _arrowController;
  late AnimationController _fadeController;
  late AnimationController _swipeFadeController;
  late Animation<double> _arrowAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _swipeFadeAnimation;

  final List<String> _images = [
    'assets/img3.jpeg',
    'assets/1.png',
    'assets/img4.png',
    'assets/awasaan_trailer.jpg',
    'assets/red_trailer.jpg',
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      viewportFraction: 0.72,
      initialPage: 2, // ✅ center se start
    );

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _swipeFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _arrowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _swipeFadeAnimation = CurvedAnimation(
      parent: _swipeFadeController,
      curve: Curves.easeIn,
    );

    _checkFirstTime();
  }
Future<void> _checkFirstTime() async {
  final isFirst = await LocalStore.isFirstTime();
  
  if (isFirst) {
    await LocalStore.setFirstTimeDone();
    setState(() => _isFirstTime = true);
    _showSwipeScreen();
  } else {
    setState(() => _isFirstTime = false);
    _initializeVideo();
  }
}

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/logo.mp4');
      await _controller!.initialize();

      if (mounted) {
        setState(() {});
        _controller!.addListener(_videoListener);
        await _controller!.play();
      }
    } catch (e) {
      debugPrint('❌ Video error: $e');
      _navigateToHome();
    }
  }

  void _videoListener() {
    if (_controller != null &&
        _controller!.value.position >= _controller!.value.duration &&
        !_hasNavigated) {
      _navigateToHome();
    }
  }

  void _showSwipeScreen() {
    if (!mounted) return;
    setState(() => _showSwipeUI = true);
    _fadeController.forward();
    _swipeFadeController.forward();

    // ✅ Timer yahan start hoga — swipe screen aane ke baad
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final nextPage = _currentPage + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _navigateToHome() async {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      _autoScrollTimer?.cancel(); // ✅ navigate pe timer cancel
      if (_isFirstTime) setState(() => _isUnlocking = true);

      final isLoggedIn = await LocalStore.isLoggedIn();

      if (isLoggedIn) {
        Get.offAll(
          () => const BottomNavigationScreen(initialIndex: 0),
          binding: BottomBindings(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      } else {
        Get.offAll(
          () => PhoneLoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      }
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel(); // ✅ dispose mein bhi cancel
    _arrowController.dispose();
    _fadeController.dispose();
    _swipeFadeController.dispose();
    _pageController.dispose();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _showSwipeUI ? _buildSwipeUI(context) : _buildVideoUI(),
    );
  }

  Widget _buildVideoUI() {
    return _controller != null && _controller!.value.isInitialized
        ? Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
  }

  Widget _buildSwipeUI(BuildContext context) {
    final double sliderWidth = 1.sw - 60.w;

    return FadeTransition(
      opacity: _swipeFadeAnimation,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D1B14),
                    Color(0xFF0D1B14),
                    Color(0xFF000000),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20.h),

                // ✅ Fan cards with auto scroll + loop
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    height: 440.h,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 99999, // ✅ infinite loop
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index; // raw index store karo
                        });
                      },
                      itemBuilder: (context, index) {
                        final realIndex = index % _images.length; // ✅ actual image
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double page = _pageController.hasClients &&
                                    _pageController.position.haveDimensions
                                ? (_pageController.page ?? index.toDouble())
                                : index.toDouble();
                            double distance = (page - index).abs();
                            double scale =
                                (1 - distance * 0.12).clamp(0.85, 1.0);
                            double angle = (page - index) * -0.18;
                            double translateY = distance * 20;

                            return Transform.translate(
                              offset: Offset(0, translateY),
                              child: Transform.scale(
                                scale: scale,
                                child: Transform.rotate(
                                  angle: angle,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 10.h),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: Image.asset(
                                _images[realIndex],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // ✅ Dots — % se real index
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: (_currentPage % _images.length) == i ? 24.w : 6.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: (_currentPage % _images.length) == i
                            ? Colors.white
                            : Colors.white30,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Column(
                      children: [
                        Text(
                          'Watch On\nAny Device Free',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Discover unlimited entertainments',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Container(
                    height: 62.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(40.r),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        ClipRRect(
                           borderRadius: BorderRadius.circular(40.r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 30),
                            width: 60.r +
                                (_sliderValue * (sliderWidth - 50.r)),
                            height: 62.h,
                            decoration: BoxDecoration(
                              color:  Color.fromARGB(255, 155, 8, 8).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(40.r),
                            ),
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Home',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              FadeTransition(
                                opacity: _arrowAnimation,
                                child: Text(
                                  '>>>',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 16.sp,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: _sliderValue * (sliderWidth - 50.r),
                          child: GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              setState(() {
                                double newVal = _sliderValue +
                                    details.delta.dx / (sliderWidth - 50.r);
                                _sliderValue = newVal.clamp(0.0, 1.0);
                              });
                              if (_sliderValue >= 0.88) {
                                _navigateToHome();
                              }
                            },
                            onHorizontalDragEnd: (_) {
                              if (!_hasNavigated) {
                                setState(() => _sliderValue = 0.0);
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.all(6.r),
                              height: 50.r,
                              width: 49.r,
                              decoration:  BoxDecoration(
                                color: Color.fromARGB(255, 155, 8, 8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x6622C55E),
                                    blurRadius: 20.r,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: _isUnlocking
                                  ? Padding(
                                      padding: EdgeInsets.all(10.r),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.lock_open_rounded,
                                      color: Colors.white,
                                      size: 22.sp,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:gutrgoopro/bottombar/bottom_bind.dart';
// import 'package:gutrgoopro/bottombar/bottom_binding.dart';
// import 'package:gutrgoopro/profile/screen/auth/otp.dart';
// import 'package:gutrgoopro/uitls/local_store.dart';
// import 'package:video_player/video_player.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   VideoPlayerController? _controller;
//   bool _hasNavigated = false;
//   bool _showSwipeUI = false;
//   bool _isFirstTime = true; // ✅ first time check

//   int _currentPage = 0;
//   double _sliderValue = 0.0;
//   bool _isUnlocking = false;

//   late PageController _pageController;
//   late AnimationController _arrowController;
//   late AnimationController _fadeController;
//   late AnimationController _swipeFadeController;
//   late Animation<double> _arrowAnimation;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _swipeFadeAnimation;

//   final List<String> _images = [
//     'assets/img3.jpeg',
//     'assets/img1.png',
//     'assets/img4.png',
//     'assets/awasaan_trailer.jpg',
//     'assets/red_trailer.jpg',
//   ];

//   @override
//   void initState() {
//     super.initState();

//     _pageController = PageController(viewportFraction: 0.72,initialPage: 2,);
// Timer.periodic(const Duration(seconds: 3), (timer) {
//   if (!mounted) { timer.cancel(); return; }
//   _pageController.animateToPage(
//     _currentPage + 1,
//     duration: const Duration(milliseconds: 500),
//     curve: Curves.easeInOut,
//   );
// });
//     _arrowController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     )..repeat(reverse: true);

//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );

//     _swipeFadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );

//     _arrowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
//       CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
//     );

//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeIn,
//     );

//     _swipeFadeAnimation = CurvedAnimation(
//       parent: _swipeFadeController,
//       curve: Curves.easeIn,
//     );

//     _checkFirstTime(); // ✅ pehle check karo
//   }

//   // ✅ First time check
//   Future<void> _checkFirstTime() async {
//     final isFirst = await LocalStore.isFirstTime(); // LocalStore mein add karo
//     setState(() => _isFirstTime = isFirst);

//     if (isFirst) {
//       // ✅ Pehli baar — seedha swipe UI dikhao (no video)
//       await LocalStore.setFirstTimeDone(); // flag save karo
//       _showSwipeScreen();
//     } else {
//       // ✅ Second time onwards — video play karo, phir navigate
//       _initializeVideo();
//     }
//   }

//   Future<void> _initializeVideo() async {
//     try {
//       _controller = VideoPlayerController.asset('assets/logo.mp4');
//       await _controller!.initialize();

//       if (mounted) {
//         setState(() {});
//         _controller!.addListener(_videoListener);
//         await _controller!.play();
//       }
//     } catch (e) {
//       debugPrint('❌ Video error: $e');
//       _navigateToHome();
//     }
//   }

//   void _videoListener() {
//     if (_controller != null &&
//         _controller!.value.position >= _controller!.value.duration &&
//         !_hasNavigated) {
//       _navigateToHome();
//     }
//   }

//   void _showSwipeScreen() {
//     if (!mounted) return;
//     setState(() => _showSwipeUI = true);
//     _fadeController.forward();
//     _swipeFadeController.forward();
//   }

//   Future<void> _navigateToHome() async {
//     if (!_hasNavigated && mounted) {
//       _hasNavigated = true;
//       if (_isFirstTime) setState(() => _isUnlocking = true);

//       final isLoggedIn = await LocalStore.isLoggedIn();

//       if (isLoggedIn) {
//         Get.offAll(
//           () => const BottomNavigationScreen(initialIndex: 0),
//           binding: BottomBindings(),
//           transition: Transition.fadeIn,
//           duration: const Duration(milliseconds: 500),
//         );
//       } else {
//         Get.offAll(
//           () => PhoneLoginScreen(),
//           transition: Transition.fadeIn,
//           duration: const Duration(milliseconds: 500),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _arrowController.dispose();
//     _fadeController.dispose();
//     _swipeFadeController.dispose();
//     _pageController.dispose();
//     _controller?.removeListener(_videoListener);
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: _showSwipeUI ? _buildSwipeUI(context) : _buildVideoUI(),
//     );
//   }

//   // ✅ Phase 1: Video (second time onwards)
//   Widget _buildVideoUI() {
//     return _controller != null && _controller!.value.isInitialized
//         ? Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
//               child: SizedBox.expand(
//                 child: FittedBox(
//                   fit: BoxFit.contain,
//                   child: SizedBox(
//                     width: _controller!.value.size.width,
//                     height: _controller!.value.size.height,
//                     child: VideoPlayer(_controller!),
//                   ),
//                 ),
//               ),
//             ),
//           )
//         : const Center(
//             child: CircularProgressIndicator(color: Colors.white),
//           );
//   }

//   // ✅ Phase 2: Swipe UI (first time only)
//   Widget _buildSwipeUI(BuildContext context) {
//     final double sliderWidth = 1.sw - 60.w;

//     return FadeTransition(
//       opacity: _swipeFadeAnimation,
//       child: Stack(
//         children: [
//           Positioned.fill(
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Color(0xFF0D1B14),
//                     Color(0xFF0D1B14),
//                     Color(0xFF000000),
//                   ],
//                   stops: [0.0, 0.5, 1.0],
//                 ),
//               ),
//             ),
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 SizedBox(height: 20.h),

//                 // Fan cards
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: SizedBox(
//                     height: 440.h,
//                     child: PageView.builder(
//                       controller: _pageController,
//                       itemCount: 9999,
//                       onPageChanged: (index) =>
//                            setState(() => _currentPage = index % _images.length), 
//                       itemBuilder: (context, index) {
//                          final realIndex = index % _images.length;
//                         return AnimatedBuilder(
//                           animation: _pageController,
//                           builder: (context, child) {
//                             double page = _pageController.hasClients &&
//                                     _pageController.position.haveDimensions
//                                 ? (_pageController.page ?? index.toDouble())
//                                 : index.toDouble();
//                             double distance = (page - index).abs();
//                             double scale =
//                                 (1 - distance * 0.12).clamp(0.85, 1.0);
//                             double angle = (page - index) * -0.18;
//                             double translateY = distance * 20;

//                             return Transform.translate(
//                               offset: Offset(0, translateY),
//                               child: Transform.scale(
//                                 scale: scale,
//                                 child: Transform.rotate(
//                                   angle: angle,
//                                   child: child,
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 8.w, vertical: 10.h),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(20.r),
//                               child:Image.asset(_images[realIndex], fit: BoxFit.cover),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 16.h),

//                 // Dots
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     _images.length,
//                     (i) => AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       margin: EdgeInsets.symmetric(horizontal: 3.w),
//                       width: _currentPage == i ? 24.w : 6.w,
//                       height: 4.h,
//                       decoration: BoxDecoration(
//                         color: _currentPage == i
//                             ? Colors.white
//                             : Colors.white30,
//                         borderRadius: BorderRadius.circular(4.r),
//                       ),
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 28.h),

//                 // Title
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 30.w),
//                     child: Column(
//                       children: [
//                         Text(
//                           'Watch On\nAny Device Free',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 28.sp,
//                             fontWeight: FontWeight.bold,
//                             height: 1.25,
//                           ),
//                         ),
//                         SizedBox(height: 10.h),
//                         Text(
//                           'Discover unlimited entertainments',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white54,
//                             fontSize: 13.sp,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const Spacer(),

//                 // Swipe slider
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 30.w),
//                   child: Container(
//                     height: 62.h,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.07),
//                       borderRadius: BorderRadius.circular(40.r),
//                       border: Border.all(
//                           color: Colors.white.withOpacity(0.12)),
//                     ),
//                     child: Stack(
//                       alignment: Alignment.centerLeft,
//                       children: [
//                         AnimatedContainer(
//                           duration: const Duration(milliseconds: 30),
//                           width: 50.r +
//                               (_sliderValue * (sliderWidth - 50.r)),
//                           height: 62.h,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF22C55E).withOpacity(0.25),
//                             borderRadius: BorderRadius.circular(40.r),
//                           ),
//                         ),
//                         Center(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'Home',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16.sp,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               SizedBox(width: 8.w),
//                               FadeTransition(
//                                 opacity: _arrowAnimation,
//                                 child: Text(
//                                   '>>>',
//                                   style: TextStyle(
//                                     color: Colors.white60,
//                                     fontSize: 16.sp,
//                                     letterSpacing: 3,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Positioned(
//                           left: _sliderValue * (sliderWidth - 50.r),
//                           child: GestureDetector(
//                             onHorizontalDragUpdate: (details) {
//                               setState(() {
//                                 double newVal = _sliderValue +
//                                     details.delta.dx / (sliderWidth - 50.r);
//                                 _sliderValue = newVal.clamp(0.0, 1.0);
//                               });
//                               if (_sliderValue >= 0.88) {
//                                 _navigateToHome();
//                               }
//                             },
//                             onHorizontalDragEnd: (_) {
//                               if (!_hasNavigated) {
//                                 setState(() => _sliderValue = 0.0);
//                               }
//                             },
//                             child: Container(
//                               margin: EdgeInsets.all(6.r),
//                               height: 50.r,
//                               width: 50.r,
//                               decoration: const BoxDecoration(
//                                 color: Color(0xFF22C55E),
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Color(0x6622C55E),
//                                     blurRadius: 12,
//                                     spreadRadius: 2,
//                                   ),
//                                 ],
//                               ),
//                               child: _isUnlocking
//                                   ? Padding(
//                                       padding: EdgeInsets.all(13.r),
//                                       child: const CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2,
//                                       ),
//                                     )
//                                   : Icon(
//                                       Icons.lock_open_rounded,
//                                       color: Colors.white,
//                                       size: 22.sp,
//                                     ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 40.h),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
