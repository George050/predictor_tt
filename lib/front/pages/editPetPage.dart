import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../required/enumeration.dart';
import 'home.dart';

class PetPage extends StatefulWidget {

  int petId;
  String name;
  List photoUrls;
  String status;
  int petCardIndex;
  List pets;
  HomeState homeState;
  //List<Map> tags;
  //Map category;

  PetPage({ super.key, required this.petId, required this.name,
    required this.photoUrls, required this.status, required this.petCardIndex,
    required this.pets, required this.homeState});

  @override
  _PetPageState createState() => _PetPageState(this.petId, this.name,
      this.photoUrls, this.status, this.petCardIndex, this.pets, this.homeState);
}

class _PetPageState extends State<PetPage> {

  int petId;
  String name;
  List photoUrls;
  String status;
  int petCardIndex;
  List pets;
  HomeState homeState;

  String changedName = "";
  List changedPhotoUrls = [];
  String changedStatus = "";

  bool firstButtonActivity = true;
  bool secondButtonActivity = false;

  bool editingStatus = false;

  _PetPageState(this.petId, this.name, this.photoUrls, this.status,
      this.petCardIndex, this.pets, this.homeState) {
    changedName = name;
    changedPhotoUrls = photoUrls.toList();
    changedStatus = status;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    var petImage = photoUrls.isNotEmpty && photoUrls[0] != null ?
    Image.network(photoUrls[0],
        scale: 0.5,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace){
          return Icon(Icons.photo, size: 100);
        }) :
    Icon(Icons.photo, size : 100);
    return  Dialog.fullscreen(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: kIsWeb && width > height ?
        (width - height) / 2 :
        0),
            child:
            Column(
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
                                          title: Text(name,
                                            style: TextStyle(
                                                fontSize: 20
                                            ),
                                            maxLines: 2,
                                          ),
                                          subtitle: editingStatus ? TextField(
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: "Введите новое имя"
                                            ),
                                            onChanged: (String value) {
                                              setState(() {
                                                secondButtonActivity = true;
                                                changedName = value;
                                              });
                                            },
                                          ) : null,
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
                                          title: Text(photoUrls.isNotEmpty ? photoUrls[0] : "Нет URL",
                                              style: TextStyle(
                                                  fontSize: 14
                                              ),
                                              maxLines: 8
                                          ),
                                          subtitle: editingStatus ? TextField(
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: "Введите новый URL"
                                            ),
                                            onChanged: (String value) {
                                              setState(() {
                                                secondButtonActivity = true;
                                                changedPhotoUrls.isEmpty ? changedPhotoUrls.add(value) : changedPhotoUrls[0] = value;
                                              });
                                            },
                                          ) : null,
                                        ),
                                      )
                                  ),
                                  SizedBox(
                                      child: Card(
                                        child: ListTile(
                                          leading: SizedBox(
                                              width: 60,
                                              child: const Text("ID:",
                                                style: TextStyle(
                                                    fontSize: 15
                                                ),)
                                          ),
                                          title: Text(petId.toString(),
                                              style: TextStyle(
                                                  fontSize: 20
                                              ),
                                              maxLines: 8
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
                                            title: Text(status,
                                              style: TextStyle(
                                                  fontSize: 20
                                              ),
                                              maxLines: 8,
                                            ),
                                            subtitle: editingStatus ? Padding(padding: EdgeInsets.only(top: 10),
                                              child: DropdownMenu<StateLabel>(
                                                initialSelection: status == StateLabel.available.state ?
                                                StateLabel.available :
                                                status == StateLabel.pending.state ?
                                                StateLabel.pending :
                                                StateLabel.sold,
                                                requestFocusOnTap: false,
                                                label: const Text('Выбрать наличие питомца'),
                                                onSelected: (StateLabel? state) {
                                                  setState(() {
                                                    secondButtonActivity = true;
                                                    changedStatus = state != null ? state.state : status;
                                                  });
                                                },
                                                dropdownMenuEntries: StateLabel.entries,
                                              ),
                                            ) : null
                                        ),
                                      )
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
                            child: OutlinedButton(onPressed: firstButtonActivity ? () {
                              setState(() {
                                editingStatus = !editingStatus;
                              });
                            } : null,
                                child: editingStatus ? const Text("Отменить") : const Text("Редактирование")
                            )
                        ),
                        Padding(padding: EdgeInsets.only(left: 8),
                            child: editingStatus ? OutlinedButton(onPressed: secondButtonActivity ? () {
                              var petProperties = pets[petCardIndex];
                              petProperties["photoUrls"] = changedPhotoUrls;
                              petProperties["name"] = changedName == "" ? name : changedName;
                              petProperties["status"] = changedStatus;
                              firstButtonActivity = false;
                              secondButtonActivity = false;
                              updatePetData(petProperties);
                              setState(() {
                              });
                            } : null,
                                child: const Text("Сохранить")
                            ) : null
                        )
                      ]
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 30)),
                ]
            )
        )
    );
  }

  void updatePetData(Map petData) async {
    var urlPut = Uri.https('petstore.swagger.io', 'v2/pet');
    var response = await http.put(urlPut, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    }, body: jsonEncode(petData));
    homeState.setPets();
    var decodedResponse = jsonDecode(response.body);
    setState(() {
      name = decodedResponse["name"];
      photoUrls = decodedResponse["photoUrls"];
      status = decodedResponse["status"];
      firstButtonActivity = true;
      editingStatus = false;
    });

  }
}
