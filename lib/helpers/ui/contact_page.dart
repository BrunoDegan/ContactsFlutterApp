import 'dart:io';

import 'package:contacts_flutter_app/models/contact.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  Contact? contact;

  //optional param this.contact
  ContactPage(this.contact);

  @override
  State<StatefulWidget> createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {
  bool edited = false;
  late Contact editedContact;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final nameFocus = FocusNode();
  final phoneFocus = FocusNode();
  final emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      editedContact = Contact();
    } else {
      editedContact = widget.contact!;
      nameController.text = editedContact.name ?? "";
      phoneController.text = editedContact.phone ?? "";
      emailController.text = editedContact.email ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(editedContact.name ?? ""),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.save),
            backgroundColor: Colors.red,
            onPressed: () {
              if (editedContact != null &&
                  editedContact.name!.isNotEmpty &&
                  editedContact.phone != null &&
                  editedContact.phone!.isNotEmpty) {
                Navigator.pop(context, editedContact);
              } else {
                FocusScope.of(context).requestFocus(nameFocus);
              }
            }),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: _selectedImage(), fit: BoxFit.cover),
                  ),
                ),
                onTap: () {
                  getImage();
                },
              ),
              TextField(
                focusNode: nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  edited = true;
                  setState(() {
                    editedContact.name = text;
                  });
                },
                controller: nameController,
              ),
              TextField(
                focusNode: emailFocus,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  edited = true;
                  editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
              ),
              TextField(
                focusNode: phoneFocus,
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (text) {
                  edited = true;
                  editedContact.phone = text;
                },
                keyboardType: TextInputType.number,
                controller: phoneController,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> requestPop() {
    if (edited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Descartar alterações'),
              content: Text('Se sair as alterações serão perdidas'),
              actions: <Widget>[
                TextButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });

      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  ImageProvider _selectedImage() {
    if (editedContact.image != null) {
      return FileImage(File(editedContact.image ?? ""));
    } else {
      return AssetImage("images/person.png");
    }
  }

  void getImage() async {
    await ImagePicker()
        .getImage(
            source: ImageSource.camera,
            imageQuality: 100,
            preferredCameraDevice: CameraDevice.front)
        .then((file) {
      setState(() {
        editedContact.image = file?.path ?? "";
      });
    });
  }
}
