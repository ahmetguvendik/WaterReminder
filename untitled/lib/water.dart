import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Water extends StatefulWidget {
  final Function(User) onSignOut;
  String user;


  Water({@required this.onSignOut,@required this.user});

  @override
  State<Water> createState() => _WaterState();
}

class _WaterState extends State<Water>{
  double yukseklik =45;
  double deger =0;

  void addHeight() async{
    yukseklik = yukseklik +MediaQuery.of(context).size.height*0.05;
    deger = deger + 200;
    await FirebaseFirestore.instance.collection("users").doc(widget.user).collection("water").doc(widget.user).set(
      {"data": deger,
        "height": yukseklik}
    );
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
              IconButton(onPressed: logout
              , icon: Icon(Icons.login_outlined))
            ],
          title: Text("Su Hayattır"),
          centerTitle: true,
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
                          itemCount: liste.length,
                          itemBuilder: (context,index){
                            return GestureDetector(
                              onTap: (){
                                addHeight();
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
                                 child: Text(liste[index].data()["data"].toString() + " / 3000mL",style: TextStyle(fontFamily: "IndieFlower",color: Colors.black,fontSize: 24),),
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

  buildContainer({@required this.icon,@required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*0.77,
      height: MediaQuery.of(context).size.height*0.05,
      decoration: BoxDecoration(
        color: Colors.black ,
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,color: Colors.white,),
          SizedBox(width: 10,),
          Text(name,style: TextStyle(color: Colors.white),)
        ],
      ),
    );
  }
}
