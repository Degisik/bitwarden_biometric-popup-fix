# Bitwarden Safari Touch ID: सीमित Keychain अनुमति

[English](../README.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [हिन्दी](README.hi.md) · [Español](README.es.md) · [العربية](README.ar.md) · [Français](README.fr.md) · [বাংলা](README.bn.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Bahasa Indonesia](README.id.md)

## त्वरित सेटअप

Safari बंद करें (⌘Q)। [पूरा कोड पढ़ें](../fix.command), फिर [fix.command डाउनलोड](https://github.com/Degisik/bitwarden_biometric-popup-fix/raw/refs/heads/main/fix.command) करके Downloads में रखें। Apple Swift चाहिए; न हो तो `xcode-select --install` चलाएँ। केवल एक खाते और डिफ़ॉल्ट Keychain के लिए।

पहले केवल जाँचें:

```sh
cd ~/Downloads
bash fix.command
```

पूर्वावलोकन केवल डेस्कटॉप ऐप के साथ Safari घटक जोड़ता हो तो लागू करें:

```sh
bash fix.command --apply
```

अनुमति केवल macOS संवाद में दें। `save_acl=0` के बाद Safari खोलकर Touch ID जाँचें। स्क्रिप्ट पढ़ने योग्य पाठ है; नेटवर्क, `sudo` या गुप्त मान पढ़ने का उपयोग नहीं करती। केवल `--apply` अनुमति सहेजता है। अप्रत्याशित परिणाम पर रुकें। [विवरण और अखंडता जाँच](../README.md#quick-setup)।

---

यह मार्गदर्शिका एक Mac पर सफल उपाय बताती है: डेस्कटॉप Bitwarden में Touch ID चलता था, लेकिन Safari बार-बार `Bitwarden_biometric` की अनुमति माँगता था। उपयोगकर्ता ने macOS/Safari 26.5.2 और Bitwarden 2026.8.0 पर सफलता की पुष्टि की। यह आधिकारिक सुधार या हर मामले का समाधान नहीं है।

अनुमति सूची में डेस्कटॉप ऐप था, पर `/Applications/Bitwarden.app/Contents/PlugIns/safari.appex` नहीं था। केवल इस हस्ताक्षरित घटक को जोड़ा गया; बाकी अनुमतियाँ सुरक्षित रखी गईं। इससे संवेदनशील आइटम तक स्थायी पहुँच मिलती है। कोड गुप्त मान को पढ़ता या बदलता नहीं और सभी ऐप को अनुमति नहीं देता।

उपयोगकर्ता ग्राफ़िकल चयन विंडो से `.app` के भीतर यह घटक नहीं चुन पाया। इसलिए उस GUI विधि को सत्यापित समाधान नहीं बताया गया है।

1. ⌘Q से Safari बंद करें और मास्टर पासवर्ड से सामान्य पहुँच बनाए रखें।
2. [Apple Swift उपकरण और हस्ताक्षर जाँच](../README.md#before-running) पूरी करें। उपकरण न हों तो केवल Apple के उपकरण इस्तेमाल करें।
3. [पूरा कोड पढ़कर स्थानीय फ़ाइल बनाएँ](../README.md#review-and-create-the-local-source)। कोड डाउनलोड नहीं होता; उसी Terminal सत्र का उपयोग करें।
4. पहले `--apply` के बिना चलाएँ। अपेक्षित परिणाम `Dry run; unchanged` है और मौजूदा सूची में केवल डेस्कटॉप ऐप होना चाहिए। कई मिलते-जुलते आइटम, कई खाते, विशेष Keychain व्यवस्था या अप्रत्याशित अनुमति होने पर रुकें।
5. बदलाव स्वीकार हो तो `--apply` के साथ चलाएँ। Mac/Keychain पासवर्ड केवल macOS के संवाद में डालें। `sudo` आवश्यक नहीं। अनुमति विफल हो तो रुकें; यह पासवर्ड रिकवरी नहीं है।
6. `save_acl=0` के बाद फिर बिना `--apply` चलाएँ। दोनों पथ और `Already present; no changes` दिखने चाहिए। Safari दोबारा खोलकर कई बार लॉक और अनलॉक जाँचें।

वापस करने के लिए Keychain Access → संबंधित आइटम → Access Control में केवल जोड़ी गई `safari.appex` पथ वाली प्रविष्टि हटाएँ और डेस्कटॉप प्रविष्टि रहने दें। यह GUI वापसी प्रक्रिया यहाँ परीक्षण नहीं की गई है। प्रविष्टियाँ अलग न पहचान पाएँ तो आइटम न मिटाएँ; Bitwarden सहायता लें। पासवर्ड या Keychain डंप साझा न करें। अनुवाद AI की सहायता से बना है और किसी मूल वक्ता ने स्वतंत्र समीक्षा नहीं की; तकनीकी संदर्भ अंग्रेज़ी पाठ है।
