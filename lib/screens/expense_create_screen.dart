import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../services/expense_service.dart';
import '../services/hr_service.dart';
import '../models/hr_employee.dart';

class ExpenseCreateScreen extends StatefulWidget {
  const ExpenseCreateScreen({super.key});

  @override
  State<ExpenseCreateScreen> createState() => _ExpenseCreateScreenState();
}

class _ExpenseCreateScreenState extends State<ExpenseCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final ExpenseService _expenseService = ExpenseService.instance;
  final HrService _hrService = HrService();
  
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  
  HrEmployee? _currentEmployee;
  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String _paymentMode = 'own_account';
  File? _receiptImage;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final employee = await _hrService.getCurrentEmployee();
      final categories = await _expenseService.getExpenseCategories();
      
      setState(() {
        _currentEmployee = employee;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load data: $e');
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => _receiptImage = File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _receiptImage = File(image.path));
                }
              },
            ),
            if (_receiptImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Receipt', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _receiptImage = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_currentEmployee == null) {
      _showError('Employee information not available');
      return;
    }
    
    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      final result = await _expenseService.createExpense(
        employeeId: _currentEmployee!.id,
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        productId: _selectedCategory!['id'],
        date: _selectedDate,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        reference: _referenceController.text.isEmpty ? null : _referenceController.text,
        paymentMode: _paymentMode,
        receipt: _receiptImage,
      );
      
      setState(() => _isSubmitting = false);
      
      if (result['success']) {
        _showSuccess('Expense created successfully!');
        Navigator.pop(context, true);
      } else {
        _showError(result['error'] ?? 'Failed to create expense');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showError('Error creating expense: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'New Expense',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name Field
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Expense Name',
                                  hint: 'e.g., Business lunch with client',
                                  icon: Icons.receipt_long,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter expense name';
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Amount Field
                                _buildTextField(
                                  controller: _amountController,
                                  label: 'Amount',
                                  hint: '0.00',
                                  icon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter amount';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Please enter a valid amount';
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Category Dropdown
                                _buildCategoryDropdown(),
                                
                                const SizedBox(height: 20),
                                
                                // Date Selector
                                _buildDateSelector(),
                                
                                const SizedBox(height: 20),
                                
                                // Payment Mode
                                _buildPaymentModeSelector(),
                                
                                const SizedBox(height: 20),
                                
                                // Description
                                _buildTextField(
                                  controller: _descriptionController,
                                  label: 'Description (Optional)',
                                  hint: 'Additional details about the expense',
                                  icon: Icons.description,
                                  maxLines: 3,
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Reference
                                _buildTextField(
                                  controller: _referenceController,
                                  label: 'Reference (Optional)',
                                  hint: 'Invoice number or reference',
                                  icon: Icons.tag,
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Receipt Upload
                                _buildReceiptUpload(),
                                
                                const SizedBox(height: 32),
                                
                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting ? null : _submitExpense,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF667eea),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                            'Submit Expense',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, dynamic>>(
              isExpanded: true,
              value: _selectedCategory,
              hint: Row(
                children: [
                  const Icon(Icons.category, color: Color(0xFF667eea)),
                  const SizedBox(width: 12),
                  Text(
                    'Select a category',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: category,
                  child: Row(
                    children: [
                      const Icon(Icons.category, color: Color(0xFF667eea)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category['name'] ?? 'Unknown',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
            ),
          ),
        ),
        if (_categories.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No categories available. Please configure expense products in Odoo.',
              style: TextStyle(color: Colors.orange[700], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF667eea)),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Mode',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPaymentModeOption(
                'own_account',
                'Own Account',
                Icons.person,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentModeOption(
                'company_account',
                'Company Account',
                Icons.business,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentModeOption(String value, String label, IconData icon) {
    final isSelected = _paymentMode == value;
    return InkWell(
      onTap: () => setState(() => _paymentMode = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFF667eea).withOpacity(0.1) : Colors.grey[50],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF667eea) : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF667eea) : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Receipt (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickReceipt,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: _receiptImage != null 
                    ? const Color(0xFF667eea)
                    : Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: _receiptImage != null
                ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _receiptImage!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Receipt attached',
                            style: TextStyle(color: Colors.green[600]),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to upload receipt',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Take photo or select from gallery',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
