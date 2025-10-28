import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  String cardNumber = "";
  String cardHolder = "";
  String expiryDate = "";
  String cvv = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // بطاقة شكلية
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(2, 4))
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    cardNumber.isEmpty
                        ? "0000 0000 0000 0000" // placeholder
                        : cardNumber,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    cardHolder.isEmpty ? "CARD HOLDER" : cardHolder,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        expiryDate.isEmpty ? "MM/YY" : expiryDate,
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        cvv.isEmpty ? "CVV" : cvv,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // فورم الإدخال
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Card Number"),
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    onChanged: (value) {
                      setState(() => cardNumber = value);
                    },
                    validator: (value) =>
                        value!.length == 16 ? null : "Enter 16 numbers ",
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "NameHolder"),
                    onChanged: (value) {
                      setState(() => cardHolder = value);
                    },
                    validator: (value) =>
                        value!.isEmpty ? "Enter a Name" : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: " Expiration Date (MM/YY)"),
                    onChanged: (value) {
                      setState(() => expiryDate = value);
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "CVV"),
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    onChanged: (value) {
                      setState(() => cvv = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _processPayment,
              child: const Text("Pay Now"),
            )
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, "success");
    }
  }
}
