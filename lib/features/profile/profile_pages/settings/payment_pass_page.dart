import 'package:flutter/material.dart';

class PaymentPassPage extends StatefulWidget {
  const PaymentPassPage({Key? key}) : super(key: key);

  @override
  State<PaymentPassPage> createState() => _PaymentPassPageState();
}

class _PaymentPassPageState extends State<PaymentPassPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePass1 = true;
  bool _obscurePass2 = true;

  void _submit() {
    final pass = _passwordController.text;
    final confirm = _confirmController.text;

    if (pass.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(pass)) {
      _showMessage("Please enter a 6-digit numeric password");
      return;
    }
    if (pass != confirm) {
      _showMessage("Passwords do not match");
      return;
    }
    _showMessage("Payment password set successfully!");
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Set payment password",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildPasswordField(
              controller: _passwordController,
              hintText: "Enter payment password",
              obscure: _obscurePass1,
              toggle: () => setState(() => _obscurePass1 = !_obscurePass1),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmController,
              hintText: "Re-enter payment password",
              obscure: _obscurePass2,
              toggle: () => setState(() => _obscurePass2 = !_obscurePass2),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please set a 6-digit numeric payment password",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _submit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE0B2), Color(0xFFFFB74D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F5),
        borderRadius: BorderRadius.circular(40),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          counterText: "",
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey,
            ),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }
}
