import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';


TextEditingController epostacontroller = TextEditingController();
TextEditingController sifrecontroller = TextEditingController();

class LoginPage extends StatefulWidget {
  final Function(User) onSignIn;
  final Function(User) onSignOut;
  LoginPage({@required this.onSignIn,@required this.onSignOut});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int pageState =0;
  var backcolor = Colors.blueAccent;
  double loginY = 0;
  double registerY =0;
  bool keyboardVis = false;


  void initState(){
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible){
        setState(() {
            keyboardVis = visible;
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    switch(pageState){
      case 0:
        backcolor = Colors.blueAccent;
        loginY = MediaQuery.of(context).size.height;
        registerY = MediaQuery.of(context).size.height;
        break;
      case 1:
        backcolor = Colors.greenAccent;
        loginY = keyboardVis ? 45 : 180;
        registerY = MediaQuery.of(context).size.height;
        break;
      case 2:
        backcolor = Colors.greenAccent;
        registerY = keyboardVis ? 45 : 250;
        break;
    }



    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: AnimatedContainer(
          curve: Curves.fastLinearToSlowEaseIn,
          duration: Duration(
            seconds: 2,
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: backcolor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                 setState(() {
                   pageState = 0;
                 });
                },
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Text("SU HAYATTIR",style: TextStyle(fontFamily: "IndieFlower",color: Colors.white,fontSize: 24),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Günde 3 Litre su içmek vücudumuz için çok faydalıdır.",style: TextStyle(fontFamily: "IndieFlower",color: Colors.white,fontSize: 16),),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                child:Image(
                  image:  AssetImage("images/su.jpg"),
                ),
              ),
              InkWell(
                onTap: (){
                  setState(() {
                   if(pageState==1){
                     pageState = 0;
                   }
                   else{
                     pageState=1;
                   }
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(25),
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.purpleAccent
                  ),
                  child: Center(child: Text("Başlayalım",style: TextStyle(fontFamily: "IndieFlower",color: Colors.white,fontSize: 24),)),
                ),
              )
            ],
          ),
      ),
        ),
        AnimatedContainer(
          duration: Duration(
            milliseconds: 1100
          ),
          transform: Matrix4.translationValues(0, loginY, 1),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            )
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text("GİRİŞ",style: TextStyle(fontFamily: "IndieFlower",color: Colors.black,fontSize: 24),),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Container(
                  width: MediaQuery.of(context).size.width*0.88,
                          child: Form(
                            child:TextFormField(
                              controller: epostacontroller,
                        decoration: InputDecoration(
                        hintText: "Email Adresi",
                      hintStyle: TextStyle(color: Colors.blue),
                    labelText: "E Mail",
                  border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.red),
                      ),
    ),
    ),
    ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Container(
              width: MediaQuery.of(context).size.width*0.88,

    child: Form(
    child:TextFormField(
      controller: sifrecontroller,
    obscureText: true,
    decoration: InputDecoration(
    hintText: "ŞİFRE",
    hintStyle: TextStyle(color: Colors.blue),
    labelText: "Şifre",
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: Colors.blue)
    ),
    ),
    ),
    ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: GestureDetector(
                  onTap: () async{
                        try{
                          UserCredential userCredential =  await FirebaseAuth.instance.signInWithEmailAndPassword(email: epostacontroller.text, password: sifrecontroller.text);
                          widget.onSignIn(userCredential.user);
                          await FirebaseFirestore.instance.collection("users").doc(epostacontroller.text).collection("water").doc(epostacontroller.text).set(
                              {"data":0 , "height": MediaQuery.of(context).size.height*0.048});
                        }

                        catch(e){
                          setState(() {
                            Fluttertoast.showToast(
                                gravity: ToastGravity.CENTER,
                                toastLength: Toast.LENGTH_LONG,
                                msg: "HATA --> "+ e.toString());
                          });
                        }
                  },
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width*0.65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.greenAccent
                    ),
                    child: Center(child: Text("GİRİŞ YAP",style: TextStyle(fontFamily: "IndieFlower",color: Colors.white,fontSize: 24),)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: GestureDetector(
                  onTap: (){
                    setState(() {
                      pageState=2;
                    });
                  },
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width*0.65,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.greenAccent
                    ),
                    child: Center(child: Text("ÜYE OL",style: TextStyle(fontFamily: "IndieFlower",color: Colors.white,fontSize: 24),)),
                  ),
                ),
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: (){
           setState(() {
             pageState=1;
           });
          },
          child: AnimatedContainer(
            duration: Duration(
                milliseconds: 1100
            ),
            transform: Matrix4.translationValues(0, registerY, 1),
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                )
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text("KAYIT OL",style: TextStyle(fontFamily: "IndieFlower",color: Colors.white,fontSize: 24),),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Container(
                          width: MediaQuery.of(context).size.width*0.88,
                          child: Form(
                            child:TextFormField(
                              controller: epostacontroller,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Email Adresi",
                                hintStyle: TextStyle(color: Colors.white),
                                labelText: "E Mail",labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  width: MediaQuery.of(context).size.width*0.88,
                  child: Form(
                    child:TextFormField(
                      controller: sifrecontroller,
                      style: TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "ŞİFRE",
                        hintStyle: TextStyle(color: Colors.white),
                        labelText: "Şifre",labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.white)
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                      });
                    },
                    child: GestureDetector(
                      onTap: () async{
                          try{
                            await  FirebaseAuth.instance.createUserWithEmailAndPassword(email: epostacontroller.text, password: sifrecontroller.text).then((value) => Fluttertoast.showToast(msg: "BAŞARILI"));

                          }
                          catch(e){
                            setState(() {
                              Fluttertoast.showToast(
                                  gravity: ToastGravity.CENTER,
                                  toastLength: Toast.LENGTH_LONG,
                                  msg: "HATA --> "+ e.toString());
                            });
                          }
                      },
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width*0.65,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Colors.greenAccent
                        ),
                        child: Center(child: Text("KAYIT OL",style: TextStyle(fontFamily: "IndieFlower",color: Colors.white,fontSize: 24),)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]
    );
  }
}
