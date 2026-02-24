import 'package:flutter/material.dart';
import 'package:foodaroundme/authentication/ui/sign_in_screen.dart';
import 'package:foodaroundme/authentication/viewmodel/authViewModel.dart';
import 'package:foodaroundme/main.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    final user = supabase.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'];
    final email = user?.email;
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              viewModel.signOut();
              if(context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                );
              }
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // 🔵 Avatar
            const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage("assets/images/man.png"), // replace
            ),

            const SizedBox(height: 12),

            // Name
            Text(
              fullName ?? 'null',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // email or username
            Text(
              email ?? 'null',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // ❤️ Likes & Dislikes row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _iconStatButton(Icons.thumb_up_alt, "Likes"),
                const SizedBox(width: 10),
                _iconStatButton(Icons.thumb_down_alt, "Dislikes"),
              ],
            ),

            const SizedBox(height: 20),

            // "View my saves"
            _profileOptionButton(Icons.bookmark, "View my saves"),

            const SizedBox(height: 12),

            // Bio
            _profileOptionButton(Icons.edit, "Bio"),

            const SizedBox(height: 25),

            // Upload text
            const Text(
              "You haven’t uploaded any photos yet.\n"
                  "Click Upload to send all your photos here!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Photo grid (placeholders)
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (_, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ⭐ Button with icon + label (Likes / Dislikes)
  Widget _iconStatButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  // ⭐ Profile option button
  Widget _profileOptionButton(IconData icon, String text) {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
