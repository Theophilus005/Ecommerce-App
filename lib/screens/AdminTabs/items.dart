import 'package:flutter/material.dart';

class Items extends StatefulWidget {
  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text("Add/Edit Items"),
              backgroundColor: Colors.orange[300],
            ),
        body: Column(
          children: <Widget> [
          SizedBox(height:15),
          ItemCard(image: "assets/images/jollof.png", name: "Kentucky Pizza", price:24 )
          ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.orange[300],
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({
    Key key, this.image, this.name, this.price,
  }) : super(key: key);

  final String image;
  final String name;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:EdgeInsets.only(left:5, right:5, bottom:15),
      width:double.infinity,
      height:100,
      decoration:BoxDecoration(
      color: Colors.orange,
      borderRadius: BorderRadius.circular(10),  
      ),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left:10),
            width:100,
            height: 80,
            color: Colors.white,
            child: Image.asset(image),
          ),
          SizedBox(width:20),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                Text("Item: ", style: TextStyle(color: Colors.white, fontSize:18),),
                Text(name, style: TextStyle(color: Colors.white, fontSize:18),),
              ],
              ),
              Row(children: <Widget>[
                Text("Price: ", style: TextStyle(color: Colors.white, fontSize:18),),
                Text("GH¢$price", style: TextStyle(color: Colors.white, fontSize:18),),
              ],
              ),

              Row(children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.edit, color: Colors.white, size:25),
                      Text("Edit", style: TextStyle(color:Colors.white, fontSize: 17),),
                    ],
                  ),
                ),
                SizedBox(width:20),
                Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete, color:Colors.white, size:25),
                      Text("Delete", style: TextStyle(color:Colors.white, fontSize: 17),),                  ],
                  ),
                ),
              ],
              ),
            ],
          ),
        ],
      )    
    );
  }
}