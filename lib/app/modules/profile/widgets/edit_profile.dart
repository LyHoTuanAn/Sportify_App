part of 'widgets.dart';

class EditProfileBottom extends StatefulWidget {
  const EditProfileBottom({super.key});
  static void showBottom() {
    Get.bottomSheet(
      const EditProfileBottom(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<EditProfileBottom> createState() => _EditProfileBottomState();
}

class _EditProfileBottomState extends State<EditProfileBottom> {
  ProfileController get ctr => Get.find();
  final _formKey = GlobalKey<FormState>();
  final _stateObx = RxStatus.success().obs;
  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late TextEditingController _birthDay;
  late TextEditingController _email;
  late TextEditingController _gender;
  late TextEditingController _phoneNumber;
  late TextEditingController _mediaRecord;

  DateTime? birthDay;
  @override
  void initState() {
    _firstName = TextEditingController(text: ctr.user.value?.firstName);
    _lastName = TextEditingController(text: ctr.user.value?.lastName);
    _birthDay = TextEditingController(text: ctr.user.value?.birthDay);
    _email = TextEditingController(text: ctr.user.value?.email);
    _gender = TextEditingController(text: ctr.user.value?.gender);
    _phoneNumber = TextEditingController(text: ctr.user.value?.phone);
    _mediaRecord =
        TextEditingController(text: ctr.user.value?.medicalRecordNumber);

    super.initState();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _birthDay.dispose();
    _gender.dispose();
    _email.dispose();
    _phoneNumber.dispose();
    _mediaRecord.dispose();
    super.dispose();
  }

  Future<DateTime?> _showDatePicker() async {
    final startDate = DateTime.now();
    var selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 100),
      initialDate: birthDay ?? startDate,
      lastDate: DateTime.now(),
    );

    return selectedDate;
  }

  Future<void> updateUser() async {
    Get.focusScope?.unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        _stateObx.value = RxStatus.loading();
        final data = {
          "recipient": UserModel(
            firstName: _firstName.text,
            lastName: _lastName.text,
            dateOfBirth: birthDay,
            email: _email.text,
            phone: _phoneNumber.text,
            gender: _gender.text.toLowerCase(),
            medicalRecordNumber: _mediaRecord.text,
          ).toMap()
        };
        final res = await Repo.user.updateUser(data);
        if (res) {
          Get.back();
          ctr.getUserDetail();
          BottomWellSuccess.show('Thông tin cá nhân đã được cập nhật thành công.');
        }
        _stateObx.value = RxStatus.success();
      } catch (e) {
        _stateObx.value = RxStatus.success();
        AppUtils.toast(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight * .9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2B7A78),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chỉnh sửa thông tin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          
          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin cá nhân',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B7A78),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Các trường thông tin
                    _buildInputField(
                      label: 'Họ',
                      controller: _firstName,
                      icon: Icons.person_outline,
                      validator: (val) => val!.isEmpty ? 'Vui lòng nhập họ' : null,
                    ),
                    
                    _buildInputField(
                      label: 'Tên',
                      controller: _lastName,
                      icon: Icons.person_outline,
                      validator: (val) => val!.isEmpty ? 'Vui lòng nhập tên' : null,
                    ),
                    
                    _buildInputField(
                      label: 'Giới tính',
                      controller: _gender,
                      icon: Icons.people_outline,
                      readOnly: true,
                      onTap: () {
                        BottomChangeSelect.show(
                          items: const ['Nữ', 'Nam'],
                          active: _gender.text,
                          callback: (val) {
                            _gender.text = val;
                          },
                        );
                      },
                    ),
                    
                    _buildInputField(
                      label: 'Ngày sinh',
                      controller: _birthDay,
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () async {
                        final pickupDate = await _showDatePicker();
                        if (pickupDate != null) {
                          var formattedDate =
                              DateFormat('dd/MM/yyyy').format(pickupDate);
                          _birthDay.text = formattedDate;
                          birthDay = pickupDate;
                        }
                      },
                    ),
                    
                    _buildInputField(
                      label: 'Số điện thoại',
                      controller: _phoneNumber,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    
                    _buildInputField(
                      label: 'Email',
                      controller: _email,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    
                    _buildInputField(
                      label: 'Mã số y tế (không bắt buộc)',
                      controller: _mediaRecord,
                      icon: Icons.health_and_safety_outlined,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Nút cập nhật
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _stateObx.value.isLoading ? null : updateUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B7A78),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _stateObx.value.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'CẬP NHẬT',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
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
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF777777),
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF2B7A78), size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2B7A78)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              fillColor: const Color(0xFFF9F9F9),
              filled: true,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
