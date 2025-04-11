import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeTopBar(),
      body: HomeBodyApp(), // Ensure HomeBodyApp is in the body here
    );
  }
}

class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTopBar({super.key});
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("History Calculator App"),
      titleTextStyle: TextStyle(
        color: const Color(0xFF000000),
        fontSize: 20,
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFF2196F3),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56); // Standard AppBar height
}

class HomeBodyApp extends StatefulWidget {
  const HomeBodyApp({super.key});

  @override
  _HomeBodyAppState createState() => _HomeBodyAppState();
}

class _HomeBodyAppState extends State<HomeBodyApp> {
  final TextEditingController _firstCurrencyController = TextEditingController();
  final TextEditingController _secondCurrencyController = TextEditingController();
  String _conventionMessage = ''; // Store the answer as a string
  String _errorText = '';
  Color _answerColor = const Color(0xFF000000);
  bool _isConverted = false; // Renamed from _currencyConverted to avoid conflict

  // Default Dropdown selection
  String? _fromCurrency = 'Select Currency';
  String? _toCurrency = 'Select Currency';

  // Late to intialize the dropdown list
  late List<String> _options;

  late Map<String, Map<String, double>> _conversionRates;
  
  @override
  void initState() {
    super.initState();
    print("ALL INITSTATE ACTIVE!");

    // correctly initiaize late variables
    // Dropdown list
    _options = ['Select Currency', 'South African Rand (R)', 'US Dollars (\$)', 'Chinese Yuan (\\Y)'];

    // Data of all conversion rates
    _conversionRates = {
      'South African Rand (R)': {
        'US Dollars (\$)' : 0.052,
        'Chinese Yuan (\\Y)': 0.38,
        'South African Rand (R)': 1.0
      },
    
      'US Dollars (\$)': {
        'South African Rand (R)': 19.40,
        'Chinese Yuan (\\Y)': 7.31,
        'US Dollars (\$)' : 1.0,
      },

      'Chinese Yuan (\\Y)': {
        'South African Rand (R)': 2.65,
        'US Dollars (\$)': 0.14,
        'Chinese Yuan (\\Y)': 1.0
      }
    };
    print("Displaying currencies: $_options");
  }
  // Helper to extract currency symbol from selection
  String _getCurrencySymbol(String? currency) {
    if (currency == 'South African Rand (R)') return 'R';
    if (currency == 'US Dollars (\$)') return '\$';
    if (currency == 'Chinese Yuan (\\Y)') return '\\Y';
    return '';
  }

  void _dropDownEventHandler() {
    setState(() {
      if (_fromCurrency == 'Select Currency' || _toCurrency == 'Select Currency') {
        _errorText = "Error make sure your options of both dropdowns are selected";
        _answerColor = Colors.red;
        _conventionMessage = '';
      } else {
        _errorText = '';

        if(_firstCurrencyController.text.isNotEmpty) {
          _convertCurrency(true);
        } else if (_secondCurrencyController.text.isNotEmpty) {
          _convertCurrency(false);
        }
      } 
    });
  }

  void _convertCurrency(bool fromFirstField) {
    setState(() {
      // Clear previous error messages
      _errorText = '';
      
      // Check if currencies are selected
      if (_fromCurrency == 'Select Currency' || _toCurrency == 'Select Currency') {
        _errorText = "Error: Select both currencies first";
        _answerColor = Colors.red;
        return;
      }
      
      try {
        if (fromFirstField) {
          // Converting from first field to second field
          String amountText = _firstCurrencyController.text.trim();
          if (amountText.isEmpty) {
            _secondCurrencyController.text = '';
            _errorText = '';
            _conventionMessage = '';
            return;
          }
          
          double? amount = double.tryParse(amountText);
          if (amount == null) {
            _errorText = "Please enter a valid number";
            _answerColor = Colors.red;
            return;
          }
          
          // Get conversion rate
          double rate = _conversionRates[_fromCurrency]![_toCurrency]!;
          double result = amount * rate;
          
          // Update second field and display answer
          _secondCurrencyController.text = result.toStringAsFixed(2);
          _conventionMessage = "${_getCurrencySymbol(_fromCurrency)}$amount = ${_getCurrencySymbol(_toCurrency)}${result.toStringAsFixed(2)}";
          _answerColor = Colors.green;
          _isConverted = true;
        } else {
          // Converting from second field to first field
          String amountText = _secondCurrencyController.text.trim();
          if (amountText.isEmpty) {
            _firstCurrencyController.text = '';
            _conventionMessage = '';
            return;
          }
          
          double? amount = double.tryParse(amountText);
          if (amount == null) {
            _errorText = "Please enter a valid number";
            _answerColor = Colors.red;
            return;
          }
          
          // Calculate reverse conversion
          double rate = _conversionRates[_toCurrency]![_fromCurrency]!;
          double result = amount * rate;
          
          // Update first field and display answer
          _firstCurrencyController.text = result.toStringAsFixed(2);
          _conventionMessage = "${_getCurrencySymbol(_toCurrency)}$amount = ${_getCurrencySymbol(_fromCurrency)}${result.toStringAsFixed(2)}";
          _answerColor = Colors.green;
          _isConverted = true;
        }
      } catch (e) {
        _errorText = "Conversion error: $e";
        _answerColor = Colors.red;
      }
    });
  }

  // Main conversion function to be called by the Convert button
  void _getAnswer() {
    if (_firstCurrencyController.text.isNotEmpty) {
      _convertCurrency(true);
    } else if (_secondCurrencyController.text.isNotEmpty) {
      _convertCurrency(false);
    } else {
      setState(() {
        _errorText = "Please enter an amount to convert";
        _answerColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Print the screen size of the device
    int screenWidth = MediaQuery.of(context).size.width.toInt();
    int screenHeight = MediaQuery.of(context).size.height.toInt();

    print("Phone Width: $screenWidth");
    print("Phone Height: $screenHeight"); 
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildDropDown(context, _fromCurrency!, true), // Pass true for fromCurrency
            const SizedBox(height: 20),
            _buildTextField("Enter the amount: ", _firstCurrencyController, true), // Pass true for first field
            const SizedBox(height: 20),
            _buildDropDown(context, _toCurrency, false), // Pass false for toCurrency
            const SizedBox(height: 20),
            _buildTextField("Enter the amount: ", _secondCurrencyController, false), // Pass false for second field
            // Display the answer here
            const SizedBox(height: 30),
            _buildButton("Update", _getAnswer, const Color(0xFF448AFF)),
            /*ElevatedButton( button update debug
              onPressed: () {
                print("Current Currencies: $_options");
              }, 
              child: Text("Currency debug")
            ),*/
            const SizedBox(height: 20),
            // Show error text if present
            if (_errorText.isNotEmpty)
              Text(
                _errorText,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold
                ),
              ),
            // Show conversion message if present
            if (_conventionMessage.isNotEmpty)
              Text(
                _conventionMessage,
                style: TextStyle(
                  fontSize: 24,
                  color: _answerColor,
                  fontWeight: FontWeight.bold
                ),
              ),
            const SizedBox(height: 50),
            Text(
              "Remember the currency rates between all currencies will" + 
              "\ncontinuously change due to factors such as" + 
              "\nEconomical factors: inflation; Social Factors: war and tensions between countries. We will update ASAP.",
              style: TextStyle(
                fontSize: 20,
                color: const Color(0xFF000000),
                fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller, bool isFirstField) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      onChanged: (value) {
        if (_fromCurrency != 'Select Currency' && _toCurrency != 'Select Currency' && value.isNotEmpty) {
          _convertCurrency(isFirstField);
        }
      },
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text, 
        textAlign: TextAlign.center, 
        style: const TextStyle(
          fontSize: 18, 
          color: Colors.white, 
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _buildDropDown(BuildContext context, String? currencyValue, bool isFromCurrency) {
    double screenWidth = MediaQuery.of(context).size.width;

    print("Reloading app with added currency: $currencyValue");
    print("Currencies: $_options");
  
    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5)
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: _options.contains(currencyValue) ? currencyValue : _options.first,
            isExpanded: true,
            isDense: false,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  if (isFromCurrency) {
                    _fromCurrency = newValue;
                  } else {
                    _toCurrency = newValue;
                  }
                  print("Currency updated $newValue");
                  _dropDownEventHandler();
                });
              }
            },
            items: _options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16)
                  ),
                ),
              );
            }).toList()
          )
        )
      )
    );
  }
}