import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Ranglar
const Color _chatBlue = Color(0xFF007AFF); // Xabar baloni rangi
const Color _appBarTitleColor = Color(0xFF000000);
const Color _backIconColor = Color(0xFF000000);
const Color _dateTextColor = Color(0xFF9E9E9E);
const Color _backgroundColor = Color(0xFFF7F7F7); // Chat fon rangi
const Color _inputFieldColor = Color(0xFFF0F0F0); // Input field fon rangi

// Xabar modeli
class Message {
  final String text;
  final String time;
  final bool isMe;
  final bool isSent;
  final bool isRead;

  Message({
    required this.text,
    required this.time,
    required this.isMe,
    this.isSent = true,
    this.isRead = true,
  });
}

@RoutePage()
class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  // Text input uchun Controller
  final TextEditingController _textController = TextEditingController();

  // ListView'ni boshqarish uchun Controller (yangi xabar kelganda pastga o'tkazish uchun)
  final ScrollController _scrollController = ScrollController();

  // Dinamik xabarlar ro'yxati
  final List<Message> _messages = [
    Message(
      text:
          "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book",
      time: "13:00",
      isMe: true,
      isRead: true,
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // === Xabar yuborish funksiyasi ===
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return; // Bo'sh xabarni yubormaymiz

    // Joriy vaqtni (soat:minut) olish
    final now = DateTime.now();
    final timeString =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // Yangi xabar obyekti
    final newMessage = Message(
      text: text,
      time: timeString,
      isMe: true, // Hozircha faqat o'zimiz yuborayotganimizni ko'rsatamiz
      isRead: false, // Yuborilgan, hali o'qilmagan
    );

    setState(() {
      _messages.add(newMessage); // Ro'yxatga qo'shamiz
      _textController.clear(); // Input maydonini tozalaymiz
    });

    // Chatni eng pastga aylantirish
    _scrollToBottom();
  }

  // Chatni pastga o'tkazish
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: <Widget>[
          // Chat xabarlari qismi
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Controller qo'shamiz
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 15.h,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Birinchi xabar oldidan sanani ko'rsatish (statik)
                if (index == 0) {
                  return Column(
                    children: [
                      _buildDateSeparator("12.08.2025"),
                      SizedBox(height: 10.h),
                      _buildMessageBubble(_messages[index]),
                    ],
                  );
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          // Xabar yozish qismi (pastki panel)
          _buildMessageInput(context),
        ],
      ),
    );
  }

  // === AppBar UI ===
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _backIconColor),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        "Support",
        style: TextStyle(
          color: _appBarTitleColor,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  // === Sana ajratuvchisi ===
  Widget _buildDateSeparator(String date) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Text(
          date,
          style: TextStyle(color: _dateTextColor, fontSize: 13.sp),
        ),
      ),
    );
  }

  // === Xabar baloni ===
  Widget _buildMessageBubble(Message message) {
    final alignment =
        message.isMe ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(15),
      topRight: const Radius.circular(15),
      bottomLeft: const Radius.circular(15),
      bottomRight: message.isMe
          ? const Radius.circular(5)
          : const Radius.circular(15),
    );

    // Xabarning maksimal kengligi, rasmga o'xshatish uchun muhim
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.only(
          left: 15.w,
          top: 10.h,
          right: 10.w,
          bottom: 8.h,
        ),
        decoration: BoxDecoration(
          color: message.isMe ? _chatBlue : Colors.white,
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? Colors.white : Colors.black,
                fontSize: 15.sp,
                height: 1.3,
              ),
            ),
            SizedBox(height: 5.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: TextStyle(
                    color: message.isMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                // O'qilganlik belgisi
                if (message.isMe)
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    color: message.isRead
                        ? Colors.white70
                        : Colors.white70, // Hali o'qilmagan bo'lsa bitta 'done'
                    size: 15.sp,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // === Xabar kiritish paneli ===
  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        // Rasmga o'xshashlik uchun yengil soya
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE0E0E0),
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: Offset(0.0, -1.0),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            // Attach ikonkasi
            IconButton(
              icon: Icon(
                Icons.attach_file_outlined,
                color: Colors.grey,
                size: 28.sp,
              ),
              onPressed: () {
                // Fayl biriktirish funksiyasi
              },
            ),
            // Matn kiritish maydoni
            Expanded(
              child: Container(
                // Input maydoni rasmda chetidan to'liq boshlanmagan
                margin: EdgeInsets.only(left: 4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: _inputFieldColor, width: 1.0),
                ),
                child: TextField(
                  controller: _textController, // Controller ulandi
                  onSubmitted:
                      _handleSubmitted, // Enter tugmasi bosilganda xabar yuborish
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 10.w,
                    ),
                  ),
                  style: TextStyle(color: Colors.black, fontSize: 16.sp),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Yuborish tugmasi
            Container(
              decoration: BoxDecoration(
                color: _chatBlue,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white, size: 24.sp),
                onPressed: () => _handleSubmitted(
                  _textController.text,
                ), // Tugma bosilganda xabar yuborish
              ),
            ),
          ],
        ),
      ),
    );
  }
}

