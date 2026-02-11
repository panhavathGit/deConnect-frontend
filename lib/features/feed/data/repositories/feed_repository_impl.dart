// lib/features/feed/data/repositories/feed_repository.dart
import '../datasources/feed_remote_data_source.dart';
import '../datasources/feed_mock_data_source.dart';
import '../models/feed_model.dart';
import './feed_repository.dart';
import 'dart:io';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource? remoteDataSource;
  final FeedMockDataSource? mockDataSource;
  final bool useMockData;

  FeedRepositoryImpl({
    this.remoteDataSource,
    this.mockDataSource,
    this.useMockData = true, // Set to false when backend is ready
  });

  @override
  Future<List<FeedPost>> getPosts({String? category}) async {
    if (useMockData) {
      return await mockDataSource!.getPosts(category: category);
    } else {
      return await remoteDataSource!.getPosts(category: category);
    }
  }

  @override
  Future<FeedPost> getPostById(String id) async {
    if (useMockData) {
      return await mockDataSource!.getPostById(id);
    } else {
      return await remoteDataSource!.getPostById(id);
    }
  }

  @override
  Future<void> createPost(FeedPost post) async {
    if (!useMockData) {
      await remoteDataSource!.createPost(post);
    }
  }

  @override
  Future<void> updatePost(FeedPost post) async {
    if (!useMockData) {
      await remoteDataSource!.updatePost(post);
    }
  }

  @override
  Future<void> deletePost(String id) async {
    if (!useMockData) {
      await remoteDataSource!.deletePost(id);
    }
  }

  @override
  Future<String> uploadPostImage(File image, String userId) async {
    return await remoteDataSource!.uploadPostImage(image, userId);
  }
}
