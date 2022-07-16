import 'package:blog/core/services/app_service.dart';
import 'package:blog/model/blog.dart';
import 'package:blog/model/blog_user.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

abstract class BlogService extends AppService {
  Future<void> signUp(
      String username, String email, String password, BuildContext context);
  Future<void> signIn(String email, String password, BuildContext context);
  Future<void> createPost(
      String title, String content, String author, List<XFile> image);
  Stream<BuiltList<Blog>> getPost();

  Stream<BuiltList<Blog>> getComment(String docId);
  Future<void> addComment(
      String comment, String uid, String docId, String username);
  Future<void> replyComment(
      String reply, String uid, String docId, String commentId, String name);
  Future<BuiltList<Blog>> getReplyComment(String docId);
  Future<void> updateComment(
      String comment, String commentId, String docId, String username);

  Future<void> like(String docId);

  Future<BuiltList<Blog>> getLike(String docId);

  Future<BuiltList<BlogUser>> getUser();
}
