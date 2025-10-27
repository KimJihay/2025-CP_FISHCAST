import 'package:flutter/material.dart';
import '../../core/utils/constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/location_service.dart';
import '../../core/models/user_model.dart';
import '../authentication/login_page.dart';
import '../settings/settings_page.dart';
import 'legal/privacy_policy_page.dart';
import 'legal/terms_of_use_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  UserModel? _user;
  bool _isLoading = true;
  bool _isCheckingLocation = false;
  File? _localProfileImage;
  LocationPermission? _locationPermission;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      UserModel? user = await _authService.getCurrentUserModel();
      
      // Load saved profile picture from local storage
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final savedImagePath = prefs.getString('profile_image_${user.uid}');
        
        if (savedImagePath != null && File(savedImagePath).existsSync()) {
          if (mounted) {
            setState(() {
              _localProfileImage = File(savedImagePath);
            });
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Error loading user data: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _handleLogout() async {
    // Show confirmation dialog
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    // If user confirmed logout
    if (confirmLogout == true && mounted) {
      try {
        // Show loading indicator
        setState(() {
          _isLoading = true;
        });

        // Call the logout service
        await _authService.signOut();

        // Navigate to login page and clear the navigation stack
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Reset loading state
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show error message
          _showErrorSnackBar('Error logging out: $e');
        }
      }
    }
  }

  Future<void> _showReauthenticationDialog() async {
    String? signInMethod = _authService.getUserSignInMethod();
    
    if (signInMethod == 'google') {
      // Google Sign-In re-authentication
      try {
        await _authService.reauthenticateWithGoogle();
        return; // Success
      } catch (e) {
        throw Exception('Google re-authentication failed: $e');
      }
    } else if (signInMethod == 'password') {
      // Email/Password re-authentication
      final TextEditingController passwordController = TextEditingController();
      bool? confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Verify Your Identity',
              style: TextStyle(
                color: kForegroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'For security reasons, please enter your password to continue.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Verify'),
              ),
            ],
          );
        },
      );

      if (confirmed == true && mounted) {
        try {
          await _authService.reauthenticateWithEmailPassword(passwordController.text);
          return; // Success
        } catch (e) {
          throw Exception('Password verification failed: $e');
        }
      } else {
        throw Exception('Re-authentication cancelled');
      }
    } else {
      throw Exception('Unknown sign-in method');
    }
  }

  Future<void> _handleLocationPermission() async {
    setState(() {
      _isCheckingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them in your device settings.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          // Open location settings
          await Geolocator.openLocationSettings();
        }
        return;
      }

      // Check current permission status
      LocationPermission permission = await _locationService.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          // Show dialog to open app settings
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text(
                'Location permission is permanently denied. Please enable it in app settings to use location features.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Geolocator.openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await _locationService.requestPermission();
      }

      if (mounted) {
        setState(() {
          _locationPermission = permission;
        });

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          // Permission granted - now try to get actual location
          try {
            final locationData = await _locationService.getCurrentLocation();
            
            if (mounted) {
              // Build location display string
              String locationDisplay;
              if (locationData.city != null && locationData.city!.isNotEmpty) {
                locationDisplay = '${locationData.city}, ${locationData.country ?? "Unknown"}';
              } else if (locationData.administrativeArea != null && locationData.administrativeArea!.isNotEmpty) {
                locationDisplay = '${locationData.administrativeArea}, ${locationData.country ?? "Unknown"}';
              } else if (locationData.country != null && locationData.country!.isNotEmpty) {
                locationDisplay = locationData.country!;
              } else {
                // Show coordinates if no address available
                locationDisplay = 'Lat: ${locationData.latitude.toStringAsFixed(4)}, Lon: ${locationData.longitude.toStringAsFixed(4)}';
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Location enabled! Current location: $locationDisplay'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Permission granted but failed to get location: $e'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLocation = false;
        });
      }
    }
  }

  void _handleAccountDeletion() async {
    // Show confirmation dialog with warning
    bool? confirmDeletion = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_rounded, color: Colors.red, size: 28),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete Account',
                style: TextStyle(
                  color: kForegroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This will permanently delete:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Your profile information'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('All your app data'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Account settings'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This action cannot be undone!',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: kForegroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Delete Account',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    // If user confirmed deletion
    if (confirmDeletion == true && mounted) {
      try {
        // Show loading indicator
        setState(() {
          _isLoading = true;
        });

        // Call the account deletion service
        await _authService.deleteAccount();

        // Navigate to login page and clear the navigation stack
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Check if re-authentication is required
        if (e.toString().contains('REQUIRES_REAUTH')) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          
          try {
            // Show re-authentication dialog
            await _showReauthenticationDialog();
            
            // Retry deletion after successful re-authentication
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
            
            await _authService.deleteAccount();
            
            // Navigate to login page and clear the navigation stack
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (reauthError) {
            // Reset loading state
            if (mounted) {
              setState(() {
                _isLoading = false;
              });

              // Show error message
              _showErrorSnackBar('Error: $reauthError');
            }
          }
        } else {
          // Reset loading state
          if (mounted) {
            setState(() {
              _isLoading = false;
            });

            // Show error message
            _showErrorSnackBar('Error deleting account: $e');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.zero, // Remove padding from ListView
                children: [
                  _buildProfileHeader(),
                  Padding(
                    padding: const EdgeInsets.all(
                      16.0,
                    ), // Add padding only to the list items
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildListTile(
                          icon: Icons.edit,
                          text: 'Edit Profile',
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                            // Reload user data if changes were saved
                            if (result == true && mounted) {
                              _loadUserData();
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildListTile(
                          icon: Icons.location_on,
                          text: 'Enable Location',
                          onTap: _handleLocationPermission,
                        ),
                        _buildDivider(),
                        _buildListTile(
                          icon: Icons.privacy_tip,
                          text: 'Privacy Policy',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrivacyPolicyPage(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildListTile(
                          icon: Icons.description,
                          text: 'Terms of Use',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TermsOfUsePage(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildListTile(
                          icon: Icons.logout,
                          text: 'Log Out',
                          onTap: _handleLogout,
                        ),
                        _buildDivider(),
                        _buildListTile(
                          icon: Icons.delete_forever,
                          text: 'Request Account Deletion',
                          onTap: _handleAccountDeletion,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 360 ? 22.0 : 24.0;
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;
    
    return ListTile(
      leading: Icon(icon, color: kForegroundColor, size: iconSize),
      title: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey, size: iconSize - 2),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey,
    );
  }

  Widget _buildProfileHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = (screenWidth * 0.13).clamp(45.0, 60.0);
    final nameFontSize = screenWidth < 360 ? 20.0 : 24.0;
    final emailFontSize = screenWidth < 360 ? 14.0 : 16.0;
    
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.blue),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          // Profile Picture
          _buildProfilePicture(avatarRadius),
          const SizedBox(height: 16),
          Text(
            _user?.fullName ?? 'Guest User',
            style: TextStyle(
              color: Colors.white,
              fontSize: nameFontSize,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          Text(
            _user?.email ?? 'guest@example.com',
            style: TextStyle(color: Colors.white70, fontSize: emailFontSize),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(double radius) {
    final iconSize = radius * 1.0;
    
    // Show local image first if available
    if (_localProfileImage != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        backgroundImage: FileImage(_localProfileImage!),
      );
    }
    
    // Fall back to network image
    if (_user?.profilePictureUrl != null &&
        _user!.profilePictureUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(_user!.profilePictureUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Fallback to default avatar if image fails to load
          setState(() {
            // Could add error handling here
          });
        },
        child: _user!.profilePictureUrl!.isEmpty
            ? Icon(Icons.person, size: iconSize, color: Colors.blue)
            : null,
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: iconSize, color: Colors.blue),
      );
    }
  }
}
