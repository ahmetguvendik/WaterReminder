import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NewWater extends StatefulWidget {

  final Function(User) onSignOut;
  String user;
  NewWater({@required this.onSignOut, @required this.user});

  @override
  State<NewWater> createState() => _NewWaterState();
}

class _NewWaterState extends State<NewWater> {
   AndroidNotificationChannel channel;

   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState(){
    super.initState();

    loadFCM();

    listenFCM();

    getToken();
  }

    void listenFCM() async{

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification notification = message.notification;
        AndroidNotification android = message.notification?.android;
        if (notification != null && android != null && !kIsWeb) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ),
          );
        }
      });

    }

    void getToken()async{
    await FirebaseMessaging.instance.getToken().then((value) => print(value));
    }

   void loadFCM() async{
     if (!kIsWeb) {
       channel = const AndroidNotificationChannel(
         'high_importance_channel', // id
         'High Importance Notifications', // title
         importance: Importance.high,
         enableVibration: true,
       );

       flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

       /// Create an Android Notification Channel.
       ///
       /// We use this channel in the `AndroidManifest.xml` file to override the
       /// default FCM channel to enable heads up notifications.
       await flutterLocalNotificationsPlugin
           .resolvePlatformSpecificImplementation<
           AndroidFlutterLocalNotificationsPlugin>()
           ?.createNotificationChannel(channel);

       /// Update the iOS foreground notification presentation options to allow
       /// heads up notifications.
       await FirebaseMessaging.instance
           .setForegroundNotificationPresentationOptions(
         alert: true,
         badge: true,
         sound: true,
       );
     }
   }

  Future<void> logout() async{
    await FirebaseAuth.instance.signOut();
    widget.onSignOut(null);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              CupertinoButton(child: Text("Veriyi Sıfırla",style: TextStyle(fontFamily: "IndieFlower",color: Colors.black,fontSize: 24),), onPressed: () async{
                await FirebaseFirestore.instance.collection("users").doc(widget.user).collection("water").doc(widget.user).set(
                    {"data":0 , "height": MediaQuery.of(context).size.height*0.048});
              }),

              IconButton(onPressed: logout
                  , icon: Icon(Icons.login_outlined)),
            ],
            title: Text("Su Hayattır"),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.blue, Colors.greenAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight
                  )
              ),
            ),
            bottom: TabBar(
                indicatorColor: Colors.black,
                indicatorWeight: 3,
                tabs: [
                  Tab(icon: Icon(Icons.home),text: "AnaSayfa",),
                  Tab(icon: Icon(Icons.person),text: "Profil",),
                  Tab(icon: Icon(Icons.timeline),text: "Geçmiş",)
                ]
            ),
          ),
          body: TabBarView(
              children: [
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("users").doc(widget.user).collection("water").snapshots(),
                  // ignore: missing_return
                  builder: (BuildContext context , AsyncSnapshot async ){
                    if(async.hasError){
                      return Center(child: Text("Bir hata Oluştu, Lütfen Daha Sonra Tekrar Deneyiniz"),);
                    }
                    else{
                      if(async.hasData){
                        final List liste = async.data.docs;
                        return ListView.builder(
                          reverse: true,
                            itemCount: liste.length,
                            itemBuilder: (context,index){
                              return GestureDetector(
                                onTap: () async{
                                  await FirebaseFirestore.instance.collection("users").doc(widget.user).collection("water").doc(widget.user).update(
                                      {"data": liste[index].data()["data"] = liste[index].data()["data"]+200, "height":liste[index].data()["height"] = liste[index].data()["height"]+MediaQuery.of(context).size.height*0.050});
                                },
                                child: AnimatedContainer(
                                  height: liste[index].data()["height"],
                                  width: MediaQuery.of(context).size.width,
                                  duration: Duration(seconds: 1),
                                  decoration: BoxDecoration(
                                      color: Colors.lightBlueAccent,
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(10))
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(liste[index].data()["data"].toString() +"mL"+ " / 3000mL",style: TextStyle(fontFamily: "IndieFlower",color: Colors.black,fontSize: 24),),
                                  ),
                                ),
                              );

                          }
                        );

                      }
                      else{
                        return Center(child: CircularProgressIndicator(),);
                      }
                    }
                  },
                ),

                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50,horizontal: 50),
                      child: Row(
                        children: [
                          CircleAvatar(
                            maxRadius: 60,
                            backgroundImage: AssetImage("images/su.jpg"),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                            child: Column(
                              children: [
                                Text("HOŞ GELDİNİZ",style: TextStyle(fontSize: 22,fontStyle: FontStyle.italic),),
                                SizedBox(height: 5,),
                                Text(widget.user.toString()),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    buildContainer(icon: Icons.security,name: "Gizlilik"),
                    SizedBox(height: 20,),
                    buildContainer(icon: Icons.help, name: "Yardım ve Destek"),
                    SizedBox(height: 20,),
                    buildContainer(icon: Icons.settings, name: "Ayarlar"),
                    SizedBox(height: 20,),
                    buildContainer(icon: Icons.person_add, name: "Arkadaşlarını Davet Et"),
                    SizedBox(height: 20,),
                    GestureDetector(
                        onTap: (){
                          logout();
                        },
                        child: buildContainer(icon: Icons.login_outlined, name: "Çıkış Yap"))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView(
                    children: [
                      buildCard(deger: "3000ml",tarih: "20/02/2022",),
                      buildCard(deger: "2800ml",tarih: "21/02/2022",),
                      buildCard(deger: "1000ml",tarih: "22/02/2022",),
                      buildCard(deger: "2300ml",tarih: "23/02/2022",),
                    ],
                  ),
                )
              ])
      ),
    );
  }
}
class buildCard extends StatelessWidget {
  String tarih;
  String deger;

  buildCard({@required this.deger,@required this.tarih});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(tarih,style: TextStyle(fontFamily: "IndieFlower",color: Colors.white70,fontSize: 20),),
              Spacer(),
              Text(deger,style: TextStyle(fontFamily: "IndieFlower",color: Colors.white70,fontSize: 26),)
            ],
          ),
        )
    );
  }
}

class buildContainer extends StatelessWidget {
  String name;
  IconData icon;

  buildContainer({@required this.icon, @required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.77,
      height: MediaQuery
          .of(context)
          .size
          .height * 0.05,
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white,),
          SizedBox(width: 10,),
          Text(name, style: TextStyle(color: Colors.white),)
        ],
      ),
    );
  }
}