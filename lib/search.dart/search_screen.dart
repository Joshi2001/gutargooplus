import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:gutrgoopro/bottombar/bottom_controller.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/model/favorite_model.dart';
import 'package:gutrgoopro/search.dart/search_controller.dart';
import 'package:gutrgoopro/uitls/colors.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchScreen extends StatefulWidget {
  final bool fromBottomNav;
  const SearchScreen({super.key, required this.fromBottomNav});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  late final SearchControllerX controller;
  late final HomeController homeController;
  late final FavoritesController favoritesController;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  final List<String> _hints = ['Web Series...', 'Movies...'];
  int _hintIndex = 0;
  int _charIndex = 0;
  String _currentHint = '';
  bool _isDeleting = false;
  Timer? _typeTimer;
 @override
  void initState() {
    super.initState();
    print("error");
    // ✅ initState mein Get.find karo
    controller = Get.find<SearchControllerX>();
    homeController = Get.find<HomeController>();
    favoritesController = Get.find<FavoritesController>();
    
    _startTypewriter();
    // _initSpeech();
  }
//   Future<void> _toggleListening() async {
//     if (!_speechAvailable) {
//       Get.snackbar(
//         'Mic unavailable',
//         'Speech recognition not supported on this device',
//         backgroundColor: Colors.red.shade800,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }
//     if (_isListening) {
//       await _speech.stop();
//       setState(() => _isListening = false);
//     } else {
//       setState(() => _isListening = true);
//       _typeTimer?.cancel();
//       setState(() => _currentHint = '');
//       await _speech.listen(
//   onResult: (result) {
//     final words = result.recognizedWords;
//     if (mounted) {
//       setState(() {
//         searchController.text = words;
//         controller.query.value = words;
//       });
//       searchController.selection = TextSelection.fromPosition(
//         TextPosition(offset: words.length),
//       );
//     }
//   },
//   listenFor: const Duration(seconds: 30),
//   pauseFor: const Duration(seconds: 3),
//   partialResults: true,
//   cancelOnError: true,
// );
//     }
//   }

  void _startTypewriter() {
    _typeTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) return;
      final fullText = _hints[_hintIndex];
      setState(() {
        if (!_isDeleting) {
          if (_charIndex < fullText.length) {
            _charIndex++;
            _currentHint = fullText.substring(0, _charIndex);
          } else {
            _isDeleting = true;
            timer.cancel();
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (mounted) _startTypewriter();
            });
          }
        } else {
          if (_charIndex > 0) {
            _charIndex--;
            _currentHint = fullText.substring(0, _charIndex);
          } else {
            _isDeleting = false;
            _hintIndex = (_hintIndex + 1) % _hints.length;
            timer.cancel();
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _startTypewriter();
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    print("dispose");
    _typeTimer?.cancel();
    _speech.stop();
    searchController.dispose();
    super.dispose();
  }

  void _goBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    searchController.clear();
    controller.query.value = '';
    if (widget.fromBottomNav) {
      Get.find<NavigationController>().currentIndex.value = 0;
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50.h),

                // ── Search bar row ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: _goBack,
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.arrow_back,
                            color: Colors.white, size: 22.sp),
                      ),
                    ),
                    // SizedBox(width: 10.w),

                    // // Search field
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: TextField(
                          controller: searchController,
                          onChanged: (v) {
                            controller.query.value = v;
                            if (v.isEmpty) {
                              _typeTimer?.cancel();
                              _charIndex = 0;
                              _currentHint = '';
                              _isDeleting = false;
                              _startTypewriter();
                            } else {
                              _typeTimer?.cancel();
                              setState(() => _currentHint = '');
                            }
                          },
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              controller.addSearch(value.trim());
                            }
                          },
                          style:
                              TextStyle(color: Colors.white, fontSize: 14.sp),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: _isListening
                                ? 'Listening...'
                                : 'Search $_currentHint',
                            hintStyle: TextStyle(
                              color: _isListening
                                  ? Colors.red.shade300
                                  : Colors.white38,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: Icon(Icons.search,
                                color: Colors.white54, size: 18.sp),

                            // ✅ Mic button on right side
                            // suffixIcon: GestureDetector(
                            //   onTap: _toggleListening,
                            //   child: AnimatedContainer(
                            //     duration: const Duration(milliseconds: 200),
                            //     margin: EdgeInsets.all(8.r),
                            //     padding: EdgeInsets.all(6.r),
                            //     decoration: BoxDecoration(
                            //       color: _isListening
                            //           ? Colors.red
                            //           : Colors.grey.shade800,
                            //       shape: BoxShape.circle,
                            //     ),
                            //     child: Icon(
                            //       _isListening ? Icons.mic : Icons.mic_none,
                            //       color: Colors.white,
                            //       size: 16.sp,
                            //     ),
                            //   ),
                            // ),

                            filled: true,
                            fillColor: Colors.grey.shade900,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 15.w,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                  color: AppColors.orangedark, width: 2.w),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: _isListening
                                    ? Colors.red
                                    : AppColors.orangedark,
                                width: 2.w,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: _isListening
                                    ? Colors.red.withOpacity(0.5)
                                    : AppColors.orangedark,
                                width: 2.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Listening indicator ──
                if (_isListening)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h, left: 50.w),
                    child: Row(
                      children: [
                        _buildPulsingDot(),
                        SizedBox(width: 8.w),
                        Text(
                          'Listening... tap mic to stop',
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Recent searches (jab query empty ho) ──
                Obx(() {
                  if (controller.query.value.isEmpty &&
                      controller.recentSearches.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Searches',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: controller.clearAll,
                                child: Text(
                                  'Clear All',
                                  style: TextStyle(
                                    color: AppColors.orange,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: controller.recentSearches.map((s) {
                              return GestureDetector(
                                onTap: () {
                                  searchController.text = s;
                                  controller.query.value = s;
                                  _typeTimer?.cancel();
                                  setState(() => _currentHint = '');
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                        color: Colors.white12, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.history,
                                          color: Colors.white38, size: 12.sp),
                                      SizedBox(width: 4.w),
                                      Text(s,
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12.sp)),
                                      SizedBox(width: 6.w),
                                      GestureDetector(
                                        onTap: () =>
                                            controller.removeSearch(s),
                                        child: Icon(Icons.close,
                                            color: Colors.white38,
                                            size: 12.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 8.h),
                          Divider(color: Colors.white12, height: 1.h),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                }),

                // ── Results ──
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          final query =
                              controller.query.value.trim().toLowerCase();

                          if (query.isEmpty) return _allMoviesGrid();

                          final filtered = homeController.trendingList
                              .where((item) =>
                                  item['title']
                                      .toString()
                                      .toLowerCase()
                                      .contains(query) ||
                                  item['subtitle']
                                      .toString()
                                      .toLowerCase()
                                      .contains(query))
                              .toList();

                          if (filtered.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Text('No results found',
                                    style:
                                        TextStyle(color: Colors.white70)),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return GestureDetector(
                                onTap: () {
                                  controller.addSearch(item['title']);
                                  Get.to(() => VideoDetailScreen(
                                        videoTrailer: item['videoTrailer'],
                                        videoMoives: item['videoMovies'] ??
                                            item['videoTrailer'],
                                        image: item['image'] ?? '',
                                        subtitle: item['subtitle'] ?? '',
                                        videoTitle: item['title'],
                                        dis: item['dis'],
                                        logoImage: '',
                                      ));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 16.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    borderRadius:
                                        BorderRadius.circular(12.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12.r),
                                          topRight: Radius.circular(12.r),
                                        ),
                                        child: Image.asset(
                                          item['image'] ?? '',
                                          width: double.infinity,
                                          height: 300.h,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(12.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item['title'] ?? '',
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                Obx(() {
                                                  final inMyList =
                                                      favoritesController
                                                          .isInMyList(item[
                                                              'videoTrailer']);
                                                  return _actionBtn(
                                                    inMyList
                                                        ? Icons.check_circle
                                                        : Icons.add_outlined,
                                                    'Save',
                                                    onTap: () {
                                                      if (inMyList) {
                                                        favoritesController
                                                            .removeByvideoTrailer(
                                                                item['videoTrailer']);
                                                      } else {
                                                        favoritesController
                                                            .addFavorite(
                                                          FavoriteItem(
                                                            title: item[
                                                                'title'],
                                                            image: item[
                                                                    'image'] ??
                                                                '',
                                                            videoTrailer: item[
                                                                'videoTrailer'],
                                                            subtitle: item[
                                                                    'subtitle'] ??
                                                                '',
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    color: inMyList
                                                        ? Colors.red
                                                        : Colors.white,
                                                  );
                                                }),
                                                SizedBox(width: 12.w),
                                                _actionBtn(
                                                    Icons.info_outline,
                                                    'Detail'),
                                                SizedBox(width: 12.w),
                                                GestureDetector(
                                                  onTap: () {
                                                    controller.addSearch(
                                                        item['title']);
                                                    Get.to(() =>
                                                        VideoDetailScreen(
                                                          videoTrailer: item[
                                                              'videoTrailer'],
                                                          videoMoives: item[
                                                                  'videoMovies'] ??
                                                              item['videoTrailer'],
                                                          image: item[
                                                                  'image'] ??
                                                              '',
                                                          subtitle: item[
                                                                  'subtitle'] ??
                                                              '',
                                                          videoTitle:
                                                              item['title'],
                                                          dis: item['dis'],
                                                          logoImage: '',
                                                        ));
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(
                                                                8.r),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                            Icons.play_arrow,
                                                            color:
                                                                Colors.black,
                                                            size: 20.sp),
                                                      ),
                                                      SizedBox(height: 4.h),
                                                      Text('Play',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                              fontSize:
                                                                  10.sp)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.h),
                                            // Row(
                                            //   children: [
                                            //     Container(
                                            //       padding: EdgeInsets.symmetric(
                                            //           horizontal: 6.w,
                                            //           vertical: 2.h),
                                            //       decoration: BoxDecoration(
                                            //         color: const Color(
                                            //             0xFFFFB800),
                                            //         borderRadius:
                                            //             BorderRadius.circular(
                                            //                 4.r),
                                            //       ),
                                            //       child: Text('VIP',
                                            //           style: TextStyle(
                                            //               color: Colors.black,
                                            //               fontSize: 10.sp,
                                            //               fontWeight: FontWeight
                                            //                   .bold)),
                                            //     ),
                                            //     SizedBox(width: 8.w),
                                            //     Text(
                                            //         '2024  |  India  |  1 Part',
                                            //         style: TextStyle(
                                            //             color: Colors.white54,
                                            //             fontSize: 11.sp)),
                                            //   ],
                                            // ),
                                            // SizedBox(height: 8.h),
                                            Text(item['dis'] ?? '',
                                                maxLines: 3,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12.sp,
                                                    height: 1.5)),
                                            SizedBox(height: 8.h),
                                            Text(item['subtitle'] ?? '',
                                                style: TextStyle(
                                                    color: Colors.white38,
                                                    fontSize: 11.sp)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Pulsing dot for listening indicator ──
  Widget _buildPulsingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8.r,
            height: 8.r,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _allMoviesGrid() {
    return Obx(() {
      final list = homeController.trendingList;
      if (list.isEmpty) return const SizedBox();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Text(
            'Recommended for You',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 0.65,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return GestureDetector(
                onTap: () {
                  controller.addSearch(item['title']);
                  Get.to(() => VideoDetailScreen(
                        videoTrailer: item['videoTrailer'],
                        videoMoives:
                            item['videoMovies'] ?? item['videoTrailer'],
                        image: item['image'] ?? '',
                        subtitle: item['subtitle'] ?? '',
                        videoTitle: item['title'],
                        dis: item['dis'],
                        logoImage: '',
                      ));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    item['image'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade800,
                      child: Icon(Icons.movie,
                          color: Colors.white54, size: 30.sp),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _actionBtn(IconData icon, String label,
      {VoidCallback? onTap, Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54, width: 1.5),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(height: 4.h),
          Text(label,
              style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'dart:async';
// import 'package:gutrgoopro/bottombar/bottom_controller.dart';
// import 'package:gutrgoopro/home/getx/home_controller.dart';
// import 'package:gutrgoopro/home/screen/details_screen.dart';
// import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
// import 'package:gutrgoopro/profile/model/favorite_model.dart';
// import 'package:gutrgoopro/search.dart/search_controller.dart';
// import 'package:gutrgoopro/uitls/colors.dart';

// class SearchScreen extends StatefulWidget {
//   final bool fromBottomNav;
//   const SearchScreen({super.key, required this.fromBottomNav});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController searchController = TextEditingController();
//   final SearchControllerX controller = Get.find<SearchControllerX>();
//   final HomeController homeController = Get.find<HomeController>();
//   final FavoritesController favoritesController = Get.find<FavoritesController>();


//  final List<String> _hints = [
//   'Web Series...',
//   'Movies...',
// ];
//   int _hintIndex = 0;
//   int _charIndex = 0;
//   String _currentHint = '';
//   bool _isDeleting = false;
//   Timer? _typeTimer;

//   @override
//   void initState() {
//     super.initState();
//     _startTypewriter();
//   }

//   void _startTypewriter() {
//     _typeTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
//       if (!mounted) return;

//       final fullText = _hints[_hintIndex];

//       setState(() {
//         if (!_isDeleting) {
//           // Typing
//           if (_charIndex < fullText.length) {
//             _charIndex++;
//             _currentHint = fullText.substring(0, _charIndex);
//           } else {
//             // Pause then start deleting
//             _isDeleting = true;
//             timer.cancel();
//             Future.delayed(const Duration(milliseconds: 1200), () {
//               if (mounted) _startTypewriter();
//             });
//           }
//         } else {
//           // Deleting
//           if (_charIndex > 0) {
//             _charIndex--;
//             _currentHint = fullText.substring(0, _charIndex);
//           } else {
//             _isDeleting = false;
//             _hintIndex = (_hintIndex + 1) % _hints.length;
//             timer.cancel();
//             Future.delayed(const Duration(milliseconds: 300), () {
//               if (mounted) _startTypewriter();
//             });
//           }
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _typeTimer?.cancel();
//     searchController.dispose();
//     super.dispose();
//   }

//   void _goBack() {
//   FocusManager.instance.primaryFocus?.unfocus();
//   searchController.clear();
//   controller.query.value = '';

//   if (widget.fromBottomNav) {
//     Get.find<NavigationController>().currentIndex.value = 0;
//   } else {
//     Get.back(); 
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//      onWillPop: () async {
//       if (widget.fromBottomNav) {
//         Get.find<NavigationController>().currentIndex.value = 0;
//         return false;
//       } else {
//         return true; 
//       }
//     },
//       child: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Scaffold(
//           resizeToAvoidBottomInset: false,
//           backgroundColor: Colors.black,
//           body: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 50.h),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: _goBack,
//                       child: Container(
//                         width: 36.w,
//                         height: 36.h,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade900,
//                           shape: BoxShape.circle,
//                         ),
//                         alignment: Alignment.center,
//                         child: Icon(
//                           Icons.arrow_back,
//                           color: Colors.white,
//                           size: 22.sp,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 10.w),
//                     Expanded(
//                       child: SizedBox(
//                         height: 50.h,
//                         child: TextField(
//                           controller: searchController,
//                           onChanged: (v) {
//   controller.query.value = v;
//   if (v.isEmpty) {
//     _typeTimer?.cancel();
//     _charIndex = 0;
//     _currentHint = '';
//     _isDeleting = false;
//     _startTypewriter();
//   } else {
//     _typeTimer?.cancel();
//     setState(() => _currentHint = '');
//   }
// },
//                           onSubmitted: (value) {
//                             if (value.trim().isNotEmpty) {
//                               controller.addSearch(value.trim());
//                             }
//                           },
//                           style: TextStyle(color: Colors.white, fontSize: 14.sp),
//                           decoration: InputDecoration(
//                             isDense: true,
//                             hintText: 'Search $_currentHint',
//                             hintStyle: TextStyle(
//                               color: Colors.white38,
//                               fontSize: 12.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             prefixIcon: Icon(Icons.search,
//                                 color: Colors.white54, size: 18.sp),
//                             filled: true,
//                             fillColor: Colors.grey.shade900,
//                             contentPadding: EdgeInsets.symmetric(
//                               vertical: 0,
//                               horizontal: 15.w,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                               borderSide: BorderSide(
//                                   color: AppColors.orangedark, width: 2.w),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                               borderSide: BorderSide(
//                                   color: AppColors.orangedark, width: 2.w),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Obx(() {
//                           final query =
//                               controller.query.value.trim().toLowerCase();

//                           if (query.isEmpty) {
//                             return _allMoviesGrid();
//                           }

//                           final filtered = homeController.trendingList
//                               .where((item) =>
//                                   item['title']
//                                       .toString()
//                                       .toLowerCase()
//                                       .contains(query) ||
//                                   item['subtitle']
//                                       .toString()
//                                       .toLowerCase()
//                                       .contains(query))
//                               .toList();

//                           if (filtered.isEmpty) {
//                             return const Center(
//                               child: Padding(
//                                 padding: EdgeInsets.only(top: 40),
//                                 child: Text(
//                                   'No results found',
//                                   style: TextStyle(color: Colors.white70),
//                                 ),
//                               ),
//                             );
//                           }

//                           return ListView.builder(
//                             shrinkWrap: true,
//                             padding: EdgeInsets.zero,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemCount: filtered.length,
//                             itemBuilder: (context, index) {
//                               final item = filtered[index];
//                               return GestureDetector(
//                                 onTap: () {
//                                   controller.addSearch(item['title']);
//                                   Get.to(() => VideoDetailScreen(
//                                         videoTrailer: item['videoTrailer'],
//                                         videoMoives: item['videoMovies'] ??
//                                             item['videoTrailer'],
//                                         image: item['image'] ?? '',
//                                         subtitle: item['subtitle'] ?? '',
//                                         videoTitle: item['title'],
//                                         dis: item['dis'], logoImage: '',
//                                       ));
//                                 },
//                                 child: Container(
//                                   margin: EdgeInsets.only(bottom: 16.h),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF1A1A1A),
//                                     borderRadius: BorderRadius.circular(12.r),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(12.r),
//                                           topRight: Radius.circular(12.r),
//                                         ),
//                                         child: Image.asset(
//                                           item['image'] ?? '',
//                                           width: double.infinity,
//                                           height: 300.h,
//                                           fit: BoxFit.fill,
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.all(12.w),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                               children: [
//                                                 Expanded(
//                                                   child: Text(
//                                                     item['title'] ?? '',
//                                                     maxLines: 2,
//                                                     style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 16.sp,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(width: 8.w),
//                                                 Obx(() {
//                                                   final inMyList =
//                                                       favoritesController
//                                                           .isInMyList(
//                                                               item['videoTrailer']);
//                                                   return _actionBtn(
//                                                     inMyList
//                                                         ? Icons.check_circle
//                                                         : Icons.add_outlined,
//                                                     'Save',
//                                                     onTap: () {
//                                                       if (inMyList) {
//                                                         favoritesController
//                                                             .removeByvideoTrailer(
//                                                                 item['videoTrailer']);
//                                                       } else {
//                                                         favoritesController
//                                                             .addFavorite(
//                                                           FavoriteItem(
//                                                             title: item['title'],
//                                                             image: item['image'] ?? '',
//                                                             videoTrailer: item['videoTrailer'],
//                                                             subtitle: item['subtitle'] ?? '',
//                                                           ),
//                                                         );
//                                                       }
//                                                     },
//                                                     color: inMyList
//                                                         ? Colors.red
//                                                         : Colors.white,
//                                                   );
//                                                 }),
//                                                 SizedBox(width: 12.w),
//                                                 _actionBtn(Icons.info_outline, 'Detail'),
//                                                 SizedBox(width: 12.w),
//                                                 GestureDetector(
//                                                   onTap: () {
//                                                     controller.addSearch(item['title']);
//                                                     Get.to(() => VideoDetailScreen(
//                                                           videoTrailer: item['videoTrailer'],
//                                                           videoMoives: item['videoMovies'] ?? item['videoTrailer'],
//                                                           image: item['image'] ?? '',
//                                                           subtitle: item['subtitle'] ?? '',
//                                                           videoTitle: item['title'],
//                                                           dis: item['dis'], logoImage: '',
//                                                         ));
//                                                   },
//                                                   child: Column(
//                                                     children: [
//                                                       Container(
//                                                         padding: EdgeInsets.all(8.r),
//                                                         decoration: const BoxDecoration(
//                                                           color: Colors.white,
//                                                           shape: BoxShape.circle,
//                                                         ),
//                                                         child: Icon(Icons.play_arrow,
//                                                             color: Colors.black,
//                                                             size: 20.sp),
//                                                       ),
//                                                       SizedBox(height: 4.h),
//                                                       Text('Play',
//                                                           style: TextStyle(
//                                                               color: Colors.white70,
//                                                               fontSize: 10.sp)),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(height: 8.h),
//                                             Row(
//                                               children: [
//                                                 Container(
//                                                   padding: EdgeInsets.symmetric(
//                                                       horizontal: 6.w, vertical: 2.h),
//                                                   decoration: BoxDecoration(
//                                                     color: const Color(0xFFFFB800),
//                                                     borderRadius: BorderRadius.circular(4.r),
//                                                   ),
//                                                   child: Text('VIP',
//                                                       style: TextStyle(
//                                                           color: Colors.black,
//                                                           fontSize: 10.sp,
//                                                           fontWeight: FontWeight.bold)),
//                                                 ),
//                                                 SizedBox(width: 8.w),
//                                                 Text('2024  |  India  |  1 Part',
//                                                     style: TextStyle(
//                                                         color: Colors.white54,
//                                                         fontSize: 11.sp)),
//                                               ],
//                                             ),
//                                             SizedBox(height: 8.h),
//                                             Text(item['dis'] ?? '',
//                                                 maxLines: 3,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: TextStyle(
//                                                     color: Colors.white70,
//                                                     fontSize: 12.sp,
//                                                     height: 1.5)),
//                                             SizedBox(height: 8.h),
//                                             Text(item['subtitle'] ?? '',
//                                                 style: TextStyle(
//                                                     color: Colors.white38,
//                                                     fontSize: 11.sp)),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         }),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _allMoviesGrid() {
//     return Obx(() {
//       final list = homeController.trendingList;
//       if (list.isEmpty) return const SizedBox();

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 16.h),
//           Text(
//             'Recommended for You',
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 1,
//             ),
//           ),
//           SizedBox(height: 12.h),
//           GridView.builder(
//             shrinkWrap: true,
//             padding: EdgeInsets.zero,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 8.w,
//               mainAxisSpacing: 8.h,
//               childAspectRatio: 0.65,
//             ),
//             itemCount: list.length,
//             itemBuilder: (context, index) {
//               final item = list[index];
//               return GestureDetector(
//                 onTap: () {
//                   controller.addSearch(item['title']);
//                   Get.to(() => VideoDetailScreen(
//                         videoTrailer: item['videoTrailer'],
//                         videoMoives: item['videoMovies'] ?? item['videoTrailer'],
//                         image: item['image'] ?? '',
//                         subtitle: item['subtitle'] ?? '',
//                         videoTitle: item['title'],
//                         dis: item['dis'], logoImage: '',
//                       ));
//                 },
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8.r),
//                   child: Image.asset(
//                     item['image'] ?? '',
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => Container(
//                       color: Colors.grey.shade800,
//                       child: Icon(Icons.movie,
//                           color: Colors.white54, size: 30.sp),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       );
//     });
//   }

//   Widget _actionBtn(IconData icon, String label,
//       {VoidCallback? onTap, Color color = Colors.white}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8.r),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white54, width: 1.5),
//             ),
//             child: Icon(icon, color: color, size: 18.sp),
//           ),
//           SizedBox(height: 4.h),
//           Text(label,
//               style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
//         ],
//       ),
//     );
//   }
// }
