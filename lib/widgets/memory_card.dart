import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muchi/data/memory.dart';
import 'package:muchi/utils/helpers.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  final int index;
  final VoidCallback onTap;

  const MemoryCard({
    super.key,
    required this.memory,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Stack(
          children: [
            // Timeline line
            Positioned(
              left: 30,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                color: const Color(0xFFFFB6C1).withOpacity(0.3),
              ),
            ),

            // Heart connector
            Positioned(
              left: 20,
              top: 40,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: memory.isMilestone
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFFF6B6B),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: memory.isMilestone
                          ? const Color(0xFFD4AF37).withOpacity(0.5)
                          : const Color(0xFFFF6B6B).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),

            // Memory Card
            Container(
              margin: const EdgeInsets.only(left: 50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.shade100.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: memory.isMilestone
                            ? [
                                const Color(0xFFD4AF37).withOpacity(0.1),
                                const Color(0xFFFFD700).withOpacity(0.05),
                              ]
                            : [
                                const Color(0xFFFFB6C1).withOpacity(0.1),
                                const Color(0xFFFFE4E1).withOpacity(0.05),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 16,
                              color: memory.isMilestone
                                  ? const Color(0xFFD4AF37)
                                  : const Color(0xFFFF6B6B),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM dd, yyyy').format(memory.date),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: memory.isMilestone
                                    ? const Color(0xFFD4AF37)
                                    : const Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              getWeatherIcon(memory.weather),
                              size: 18,
                              color: const Color(0xFF4FC3F7),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              getMoodIcon(memory.mood),
                              color: const Color(0xFFFFB6C1),
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      memory.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),

                  // Photo Preview
                  if (memory.photos.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          child: Container(
                            color: Colors.pink.shade100,
                            child: const Center(
                              child: Icon(
                                Icons.photo,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Highlights
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...memory.highlights.map((highlight) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: memory.isMilestone
                                          ? const Color(0xFFD4AF37)
                                          : const Color(0xFFFF6B6B),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      highlight,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.4,
                                        color: Color(0xFF555555),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              memory.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                        // Love Rating
                        Row(
                          children: List.generate(
                            5,
                            (index) => Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Icon(
                                Icons.favorite,
                                size: 16,
                                color: index < memory.loveRating
                                    ? const Color(0xFFFF6B6B)
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),

                        // Tags preview
                        if (memory.tags.isNotEmpty)
                          Text(
                            memory.tags[0],
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFFFF6B6B).withOpacity(0.8),
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
      ),
    );
  }
}
