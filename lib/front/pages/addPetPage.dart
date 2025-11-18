import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:tt_predictor/front/pages/editPetPage.dart';
import 'package:tt_predictor/required/enumeration.dart';


class AddPetPage extends StatefulWidget {
  @override
  _AddPetPageState createState() => _AddPetPageState();
}

class _AddPetPageState extends State {

  var newName = "";
  var newPhotoUrls = [];
  var newStatus = StateLabel.available.state;
  var newId = 0;


  bool firstButtonActivity = true;
  bool secondButtonActivity = false;

  @override
  Widget build(BuildContext context) {
    var petImage = newPhotoUrls.isNotEmpty && newPhotoUrls[0] != null?
    Image.network(newPhotoUrls[0],
        scale: 0.5,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace){
          return Icon(Icons.photo, size: 100);
        }) :
    Icon(Icons.photo, size : 100);
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Dialog.fullscreen(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: kIsWeb && width > height ?
        (width - height) / 2 :
        0),
            child: Column(
              children: [
                Flexible (
                  child: Padding(padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    child: petImage,
                  )
                ),
                Flexible(
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        child: Padding(padding: EdgeInsets.symmetric(horizontal: 4),
                            child: ListView(
                              padding: const EdgeInsets.all(4),
                              children: [
                                SizedBox(
                                    child: Card(
                                      child: ListTile(
                                        leading: SizedBox(
                                            width: 60,
                                            child: const Text("Name:",
                                              style: TextStyle(
                                                  fontSize: 15
                                              ),)
                                        ),
                                        title: TextField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Введите имя"
                                          ),
                                          onChanged: (String value) {
                                            setState(() {
                                              secondButtonActivity = true;
                                              newName = value == "" ? "no name" : value;
                                            });
                                          },
                                        ),
                                      ),
                                    )
                                ),
                                SizedBox(
                                    child: Card(
                                      child: ListTile(
                                        leading: SizedBox(
                                            width: 60,
                                            child: const Text("Photo URL:",
                                              style: TextStyle(
                                                  fontSize: 15
                                              ),)
                                        ),
                                        title: TextField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Введите URL фотографии"
                                          ),
                                          onChanged: (String value) {
                                            setState(() {
                                              secondButtonActivity = true;
                                              newPhotoUrls.isEmpty ? newPhotoUrls.add(value) : newPhotoUrls[0] = value;
                                            });
                                          },
                                        ),
                                      ),
                                    )
                                ),
                                SizedBox(
                                    child: Card(
                                      child: ListTile(
                                          leading: SizedBox(
                                              width: 60,
                                              child: const Text("Статус:",
                                                style: TextStyle(
                                                    fontSize: 15
                                                ),)
                                          ),
                                          title:  DropdownMenu<StateLabel>(
                                            initialSelection: StateLabel.available,
                                            requestFocusOnTap: false,
                                            label: const Text('Выбрать наличие питомца'),
                                            onSelected: (StateLabel? state) {
                                              setState(() {
                                                secondButtonActivity = true;
                                                newStatus = state != null ? state.state : StateLabel.available.state;
                                              });
                                            },
                                            dropdownMenuEntries: StateLabel.entries,
                                          ),
                                      ),
                                    )
                                ),
                                SizedBox(
                                    child: newId != 0 ? Card(
                                      child: ListTile(
                                          leading: SizedBox(
                                              width: 60,
                                              child: const Text("ID:",
                                                style: TextStyle(
                                                    fontSize: 15
                                                ),)
                                          ),
                                          title: Text(newId.toString())
                                      ),
                                    ) : null
                                ),
                              ],
                            )
                        )
                    )
                ),
                Padding(padding: EdgeInsets.only(bottom: 10)),
                Row(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 8)),
                      OutlinedButton(onPressed: firstButtonActivity ? () {
                        Navigator.of(context).pop();
                      } : null,
                          child: const Text("Назад")
                      ),
                      Padding(padding: EdgeInsets.only(left: 8),
                          child: OutlinedButton(onPressed: secondButtonActivity ? () {
                            setState(() {
                              firstButtonActivity = false;
                              secondButtonActivity = false;
                              addNewPet(newName, newPhotoUrls, newStatus);
                            });
                          } : null,
                              child: const Text("Добавить питомца")
                          )
                      ),
                    ]
                )
              ]
            )
        )
    );
  }

  void addNewPet(String name, List photoUrls, String status) async {
    var petData = {
      "id": 0,
      "category": {
        "id": 0,
        "name": "string"
      },
      "name": name,
      "photoUrls": photoUrls,
      "tags": [
        {
          "id": 0,
          "name": "string"
        }
      ],
      "status": status
    };
    var urlPut = Uri.https('petstore.swagger.io', 'v2/pet');
    var response = await http.post(urlPut, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    }, body: jsonEncode(petData));
    setState(() {
      newId = jsonDecode(response.body)["id"];
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: response.statusCode == 200 ? const Text('Питомец был успешно добавлен!') : Text("Произошла ошибка: ${response.statusCode.toString()}"),
    //       duration: const Duration(milliseconds: 1500),
    //       width: 280.0, // Width of the SnackBar.
    //       padding: const EdgeInsets.symmetric(
    //         horizontal: 8.0,
    //         vertical: 4.0
    //       ),
    //       behavior: SnackBarBehavior.floating,
    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    //     ),
    //   );
      firstButtonActivity = true;
      if (response.statusCode != 200) {
        secondButtonActivity = true;
      }
    });
  }

}