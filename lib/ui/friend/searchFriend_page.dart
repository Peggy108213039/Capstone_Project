import 'package:flutter/material.dart';
import 'package:capstone_project/models/friend/friendList_model.dart';
import 'package:provider/provider.dart';

class SearchFriendPage extends StatefulWidget {
  const SearchFriendPage({Key? key}) : super(key:key) ;

  @override
  State<SearchFriendPage> createState() => _SearchFriendPageState() ;
}

class _SearchFriendPageState extends State<SearchFriendPage> {
  FriendViewModel viewModel = FriendViewModel();
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Friend"),
          ),
          body: Column(
            children: [
              Container(
                height: 44,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  onChanged: (newValue) {
                    viewModel.searchFieldOnChanged(newValue);
                  },
                  controller: viewModel.searchController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, size: 30,),
                    hintText: "name",
                    border: InputBorder.none
                  ),
                )
              ),
              Consumer(
                builder: (BuildContext context, FriendViewModel vm, Widget? chil) {
                  return Expanded(
                    child:ListView.separated(itemBuilder: ((context, index) {
                      Friend friend = vm.filterFriends[index];
                      return Container(
                        height: 44,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(child: Text(
                              friend.name,
                              style: const TextStyle(fontSize: 17, /*fontWeight: FontWeight.bold*/),
                            )),
                            Text(friend.tel, style: const TextStyle(
                              fontSize: 15,
                            ),)
                          ],
                        ),
                      );
                    }), separatorBuilder: ((context, index) {
                      return Container(
                        margin: const EdgeInsets.only(left: 20),
                        height: 1,
                        width: double.infinity,
                        color: Colors.black,
                      );
                    }), itemCount: viewModel.filterFriends.length)
                  );
                },
              ),
            ]
          ),
        );
      },
    );
    
  }
}