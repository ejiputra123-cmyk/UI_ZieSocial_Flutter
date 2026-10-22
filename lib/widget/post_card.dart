import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/model/post_model.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';
import 'package:ziesocial/viewmodel/post_viewmodel.dart';
import 'package:ziesocial/widget/comment_bottom_sheet.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool _showHeartAnimation = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDoubleTapLike() {
    final user = context.read<LoginViewModel>().user;
    if (user == null) return;

    // Trigger animasi love di tengah gambar
    setState(() {
      _showHeartAnimation = true;
    });
    _animController.forward(from: 0.0).then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showHeartAnimation = false;
          });
        }
      });
    });

    // Jika belum di-like, panggil toggleLike untuk like postingan.
    // Jika SUDAH di-like, double tap TIDAK akan me-unlike (hanya bisa unlike lewat tombol like).
    if (!widget.post.isLiked) {
      context.read<PostViewModel>().toggleLike(
        postId: widget.post.id,
        userId: int.parse(user.id),
      );
    }
  }

  void _onButtonLike() {
    final user = context.read<LoginViewModel>().user;
    if (user == null) return;

    context.read<PostViewModel>().toggleLike(
      postId: widget.post.id,
      userId: int.parse(user.id),
    );
  }

  void _openComments() {
    CommentBottomSheet.show(context, widget.post);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.post.userAvatar),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (widget.post.location.isNotEmpty)
                      Text(
                        widget.post.location,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Color(0xFF1F2937)),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Main Post Image dengan Fitur Double Tap
        GestureDetector(
          onDoubleTap: _onDoubleTapLike,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                widget.post.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
              if (_showHeartAnimation)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
            ],
          ),
        ),

        // Action Bar (Like, Comment, Share, Bookmark)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      widget.post.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.post.isLiked
                          ? Colors.red
                          : const Color(0xFF1F2937),
                    ),
                    onPressed: _onButtonLike,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Color(0xFF1F2937),
                    ),
                    onPressed: _openComments,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send_outlined,
                      color: Color(0xFF1F2937),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  widget.post.isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: const Color(0xFF1F2937),
                ),
                onPressed: () {
                  setState(() {
                    widget.post.isBookmarked = !widget.post.isBookmarked;
                  });
                },
              ),
            ],
          ),
        ),

        // Post Info (Likes, Caption, Time Ago)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _openComments,
                child: Text(
                  '${widget.post.likesCount} likes • ${widget.post.commentsCount} comments',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              if (widget.post.caption.isNotEmpty) ...[
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1F2937),
                    ),
                    children: [
                      TextSpan(
                        text: '${widget.post.username} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: widget.post.caption),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                widget.post.timeAgo,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}
