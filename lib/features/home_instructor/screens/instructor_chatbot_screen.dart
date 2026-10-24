import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';

import '../../../core/theme/app_colors.dart';

class InstructorChatbotScreen extends StatefulWidget {
  const InstructorChatbotScreen({super.key});

  @override
  State<InstructorChatbotScreen> createState() => _InstructorChatbotScreenState();
}

class _InstructorChatbotScreenState extends State<InstructorChatbotScreen> {
  String _currentLanguage = 'English';

  final List<Map<String, dynamic>> _messages = [];
  List<Map<String, String>> _faqs = [];

  // Localized Greetings
  final Map<String, String> _greetings = {
    'English': 'Hi! I am your iAgrow Assistant. How can I help you upload your courses and ebooks today?',
    'हिन्दी': 'नमस्ते! मैं आपका iAgrow सहायक हूँ। मैं आज आपके कोर्स और ई-बुक अपलोड करने में कैसे मदद कर सकता हूँ?',
    'मराठी': 'नमस्कार! मी तुमचा iAgrow सहाय्यक आहे. आज तुमचे कोर्सेस आणि ई-बुक्स अपलोड करण्यासाठी मी तुम्हाला कशी मदत करू शकेन?',
  };

  // Localized FAQs
  final Map<String, List<Map<String, String>>> _allLocalizedFaqs = {
    'English': [
      {
        'q': 'How to upload an Ebook?',
        'a': 'To upload an Ebook:\n1. Go to Home -> Upload Ebook.\n2. Enter the title, short description, and price.\n3. Upload a cover image (16:9 ratio).\n4. Select your PDF file.\n5. Click Submit. Your ebook will be reviewed and published!',
      },
      {
        'q': 'How to upload a Video Course?',
        'a': 'To create a course:\n1. Go to Home -> Upload Course.\n2. Fill in the course details (Title, Price, Level).\n3. Upload a thumbnail and preview video.\n4. Once created, you will be taken to Manage Course where you can add Sections.\n5. Click "Add Lecture" inside a Section and easily pick a video directly from your mobile gallery to upload instantly!',
      },
      {
        'q': 'Can I pick videos from my phone gallery?',
        'a': 'Yes! We recently added a feature where you can click "Pick Video from Gallery" directly inside the Add Lecture popup. Once selected, it uploads automatically!',
      },
      {
        'q': 'What video formats are supported?',
        'a': 'We support MP4, MOV, and AVI formats. We recommend keeping videos under 500MB and in 1080p for the best student experience.',
      },
      {
        'q': 'When do I get paid?',
        'a': 'Your revenue is calculated automatically when a student buys your course. Payouts happen on the 1st of every month directly to your registered bank account.',
      },
      {
        'q': 'What topics should I teach?',
        'a': 'Since iAgrow focuses on Krushi Siksha (Agriculture Education), students love topics like Organic Farming, modern irrigation techniques, crop disease management, and dairy farming business strategies.',
      },
      {
        'q': 'Can I offer free courses?',
        'a': 'Absolutely! Offering a free course or ebook is a fantastic way to build a follower base of farmers and showcase your teaching style before launching a premium course.',
      },
      {
        'q': 'How do I answer student doubts?',
        'a': 'You can interact with students in the iAgrow Community tab! Students can ask questions on your course, and you can reply to them directly to build trust and increase ratings.',
      },
      {
        'q': 'How to update my Instructor Profile?',
        'a': 'Navigate to the Profile tab. From there, you can upload a professional photo, add your agricultural expertise (like "Horticulture Expert"), and link your social media.',
      }
    ],
    'हिन्दी': [
      {
        'q': 'ई-बुक कैसे अपलोड करें?',
        'a': 'ई-बुक अपलोड करने के लिए:\n1. होम -> ई-बुक अपलोड करें पर जाएँ।\n2. शीर्षक, संक्षिप्त विवरण और मूल्य दर्ज करें।\n3. एक कवर छवि अपलोड करें (16:9 अनुपात)।\n4. अपनी पीडीएफ फाइल चुनें।\n5. सबमिट पर क्लिक करें। आपकी ई-बुक की समीक्षा की जाएगी और उसे प्रकाशित किया जाएगा!',
      },
      {
        'q': 'वीडियो कोर्स कैसे अपलोड करें?',
        'a': 'कोर्स बनाने के लिए:\n1. होम -> कोर्स अपलोड करें पर जाएँ।\n2. कोर्स विवरण भरें।\n3. थंबनेल अपलोड करें।\n4. इसके बाद मैनेज कोर्स में जाकर आप सेक्शन और लेक्चर जोड़ सकते हैं। अब आप सीधे गैलरी से वीडियो चुनकर अपलोड कर सकते हैं!',
      },
      {
        'q': 'क्या मैं गैलरी से वीडियो चुन सकता हूँ?',
        'a': 'हाँ! अब आप "ऐड लेक्चर" पॉपअप में "Pick Video from Gallery" बटन पर क्लिक करके सीधे अपने फोन की गैलरी से वीडियो चुन सकते हैं। यह स्वचालित रूप से अपलोड हो जाएगा!',
      },
      {
        'q': 'कौन से वीडियो प्रारूप समर्थित हैं?',
        'a': 'हम MP4, MOV और AVI प्रारूपों का समर्थन करते हैं। हम सर्वोत्तम छात्र अनुभव के लिए वीडियो को 500MB से कम और 1080p में रखने की सलाह देते हैं।',
      },
      {
        'q': 'मुझे भुगतान कब मिलेगा?',
        'a': 'जब कोई छात्र आपका कोर्स खरीदता है तो आपके राजस्व की गणना स्वचालित रूप से की जाती है। भुगतान हर महीने की 1 तारीख को सीधे आपके पंजीकृत बैंक खाते में किया जाता है।',
      },
      {
        'q': 'मुझे कौन से विषय पढ़ाने चाहिए?',
        'a': 'चूंकि iAgrow कृषि शिक्षा पर केंद्रित है, छात्र जैविक खेती, आधुनिक सिंचाई तकनीक, फसल रोग प्रबंधन और डेयरी फार्मिंग व्यवसाय रणनीतियों जैसे विषयों को पसंद करते हैं।',
      },
      {
        'q': 'क्या मैं मुफ्त कोर्स दे सकता हूँ?',
        'a': 'बिल्कुल! मुफ्त कोर्स या ई-बुक देना किसानों का अनुसरणकर्ता आधार बनाने और प्रीमियम कोर्स शुरू करने से पहले अपनी शिक्षण शैली को प्रदर्शित करने का एक शानदार तरीका है।',
      },
      {
        'q': 'मैं छात्रों के संदेहों का उत्तर कैसे दूँ?',
        'a': 'आप iAgrow कम्युनिटी टैब में छात्रों के साथ बातचीत कर सकते हैं! छात्र आपके कोर्स पर सवाल पूछ सकते हैं, और आप विश्वास बनाने और रेटिंग बढ़ाने के लिए उन्हें सीधे जवाब दे सकते हैं।',
      },
      {
        'q': 'अपनी प्रशिक्षक प्रोफ़ाइल कैसे अपडेट करें?',
        'a': 'प्रोफ़ाइल टैब पर जाएँ। वहाँ से, आप एक पेशेवर फ़ोटो अपलोड कर सकते हैं, अपनी कृषि विशेषज्ञता जोड़ सकते हैं, और अपने सोशल मीडिया को लिंक कर सकते हैं।',
      }
    ],
    'मराठी': [
      {
        'q': 'ई-बुक कशी अपलोड करावी?',
        'a': 'ई-बुक अपलोड करण्यासाठी:\n1. होम -> ई-बुक अपलोड करा वर जा.\n2. शीर्षक, संक्षिप्त वर्णन आणि किंमत प्रविष्ट करा.\n3. कव्हर इमेज अपलोड करा (16:9 प्रमाण).\n4. तुमची पीडीएफ फाईल निवडा.\n5. सबमिट वर क्लिक करा. तुमच्या ई-बुकचे पुनरावलोकन केले जाईल आणि ती प्रकाशित केली जाईल!',
      },
      {
        'q': 'व्हिडिओ कोर्स कसा अपलोड करावा?',
        'a': 'कोर्स तयार करण्यासाठी:\n1. होम -> कोर्स अपलोड करा वर जा.\n2. कोर्सचे तपशील भरा.\n3. थंबनेल अपलोड करा.\n4. त्यानंतर मॅनेज कोर्समध्ये जाऊन तुम्ही विभाग आणि लेक्चर जोडू शकता. आता तुम्ही थेट गॅलरीतून व्हिडिओ निवडून अपलोड करू शकता!',
      },
      {
        'q': 'मी गॅलरीतून व्हिडिओ निवडू शकतो का?',
        'a': 'होय! आता तुम्ही "अॅड लेक्चर" पॉपअपमध्ये "Pick Video from Gallery" बटणावर क्लिक करून थेट तुमच्या फोनच्या गॅलरीतून व्हिडिओ निवडू शकता. तो आपोआप अपलोड होईल!',
      },
      {
        'q': 'कोणते व्हिडिओ स्वरूप समर्थित आहेत?',
        'a': 'आम्ही MP4, MOV आणि AVI स्वरूपांना समर्थन देतो. सर्वोत्तम विद्यार्थी अनुभवासाठी आम्ही व्हिडिओ 500MB च्या खाली आणि 1080p मध्ये ठेवण्याची शिफारस करतो.',
      },
      {
        'q': 'मला पैसे कधी मिळतील?',
        'a': 'जेव्हा एखादा विद्यार्थी तुमचा कोर्स विकत घेतो तेव्हा तुमच्या महसुलाची आपोआप गणना केली जाते. प्रत्येक महिन्याच्या 1 तारखेला थेट तुमच्या नोंदणीकृत बँक खात्यात पेआउट केले जाते.',
      },
      {
        'q': 'मी कोणते विषय शिकवावे?',
        'a': 'iAgrow कृषी शिक्षणावर लक्ष केंद्रित करत असल्याने, विद्यार्थ्यांना सेंद्रिय शेती, आधुनिक सिंचन तंत्र, पीक रोग व्यवस्थापन आणि दुग्धव्यवसाय धोरणे यासारखे विषय आवडतात.',
      },
      {
        'q': 'मी मोफत कोर्सेस देऊ शकतो का?',
        'a': 'नक्कीच! मोफत कोर्स किंवा ई-बुक ऑफर करणे हा शेतकरी फॉलोअर्सचा बेस तयार करण्याचा आणि प्रीमियम कोर्स लॉन्च करण्यापूर्वी तुमची शिकवण्याची शैली दाखवण्याचा एक उत्तम मार्ग आहे.',
      },
      {
        'q': 'विद्यार्थ्यांच्या शंकांचे निरसन कसे करू?',
        'a': 'तुम्ही iAgrow कम्युनिटी टॅबमध्ये विद्यार्थ्यांशी संवाद साधू शकता! विद्यार्थी तुमच्या कोर्सवर प्रश्न विचारू शकतात आणि विश्वास निर्माण करण्यासाठी आणि रेटिंग वाढवण्यासाठी तुम्ही त्यांना थेट उत्तर देऊ शकता.',
      },
      {
        'q': 'माझी इन्स्ट्रक्टर प्रोफाइल कशी अपडेट करावी?',
        'a': 'प्रोफाइल टॅबवर जा. तेथून, तुम्ही एक व्यावसायिक फोटो अपलोड करू शकता, तुमचे कृषी कौशल्य जोडू शकता आणि तुमचे सोशल मीडिया लिंक करू शकता.',
      }
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadLanguage(_currentLanguage);
  }

  void _loadLanguage(String lang, {bool isSwitch = false}) {
    setState(() {
      _currentLanguage = lang;
      if (_messages.isEmpty) {
        _messages.add({
          'isBot': true,
          'text': _greetings[lang]!,
        });
      } else if (isSwitch) {
        _messages.add({
          'isBot': true,
          'text': _greetings[lang]!,
        });
      }
      _faqs = List<Map<String, String>>.from(_allLocalizedFaqs[lang]!);
    });
    if (isSwitch) {
      _scrollToBottom();
    }
  }

  final ScrollController _scrollController = ScrollController();

  void _askQuestion(String question, String answer) async {
    setState(() {
      _faqs.removeWhere((faq) => faq['q'] == question);
      _messages.add({'isBot': false, 'text': question});
    });
    
    _scrollToBottom();

    // Delay for typing simulation
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() {
      _messages.add({'isBot': true, 'text': answer});
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Guide'),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(IconlyLight.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: 'Select Language',
            onSelected: (String lang) {
              if (_currentLanguage != lang) {
                _loadLanguage(lang, isSwitch: true);
              }
            },
            itemBuilder: (BuildContext context) {
              return ['English', 'हिन्दी', 'मराठी'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    style: TextStyle(
                      fontWeight: _currentLanguage == choice ? FontWeight.bold : FontWeight.normal,
                      color: _currentLanguage == choice ? AppColors.primaryGreen : null,
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg['text'], msg['isBot'], isDark);
              },
            ),
          ),
          if (_faqs.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.lineDark : AppColors.lineLight,
                  ),
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _faqs.map((faq) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(faq['q']!),
                          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => _askQuestion(faq['q']!, faq['a']!),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isBot, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 1),
                image: const DecorationImage(
                  image: AssetImage('assets/images/igrow_teacher_bot.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isBot 
                    ? (isDark ? AppColors.cardDark : AppColors.white)
                    : AppColors.primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isBot ? const Radius.circular(4) : const Radius.circular(20),
                  bottomRight: isBot ? const Radius.circular(20) : const Radius.circular(4),
                ),
                border: isBot ? Border.all(color: isDark ? AppColors.lineDark : AppColors.lineLight) : null,
              ),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isBot 
                      ? (isDark ? AppColors.white : AppColors.inkDark)
                      : AppColors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!isBot) const SizedBox(width: 40), // Margin for user messages
        ],
      ),
    );
  }
}
