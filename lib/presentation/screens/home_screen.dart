import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'movie_details_screen.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final Dio _dio = Dio();

  List movies = [];
  int currentPage = 1;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMore) {
      fetchMoreMovies();
    }
  }

  Future<void> fetchMovies({int page = 1}) async {
    try {
      var response = await _dio.get(
        "https://omdbapi.com/",
        queryParameters: {"apikey": "1227a426", "s": "avengers", "page": page},
      );

      if (response.statusCode == 200 &&
          response.data["Search"] != null &&
          mounted) {
        setState(() {
          movies = response.data["Search"];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching movies: $e");
    }
  }

  Future<void> fetchMoreMovies() async {
    setState(() => isLoadingMore = true);
    currentPage++;

    try {
      var response = await _dio.get(
        "https://omdbapi.com/",
        queryParameters: {
          "apikey": "1227a426",
          "s": "avengers",
          "page": currentPage,
        },
      );

      if (response.statusCode == 200 && response.data["Search"] != null) {
        setState(() {
          movies.addAll(response.data["Search"]);
        });
      } else {
        setState(() => hasMore = false);
      }
    } catch (e) {
      debugPrint("Pagination error: $e");
      setState(() => hasMore = false);
    }

    setState(() => isLoadingMore = false);
  }

  // Navigation method
  void _navigateToMovieDetails(Map<String, dynamic> movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(imdbID: movie["imdbID"]),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF160707),
      body: SafeArea(
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                )
                : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      currentPage = 1;
                      movies.clear();
                      hasMore = true;
                    });
                    await fetchMovies();
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 250,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    movies.isNotEmpty
                                        ? movies[0]["Poster"]
                                        : "https://via.placeholder.com/400x250",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              height: 250,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              right: 16,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.search,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextField(
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                              decoration: const InputDecoration(
                                                hintText: "Search Movie",
                                                hintStyle: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.notifications_none,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: CarouselSlider.builder(
                            itemCount: movies.length > 5 ? 5 : movies.length,
                            itemBuilder: (context, index, realIndex) {
                              final movie = movies[index];
                              return GestureDetector(
                                onTap: () => _navigateToMovieDetails(movie),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        movie["Poster"],
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.8),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            movie["Title"],
                                            style: GoogleFonts.spaceGrotesk(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            options: CarouselOptions(
                              height: 220,
                              enlargeCenterPage: true,
                              autoPlay: true,
                              viewportFraction: 0.4,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 🔥 Trending Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Trending Movies Near You",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _horizontalMovieList(height: 140, count: 6),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Upcoming",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _horizontalMovieList(height: 200, count: 5, wide: true),

                        if (isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _horizontalMovieList({
    required double height,
    required int count,
    bool wide = false,
  }) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length < count ? movies.length : count,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () => _navigateToMovieDetails(movie),
            child: Container(
              margin: const EdgeInsets.only(left: 16),
              width: wide ? 140 : 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      movie["Poster"],
                      height: wide ? 140 : 100,
                      width: wide ? 140 : 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      movie["Title"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
