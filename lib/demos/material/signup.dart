// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';

// 注册

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(GalleryLocalizations.of(context)!.demoTextFieldTitle),
      ),
      body: const SignupFormField(),
    );
  }
}

class SignupFormField extends StatefulWidget {
  const SignupFormField({super.key});

  @override
  SignupFormFieldState createState() => SignupFormFieldState();
}

class SignupPersonData {
  String? name = '';
  String? phoneNumber = '';
  String? email = '';
  String password = '';
}

class MyPasswordField extends StatefulWidget {
  const MyPasswordField({
    super.key,
    this.restorationId,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
  });

  final String? restorationId;
  final Key? fieldKey;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  State<MyPasswordField> createState() => _MyPasswordFieldState();
}

class _MyPasswordFieldState extends State<MyPasswordField> with RestorationMixin {
  final RestorableBool _obscureText = RestorableBool(true);

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_obscureText, 'obscure_text');
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      restorationId: 'password_text_field',
      obscureText: _obscureText.value,
      maxLength: 16,
      onSaved: widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        filled: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText.value = !_obscureText.value;
            });
          },
          hoverColor: Colors.transparent,
          icon: Icon(
            _obscureText.value ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscureText.value
                ? GalleryLocalizations.of(context)!
                    .demoTextFieldShowPasswordLabel
                : GalleryLocalizations.of(context)!
                    .demoTextFieldHidePasswordLabel,
          ),
        ),
      ),
    );
  }
}

class SignupFormFieldState extends State<SignupFormField>
    with RestorationMixin {
  SignupPersonData person = SignupPersonData();

  late FocusNode _phoneNumber, _email, _lifeStory, _password, _retypePassword;

// Flutter中的initState是一个生命周期方法，它在当前widget被插入到widget树中时被调用[2]。可以在initState中进行一些初始化操作，例如异步请求数据
  @override
  void initState() {
    super.initState();
    _email = FocusNode();
    _password = FocusNode();
    _retypePassword = FocusNode();
    _phoneNumber = FocusNode();
    _lifeStory = FocusNode();
  }

// Flutter中的dispose方法是用来释放State所占用的内存空间的。具体来说，dispose方法可以在以下情况下使用：
// 当Stateful widget被永久性地从树中移除时，dispose方法会被调用。这个时候，可以在dispose方法中执行一些额外的指令。
// 当使用一些需要手动释放内存空间的资源时，例如stream，需要在dispose方法中释放这些资源，以免内存泄漏。
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _retypePassword.dispose();
    _phoneNumber.dispose();
    _lifeStory.dispose();
    super.dispose();
  }

// ScaffoldMessenger是一个小部件，提供了在屏幕顶部和底部显示snackBar和material banner的API。
  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  String get restorationId => 'my_login_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_autoValidateModeIndex, 'autovalidate_mode');
  }

  final RestorableInt _autoValidateModeIndex =
      RestorableInt(AutovalidateMode.disabled.index);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();
  final _UsNumberTextInputFormatter _phoneNumberFormatter =
      _UsNumberTextInputFormatter();

  // 提交
  void _handleSubmitted() {
    final form = _formKey.currentState!;
    print(form);
    print(form.validate());
    if (!form.validate()) {
      _autoValidateModeIndex.value =
          AutovalidateMode.always.index; // Start validating on every change.
      showInSnackBar(
        GalleryLocalizations.of(context)!.demoTextFieldFormErrors,
      );
    } else {
      form.save();
      // print(person.phoneNumber,person.password,person.email);
      print(person);
      print(person.email);
      print(person.password);
      showInSnackBar(GalleryLocalizations.of(context)!
          .demoMyLoginEMailAndPwd(person.email!, person.password!));
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return GalleryLocalizations.of(context)!.demoTextFieldNameRequired;
    }
    final nameExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return GalleryLocalizations.of(context)!
          .demoTextFieldOnlyAlphabeticalChars;
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final phoneExp = RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$');
    if (!phoneExp.hasMatch(value!)) {
      return GalleryLocalizations.of(context)!.demoTextFieldEnterUSPhoneNumber;
    }
    return null;
  }

  //             phone = {type = "string", pattern = "^[1][3,5,7,8][0-9]\\d{8}$"},

  String? _validateEMailOrPhone(String? value) {
    final emailExp = RegExp(r"^[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?$");
    final phoneExp = RegExp(r'^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$');
    if (!emailExp.hasMatch(value!) && !phoneExp.hasMatch(value!)) {
      return GalleryLocalizations.of(context)!.demoTextFieldEnterMobilePhoneNumberOrEMail;
    }
    //
    // if (!phoneExp.hasMatch(value!)) {
    //   return GalleryLocalizations.of(context)!.demoTextFieldEnterUSPhoneNumber;
    // }
    return null;
  }
  String? _validateEMail(String? value) {
    final phoneExp = RegExp(r"^[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?$");
    if (!phoneExp.hasMatch(value!)) {
      return GalleryLocalizations.of(context)!.demoTextFieldEmail;
    }
    return null;
  }

  String? _validatePasswordEmpty(String? value) {

    final passwordField = _passwordFieldKey.currentState!;
    final phoneExp = RegExp(r"^[a-zA-Z][a-zA-Z0-9_]{4,18}$");
    if (!phoneExp.hasMatch(passwordField.value!)) {
      return GalleryLocalizations.of(context)!.demoPWDFieldNoMoreThan;
    }
    // if (passwordField.value == null || passwordField.value!.isEmpty) {
    //   return GalleryLocalizations.of(context)!.demoTextFieldEnterPassword;
    // }
    return null;
  }

  String? _validatePassword(String? value) {
    final passwordField = _passwordFieldKey.currentState!;
    if (passwordField.value == null || passwordField.value!.isEmpty) {
      return GalleryLocalizations.of(context)!.demoTextFieldEnterPassword;
    }
    if (passwordField.value != value) {
      return GalleryLocalizations.of(context)!.demoTextFieldPasswordsDoNotMatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);
    final localizations = GalleryLocalizations.of(context)!;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.values[_autoValidateModeIndex.value],
      child: Scrollbar(
        child: SingleChildScrollView(
          restorationId: 'text_field_demo_scroll_view',
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // sizedBoxSpace,
              // TextFormField(
              //   restorationId: 'name_field',
              //   // 键盘上next键（下一个或>l表示执行下一个动作
              //   textInputAction: TextInputAction.next,
              //   // 将textCapitalization属性设置为TextCapitalization.words，以使虚拟键盘在每个单词的开头自动切换到大写。
              //   textCapitalization: TextCapitalization.words,
              //   // Flutter提供了Decoration类来设置Container的样式，包括背景色、背景图、边框、圆角、阴影、渐变色等属性。
              //   decoration: InputDecoration(
              //     filled: true,
              //     icon: const Icon(Icons.person),
              //     hintText: localizations.demoTextFieldWhatDoPeopleCallYou,
              //     labelText: localizations.demoTextFieldNameField,
              //   ),
              //   // onSaved是一个可选参数，当Form调用FormState.save时才会回调此方法。
              //   onSaved: (value) {
              //     person.name = value;
              //     _phoneNumber.requestFocus();
              //   },
              //   validator: _validateName,
              // ),
              // sizedBoxSpace,
              // TextFormField(
              //   restorationId: 'phone_number_field',
              //   textInputAction: TextInputAction.next,
              //   focusNode: _phoneNumber,
              //   decoration: InputDecoration(
              //     filled: true,
              //     icon: const Icon(Icons.phone),
              //     hintText: localizations.demoTextFieldWhereCanWeReachYou,
              //     labelText: localizations.demoTextFieldPhoneNumber,
              //     prefixText: '+1 ',
              //   ),
              //   // TextInputType.text：文本类型
              //   // TextInputType.number：数字类型
              //   // TextInputType.phone：电话类型
              //   // TextInputType.emailAddress：邮箱类型
              //   keyboardType: TextInputType.phone,
              //   onSaved: (value) {
              //     person.phoneNumber = value;
              //     _email.requestFocus();
              //   },
              //   maxLength: 14,
              //   // maxLengthEnforcement有三种取值：enforced、truncateAfterCompositionEnds和none。其中enforced和truncateAfterCompositionEnds都确保文本的最终长度不超过指定的最大长度，但是它们的处理方式有所不同。enforced会截断所有文本，而truncateAfterCompositionEnds则允许组合文本超过限制，这可以提供更好的用户体验，特别是输入表意文字（例如CJK字符）时。而none则会在字符计数达到最大长度时显示一个错误信息，但不会截断文本。
              //   maxLengthEnforcement: MaxLengthEnforcement.none,
              //   validator: _validatePhoneNumber,
              //   // TextInputFormatters are applied in sequence.
              //   inputFormatters: <TextInputFormatter>[
              //     FilteringTextInputFormatter.digitsOnly,
              //     // Fit the validating format.
              //     _phoneNumberFormatter,
              //   ],
              // ),
              sizedBoxSpace,
              TextFormField(
                restorationId: 'email_field',
                textInputAction: TextInputAction.next,
                focusNode: _email,
                decoration: InputDecoration(
                  filled: true,
                  icon: const Icon(Icons.email),
                  hintText: localizations.demoSharedXAxisSignInTextFieldLabel,
                  labelText: localizations.demoSharedXAxisSignInTextFieldLabel,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEMailOrPhone,
                onSaved: (value) {
                  person.email = value;
                  _password.requestFocus();
                },
              ),
              // sizedBoxSpace,
              // // Disabled text field
              // TextFormField(
              //   enabled: false,
              //   restorationId: 'disabled_email_field',
              //   textInputAction: TextInputAction.next,
              //   decoration: InputDecoration(
              //     filled: true,
              //     icon: const Icon(Icons.email),
              //     hintText: localizations.demoTextFieldYourEmailAddress,
              //     labelText: localizations.demoTextFieldEmail,
              //   ),
              //   keyboardType: TextInputType.emailAddress,
              // ),
              // sizedBoxSpace,
              // TextFormField(
              //   restorationId: 'life_story_field',
              //   focusNode: _lifeStory,
              //   decoration: InputDecoration(
              //     border: const OutlineInputBorder(),
              //     hintText: localizations.demoTextFieldTellUsAboutYourself,
              //     helperText: localizations.demoTextFieldKeepItShort,
              //     labelText: localizations.demoTextFieldLifeStory,
              //   ),
              //   maxLines: 3,
              // ),
              // sizedBoxSpace,
              // TextFormField(
              //   restorationId: 'salary_field',
              //   textInputAction: TextInputAction.next,
              //   keyboardType: TextInputType.number,
              //   decoration: InputDecoration(
              //     border: const OutlineInputBorder(),
              //     labelText: localizations.demoTextFieldSalary,
              //     suffixText: localizations.demoTextFieldUSD,
              //   ),
              //   maxLines: 1,
              // ),
              sizedBoxSpace,
              MyPasswordField(
                restorationId: 'password_field',
                textInputAction: TextInputAction.next,
                focusNode: _password,
                fieldKey: _passwordFieldKey,
                helperText: localizations.demoPWDFieldNoMoreThan,
                labelText: localizations.demoTextFieldPassword,
                validator: _validatePasswordEmpty,
                onSaved: (value) {
                  person.password = value!;
                },
                onFieldSubmitted: (value) {
                  // print("onFieldSubmitted");
                  setState(() {
                    // print(value);
                    person.password = value;
                    // _retypePassword.requestFocus();
                  });
                  // _handleSubmitted();
                },
              ),
              sizedBoxSpace,
              TextFormField(
                restorationId: 'retype_password_field',
                focusNode: _retypePassword,
                decoration: InputDecoration(
                  filled: true,
                  labelText: localizations.demoTextFieldRetypePassword,
                ),
                maxLength: 16,
                obscureText: true,
                validator: _validatePassword,
                onFieldSubmitted: (value) {
                  _handleSubmitted();
                },
              ),
              sizedBoxSpace,
              Center(
                child: ElevatedButton(
                  onPressed: _handleSubmitted,
                  child: Text(localizations.signUp),
                ),
              ),
              sizedBoxSpace,
              Text(
                localizations.demoTextFieldRequiredField,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              sizedBoxSpace,
            ],
          ),
        ),
      ),
    );
  }
}

/// Format incoming numeric text to fit the format of (###) ###-#### ##
class _UsNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newTextLength = newValue.text.length;
    final newText = StringBuffer();
    var selectionIndex = newValue.selection.end;
    var usedSubstringIndex = 0;
    if (newTextLength >= 1) {
      newText.write('(');
      if (newValue.selection.end >= 1) selectionIndex++;
    }
    if (newTextLength >= 4) {
      newText.write('${newValue.text.substring(0, usedSubstringIndex = 3)}) ');
      if (newValue.selection.end >= 3) selectionIndex += 2;
    }
    if (newTextLength >= 7) {
      newText.write('${newValue.text.substring(3, usedSubstringIndex = 6)}-');
      if (newValue.selection.end >= 6) selectionIndex++;
    }
    if (newTextLength >= 11) {
      newText.write('${newValue.text.substring(6, usedSubstringIndex = 10)} ');
      if (newValue.selection.end >= 10) selectionIndex++;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

// END
