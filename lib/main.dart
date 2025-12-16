import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr/qr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SVG Text Replacer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SvgReplacerPage(),
    );
  }
}

class SvgReplacerPage extends StatefulWidget {
  const SvgReplacerPage({super.key});

  @override
  State<SvgReplacerPage> createState() => _SvgReplacerPageState();
}

class _SvgReplacerPageState extends State<SvgReplacerPage> {
  String? _originalSvgContent;
  String? _modifiedSvgContent;
  
  // Controllers for all fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSvgFromAssets();
    _setRandomData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _loadSvgFromAssets() async {
    try {
      print('Attempting to load SVG from assets...');
      final svgString = await rootBundle.loadString('assets/test-1.svg');
      print('SVG loaded successfully: ${svgString.length} characters');
      setState(() {
        _originalSvgContent = svgString;
        _modifiedSvgContent = svgString;
      });
      // Apply initial replacement
      _replaceText();
    } catch (e) {
      print('Error loading SVG: $e');
      setState(() {
        _originalSvgContent = 'ERROR';
      });
      _showErrorDialog('Error loading SVG: $e');
    }
  }

  void _setRandomData() {
    // Set random/sample data
    final names = [
      ['John', 'Doe'],
      ['Jane', 'Smith'],
      ['Michael', 'Johnson'],
      ['Sarah', 'Williams'],
      ['David', 'Brown'],
      ['Emma', 'Davis'],
      ['James', 'Miller'],
      ['Olivia', 'Wilson'],
    ];
    
    final jobs = [
      'Software Engineer',
      'Product Manager',
      'UI/UX Designer',
      'Data Scientist',
      'Marketing Director',
      'Sales Manager',
      'CEO',
      'CTO',
    ];

    final randomName = names[DateTime.now().millisecond % names.length];
    final randomJob = jobs[DateTime.now().millisecond % jobs.length];
    
    _firstNameController.text = randomName[0];
    _lastNameController.text = randomName[1];
    _jobTitleController.text = randomJob;
    _emailController.text = '${randomName[0].toLowerCase()}.${randomName[1].toLowerCase()}@company.com';
    _phoneController.text = '+1 (555) 123-4567';
    _mobileController.text = '+1 (555) 987-6543';
    _websiteController.text = 'www.${randomName[1].toLowerCase()}.com';
  }

  String _generateQrCodeSvgRects(String data) {
    try {
      // Generate REAL QR code using the qr package
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.L,
      );
      
      // Create QrImage from QrCode
      final qrImage = QrImage(qrCode);
      
      final moduleCount = qrImage.moduleCount;
      final cellSize = 64.7 / moduleCount; // Total size divided by module count
      final startX = 174.23;
      final startY = 60.21;
      
      StringBuffer rects = StringBuffer();
      
      // White background
      rects.writeln('<rect x="$startX" y="$startY" width="64.7" height="64.7" fill="white"/>');
      
      // Generate actual QR code pattern
      for (int y = 0; y < moduleCount; y++) {
        for (int x = 0; x < moduleCount; x++) {
          // Check if this module is dark/black
          if (qrImage.isDark(y, x)) {
            double rectX = startX + (x * cellSize);
            double rectY = startY + (y * cellSize);
            rects.writeln('<rect x="${rectX.toStringAsFixed(2)}" y="${rectY.toStringAsFixed(2)}" width="${cellSize.toStringAsFixed(2)}" height="${cellSize.toStringAsFixed(2)}" fill="black"/>');
          }
        }
      }
      
      return rects.toString();
    } catch (e) {
      print('Error generating QR code: $e');
      // Fallback: return a simple placeholder
      return '<rect x="174.23" y="60.21" width="64.7" height="64.7" fill="white" stroke="black" stroke-width="1"/><text x="206" y="95" text-anchor="middle" font-size="8" fill="black">QR Error</text>';
    }
  }

  void _replaceText() {
    if (_originalSvgContent == null) return;

    String modifiedContent = _originalSvgContent!;

    // Replace all placeholders
    modifiedContent = modifiedContent.replaceAll('{first_name}', _firstNameController.text);
    modifiedContent = modifiedContent.replaceAll('{last_name}', _lastNameController.text);
    modifiedContent = modifiedContent.replaceAll('{job_title}', _jobTitleController.text);
    modifiedContent = modifiedContent.replaceAll('{email}', _emailController.text);
    modifiedContent = modifiedContent.replaceAll('{phone}', _phoneController.text);
    modifiedContent = modifiedContent.replaceAll('{mobile}', _mobileController.text);
    modifiedContent = modifiedContent.replaceAll('{website}', _websiteController.text);

    // Generate QR code from website URL
    String qrData = _websiteController.text.isNotEmpty 
        ? _websiteController.text 
        : 'https://example.com';
    
    // Generate QR code SVG elements
    String qrCodeSvg = _generateQrCodeSvgRects(qrData);
    
    // Replace the rectangle with the QR code pattern
    final qrGroupPattern = RegExp(
      r'<g id="_qr_"[^>]*>[\s\S]*?</g>',
      multiLine: true,
    );
    
    String qrReplacement = '''<g id="_qr_" data-name="{qr}">
    $qrCodeSvg
  </g>''';
    
    modifiedContent = modifiedContent.replaceAllMapped(qrGroupPattern, (match) => qrReplacement);

    setState(() {
      _modifiedSvgContent = modifiedContent;
    });
  }

  void _downloadModifiedSvg() {
    if (_modifiedSvgContent == null) return;
    
    // Show a dialog instead for now
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SVG Content'),
        content: SingleChildScrollView(
          child: SelectableText(_modifiedSvgContent!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        onChanged: (_) => _replaceText(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Card Generator'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _originalSvgContent == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading SVG...'),
                    ],
                  ),
                )
              : _originalSvgContent == 'ERROR'
                  ? const Center(
                      child: Text(
                        'Error loading SVG. Check console for details.',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    )
                  : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left panel - Input fields
                    Expanded(
                      flex: 2,
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Card Information',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Edit the fields below and see real-time changes',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const Divider(height: 24),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _buildTextField('First Name', _firstNameController, Icons.person),
                                      _buildTextField('Last Name', _lastNameController, Icons.person_outline),
                                      _buildTextField('Job Title', _jobTitleController, Icons.work),
                                      _buildTextField('Email', _emailController, Icons.email),
                                      _buildTextField('Phone', _phoneController, Icons.phone),
                                      _buildTextField('Mobile', _mobileController, Icons.smartphone),
                                      _buildTextField('Website', _websiteController, Icons.language),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _setRandomData();
                                        _replaceText();
                                      },
                                      icon: const Icon(Icons.shuffle),
                                      label: const Text('Random Data'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _downloadModifiedSvg,
                                      icon: const Icon(Icons.download),
                                      label: const Text('Download'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right panel - SVG Preview
                    Expanded(
                      flex: 3,
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.preview, color: Colors.blue.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Live Preview',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your business card updates in real-time',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const Divider(height: 24),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Center(
                                    child: _modifiedSvgContent != null
                                        ? SingleChildScrollView(
                                              child: Padding(
                                                padding: const EdgeInsets.all(24.0),
                                                child: SvgPicture.string(
                                                  _modifiedSvgContent!,
                                                  fit: BoxFit.contain,
                                                  width: 900,
                                                  height: 500,
                                                ),
                                              ),
                                          )
                                        : const CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
