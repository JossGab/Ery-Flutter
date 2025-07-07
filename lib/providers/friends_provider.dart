// lib/providers/friends_provider.dart

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

// Es una buena práctica crear modelos para las respuestas de la API,
// pero por simplicidad aquí usaremos Map<String, dynamic> directamente.

class FriendsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // --- ESTADO DEL PROVIDER ---
  List<dynamic> _friends = [];
  List<dynamic> _receivedInvitations = [];
  List<dynamic> _sentInvitations = [];
  List<dynamic> _searchResults = [];

  bool _isLoadingFriends = false;
  bool _isLoadingInvitations = false;
  bool _isLoadingSearch = false;
  String _error = '';

  // --- GETTERS PÚBLICOS PARA LA UI ---
  List<dynamic> get friends => _friends;
  List<dynamic> get receivedInvitations => _receivedInvitations;
  List<dynamic> get sentInvitations => _sentInvitations;
  List<dynamic> get searchResults => _searchResults;

  bool get isLoadingFriends => _isLoadingFriends;
  bool get isLoadingInvitations => _isLoadingInvitations;
  bool get isLoadingSearch => _isLoadingSearch;
  String get error => _error;

  // --- MÉTODOS PARA INTERACTUAR CON LA API ---

  /// Carga la lista de amigos del usuario.
  Future<void> fetchFriends() async {
    _isLoadingFriends = true;
    notifyListeners();
    try {
      _friends = await _apiService.getFriends();
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingFriends = false;
      notifyListeners();
    }
  }

  /// Carga las invitaciones pendientes (recibidas y enviadas).
  Future<void> fetchInvitations() async {
    _isLoadingInvitations = true;
    notifyListeners();
    try {
      final invitationsData = await _apiService.getFriendInvitations();
      _receivedInvitations = invitationsData['received_invitations'] ?? [];
      _sentInvitations = invitationsData['sent_invitations'] ?? [];
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingInvitations = false;
      notifyListeners();
    }
  }

  /// Busca usuarios para añadir como amigos.
  Future<void> searchUsers(String query) async {
    if (query.length < 2) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isLoadingSearch = true;
    notifyListeners();
    try {
      _searchResults = await _apiService.searchUsers(query);
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingSearch = false;
      notifyListeners();
    }
  }

  /// Envía una solicitud de amistad.
  Future<bool> sendFriendInvitation(int userId) async {
    try {
      await _apiService.sendFriendInvitation(userId);
      // Opcional: Refrescar las invitaciones enviadas para mostrar el estado actualizado.
      fetchInvitations();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Responde a una solicitud de amistad.
  Future<bool> respondToInvitation(int invitationId, String action) async {
    try {
      await _apiService.respondToInvitation(invitationId, action);
      // Si la acción fue exitosa, recargamos tanto las invitaciones como la lista de amigos.
      fetchInvitations();
      if (action == 'accept') {
        fetchFriends();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Elimina a un amigo de la lista.
  Future<bool> deleteFriend(int friendId) async {
    try {
      await _apiService.deleteFriend(friendId);
      // Actualización optimista: lo removemos de la lista local al instante.
      _friends.removeWhere((friend) => friend['id'] == friendId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      // Si falla, recargamos la lista para asegurar consistencia.
      fetchFriends();
      return false;
    }
  }
}
