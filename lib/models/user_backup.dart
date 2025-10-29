import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String? gender;
  final String? name;
  final String? title;
  final String? email;
  final String? phone;
  final String? photo;
  final String? avatar;
  final String? id;
  final String? accountType;
  final String? academic;
  final String? school;
  final List<Map<String, dynamic>>? schools;
  final String? token;
  final int? smsWallet;
  final List<String>? preferredChannels;

  const User({
    this.academic,
    this.school,
    this.gender,
    this.name,
    this.title,
    this.email,
    this.id,
    this.accountType,
    this.avatar,
    this.token,
    this.phone,
    this.photo,
    this.preferredChannels,
    this.smsWallet,
    this.schools,
  });

  static Future<bool> isAuth() async {
    String? token = (await User.fromLocalStorage())?.token;
    return token != null && token.isNotEmpty;
  }

  bool isAccountType(String type) {
    return schools != null &&
        schools!.where((s) {
          return s['school_id'] == school && s['account_type'] == type;
        }).isNotEmpty &&
        accountType == type;
  }

  static Future<String?> getId() async {
    return (await User.fromLocalStorage())?.id;
  }

  static Future<String?> getToken() async {
    return (await User.fromLocalStorage())?.token;
  }

  static Future<Map<String, dynamic>?> login(
    String login,
    String password,
  ) async {
    try {
      Map<String, dynamic>? device = await _deviceDetails();
      Map<String, String?> data = {
        'login': login,
        'password': password,
        'device_name': device?['deviceName'],
      };
      Map<String, dynamic>? response = await MasterCrudModel.post(
        '/auth/login',
        data: data,
      );

      if (response != null) {
        var user = Map<String, dynamic>.from(response['user']);
        user['token'] = response['token'];
        storeUserInfo(user);
        addAccountToLocalStorage(User.fromMap(user));
        return Map<String, dynamic>.from(user);
      } else {
        Fluttertoast.showToast(
          msg: "Erreur de connexion !",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return null;
    }
  }

  static Future<Map<String, dynamic>?> refresh() async {
    try {
      Map<String, dynamic>? response = await MasterCrudModel.find('/auth/user');

      if (response != null) {
        storeUserInfo(response);
        return response;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> refreshFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        return await MasterCrudModel.patch('/auth/user/update-fcm-token', {
          'device_fcm_token': fcmToken,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Firebase platform not supported !");
      }
      return null;
    }
    return null;
  }

  static Future<String?> getCurrentFcmToken() async {
    Map<String, dynamic>? token = await MasterCrudModel.post(
      '/auth/user/sanctum/token',
    );
    return token?['device_fcm_token'];
  }

  static Future<void> logout({required Function callback}) async {
    SharedPreferences local = await Http().local();
    User? user = await User.fromLocalStorage();
    if (user != null) {
      removeAccountFromLocalStorage(user);
    }
    local.remove('auth_user');
    callback();
  }

  static Future<void> deleteAccount(
    BuildContext context,
    String password, {
    required Function callback,
  }) async {
    var response = await MasterCrudModel.delete(
      (await getId()) ?? '__unknown__',
      'user',
      data: {'password': password},
    );
    if (response != null) {
      if (context.mounted) {
        await logout(callback: callback);
      }
    }
  }

  static Future<Map<String, dynamic>?> _deviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        return {
          'deviceName': "${build.model} - ${build.id}",
          'deviceVersion': build.version.toString(),
          'identifier': build.id,
        };
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        return {
          'deviceName': "${data.name} - ${data.identifierForVendor}",
          'deviceVersion': data.systemVersion,
          'identifier': data.identifierForVendor!,
        };
      }
    } on PlatformException {
      return null;
    }
    return null;
  }

  static Future<void> storeUserInfo(Map response) async {
    var prefs = await Http().local();
    if (response['token'] == null) {
      User? current = await User.fromLocalStorage();
      if (current != null) {
        response['token'] = current.token;
      }
    }
    String localUser = jsonEncode(User.fromMap(response).toMap());
    prefs.remove('school');
    prefs.remove('academic');
    prefs.setString('auth_user', localUser);
  }

  static User fromMap(response) {
    return User(
      gender: response['gender'],
      name: response['name'],
      title: response['title'],
      email: response['email'],
      avatar: response['avatar'],
      accountType: response['account_type'],
      phone: response['phone'],
      photo: response['photo'],
      id: response['id'],
      token: response['token'],
      academic: response['academic_id'],
      school: response['school_id'],
      smsWallet: response['sms_wallet'],
      schools: List<Map<String, dynamic>>.from(response['schools'] ?? []),
      preferredChannels: List<String>.from(
        response['preferred_channels'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'name': name,
      'title': title,
      'email': email,
      'id': id,
      'account_type': accountType,
      'avatar': avatar,
      'token': token,
      'phone': phone,
      'photo': photo,
      'academic_id': academic,
      'school_id': school,
      'preferred_channels': preferredChannels,
      'schools': schools,
    };
  }

  static Future<User?> fromLocalStorage() async {
    var local = await Http().local();
    return User.fromMap(
      jsonDecode(local.getString(LocalStorageKeys.authUser) ?? '{}'),
    );
  }

  static Future<Map<String, dynamic>?> fromServer() async {
    return await MasterCrudModel.find('/auth/user');
  }

  static Future<List<User>> accountsFromLocalStorage() async {
    var prefs = await Http().local();
    return List<User>.from(
      List.from(
        jsonDecode(prefs.getString(LocalStorageKeys.authUserList) ?? '[]'),
      ).map((user) => User.fromMap(user)).toList(),
    );
  }

  static Future<void> addAccountToLocalStorage(User user) async {
    List<User> accounts = await accountsFromLocalStorage();
    bool exists =
        accounts.firstWhereOrNull((account) {
          return account.id == user.id;
        }) !=
        null;
    if (!exists) {
      accounts.add(user);
    } else {
      accounts = accounts.map((e) {
        if (e.id == user.id) {
          return user;
        }
        return e;
      }).toList();
    }
    var prefs = await Http().local();
    prefs.setString(
      LocalStorageKeys.authUserList,
      jsonEncode(
        accounts.map((e) {
          return e.toMap();
        }).toList(),
      ),
    );
  }

  static Future<void> removeAccountFromLocalStorage(User user) async {
    List<User> accounts = await accountsFromLocalStorage();
    accounts = accounts.where((account) {
      return user.id != account.id;
    }).toList();
    var prefs = await Http().local();
    prefs.setString(
      LocalStorageKeys.authUserList,
      jsonEncode(
        accounts.map((e) {
          return e.toMap();
        }).toList(),
      ),
    );
  }

  static Future<bool> selectAccountFromLocalStorage(String user) async {
    List<User> accounts = await accountsFromLocalStorage();
    User? exists = accounts.firstWhereOrNull((account) {
      return account.id == user;
    });
    if (exists != null) {
      storeUserInfo(exists.toMap());
      return true;
    } else {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> changeSpace({
    required String accountType,
    required String schoolId,
  }) async {
    Map<String, dynamic>? response = await MasterCrudModel.patch(
      '/auth/user/school/update',
      {'school_id': schoolId, 'account_type': accountType},
    );
    if (response != null) {
      User.storeUserInfo(response);
      User.addAccountToLocalStorage(User.fromMap(response));
    }
    return response;
  }

  static Future<Map<String, dynamic>?> getAcademic(User? user) async {
    SharedPreferences pref = (await Http().local());
    if (user == null || user.academic == null) {
      return null;
    }
    String? local = pref.getString('academic');
    if (local != null) {
      return Map<String, dynamic>.from(jsonDecode(local));
    }
    Map<String, dynamic>? response = await MasterCrudModel(
      'academic',
    ).get(user.academic ?? '');
    if (response != null) {
      pref.setString('academic', jsonEncode(response));
    }
    return response;
  }

  static Future<Map<String, dynamic>?> getSchool(User? user) async {
    SharedPreferences pref = (await Http().local());
    if (user == null || user.school == null) {
      return null;
    }
    String? local = pref.getString('school');
    if (local != null) {
      return Map<String, dynamic>.from(jsonDecode(local));
    }
    Map<String, dynamic>? response = await MasterCrudModel(
      'school',
    ).get(user.school ?? '');
    if (response != null) {
      pref.setString('school', jsonEncode(response));
    }
    return response;
  }
}
