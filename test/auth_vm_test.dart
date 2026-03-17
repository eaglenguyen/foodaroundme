import 'package:flutter_test/flutter_test.dart';
import 'package:foodaroundme/authentication/viewmodel/authViewModel.dart';
import 'package:foodaroundme/map/model/place.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'mock_user.dart';

// ─── Mocks ───────────────────────────────────────────────────────
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late AuthViewModel viewModel;

  // helper to create a test place
  Place testPlace({String id = 'place_1', String name = 'Test Place'}) => Place(
    id: id,
    name: name,
    address: '123 Test St',
    location: const LatLng(0, 0),
    categories: ['food'],
  );

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    viewModel = AuthViewModel(supabaseClient: mockSupabase);
  });

  // ─── isSaved ─────────────────────────────────────────────────────
  group('isSaved', () {
    test('returns false when savedPlaces is empty', () {
      expect(viewModel.isSaved('place_1'), false);
    });

    test('returns true when place is in savedPlaces', () {
      viewModel.savedPlaces.add(testPlace());
      expect(viewModel.isSaved('place_1'), true);
    });

    test('returns false for different place id', () {
      viewModel.savedPlaces.add(testPlace(id: 'place_1'));
      expect(viewModel.isSaved('place_2'), false);
    });

    test('returns true for correct place among multiple', () {
      viewModel.savedPlaces.add(testPlace(id: 'place_1'));
      viewModel.savedPlaces.add(testPlace(id: 'place_2'));
      viewModel.savedPlaces.add(testPlace(id: 'place_3'));
      expect(viewModel.isSaved('place_2'), true);
    });
  });

  // ─── getUserVote ──────────────────────────────────────────────────
  group('getUserVote', () {
    test('returns null when no vote exists', () {
      expect(viewModel.getUserVote('place_1'), null);
    });

    test('returns like when user liked', () {
      viewModel.testSetVote('place_1', 'like'); // we will add this test helper
      expect(viewModel.getUserVote('place_1'), 'like');
    });

    test('returns dislike when user disliked', () {
      viewModel.testSetVote('place_1', 'dislike');
      expect(viewModel.getUserVote('place_1'), 'dislike');
    });

    test('returns null after vote is removed', () {
      viewModel.testSetVote('place_1', 'like');
      viewModel.testSetVote('place_1', null);
      expect(viewModel.getUserVote('place_1'), null);
    });
  });

  // ─── getLikes / getDislikes ───────────────────────────────────────
  group('getLikes and getDislikes', () {
    test('returns 0 when no counts loaded', () {
      expect(viewModel.getLikes('place_1'), 0);
      expect(viewModel.getDislikes('place_1'), 0);
    });

    test('returns correct counts after set', () {
      viewModel.testSetCounts('place_1', likes: 5, dislikes: 2);
      expect(viewModel.getLikes('place_1'), 5);
      expect(viewModel.getDislikes('place_1'), 2);
    });
  });

  // ─── isLoggedIn ───────────────────────────────────────────────────
  group('isLoggedIn', () {
    test('returns false when no current user', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(viewModel.isLoggedIn, false);
    });

    test('returns true when user is logged in', () {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      expect(viewModel.isLoggedIn, true);
    });
  });

  // ─── savePlace (local state only) ────────────────────────────────
  group('savePlace local state', () {
    test('savedPlaces is empty initially', () {
      expect(viewModel.savedPlaces, isEmpty);
    });

    test('adding place directly updates isSaved', () {
      final place = testPlace();
      viewModel.savedPlaces.add(place);
      expect(viewModel.isSaved(place.id), true);
    });

    test('removing place updates isSaved', () {
      final place = testPlace();
      viewModel.savedPlaces.add(place);
      viewModel.savedPlaces.removeWhere((p) => p.id == place.id);
      expect(viewModel.isSaved(place.id), false);
    });
  });
}