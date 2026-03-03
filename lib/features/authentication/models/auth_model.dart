import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  final String txt;
  final double txtsize;
  final Color txtColor;
  final TextAlign txtAlign;
  final int maxLine;

  const CustomTextWidget({
    super.key,
    required this.txt,
    required this.txtsize,
    required this.txtColor,
    required this.txtAlign,
    this.maxLine = 2,
    TextOverflow overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      textAlign: txtAlign,
      style: TextStyle(
        fontSize: txtsize,
        fontFamily: "Lato",
        fontWeight: FontWeight.bold,
        color: txtColor,
      ),
    );
  }
}

class CustomTxtFormField extends StatefulWidget {
  final String hint;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final Function(String?)? onSave;
  final TextInputType? keyboardType;

  const CustomTxtFormField(
      {super.key,
      required this.hint,
      this.isPassword = false,
      this.validator,
      this.controller,
      this.onSave,
      this.keyboardType});

  @override
  _CustomTxtFormFieldState createState() => _CustomTxtFormFieldState();
}

class _CustomTxtFormFieldState extends State<CustomTxtFormField> {
  bool _obscureText = true; // ✅ حالة إظهار/إخفاء النص

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText:
          widget.isPassword ? _obscureText : false, // ✅ التحكم في الإخفاء
      decoration: InputDecoration(
        hintText: widget.hint,
        border: OutlineInputBorder(),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off
                      : Icons.visibility, // ✅ تغيير الأيقونة
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText; // ✅ تحديث الحالة عند الضغط
                  });
                },
              )
            : null, // ✅ عدم إظهار الأيقونة إذا لم يكن حقل كلمة مرور
      ),
      validator: widget.validator,
      onSaved: widget.onSave,
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPress;

  const CustomButton({
    super.key,
    required this.onPress,
    this.text = 'Write text',
    this.color = const Color(0xffFFE70C),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      // ✅ جعل الزر في منتصف الشاشة
      child: SizedBox(
        width: double.infinity, // ✅ جعل العرض بعرض الشاشة بالكامل
        height: 50, // ✅ تكبير الارتفاع
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
          onPressed: onPress,
          child: CustomTextWidget(
            txt: text,
            txtsize: 18, // ✅ تكبير حجم النص داخل الزر
            txtColor: Colors.black,
            txtAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
