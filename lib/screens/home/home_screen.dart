import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/models/user_model.dart';
import 'package:ripple/providers/auth_provider.dart';
import 'package:ripple/providers/user_provider.dart';
import 'package:ripple/widgets/custom_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = context.watch<UserProvider>();
    List<UserModel> users = userProvider.users;
    //userProvider.getAvailableUsers();
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: "Chats"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment:CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return Row(
                        spacing: 10,
                        children: [
                          CustomText(text: users[index].name.isNotEmpty ?  users[index].name : users[index].email.substring(0,users[index].email.indexOf("@"))),
                          CustomText(text: "Is online: ${users[index].isOnline}"),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          FilledButton(onPressed: (){

            context.read<AuthenticationProvider>().signOut(context);
          }, child: CustomText(text: "Sign out"))
        ],
      ),
    );
  }
}
