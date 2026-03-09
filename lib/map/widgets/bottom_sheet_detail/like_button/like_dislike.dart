
import 'package:flutter/material.dart';
import 'package:foodaroundme/app_root.dart';
import 'package:foodaroundme/main.dart';
import 'package:provider/provider.dart';

import '../../../../authentication/ui/sign_in_screen.dart';
import '../../../../authentication/viewmodel/authViewModel.dart';


class LikeButtons extends StatefulWidget {
  final String providerPlaceId;

  const LikeButtons({super.key, required this.providerPlaceId});

  @override
  State<LikeButtons> createState() => LikeButtonsState();
}

class LikeButtonsState extends State<LikeButtons> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<AuthViewModel>().loadVotes(widget.providerPlaceId)
    );
  }

  @override
  Widget build(BuildContext context) {
    final voteVm = context.watch<AuthViewModel>();
    final user = voteVm.currentUser;
    final userVote = voteVm.getUserVote(widget.providerPlaceId);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Like button
        GestureDetector(
          onTap: () {
            if (user == null) {
            _showLoginDialog(context);
            }
            voteVm.vote(widget.providerPlaceId, 'like');
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: userVote == 'like'
                  ? Colors.red.withOpacity(0.15)
                  : Colors.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                userVote == 'like' ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: userVote == 'like' ? Colors.red : Colors.black87,
                ),
                const SizedBox(width: 4),
                Text(
                  '${voteVm.getLikes(widget.providerPlaceId)}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Dislike button
        GestureDetector(
          onTap: () {
            if (user == null) {
              _showLoginDialog(context);
            }
            voteVm.vote(widget.providerPlaceId, 'dislike');
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: userVote == 'dislike'
                  ? Colors.blue.withOpacity(0.15)
                  : Colors.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  userVote == 'dislike' ? Icons.thumb_down : Icons.thumb_down_outlined,
                  size: 20,
                  color: userVote == 'dislike' ? Colors.blue : Colors.black87,
                ),
                const SizedBox(width: 4),
                Text(
                  '${voteVm.getDislikes(widget.providerPlaceId)}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ],
    );


  }



}
void _showLoginDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Account Required',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text('You need an account to like or dislike places.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            isGuestMode.value = false;
          },

          child: const Text('Sign In'),
        ),
      ],
    ),
  );
}
