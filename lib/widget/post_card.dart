// ziesocial/flutter/ziesocial/lib/widget/post_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/model/post_model.dart';
import 'package:ziesocial/view/edit_post_view.dart';
import 'package:ziesocial/view/profile_view.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';
import 'package:ziesocial/viewmodel/post_viewmodel.dart';
import 'package:ziesocial/viewmodel/profile_viewmodel.dart';
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
  bool _isFollowBusy = false;
  bool _isLikeBusy = false;
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

  Future<void> _executeToggleLike() async {
    if (_isLikeBusy) return;
    final user = context.read<LoginViewModel>().user;
    if (user == null) return;

    setState(() => _isLikeBusy = true);

    final status = await context.read<PostViewModel>().toggleLike(
      postId: widget.post.id,
      userId: int.parse(user.id),
    );

    if (!mounted) return;

    if (status != null) {
      // Sinkronkan ke daftar postingan di ProfileViewModel
      context.read<ProfileViewModel>().syncLikeStatus(widget.post.id, status);

      // Pastikan objek widget.post saat ini juga ter-update jika belum berubah
      setState(() {
        if (status == 'liked' && !widget.post.isLiked) {
          widget.post.isLiked = true;
          widget.post.likesCount += 1;
        } else if (status == 'unliked' && widget.post.isLiked) {
          widget.post.isLiked = false;
          if (widget.post.likesCount > 0) {
            widget.post.likesCount -= 1;
          }
        }
      });
    }

    setState(() => _isLikeBusy = false);
  }

  Future<void> _onDoubleTapLike() async {
    final user = context.read<LoginViewModel>().user;
    if (user == null) return;

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

    if (!widget.post.isLiked) {
      await _executeToggleLike();
    }
  }

  Future<void> _onButtonLike() async {
    await _executeToggleLike();
  }

  Future<void> _onToggleFollowAuthor() async {
    if (_isFollowBusy) return;
    final user = context.read<LoginViewModel>().user;
    if (user == null) return;
    final myId = int.tryParse(user.id);
    if (myId == null || myId == widget.post.userId) return;

    setState(() => _isFollowBusy = true);

    final newStatus = await context.read<ProfileViewModel>().toggleFollow(
      followerId: myId,
      followingId: widget.post.userId,
    );

    if (mounted) {
      setState(() => _isFollowBusy = false);
      if (newStatus != null) {
        context.read<PostViewModel>().syncFollowStatus(
          widget.post.userId,
          newStatus,
        );
      }
    }
  }

  void _openUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileView(userId: widget.post.userId),
      ),
    );
  }

  void _openComments() {
    CommentBottomSheet.show(context, widget.post);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<LoginViewModel>().user;
    final currentUserId = currentUser != null
        ? int.tryParse(currentUser.id)
        : null;
    final isOwner =
        currentUserId != null && widget.post.userId == currentUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: _openUserProfile,
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(widget.post.userAvatar),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _openUserProfile,
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
              ),

              // Tombol Follow HANYA tampil jika bukan milik sendiri DAN belum di-follow
              if (!isOwner &&
                  currentUserId != null &&
                  !widget.post.isAuthorFollowed)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SizedBox(
                    height: 30,
                    child: TextButton(
                      onPressed: _isFollowBusy ? null : _onToggleFollowAuthor,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFEEF2FF),
                        foregroundColor: const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              // Menu Popup: Tampilkan 'Edit' HANYA untuk pemilik postingan
              if (isOwner)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF1F2937)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPostView(post: widget.post),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Color(0xFF374151),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Edit Postingan',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Main Post Image
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
