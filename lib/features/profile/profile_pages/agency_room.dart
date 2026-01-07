import 'package:flutter/material.dart';
import 'package:kittyparty/core/constants/colors.dart';
import 'package:kittyparty/core/global_widgets/buttons/gradient_button.dart';
import 'package:kittyparty/features/auth/widgets/text_field.dart';

class AgencyRoom extends StatefulWidget {
  const AgencyRoom({super.key});

  @override
  State<AgencyRoom> createState() => _AgencyRoomState();
}

class _AgencyRoomState extends State<AgencyRoom> {
  final _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(useMaterial3: true),
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text('All'), // Added title for clarity
          bottom: PreferredSize(
            preferredSize: Size.fromRadius(35),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: BasicTextField(
                labelText: 'UserName',
                controller: _searchController,
                hintText: 'Please enter the Agent ID to search',
                validator: (p0) {
                  return null;
                },
              ),
            ),
          ),
        ),
        extendBody: true,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(14),
          child: GradientButton(
            width: 20,
            gradient: AppColors.goldShineGradient,
            text: 'Create Agency',
            onPressed: () {},
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 8,
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: 10,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildUserContainer();
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 14);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stack _buildUserContainer() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(60, 24, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: Row(
            children: [
              SizedBox(width: 56),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username', style: TextStyle(color: Colors.amber)),
                  Text(
                    'Agent ID: 000001',
                    style: TextStyle(color: Colors.amber),
                  ),
                  Text('1/40', style: TextStyle(color: Colors.amber)),
                ],
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () => _showDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Join', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          top: -10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.amber),
              ),
              child: Icon(Icons.person),
            ),
          ),
        ),
      ],
    );
  }
}

void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            spacing: 12,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Apply to join?'),
              Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientButton(
                    text: 'Cancel',
                    gradient: AppColors.grayGradient,
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                  GradientButton(
                    text: 'Confirm',
                    gradient: AppColors.mainGradient,
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
