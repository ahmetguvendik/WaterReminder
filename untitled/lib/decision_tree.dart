import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/new_water.dart';
import 'package:untitled/water.dart';
import 'login_page.dart';

class DecisionTree extends StatefulWidget {
  const DecisionTree({Key key}) : super(key: key);

  @override
  _DecisionTreeState createState() => _DecisionTreeState();
}

class _DecisionTreeState extends State<DecisionTree> {
  User user;
  void initState(){
    super.initState();
    onReflesh(FirebaseAuth.instance.currentUser);
  }
  onReflesh(userCred){
    setState(() {
      user = userCred;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(user==null){
      return LoginPage(onSignIn: (userCred)=> onReflesh(userCred),);
    }
    return NewWater(onSignOut: (userCred)=>onReflesh(userCred),user: user.email,);
  }
}