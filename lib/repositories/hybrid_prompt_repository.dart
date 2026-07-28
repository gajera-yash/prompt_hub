import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/prompt_model.dart';
import 'prompt_repository.dart';
class HybridPromptRepository implements PromptRepository {
  final MockPromptRepository _mockRepo = MockPromptRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isInitialized = false;
  List<PromptModel> _cachedPrompts = [];

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    // 1. Fetch Local (Mock) Prompts
    final localPrompts = await _mockRepo.searchPrompts('');
    
    _cachedPrompts.addAll(localPrompts);

    // 2. Fetch Firebase Prompts
    try {
      final snapshot = await _firestore.collection('prompts').get();
      final firebasePrompts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // ensure ID is set from doc ID
        return PromptModel.fromJson(data);
      }).toList();
      
      // Merge them, placing Firebase prompts first so they appear prominently
      _cachedPrompts.insertAll(0, firebasePrompts);
    } catch (e) {
      debugPrint('Error fetching prompts from Firebase: $e');
    }

    _isInitialized = true;
  }

  @override
  Future<List<PromptModel>> getFeaturedPrompts() async {
    await _ensureInitialized();
    return _cachedPrompts.take(15).toList();
  }

  @override
  Future<List<PromptModel>> getTrendingPrompts() async {
    await _ensureInitialized();
    final sorted = List<PromptModel>.from(_cachedPrompts)
      ..sort((a, b) => b.copyCount.compareTo(a.copyCount));
    return sorted.take(20).toList();
  }

  @override
  Future<List<PromptModel>> getRecentPrompts() async {
    await _ensureInitialized();
    return _cachedPrompts.reversed.take(20).toList();
  }

  @override
  Future<PromptModel> getDailyPrompt() async {
    await _ensureInitialized();
    if (_cachedPrompts.isEmpty) throw Exception('No prompts available');
    return _cachedPrompts.first;
  }

  @override
  Future<List<PromptModel>> searchPrompts(String query) async {
    await _ensureInitialized();
    final lowercaseQuery = query.toLowerCase();
    return _cachedPrompts.where((p) =>
        p.title.toLowerCase().contains(lowercaseQuery) ||
        p.content.toLowerCase().contains(lowercaseQuery) ||
        p.category.toLowerCase().contains(lowercaseQuery)).toList();
  }

  @override
  Future<List<PromptModel>> getPromptsByCategory(String category) async {
    await _ensureInitialized();
    return _cachedPrompts
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<PromptModel?> getPromptById(String id) async {
    await _ensureInitialized();
    try {
      return _cachedPrompts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
