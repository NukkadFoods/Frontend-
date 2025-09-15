import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver_app/providers/edit_profile_provider.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:driver_app/widgets/common/custom_phone_field.dart';
import 'package:driver_app/widgets/common/custom_text_field.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:driver_app/widgets/common/info_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key, this.deliveryBoyData});
  final deliveryBoyData;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditProfileProvider(deliveryBoyData),
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                    opacity: .5,
                    image: AssetImage('assets/images/otpbbg.png'))),
            child: SizedBox.expand(),
          ),
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () async {
                      context.read<EditProfileProvider>().navigateBack(context);
                    },
                    icon: Icon(Icons.arrow_back_ios_new)),
                centerTitle: true,
                title: Text(
                  'Edit profile',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: medium),
                ),
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Consumer<EditProfileProvider>(
                      builder: (context, value, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 4,
                                  color: colorGreen,
                                ),
                                shape: BoxShape.circle),
                            child: Stack(
                              alignment: AlignmentDirectional.bottomEnd,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  foregroundImage: deliveryBoyData != null
                                      ? deliveryBoyData['profilePic'] != null
                                          ? CachedNetworkImageProvider(
                                              deliveryBoyData['profilePic']!)
                                          : deliveryBoyData['gender'] == 'Male'
                                              ? AssetImage(
                                                  'assets/images/avatarm.png',
                                                )
                                              : AssetImage(
                                                  'assets/images/avatarf.png',
                                                )
                                      : AssetImage(
                                          'assets/images/avatarm.png',
                                        ),
                                ),
                                InkWell(
                                    onTap: () {
                                      value.editProfilePic(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colorGreen),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                        color: colorWhite,
                                      ),
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          CustomTextField(
                            label: 'NAME',
                            controller: value.nameController,
                          ),
                          SizedBox(
                            height: 20,
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  value.showErrors &&
                                          value.nameController.text.isEmpty
                                      ? '   *required field'
                                      : '',
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          CustomPhoneField(controller: value.phoneNoController),
                          SizedBox(
                            height: 20,
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  value.showErrors &&
                                          value.phoneNoController.text.length < 10
                                      ? '   *required field'
                                      : '',
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          CustomTextField(
                            label: 'DATE OF BIRTH',
                            controller: value.dobController,
                            icon: IconButton(
                              onPressed: () => value.selectDate(context),
                              icon: const Icon(
                                Icons.calendar_month,
                                color: colorGreen,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  value.showErrors &&
                                          value.dobController.text.isEmpty
                                      ? '   *required field'
                                      : '',
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          CustomTextField(
                            label: 'EMAIL',
                            controller: value.emailController,
                          ),
                          SizedBox(
                            height: 20,
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  value.showErrors &&
                                          value.emailController.text.isEmpty
                                      ? '   *required field'
                                      : '',
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          CustomTextField(
                            label: 'ADDRESS',
                            controller: value.addressController,
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Text('BANK DETAILS'),
                          SizedBox(
                            height: 20,
                          ),
                          CustomTextField(
                            label: 'ACCOUNT NUMBER',
                            controller: value.accountController,
                          ),
                          SizedBox(
                            height: 20,
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  value.showErrors &&
                                          value.accountController.text.isEmpty
                                      ? '   *required field'
                                      : '',
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          CustomTextField(
                            label: 'IFSC CODE',
                            controller: value.ifscController,
                          ),
                          SizedBox(
                            height: 20,
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  value.showErrors &&
                                          value.ifscController.text.isEmpty
                                      ? '   *required field'
                                      : '',
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          CustomTextField(
                            label: 'BANK BRANCH CODE',
                            controller: value.branchController,
                          ),
                          SizedBox(
                            height: 30,
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  value.showErrors &&
                                          value.branchController.text.isEmpty
                                      ? '   *required field'
                                      : '',
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          InfoContainer(
                              message:
                                  'Your earnings will be transferred to this bank account every week.'),
                          SizedBox(
                            height: 30,
                          ),
                          FullWidthGreenButton(
                              isLoading: !value.enableUpdate,
                              label: 'UPDATE PROFILE',
                              onPressed: value.updateDetails)
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
