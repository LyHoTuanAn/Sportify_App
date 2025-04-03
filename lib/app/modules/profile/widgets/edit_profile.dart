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

  DateTime? birthDay;
  @override
  void initState() {
    _firstName = TextEditingController(text: ctr.user.value?.firstName);
    _lastName = TextEditingController(text: ctr.user.value?.lastName);
    _birthDay = TextEditingController(text: ctr.user.value?.birthDay);
    _email = TextEditingController(text: ctr.user.value?.email);
    _gender = TextEditingController(text: ctr.user.value?.gender);
    _phoneNumber = TextEditingController(text: ctr.user.value?.phone);

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

        // Tạo dữ liệu để gửi lên server với định dạng đúng
        final data = {
          'first_name': _firstName.text,
          'last_name': _lastName.text,
          'gender': _gender.text,
          'birthday': birthDay != null
              ? "${birthDay!.year}-${birthDay!.month.toString().padLeft(2, '0')}-${birthDay!.day.toString().padLeft(2, '0')}"
              : null,
          'phone': _phoneNumber.text,
          'email': _email.text,
        };

        // Sử dụng controller để cập nhật dữ liệu
        await ctr.updateProfile(data);

        Get.back();
        // Không cần gọi getUserDetail ở đây nữa vì đã được gọi bên trong updateProfile
        SnackbarUtil.showSuccess(
            'Thông tin cá nhân đã được cập nhật thành công.');

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
                      validator: (val) =>
                          val!.isEmpty ? 'Vui lòng nhập họ' : null,
                    ),

                    _buildInputField(
                      label: 'Tên',
                      controller: _lastName,
                      icon: Icons.person_outline,
                      validator: (val) =>
                          val!.isEmpty ? 'Vui lòng nhập tên' : null,
                    ),

                    _buildGenderSelection(),

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

                    const SizedBox(height: 30),

                    // Nút cập nhật
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _stateObx.value.isLoading ? null : updateUser,
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

  Widget _buildGenderSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giới tính',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF777777),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _gender.text = 'Nam';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _gender.text == 'Nam'
                          ? const Color(0xFF2B7A78)
                          : const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _gender.text == 'Nam'
                            ? const Color(0xFF2B7A78)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.male,
                          color: _gender.text == 'Nam'
                              ? Colors.white
                              : Colors.blue,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nam',
                          style: TextStyle(
                            color: _gender.text == 'Nam'
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _gender.text = 'Nữ';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _gender.text == 'Nữ'
                          ? const Color(0xFF2B7A78)
                          : const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _gender.text == 'Nữ'
                            ? const Color(0xFF2B7A78)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.female,
                          color:
                              _gender.text == 'Nữ' ? Colors.white : Colors.pink,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nữ',
                          style: TextStyle(
                            color: _gender.text == 'Nữ'
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
