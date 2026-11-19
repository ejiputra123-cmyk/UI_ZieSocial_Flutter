import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/core/constants.dart';
import 'package:ziesocial/model/story_model.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  static const Color _onSurface = Color(0xFF1C1B1B);
  static const Color _secondary = Color(0xFF5E5D6C);
  static const Color _primary = Color(0xFF4D3BCE);
  static const Color _primaryFixed = Color(0xFFE4DFFF);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _surfaceContainer = Color(0xFFF0EDED);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);

  static const String _defaultUserStoryAvatar =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBxJLFqSFUQj1bZ0wCvVpASe4ch76eoFLhUnXZ9Rr2lEYnpQOD_B7vrMH755u2OYfUK6J6d1u_HGAO74JP5v7FBq-NhO_MpVJGAGWuFZXIh-FLlA5n2HUVG8WzLDc8UFfs3tW0e-TFZiF5ffJ2wAf8wX_Cn1-5jxQuVyjEfxYRYdOULwis2IaVlZE-yVoQ_hFH-NHYc4R6hHYBoDVwjliNFscVj72IRmhpqrEPGr4fE';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginViewModel>().user;
    final userAvatar = (user != null && user.avatar.isNotEmpty)
        ? ApiConstants.getImageUrl(user.avatar)
        : _defaultUserStoryAvatar;

    final List<StoryModel> stories = [
      StoryModel(
        username: 'Your story',
        avatarUrl: userAvatar,
        isUser: true,
      ),
      StoryModel(
        username: 'alexandra',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDCkHQw21aTULOsLpZbKaJ6gM7yGtnF3h4rSsenqmo9rtsMODKm2J4zngNdCj7JuHgPJMHUO71Sie3GTR3zbH0VR9HxNq3rsc8IX69Dmqi25bBRcF1i8aWxgksV6xiVyVZ2S79g9-ZFIYzo2mq8_vrQA2KfhFGnCl5ceU-lx78J6DHRo9nuO6y-l9GEJkF0jirs0DgNX_hk1NdCdWAcz3K2sESFvjue2gQAG4Uuh_NT',
        isUser: false,
      ),
      StoryModel(
        username: 'marcus.jpg',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCLHHRpKjKoRr7L-XUtIZsoEcZQKfm_dZNrGHwHw-CosStxec2jfUeUhWdi19Rvdt0IWy1nxaUg7XDjiL06IWB0unQEudHNMZqUdtyGv_Crm7H5NVG8IaJB2MDwRqsXpymc6O9j-xbaqYgVjMNl3uOR_s_wbgs85Ba8fe0Ga_kBAr9bZH4tHZfXch18EISbuFmzY13iqLYzIR90Wjs6s9jmxW3AmLhtLo0Nl9R20MUG',
        isUser: false,
      ),
      StoryModel(
        username: 'nadine.co',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBsa2HxkfiSrHrmaWM-gNKcv4I44yXygI_2mGvaKl69_xPoCbnmCvFTHkIuzUL-HAIlr1kiuIGWHuhjSr8h4w11Ze49UDM9oUbMefosNZF3es6BATswNNw8N_7DZeZdb0M9u1z3kmXfXVQZCUsOENrEP-uPMxeVBzY3KuJWODiiqW9hbtNJ0XBQ6uX4eL58AhNoGFPY_a5UjNs-axq1FgiZcKWXRS8ygAbidxWS6i4z',
        isUser: false,
      ),
      StoryModel(
        username: 'studio.ella',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCNwJPvX6GMUkwjA7CYOToryAItsFmFYqGp6IiHnhGdlvvZ-zM3uqiHQJi5SebfTMYRQYOIcPDhgkFwhvKjOciSzAFJxviQdBneG-iS4yj2YetxBgckQlpWHX5uq5RNVGvj45Qm5GQfNeTktMy5NB_XVR6mF79p-QtTrcV0vYjqfhx2cPs6YSeDT3pf4A6ANMjLfi2Fwn3_evmknDj4uXYh8T2lSfueySX63yg1fTmD',
        isUser: false,
      ),
      StoryModel(
        username: 'ryantravels',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDBjM188ncUNyifNWi6vxvX4TAbwgGXBmTNqw2C4o9Mb7fLfFwcCxc59VULtc1NkX7j5z2JW3t5DS5D-xICPMghNvBh46ohLMBnenC53P3M9nxM254xc10pzzAzBHjMPr5j2oeJsebgrJCFfL5ECsQ9IXGakYHERQElEfWtwUwqH3w985hWKlxA7tjjCwYtHsa6DRzDstDSNAhpNSwtcuZXnuq7yg54V55LZ-2PmeS2',
        isUser: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: SizedBox(
        height: 82,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: stories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final story = stories[index];
            final isSeen = story.username == 'ryantravels';

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (story.isUser || isSeen)
                            ? _surfaceContainer
                            : null,
                        gradient: (!story.isUser && !isSeen)
                            ? const LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [_primary, _primaryFixed],
                              )
                            : null,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(story.isUser ? 0 : 2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _surfaceContainerLowest,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            story.avatarUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: _surfaceContainer,
                                  child: const Icon(
                                    Icons.person,
                                    color: _secondary,
                                    size: 28,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                    if (story.isUser)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add,
                            size: 14,
                            color: _onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 62,
                  child: Text(
                    story.username,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      height: 14 / 11,
                      letterSpacing: 0.22,
                      fontWeight: FontWeight.w400,
                      color: isSeen ? _secondary : _onSurface,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
