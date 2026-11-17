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

  // Design tokens sesuai konfigurasi Tailwind pada HTML
  static const Color _onSurface = Color(0xFF1C1B1B);
  static const Color _secondary = Color(0xFF5E5D6C);
  static const Color _primary = Color(0xFF4D3BCE);
  static const Color _error = Color(0xFFBA1A1A);
  static const Color _surfaceContainer = Color(0xFFF0EDED);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);

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

  String _formatCount(int count) {
    final str = count.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
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
      context.read<ProfileViewModel>().syncLikeStatus(widget.post.id, status);

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

    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _openUserProfile,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: _surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      widget.post.userAvatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 20,
                        color: _secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: _openUserProfile,
                              child: Text(
                                widget.post.username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 20 / 15,
                                  letterSpacing: -0.15,
                                  fontWeight: FontWeight.w600,
                                  color: _onSurface,
                                ),
                              ),
                            ),
                          ),
                          if (!isOwner && currentUserId != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: _secondary.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _isFollowBusy
                                  ? null
                                  : _onToggleFollowAuthor,
                              behavior: HitTestBehavior.opaque,
                              child: Text(
                                widget.post.isAuthorFollowed
                                    ? 'Following'
                                    : 'Follow',
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 14 / 11,
                                  letterSpacing: 0.22,
                                  fontWeight: FontWeight.w500,
                                  color: widget.post.isAuthorFollowed
                                      ? _secondary
                                      : _primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.post.location.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        GestureDetector(
                          onTap: _openUserProfile,
                          child: Text(
                            widget.post.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 14 / 11,
                              letterSpacing: 0.22,
                              fontWeight: FontWeight.w400,
                              color: _secondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isOwner)
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.more_horiz,
                        size: 20,
                        color: _secondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditPostView(post: widget.post),
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
                                color: _onSurface,
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
                  )
                else
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.more_horiz,
                      size: 20,
                      color: _secondary,
                    ),
                  ),
              ],
            ),
          ),

          // Main Photo Media
          GestureDetector(
            onDoubleTap: _onDoubleTapLike,
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Container(
                color: _surfaceContainer,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.post.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _surfaceContainer,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: _secondary,
                          ),
                        );
                      },
                    ),
                    if (_showHeartAnimation)
                      Center(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 100,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Post Actions & Micro-interactions
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Like Button
                        GestureDetector(
                          onTap: _onButtonLike,
                          behavior: HitTestBehavior.opaque,
                          child: Icon(
                            widget.post.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 24,
                            color: widget.post.isLiked ? _error : _onSurface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Comment Button
                        GestureDetector(
                          onTap: _openComments,
                          behavior: HitTestBehavior.opaque,
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            size: 24,
                            color: _onSurface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Share / Send Button
                        GestureDetector(
                          onTap: () {},
                          behavior: HitTestBehavior.opaque,
                          child: const Icon(
                            Icons.send_outlined,
                            size: 24,
                            color: _onSurface,
                          ),
                        ),
                      ],
                    ),
                    // Bookmark Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.post.isBookmarked = !widget.post.isBookmarked;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        widget.post.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 24,
                        color: widget.post.isBookmarked ? _primary : _onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Like Count
                GestureDetector(
                  onTap: _openComments,
                  child: Text(
                    '${_formatCount(widget.post.likesCount)} likes',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 20 / 15,
                      letterSpacing: -0.15,
                      fontWeight: FontWeight.w600,
                      color: _onSurface,
                    ),
                  ),
                ),

                // Caption
                if (widget.post.caption.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.375,
                        fontWeight: FontWeight.w400,
                        color: _onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: '${widget.post.username}  ',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 20 / 15,
                            letterSpacing: -0.15,
                            fontWeight: FontWeight.w600,
                            color: _onSurface,
                          ),
                        ),
                        TextSpan(text: widget.post.caption),
                      ],
                    ),
                  ),
                ],

                // Meta and Comments Link
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _openComments,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    widget.post.commentsCount > 0
                        ? 'View all ${widget.post.commentsCount} comments'
                        : 'View comments',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 18 / 13,
                      fontWeight: FontWeight.w400,
                      color: _secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.post.timeAgo.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    height: 14 / 11,
                    letterSpacing: 0.55,
                    fontWeight: FontWeight.w400,
                    color: _secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

