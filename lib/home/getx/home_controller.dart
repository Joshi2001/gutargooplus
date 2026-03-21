import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
   final ScrollController scrollController = ScrollController();
  final RxBool isTopBarSolid = false.obs;
  RxInt selectedCategoryIndex = 0.obs; 
  
 void clearContinueWatching() {
    continueWatching.clear();
  }
final List<String> categoryNames = [
  "Home",
  'Movies',
  'TV Shows',
  'Web Series',
];
final RxInt selectedLiveMatchIndex = 0.obs;

void selectLiveMatch(int index) {
  selectedLiveMatchIndex.value = index;
}
 void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }



  final RxInt currentBannerIndex = 0.obs;
  final RxString bannerTitle = ''.obs;
  final RxString bannerSubtitle = ''.obs;
  final RxString bannerSeason = ''.obs;

  PageController pageController = PageController();
  Timer? _timer;

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!pageController.hasClients) return;

      int nextPage = currentBannerIndex.value + 1;
      // if (nextPage >= banners.length) nextPage = 0;

      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

    });
  }

  final PageController heroController = PageController(
  initialPage: 1,
  viewportFraction: 0.92,  
);
  void onBannerPageChanged(int index) {
    currentBannerIndex.value = index;
  
  }

 

  final RxList<Map<String, dynamic>> trendingList = <Map<String, dynamic>>[
    {
      "image": "assets/1.png",
      "title": "The Networker (Trailer)",
      "subtitle": "Comedy . Thriller",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/24d07fc8-2468-45f9-95be-290a06553197/playlist.m3u8',
      'videoMovies': 'https://vz-fd5fa6c8-ece.b-cdn.net/24d07fc8-2468-45f9-95be-290a06553197/playlist.m3u8',
      "dis":"After his MLM company fails, Aditya partners with networker Lallan and friend Raghav to launch new ventures backed by Pradhan. They hire a motivational speaker and fake MD before absconding to Dubai with investors",
    },
    {
      "image": "assets/img4.png",
      "title": "Alien Frank",
      "subtitle": "Comedy . Thriller",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/0c0f5ae6-316d-48c3-8ea1-4de616bb62ec/playlist.m3u8',
      'videoMovies':'https://vz-fd5fa6c8-ece.b-cdn.net/fa890afd-7f35-4cf1-a8f4-fb6131948bd3/playlist.m3u8',
      "dis":"Alien Frank is a thought-provoking Hindi movie that explores the life of Adolf Hitler through his own perspective—a never-seen-before angle that challenges history, truth, and propaganda",
    },
     {
      "image": "assets/img3.jpeg",
      "title": "Sumeru",
      "subtitle": "ROMANCE, MUSICAL, COMEDY",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/74cd202a-fad1-4a09-9db0-95469c58e6f0/playlist.m3u8',
      'videoMovies': 'https://vz-fd5fa6c8-ece.b-cdn.net/1da2826f-84ed-4f42-9941-47ba419f9f57/playlist.m3u8',
      "dis":"Bhavar Paratp Singh has left everything is search of his father and he meets Savi accidentally who came for her destination wedding in Harsil. The story further continues in their struggle of finding Bhavar's father and they eventually fall in love in the journey",
    },
    {
      "image": "assets/awasaan_trailer.jpg",
      "title": "Awasaan",
      "subtitle": "Hindi • Drama ",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/5f48d5c0-af80-48a7-bfc1-93017cf7ee2b/playlist.m3u8',
      'videoMovies': 'https://vz-fd5fa6c8-ece.b-cdn.net/5f48d5c0-af80-48a7-bfc1-93017cf7ee2b/playlist.m3u8',
      "dis":"This film tells the story of a 27 year old boy named Satyawan Shukla who hails from Prayagraj and from a lower middle class family. His father is a poor priest and mother house wife, his father falls pray to a social change which urges him to make his son engineer for which he has to sell 50% of his farm l and. After not finding a satisfactory job Satyawan leaves for Lucknow and there he prepares for a government job and at the same time searching for a private job. He struggles to find a s mall pay scale job, which could not support his family economics as a result Satyawan is forced t o do small and odd jobs even though he has to sell newspapers and repair mobile phones, but suddenly a Government job vacancy comes on his way he happily goes to apply for it but on finding that there is only 2 vacancies for general category. He decided not to apply for it and at the same time he finds that if he can manage a government officer he may get a government job, he does it and becomes a car driver of a government officer after spending some time he persuades the officer for one job in exchange of Rs. 15 Lakh. Satyawan father sells his every piece of land and gives 15 lakh to that officer. Now the question is will Satyawan get one job in a government department or will something else happen to Satyawan?",
    },
    {
      "image": "assets/red_trailer.jpg",
      "title": "The Red Land",
      "subtitle": "Crime • Drama • Action",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/ca6482b3-f5c9-4e82-a5bb-25c21b327a2f/playlist.m3u8',
      'videoMovies': 'https://vz-fd5fa6c8-ece.b-cdn.net/34764e34-c1a3-4b5b-a31f-e7e36b2b566c/playlist.m3u8',
      "dis":"Bhavar Paratp Singh has left everything is search of his father and he meets Savi accidentally who came for her destination wedding in Harsil. The story further continues in their struggle of finding Bhavar's father and they eventually fall in love in the journey",
    },
  ].obs;
final RxList<Map<String, dynamic>> top10List = <Map<String, dynamic>>[
     {
      "image": "assets/1.png",
      "title": "The Networker (Trailer)",
      "subtitle": "Comedy . Thriller",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/24d07fc8-2468-45f9-95be-290a06553197/playlist.m3u8',
      'videoMovies': 'https://vz-fd5fa6c8-ece.b-cdn.net/24d07fc8-2468-45f9-95be-290a06553197/playlist.m3u8',
      "dis":"After his MLM company fails, Aditya partners with networker Lallan and friend Raghav to launch new ventures backed by Pradhan. They hire a motivational speaker and fake MD before absconding to Dubai with investors",
    },
    {
      "image": "assets/img4.png",
      "title": "Alien Frank",
      "subtitle": "Comedy . Thriller",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/0c0f5ae6-316d-48c3-8ea1-4de616bb62ec/playlist.m3u8',
      'videoMovies':'https://vz-fd5fa6c8-ece.b-cdn.net/fa890afd-7f35-4cf1-a8f4-fb6131948bd3/playlist.m3u8',
      "dis":"Alien Frank is a thought-provoking Hindi movie that explores the life of Adolf Hitler through his own perspective—a never-seen-before angle that challenges history, truth, and propaganda",
    },
     {
      "image": "assets/img3.jpeg",
      "title": "Sumeru",
      "subtitle": "ROMANCE, MUSICAL, COMEDY",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/74cd202a-fad1-4a09-9db0-95469c58e6f0/playlist.m3u8',
      'videoMovies': 'https://vz-fd5fa6c8-ece.b-cdn.net/1da2826f-84ed-4f42-9941-47ba419f9f57/playlist.m3u8',
      "dis":"Bhavar Paratp Singh has left everything is search of his father and he meets Savi accidentally who came for her destination wedding in Harsil. The story further continues in their struggle of finding Bhavar's father and they eventually fall in love in the journey",
    },
    {
      "image": "assets/awasaan_trailer.jpg",
      "title": "Awasaan",
      "subtitle": "Hindi • Drama r",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/5f48d5c0-af80-48a7-bfc1-93017cf7ee2b/playlist.m3u8',
      'videoMovies': 'https://vz-fd5fa6c8-ece.b-cdn.net/5f48d5c0-af80-48a7-bfc1-93017cf7ee2b/playlist.m3u8',
      "dis":"This film tells the story of a 27 year old boy named Satyawan Shukla who hails from Prayagraj and from a lower middle class family. His father is a poor priest and mother house wife, his father falls pray to a social change which urges him to make his son engineer for which he has to sell 50% of his farm l and. After not finding a satisfactory job Satyawan leaves for Lucknow and there he prepares for a government job and at the same time searching for a private job. He struggles to find a s mall pay scale job, which could not support his family economics as a result Satyawan is forced t o do small and odd jobs even though he has to sell newspapers and repair mobile phones, but suddenly a Government job vacancy comes on his way he happily goes to apply for it but on finding that there is only 2 vacancies for general category. He decided not to apply for it and at the same time he finds that if he can manage a government officer he may get a government job, he does it and becomes a car driver of a government officer after spending some time he persuades the officer for one job in exchange of Rs. 15 Lakh. Satyawan father sells his every piece of land and gives 15 lakh to that officer. Now the question is will Satyawan get one job in a government department or will something else happen to Satyawan?",
    },
    {
      "image": "assets/red_trailer.jpg",
      "title": "The Red Land",
      "subtitle": "Crime • Drama • Action",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/ca6482b3-f5c9-4e82-a5bb-25c21b327a2f/playlist.m3u8',
      'videoMovies': 'https://vz-fd5fa6c8-ece.b-cdn.net/34764e34-c1a3-4b5b-a31f-e7e36b2b566c/playlist.m3u8',
      "dis":"Bhavar Paratp Singh has left everything is search of his father and he meets Savi accidentally who came for her destination wedding in Harsil. The story further continues in their struggle of finding Bhavar's father and they eventually fall in love in the journey",
    },
  ].obs;

  final RxList<Map<String, dynamic>> continueWatching = <Map<String, dynamic>>[
    {
      "image": "assets/1.png",
      "title": "The Networker (Trailer)",
      "subtitle": "Comedy . Thriller",
      "progress": 0.6,
      "duration": "2:45:00",
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/24d07fc8-2468-45f9-95be-290a06553197/playlist.m3u8',
      "dis":"After his MLM company fails, Aditya partners with networker Lallan and friend Raghav to launch new ventures backed by Pradhan. They hire a motivational speaker and fake MD before absconding to Dubai with investors",
      'videoMovies': 'https://vz-fd5fa6c8-ece.b-cdn.net/24d07fc8-2468-45f9-95be-290a06553197/playlist.m3u8',
      
    },
    {
      "image": "assets/img4.png",
      "title": "Alien Frank",
      "subtitle": "Lakers vs Heat",
      "progress": 0.4,
      "duration": "2:15:00",
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/fa890afd-7f35-4cf1-a8f4-fb6131948bd3/playlist.m3u8',
      "dis":"Alien Frank is a thought-provoking Hindi movie that explores the life of Adolf Hitler through his own perspective—a never-seen-before angle that challenges history, truth, and propaganda",
      'videoMovies':'https://vz-fd5fa6c8-ece.b-cdn.net/fa890afd-7f35-4cf1-a8f4-fb6131948bd3/playlist.m3u8'
    },
     {
      "image": "assets/img3.jpeg",
      "title": "Sumeru",
      "subtitle": "ROMANCE, MUSICAL, COMEDY",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/74cd202a-fad1-4a09-9db0-95469c58e6f0/playlist.m3u8',
      'videoMovies': 'https://vz-fd5fa6c8-ece.b-cdn.net/1da2826f-84ed-4f42-9941-47ba419f9f57/playlist.m3u8',
      "dis":"Bhavar Paratp Singh has left everything is search of his father and he meets Savi accidentally who came for her destination wedding in Harsil. The story further continues in their struggle of finding Bhavar's father and they eventually fall in love in the journey",
    },
  {
      "image": "assets/img4.jpeg",
      "title": "Art Of The Dead",
      "subtitle": "Comedy . Thriller",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/74cd202a-fad1-4a09-9db0-95469c58e6f0/playlist.m3u8',
      'videoMovies': 'https://vz-fd5fa6c8-ece.b-cdn.net/1da2826f-84ed-4f42-9941-47ba419f9f57/playlist.m3u8',
      "dis":"Bhavar Paratp Singh has left everything is search of his father and he meets Savi accidentally who came for her destination wedding in Harsil. The story further continues in their struggle of finding Bhavar's father and they eventually fall in love in the journey",
    },
    {
      "image": "assets/6.jpg",
      "title": "Bad Cat",
      "subtitle": "Comedy . Thriller",
      "live": true,
      'videoTrailer': 'https://vz-fd5fa6c8-ece.b-cdn.net/74cd202a-fad1-4a09-9db0-95469c58e6f0/playlist.m3u8',
      'videoMovies': 'https://vz-fd5fa6c8-ece.b-cdn.net/1da2826f-84ed-4f42-9941-47ba419f9f57/playlist.m3u8',
      "dis":"Bhavar Paratp Singh has left everything is search of his father and he meets Savi accidentally who came for her destination wedding in Harsil. The story further continues in their struggle of finding Bhavar's father and they eventually fall in love in the journey",
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
      selectedCategoryIndex.value = 0;

    _startAutoScroll();
    scrollController.addListener(() {
  if (scrollController.offset <= 0) {
    
    isTopBarSolid.value = true;
  } else {
    
    isTopBarSolid.value = false;
  }
});
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    scrollController.dispose();
    super.onClose();
  }


  Future<void> fetchHomeData() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}