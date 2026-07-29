


import 'dart:math';

String generateOtp() {
// Create a random number generator
final random = Random();

// Generate a 6-digit random number
int otp = 100000 + random.nextInt(900000);

// Convert the number to a string and return it
return otp.toString();
}