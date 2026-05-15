// import 'package:devdar_laundry_pos_app/core/theme/app_colors.dart';
// import 'package:devdar_laundry_pos_app/features/customer/presentations/pages/main_page_customer.dart';
// import 'package:flutter/material.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isObscure = true;
  
//   // Controller untuk input
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   void _handleLogin() {
//     if (_formKey.currentState!.validate()) {
//       // Sesuai permintaan: Langsung arahkan ke Customer tanpa memandang input
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const MainPageCustomer()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE3F2FD), // Biru sangat muda sesuai desain
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 60),
//               _buildHeader(),
//               const SizedBox(height: 40),
//               _buildLoginForm(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: const Icon(Icons.water_drop, color: Colors.white, size: 50),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           "Devdara Laundry",
//           style: TextStyle(
//             fontSize: 24, 
//             fontWeight: FontWeight.bold, 
//             color: AppColors.primary
//           ),
//         ),
//         const Text("Cuci Bersih, Hidup Segar", style: TextStyle(color: AppColors.textGrey)),
//       ],
//     );
//   }

//   Widget _buildLoginForm() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           )
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             // Tab Header (Visual Only)
//             Row(
//               children: [
//                 _buildTab("Masuk", true),
//                 _buildTab("Daftar", false),
//               ],
//             ),
//             const SizedBox(height: 30),
            
//             // Email Field
//             TextFormField(
//               controller: _emailController,
//               decoration: _inputDecoration("Email", Icons.email_outlined),
//               validator: (val) => val!.isEmpty ? "Masukkan email" : null,
//             ),
//             const SizedBox(height: 20),
            
//             // Password Field
//             TextFormField(
//               controller: _passwordController,
//               obscureText: _isObscure,
//               decoration: _inputDecoration("Password", Icons.lock_outline).copyWith(
//                 suffixIcon: IconButton(
//                   icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
//                   onPressed: () => setState(() => _isObscure = !_isObscure),
//                 ),
//               ),
//               validator: (val) => val!.isEmpty ? "Masukkan password" : null,
//             ),
            
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () {},
//                 child: const Text("Lupa Password?", style: TextStyle(color: AppColors.primary)),
//               ),
//             ),
//             const SizedBox(height: 20),
            
//             // Login Button
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 onPressed: _handleLogin,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text("Masuk", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
//                     SizedBox(width: 8),
//                     Icon(Icons.arrow_forward, color: Colors.white, size: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTab(String label, bool isActive) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isActive ? Colors.white : Colors.grey[50],
//           borderRadius: BorderRadius.circular(10),
//           border: isActive ? Border.all(color: AppColors.primary.withOpacity(0.1)) : null,
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               color: isActive ? AppColors.primary : AppColors.textGrey,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String label, IconData icon) {
//     return InputDecoration(
//       prefixIcon: Icon(icon, color: AppColors.textGrey),
//       hintText: label,
//       filled: true,
//       fillColor: const Color(0xFFF5F9FF),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15),
//         borderSide: BorderSide.none,
//       ),
//     );
//   }
// }