import 'package:flutter/material.dart';
import 'package:ziesocial/model/story_model.dart';

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data untuk Stories sesuai referensi UI
    final List<StoryModel> stories = [
      StoryModel(
        username: 'Your Story',
        avatarUrl: 'https://picsum.photos/seed/user/200',
        isUser: true,
      ),
    ];

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final story = stories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: story.isUser
                              ? Colors.transparent
                              : const Color(0xFF4F46E5),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(story.avatarUrl),
                      ),
                    ),
                    if (story.isUser)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF4F46E5),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  story.username,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}