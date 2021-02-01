import 'dart:io';

import 'package:contacts_flutter_app/helpers/contact_helper.dart';
import 'package:contacts_flutter_app/helpers/ui/contact_page.dart';
import 'package:contacts_flutter_app/models/contact.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    getAllContacts();
  }

  void getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) {
              return <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de A-Z"),
                  value: OrderOptions.orderaz,
                ),
                const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de Z-A"),
                  value: OrderOptions.orderza,
                ),
              ];
            },
            onSelected: orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showContactHomePage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return contactCard(context, index);
          }),
    );
  }

  Widget contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: contacts[index].image != null
                              ? FileImage(File(contacts[index].image))
                              : AssetImage("images/person.png"),
                          fit: BoxFit.cover)),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(contacts[index].name ?? "",
                            style: TextStyle(
                                fontSize: 22.0, fontWeight: FontWeight.bold)),
                        Text(contacts[index].email ?? "",
                            style: TextStyle(fontSize: 18.0)),
                        Text(contacts[index].phone ?? "",
                            style: TextStyle(fontSize: 18.0))
                      ],
                    ))
              ],
            )),
      ),
      onTap: () {
        showOptions(context, index);
      },
    );
  }

  void showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  FlatButton(
                    child: Text("Ligar",
                        style: TextStyle(color: Colors.red, fontSize: 20.0)),
                    onPressed: () {
                      launch("tel:${contacts[index].phone}");
                      Navigator.pop((context));
                    },
                  ),
                  FlatButton(
                    child: Text("Editar",
                        style: TextStyle(color: Colors.red, fontSize: 20.0)),
                    onPressed: () {
                      Navigator.pop(context);
                      showContactHomePage(contact: contacts[index]);
                    },
                  ),
                  FlatButton(
                    child: Text("Excluir",
                        style: TextStyle(color: Colors.red, fontSize: 20.0)),
                    onPressed: () {
                      helper.deleteContact(contacts[index].id);
                      setState(() {
                        contacts.removeAt(index);
                        Navigator.pop(context);
                      });
                    },
                  ),
                ]),
              );
            },
            onClosing: () {},
          );
        });
  }

  void showContactHomePage({Contact contact}) async {
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      getAllContacts();
    }
  }

  void orderList(OrderOptions results) {
    setState(() {
      switch (results) {
        case OrderOptions.orderaz:
          contacts.sort((a, b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
          break;
        case OrderOptions.orderza:
          contacts.sort((a, b) {
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
          });
          break;
      }
    });
  }
}
