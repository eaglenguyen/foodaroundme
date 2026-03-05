import 'package:flutter/material.dart';
import 'package:foodaroundme/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _userName = TextEditingController();
  final _email = TextEditingController();
  final _bio = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState(); // loading the profile from supabase here instead of above
    _prefill();
  }

  Future<void> _prefill() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    _email.text = user.email ?? '';
    _userName.text = user.userMetadata?['full_name'] ?? '';
    _bio.text = user.userMetadata?['bio'] ?? '';


  }

  @override
  void dispose() {
    _userName.dispose();
    _email.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // TODO: integrate image_picker + upload (Supabase Storage, etc)
  }

  Future<void> _save() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final userName = _userName.text.trim();
    final bio = _bio.text.trim();

    setState(()
      => _loading = true
    );
    try{
      await supabase.from('profiles').update({
        'username': userName,
        'bio': bio,
      }).eq('id', user.id);

      await supabase.auth.updateUser(
        UserAttributes(
          data: {'full_name': userName, 'bio': bio},
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true); // should tell previous screen "updated" and visually
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong.')),
      );
    } finally {
      if (mounted) debugPrint('Saved');
      setState(() {
        _loading = false;
      });
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Update Profile',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF221A2A),
              Color(0xFF120C18),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar / Add Image
                    Expanded(
                      flex: 4,
                      child: _AvatarCard(onTap: _pickImage),
                    ),
                    const SizedBox(width: 14),
                    // First + Last name stacked
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _FieldCard(
                            label: 'Username',
                            controller: _userName,
                            hint: '...',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Email (locked)
                _FieldCard(
                  label: 'Email',
                  controller: _email,
                  hint: 'Email',
                  enabled: false,
                  trailing: const Icon(Icons.lock_outline, color: Colors.white70),
                ),
                const SizedBox(height: 14),

                // Bio (replaces phone number)
                _FieldCard(
                  label: 'Bio',
                  controller: _bio,
                  hint: 'Tell people about you…',
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
      ),

      // Bottom Save button
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: const Color(0xFFF5C518),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C518),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1422),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.person, size: 54, color: Colors.white),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.18),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Add Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.label,
    required this.controller,
    required this.hint,
    this.enabled = true,
    this.trailing,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final Widget? trailing;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1422),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment:
        maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  enabled: enabled,
                  maxLines: maxLines,
                  style: TextStyle(
                    color: enabled ? Colors.white : Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: trailing!,
            ),
          ],
        ],
      ),
    );
  }
}