part of 'widgets.dart';

class AddressItem extends StatelessWidget {
  const AddressItem({
    super.key,
    this.title = '',
    this.content = '',
    this.activated = false,
    this.loading = false,
    this.onTap,
  });
  final String title, content;
  final bool activated, loading;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 60,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 1),
                      )
                    : Icon(
                        activated ? Icons.check_circle : Icons.circle_outlined,
                        color:
                            activated ? const Color(0xFF2B7A78) : Colors.grey,
                        size: 20,
                      ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2B7A78),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
