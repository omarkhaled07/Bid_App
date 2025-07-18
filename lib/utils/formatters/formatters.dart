import 'package:intl/intl.dart';

class BidAppFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now(); // If date is null, use current date
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Assuming a 10-digit US phone number format: (123) 456-7890
    if (phoneNumber.length == 10) {
      return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6)}';
    } else if (phoneNumber.length == 11) {
      return '(${phoneNumber.substring(1, 4)}) ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7)}';
    }
    // Add more custom phone number formatting logic for different formats if needed.
    return phoneNumber;
  }

  static String internationalFormatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters from the phone number
    var digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Extract the country code from the digitsOnly
    String countryCode =
        digitsOnly.substring(0, 2); // Assuming country code is first 2 digits
    digitsOnly = digitsOnly.substring(2); // Remove country code

    // Add the remaining digits with proper formatting
    StringBuffer formattedNumber = StringBuffer();
    formattedNumber.write('($countryCode) ');

    int i = 0;
    while (i < digitsOnly.length) {
      int groupLength = 0;

      // Format the digits in groups (e.g., 3 digits, 4 digits)
      if (i == 0 && countryCode == '1') {
        groupLength = 3; // US-style (e.g., (123) 456-7890)
      } else {
        groupLength = 3; // Default group length
      }

      int end = i + groupLength;
      formattedNumber.write(digitsOnly.substring(i, end));

      if (end < digitsOnly.length) {
        formattedNumber.write('-');
      }

      i = end;
    }

    return formattedNumber.toString();
  }
}
