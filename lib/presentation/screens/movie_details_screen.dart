import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking_screen.dart'; // Import the booking screen

class MovieDetailsScreen extends StatefulWidget {
  final String imdbID;

  const MovieDetailsScreen({super.key, required this.imdbID});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  Map<String, dynamic>? movie;
  bool isLoading = true;
  int selectedDateIndex = 0;
  int selectedTimeIndex = 0;

  final List<String> dates = ["12", "13", "14", "15", "16", "17", "18"];
  final List<String> days = ["Fri", "Sat", "Sun", "Mon", "Tue", "Wed", "Thu"];
  final List<String> times = [
    "09:00 AM",
    "12:00 PM",
    "03:00 PM",
    "06:00 PM",
    "09:30 PM",
  ];

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
  }

  Future<void> fetchMovieDetails() async {
    try {
      var response = await Dio().get(
        "https://www.omdbapi.com/",
        queryParameters: {
          "apikey": "1227a426",
          "i": widget.imdbID,
          "plot": "full",
        },
      );

      if (response.statusCode == 200 && response.data["Response"] == "True") {
        setState(() {
          movie = response.data;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching movie details: $e");
    }
  }

  void _navigateToBookingSuccess() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BookingSuccessScreen(
              movieName: movie?["Title"] ?? "Movie",
              subtitle: movie?["Genre"]?.split(",").first ?? "Action",
              date: "${dates[selectedDateIndex]} ${days[selectedDateIndex]}",
              time: times[selectedTimeIndex],
              row: "A", // You can make this dynamic based on seat selection
              seats:
                  "A1, A2", // You can make this dynamic based on seat selection
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF160707),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.red),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🎬 Poster Section
                    Stack(
                      children: [
                        Container(
                          height: 280,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                movie?["Poster"] ??
                                    "https://via.placeholder.com/400x600",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          height: 280,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.85),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 16,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  movie?["Poster"] ??
                                      "https://via.placeholder.com/100x150",
                                  height: 120,
                                  width: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 130,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie?["Title"] ?? "",
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _buildTag(
                                          movie?["Genre"]?.split(",")[0],
                                        ),
                                        const SizedBox(width: 6),
                                        _buildTag(
                                          movie?["Genre"]?.split(",")[1],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "⭐ ${movie?["imdbRating"] ?? "N/A"} IMDb",
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Colors.orangeAccent,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        movie?["Plot"] ?? "",
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white70,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoTile("Director", movie?["Director"]),
                          _buildInfoTile("Actors", movie?["Actors"]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 📅 Date Selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Select Date",
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 85,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dates.length,
                        itemBuilder: (context, index) {
                          final isSelected = selectedDateIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedDateIndex = index);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 16),
                              padding: const EdgeInsets.all(10),
                              width: 55,
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.redAccent
                                        : Colors.white12,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    days[index],
                                    style: GoogleFonts.spaceGrotesk(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dates[index],
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ⏰ Time Selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Select Time",
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: times.length,
                        itemBuilder: (context, index) {
                          final isSelected = selectedTimeIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedTimeIndex = index);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.redAccent
                                        : Colors.white12,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  times[index],
                                  style: GoogleFonts.spaceGrotesk(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _navigateToBookingSuccess,
                        child: Center(
                          child: Text(
                            "BOOK NOW",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
    );
  }

  Widget _buildTag(String? text) {
    if (text == null || text.trim().isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 12),
      ),
    );
  }

  Widget _buildInfoTile(String title, String? value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? "N/A",
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
