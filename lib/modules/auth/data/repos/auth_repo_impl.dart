//
// import 'package:dartz/dartz.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../../../../core/network/remote/errors/failure.dart';
// import '../../../../core/network/remote/errors/supabase_auth_failure.dart';
// import '../../../../core/network/remote/errors/supabase_database_failure.dart';
// import '../models/auth_request_model.dart';
// import '../models/user_model.dart';
// import 'auth_repo.dart';
//
// class AuthRepoImpl extends AuthRepo {
//   final SupabaseClient client;
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     clientId: '707238649686-43ju3343jshuvp340gd2fn24j9p7bbc3.apps.googleusercontent.com',
//     scopes: ['email', 'profile'],
//   );
//
//   AuthRepoImpl(this.client);
//
//   @override
//   Future<Either<Failure, UserModel>> register(
//       AuthRequestModel authRequestModel,
//       ) async {
//     try {
//       final response = await client.auth.signUp(
//         password: authRequestModel.password,
//         email: authRequestModel.email,
//       );
//       final userModel = UserModel(
//         id: response.user?.id ?? '',
//         name: authRequestModel.name ?? 'unknown',
//         email: authRequestModel.email,
//       );
//       return Right(userModel);
//     } catch (error) {
//       if (error is AuthApiException) {
//         return Left(SupabaseAuthFailure.fromAuthException(error));
//       }
//       return Left(SupabaseAuthFailure(error.toString()));
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> createUser(UserModel userModel) async {
//     try {
//       await client.from('profiles').insert(userModel.toJson());
//       return const Right(unit);
//     } catch (error) {
//       return Left(SupabaseDatabaseFailure(error.toString()));
//     }
//   }
//
//   @override
//   Future<Either<Failure, String>> login(AuthRequestModel authRequestModel) async {
//     try {
//       final response = await client.auth.signInWithPassword(
//         email: authRequestModel.email,
//         password: authRequestModel.password,
//       );
//       return Right(response.user?.id ?? '');
//     } catch (error) {
//       if (error is AuthApiException) {
//         return Left(SupabaseAuthFailure.fromAuthException(error));
//       }
//       return Left(SupabaseAuthFailure(error.toString()));
//     }
//   }
//
//   @override
//   Future<Either<Failure, UserModel>> signInWithGoogle() async {
//     try {
//       GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
//       if (googleUser == null) {
//         googleUser = await _googleSignIn.signIn();
//       }
//       if (googleUser == null) {
//         return Left(SupabaseAuthFailure('Google sign-in was cancelled'));
//       }
//
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final String? accessToken = googleAuth.accessToken;
//       final String? idToken = googleAuth.idToken;
//
//       if (accessToken == null) {
//         return Left(SupabaseAuthFailure('No Access Token found'));
//       }
//       if (idToken == null) {
//         return Left(SupabaseAuthFailure('No ID Token found'));
//       }
//
//       final AuthResponse response = await client.auth.signInWithIdToken(
//         provider: OAuthProvider.google,
//         idToken: idToken,
//         accessToken: accessToken,
//       );
//
//       if (response.user == null) {
//         return Left(SupabaseAuthFailure('Failed to authenticate with Supabase'));
//       }
//
//       final userModel = UserModel(
//         id: response.user!.id,
//         name: googleUser.displayName ?? 'Unknown',
//         email: googleUser.email,
//       );
//
//       await createUser(userModel);
//
//       return Right(userModel);
//     } catch (error) {
//       if (error is AuthApiException) {
//         return Left(SupabaseAuthFailure.fromAuthException(error));
//       }
//       return Left(SupabaseAuthFailure(error.toString()));
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> signOut() async {
//     try {
//       await _googleSignIn.signOut();
//       await client.auth.signOut();
//       return const Right(unit);
//     } catch (error) {
//       return Left(SupabaseAuthFailure(error.toString()));
//     }
//   }
// }
// import 'package:dartz/dartz.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter/foundation.dart';
//
// import '../../../../core/network/remote/errors/failure.dart';
// import '../../../../core/network/remote/errors/supabase_auth_failure.dart';
// import '../../../../core/network/remote/errors/supabase_database_failure.dart';
// import '../models/auth_request_model.dart';
// import '../models/user_model.dart';
// import 'auth_repo.dart';
//
// class AuthRepoImpl extends AuthRepo {
//   final SupabaseClient client;
//   late final GoogleSignIn _googleSignIn;
//
//   AuthRepoImpl(this.client) {
//     _googleSignIn = GoogleSignIn(
//       clientId: '707238649686-43ju3343jshuvp340gd2fn24j9p7bbc3.apps.googleusercontent.com',
//       scopes: ['email', 'profile', 'openid'],
//     );
//   }
//
//   @override
//   Future<Either<Failure, UserModel>> register(
//       AuthRequestModel authRequestModel,
//       ) async {
//     try {
//       final response = await client.auth.signUp(
//         password: authRequestModel.password,
//         email: authRequestModel.email,
//       );
//       final userModel = UserModel(
//         id: response.user?.id ?? '',
//         name: authRequestModel.name ?? 'unknown',
//         email: authRequestModel.email,
//       );
//       return Right(userModel);
//     } catch (error) {
//       if (error is AuthApiException) {
//         return Left(SupabaseAuthFailure.fromAuthException(error));
//       }
//       return Left(SupabaseAuthFailure(error.toString()));
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> createUser(UserModel userModel) async {
//     try {
//       await client.from('profiles').insert(userModel.toJson());
//       return const Right(unit);
//     } catch (error) {
//       return Left(SupabaseDatabaseFailure(error.toString()));
//     }
//   }
//
//   @override
//   Future<Either<Failure, String>> login(AuthRequestModel authRequestModel) async {
//     try {
//       final response = await client.auth.signInWithPassword(
//         email: authRequestModel.email,
//         password: authRequestModel.password,
//       );
//       return Right(response.user?.id ?? '');
//     } catch (error) {
//       if (error is AuthApiException) {
//         return Left(SupabaseAuthFailure.fromAuthException(error));
//       }
//       return Left(SupabaseAuthFailure(error.toString()));
//     }
//   }
//
//   @override
//   Future<Either<Failure, UserModel>> signInWithGoogle() async {
//     try {
//       GoogleSignInAccount? googleUser;
//
//       if (kIsWeb) {
//         await client.auth.signInWithOAuth(OAuthProvider.google);
//         return Left(SupabaseAuthFailure('Redirecting to Google for authentication (web flow started).'));
//       } else {
//         googleUser = await _googleSignIn.signIn();
//       }
//
//       if (googleUser == null) {
//         return Left(SupabaseAuthFailure('Google sign-in was cancelled by user'));
//       }
//
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final String? accessToken = googleAuth.accessToken;
//       final String? idToken = googleAuth.idToken;
//
//       if (accessToken == null) {
//         return Left(SupabaseAuthFailure('Failed to get access token from Google'));
//       }
//
//       if (idToken == null) {
//         return Left(SupabaseAuthFailure('Failed to get ID token from Google'));
//       }
//
//       final AuthResponse response = await client.auth.signInWithIdToken(
//         provider: OAuthProvider.google,
//         idToken: idToken,
//         accessToken: accessToken,
//       );
//
//       if (response.user == null) {
//         return Left(SupabaseAuthFailure('Failed to authenticate with Supabase'));
//       }
//
//       final userModel = UserModel(
//         id: response.user!.id,
//         name: googleUser.displayName ?? 'Unknown',
//         email: googleUser.email,
//       );
//
//       await createUser(userModel);
//
//       return Right(userModel);
//     } catch (error) {
//       if (error is AuthApiException) {
//         return Left(SupabaseAuthFailure.fromAuthException(error));
//       }
//       return Left(SupabaseAuthFailure('Google sign-in failed: ${error.toString()}'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> signOut() async {
//     try {
//       await _googleSignIn.signOut();
//       await client.auth.signOut();
//       return const Right(unit);
//     } catch (error) {
//       return Left(SupabaseAuthFailure('Sign out failed: ${error.toString()}'));
//     }
//   }
// }




// import 'package:dartz/dartz.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter/foundation.dart';
// import '../../../../core/network/remote/errors/failure.dart';
// import '../../../../core/network/remote/errors/supabase_auth_failure.dart';
// import '../../../../core/network/remote/errors/supabase_database_failure.dart';
// import '../models/auth_request_model.dart';
// import '../models/user_model.dart';
// import 'auth_repo.dart';
//
// class AuthRepoImpl extends AuthRepo {
//   final SupabaseClient client;
//   late final GoogleSignIn _googleSignIn;
//
//   AuthRepoImpl(this.client) {
//     // Initialize GoogleSignIn with proper configuration
//     _googleSignIn = GoogleSignIn(
//       clientId: kIsWeb
//           ? '707238649686-43ju3343jshuvp340gd2fn24j9p7bbc3.apps.googleusercontent.com' // Web client ID
//           : null, // For mobile, it uses the configuration from google-services.json/GoogleService-Info.plist
//       scopes: ['email', 'profile'],
//     );
//   }
//
//   @override
//   Future<Either<Failure, UserModel>> register(
//       AuthRequestModel authRequestModel,
//       ) async {
//     try {
//       final response = await client.auth.signUp(
//         password: authRequestModel.password,
//         email: authRequestModel.email,
//       );
//
//       if (response.user == null) {
//         return Left(SupabaseAuthFailure('Registration failed: No user returned'));
//       }
//
//       final userModel = UserModel(
//         id: response.user!.id,
//         name: authRequestModel.name ?? 'Unknown',
//         email: authRequestModel.email,
//       );
//
//       return Right(userModel);
//     } catch (error) {
//       if (error is AuthApiException) {
//         return Left(SupabaseAuthFailure.fromAuthException(error));
//       }
//       return Left(SupabaseAuthFailure('Registration failed: ${error.toString()}'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> createUser(UserModel userModel) async {
//     try {
//       // Check if profile already exists
//       final existingProfile = await client
//           .from('profiles')
//           .select()
//           .eq('id', userModel.id)
//           .maybeSingle();
//
//       if (existingProfile != null) {
//         // Profile already exists, update it instead
//         await client
//             .from('profiles')
//             .update(userModel.toJson())
//             .eq('id', userModel.id);
//       } else {
//         // Create new profile
//         await client.from('profiles').insert(userModel.toJson());
//       }
//
//       return const Right(unit);
//     } catch (error) {
//       return Left(SupabaseDatabaseFailure('Failed to create/update user profile: ${error.toString()}'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, String>> login(AuthRequestModel authRequestModel) async {
//     try {
//       final response = await client.auth.signInWithPassword(
//         email: authRequestModel.email,
//         password: authRequestModel.password,
//       );
//
//       if (response.user == null) {
//         return Left(SupabaseAuthFailure('Login failed: Invalid credentials'));
//       }
//
//       return Right(response.user!.id);
//     } catch (error) {
//       if (error is AuthApiException) {
//         return Left(SupabaseAuthFailure.fromAuthException(error));
//       }
//       return Left(SupabaseAuthFailure('Login failed: ${error.toString()}'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, UserModel>> signInWithGoogle() async {
//     try {
//       if (kIsWeb) {
//         // Web implementation using OAuth flow
//         return await _handleWebGoogleSignIn();
//       } else {
//         // Mobile implementation using Google Sign-In package
//         return await _handleMobileGoogleSignIn();
//       }
//     } catch (error) {
//       if (error is AuthApiException) {
//         return Left(SupabaseAuthFailure.fromAuthException(error));
//       }
//       return Left(SupabaseAuthFailure('Google sign-in failed: ${error.toString()}'));
//     }
//   }
//
//   Future<Either<Failure, UserModel>> _handleWebGoogleSignIn() async {
//     try {
//       // For web, check if we're returning from OAuth redirect
//       final session = client.auth.currentSession;
//       if (session != null) {
//         // User is already authenticated from OAuth redirect
//         final user = session.user;
//         final userModel = UserModel(
//           id: user.id,
//           name: user.userMetadata?['full_name'] ??
//               user.userMetadata?['name'] ??
//               'Unknown',
//           email: user.email ?? '',
//         );
//
//         // Create or update user profile
//         await createUser(userModel);
//
//         return Right(userModel);
//       }
//
//       // Initiate OAuth flow
//       await client.auth.signInWithOAuth(
//         OAuthProvider.google,
//         redirectTo: kIsWeb ? Uri.base.origin : null,
//         scopes: 'email profile',
//       );
//
//       // This will redirect the user, so we return a specific message
//       return Left(SupabaseAuthFailure('Redirecting to Google for authentication...'));
//     } catch (error) {
//       return Left(SupabaseAuthFailure('Web Google sign-in failed: ${error.toString()}'));
//     }
//   }
//
//   Future<Either<Failure, UserModel>> _handleMobileGoogleSignIn() async {
//     try {
//       // Clear any previous sign-in session
//       await _googleSignIn.signOut();
//
//       // Attempt to sign in
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//
//       if (googleUser == null) {
//         return Left(SupabaseAuthFailure('Google sign-in was cancelled'));
//       }
//
//       // Get authentication details
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//       final String? idToken = googleAuth.idToken;
//       final String? accessToken = googleAuth.accessToken;
//
//       if (idToken == null || accessToken == null) {
//         return Left(SupabaseAuthFailure('Failed to obtain authentication tokens from Google'));
//       }
//
//       // Sign in with Supabase using the tokens
//       final AuthResponse response = await client.auth.signInWithIdToken(
//         provider: OAuthProvider.google,
//         idToken: idToken,
//         accessToken: accessToken,
//       );
//
//       if (response.user == null) {
//         return Left(SupabaseAuthFailure('Failed to authenticate with Supabase'));
//       }
//
//       // Create user model
//       final userModel = UserModel(
//         id: response.user!.id,
//         name: googleUser.displayName ?? 'Unknown',
//         email: googleUser.email,
//       );
//
//       // Create or update user profile
//       final createResult = await createUser(userModel);
//       if (createResult.isLeft()) {
//         // Log the error but don't fail the sign-in
//         print('Warning: Failed to create/update user profile');
//       }
//
//       return Right(userModel);
//     } catch (error) {
//       return Left(SupabaseAuthFailure('Mobile Google sign-in failed: ${error.toString()}'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> signOut() async {
//     try {
//       // Sign out from Google if not on web
//       if (!kIsWeb) {
//         try {
//           await _googleSignIn.signOut();
//         } catch (e) {
//           // Continue even if Google sign-out fails
//           print('Google sign-out failed: $e');
//         }
//       }
//
//       // Sign out from Supabase
//       await client.auth.signOut();
//
//       return const Right(unit);
//     } catch (error) {
//       return Left(SupabaseAuthFailure('Sign out failed: ${error.toString()}'));
//     }
//   }
//
//   // Helper method to check if user is returning from OAuth redirect (for web)
//   Future<Either<Failure, UserModel>> checkOAuthCallback() async {
//     try {
//       final session = client.auth.currentSession;
//       if (session != null) {
//         final user = session.user;
//         final userModel = UserModel(
//           id: user.id,
//           name: user.userMetadata?['full_name'] ??
//               user.userMetadata?['name'] ??
//               'Unknown',
//           email: user.email ?? '',
//         );
//
//         await createUser(userModel);
//         return Right(userModel);
//       }
//       return Left(SupabaseAuthFailure('No active session found'));
//     } catch (error) {
//       return Left(SupabaseAuthFailure('Failed to check OAuth callback: ${error.toString()}'));
//     }
//   }
// }
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/remote/errors/failure.dart';
import '../../../../core/network/remote/errors/supabase_auth_failure.dart';
import '../../../../core/network/remote/errors/supabase_database_failure.dart';

import '../models/auth_request_model.dart';
import '../models/user_model.dart';
import 'auth_repo.dart';

class AuthRepoImpl extends AuthRepo {
  final SupabaseClient client;
  late final GoogleSignIn _googleSignIn;

  AuthRepoImpl(this.client) {
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb
          ? '707238649686-43ju3343jshuvp340gd2fn24j9p7bbc3.apps.googleusercontent.com'
          : null, // Mobile uses google-services.json/GoogleService-Info.plist
      scopes: ['email', 'profile'],
    );
  }

  @override
  Future<Either<Failure, UserModel>> register(
      AuthRequestModel authRequestModel,
      ) async {
    try {
      final response = await client.auth.signUp(
        password: authRequestModel.password,
        email: authRequestModel.email,
      );

      if (response.user == null) {
        return Left(SupabaseAuthFailure('Registration failed: No user returned'));
      }
      final userModel = UserModel(
        id: response.user!.id,
        name: authRequestModel.name ?? 'Unknown',
        email: authRequestModel.email,
        accessToken: response.session!.refreshToken,
        refreshToken: response.session!.refreshToken
      );
      // Save token
      //await _saveUserData(userModel);
      return Right(userModel);
    } catch (error) {
      if (error is AuthApiException) {
        return Left(SupabaseAuthFailure.fromAuthException(error));
      }
      return Left(SupabaseAuthFailure('Registration failed: ${error.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> createUser(UserModel userModel) async {
    try {
      // Check if profile already exists
      final existingProfile = await client
          .from('profiles')
          .select()
          .eq('id', userModel.id)
          .maybeSingle();

      if (existingProfile != null) {
        // Update existing profile
        await client
            .from('profiles')
            .update(userModel.toJson())
            .eq('id', userModel.id);
      } else {
        // Create new profile
        await client.from('profiles').insert(userModel.toJson());
      }

      return const Right(unit);
    } catch (error) {
      return Left(SupabaseDatabaseFailure('Failed to create/update user profile: ${error.toString()}'));
    }
  }
  @override
  Future<Either<Failure, Session>> login(AuthRequestModel authRequestModel) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: authRequestModel.email,
        password: authRequestModel.password,
      );

      if (response.user == null) {
        return Left(SupabaseAuthFailure('Login failed: Invalid credentials'));
      }

      // Save token
      // await AppSecureStorage().setData(
      //   key: AppConstants.tokenKey,
      //   // value: response.user!.id,
      //   value: response.session!.refreshToken!,
      // );

      return Right(response.session!);
    } catch (error) {
      if (error is AuthApiException) {
        return Left(SupabaseAuthFailure.fromAuthException(error));
      }
      return Left(SupabaseAuthFailure('Login failed: ${error.toString()}'));
    }
  }

  // @override
  // Future<Either<Failure, Session>> signInWithGoogle() async {
  //   try {
  //     if (kIsWeb) {
  //
  //       return await _handleWebGoogleSignInPopup();
  //
  //     } else {
  //
  //       return await _handleMobileGoogleSignIn();
  //     }
  //   } catch (error) {
  //     if (error is AuthApiException) {
  //       return Left(SupabaseAuthFailure.fromAuthException(error));
  //     }
  //     return Left(SupabaseAuthFailure('Google sign-in failed: ${error.toString()}'));
  //   }
  // }
  @override
  Future<Either<Failure, Unit>> startWebGoogleSignIn() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:  kIsWeb ? '${Uri.base.origin}/auth-callback' : null,
          scopes: 'email profile',
          queryParams: {
            'access_type': 'offline',
            'prompt': 'consent',
          }
      );
      return const Right(unit);
    } on AuthApiException catch (authError) {
      return Left(SupabaseAuthFailure.fromAuthException(authError));
    } catch (e) {
      return Left(SupabaseAuthFailure('Failed to start web OAuth: ${e.toString()}'));
    }
  }
  @override
  Future<Either<Failure, Session>> mobileGoogleSignIn() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return Left(SupabaseAuthFailure('Google sign-in was cancelled'));

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        return Left(SupabaseAuthFailure('Failed to obtain tokens from Google'));
      }

      final AuthResponse response = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final session = response.session;
      if (session == null) {
        return Left(SupabaseAuthFailure('Failed to obtain session from Supabase'));
      }
      final user = response.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.id,
          name: googleUser.displayName ?? user.userMetadata?['name'] ?? 'Unknown',
          email: user.email ?? googleUser.email,
          avatarUrl: googleUser.photoUrl ?? user.userMetadata?['picture'],
        );
        await createUser(userModel);
      }

      return Right(session);
    } on AuthApiException catch (authError) {
      return Left(SupabaseAuthFailure.fromAuthException(authError));
    } catch (e) {
      return Left(SupabaseAuthFailure('Mobile Google sign-in failed: ${e.toString()}'));
    }
  }
  // Future<Either<Failure, UserModel>> _handleWebGoogleSignInPopup() async {
  //   try {
  //     // final googleUser = await _googleSignIn.signIn();
  //     // final googleAuth = await googleUser!.authentication;
  //     // final accessToken = googleAuth.accessToken;
  //     // final idToken = googleAuth.idToken;
  //     // // Use signInWithOAuth with popup mode
  //     // final response = await client.auth.signInWithIdToken(
  //     //   provider: OAuthProvider.google,
  //     //   idToken: idToken!,
  //     //   accessToken: accessToken,
  //     // );
  //     final response = await client.auth.signInWithOAuth(
  //       OAuthProvider.google,
  //       redirectTo: kIsWeb ? '${Uri.base.origin}/auth-callback' : null,
  //       scopes: 'email profile',
  //       queryParams: {
  //         'access_type': 'offline',
  //         'prompt': 'consent',
  //       },
  //     );
  //     if (!response) {
  //       return Left(SupabaseAuthFailure('Failed to initiate Google OAuth'));
  //     }
  //     // For web, the auth state will be handled by the listener
  //     // Return a special message to indicate OAuth flow started
  //     return Right(null);
  //   } catch (error) {
  //     return Left(SupabaseAuthFailure('Web Google sign-in failed: ${error.toString()}'));
  //   }
  // }
  // Future<Either<Failure, Session>> _handleWebGoogleSignInPopup() async {
  //   try {
  //     bool x=await client.auth.signInWithOAuth(
  //       OAuthProvider.google,
  //         redirectTo: kIsWeb ? '${Uri.base.origin}/auth-callback' : null,
  //       scopes: 'email profile',
  //       queryParams: {
  //         'access_type': 'offline',
  //         'prompt': 'consent',
  //       },
  //     );
  //
  //     final session = client.auth.currentSession;
  //     if (session != null) {
  //
  //       final user = session.user;
  //       if (user != null) {
  //         final userModel = UserModel(
  //           id: user.id,
  //           name: user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Unknown',
  //           email: user.email ?? '',
  //           avatarUrl: user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
  //         );
  //         await createUser(userModel);
  //       }
  //
  //       return Right(session);
  //     }
  //
  //
  //     return Right(session!);
  //   } on AuthApiException catch (authError) {
  //     return Left(SupabaseAuthFailure.fromAuthException(authError));
  //   } catch (error) {
  //     return Left(SupabaseAuthFailure('Web Google sign-in failed: ${error.toString()}'));
  //   }
  // }
  //
  // Future<Either<Failure, Session>> _handleMobileGoogleSignIn() async {
  //   try {
  //     final googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) {
  //       return Left(SupabaseAuthFailure('Google sign-in was cancelled by user'));
  //     }
  //
  //     final googleAuth = await googleUser.authentication;
  //     final idToken = googleAuth.idToken;
  //     final accessToken = googleAuth.accessToken;
  //
  //     if (idToken == null) {
  //       return Left(SupabaseAuthFailure('Failed to get ID token from Google'));
  //     }
  //
  //     final AuthResponse response = await client.auth.signInWithIdToken(
  //       provider: OAuthProvider.google,
  //       idToken: idToken,
  //       accessToken: accessToken,
  //     );
  //
  //     final session = response.session;
  //     if (session == null) {
  //       return Left(SupabaseAuthFailure('Failed to obtain session from Supabase'));
  //     }
  //
  //     // create/update profile optionally
  //     final user = response.user;
  //     if (user != null) {
  //       final userModel = UserModel(
  //         id: user.id,
  //         name: googleUser.displayName ?? user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Unknown',
  //         email: user.email ?? googleUser.email,
  //         avatarUrl: googleUser.photoUrl ?? user.userMetadata?['picture'],
  //       );
  //       await createUser(userModel);
  //     }
  //     return Right(session);
  //   } on AuthApiException catch (authError) {
  //     return Left(SupabaseAuthFailure.fromAuthException(authError));
  //   } catch (error) {
  //     return Left(SupabaseAuthFailure('Mobile Google sign-in failed: ${error.toString()}'));
  //   }
  // }


  // Future<Either<Failure, Session>> checkOAuthCallback() async {
  //   try {
  //     final session = client.auth.currentSession;
  //
  //     if (session == null) {
  //       return Left(SupabaseAuthFailure('No active session'));
  //     }
  //
  //     // Optionally create/update user profile
  //     final user = session.user;
  //     if (user != null) {
  //       final userModel = UserModel(
  //         id: user.id,
  //         name: user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Unknown',
  //         email: user.email ?? '',
  //         avatarUrl: user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
  //       );
  //       await createUser(userModel);
  //     }
  //
  //     return Right(session);
  //   } on AuthApiException catch (authError) {
  //     return Left(SupabaseAuthFailure.fromAuthException(authError));
  //   } catch (error) {
  //     return Left(SupabaseAuthFailure('Failed to process OAuth callback: ${error.toString()}'));
  //   }
  // }

  @override
  Stream<AuthState> onAuthStateChange() {
    return client.auth.onAuthStateChange;
  }

  @override
  Session? currentSession() {
    return client.auth.currentSession;
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      // Sign out from Google if on mobile
      if (!kIsWeb) {
        try {
          await _googleSignIn.signOut();
        } catch (e) {
          print('Google sign-out failed: $e');
        }
      }

      // Sign out from Supabase
      await client.auth.signOut();

      return const Right(unit);
    } catch (error) {
      return Left(SupabaseAuthFailure('Sign out failed: ${error.toString()}'));
    }
  }
}