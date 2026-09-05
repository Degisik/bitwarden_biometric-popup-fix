# Bitwarden Safari Touch ID: নির্দিষ্ট Keychain অনুমতি

[English](../README.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [हिन्दी](README.hi.md) · [Español](README.es.md) · [العربية](README.ar.md) · [Français](README.fr.md) · [বাংলা](README.bn.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Bahasa Indonesia](README.id.md)

## নির্দেশিত সেটআপ

[ZIP](https://github.com/Degisik/bitwarden_biometric-popup-fix/releases/download/v1.0.0/bitwarden-biometric-installer-v1.0.0.zip) · [Source](../install.command) · [SHA-256](../INSTALLER-SHA256SUMS)

ZIP খুলুন, কোড পড়ুন, Safari বন্ধ করে `install.command` খুলুন। আগে পরীক্ষা হবে; পরিবর্তনের জন্য `APPLY` লিখুন। `sudo` লাগে না; Apple Swift প্রয়োজন। macOS বাধা দিলে সুরক্ষা বন্ধ করবেন না; ম্যানুয়াল পদ্ধতি বা সহায়তা নিন।

## দ্রুত সেটআপ

Safari বন্ধ করুন (⌘Q)। [সম্পূর্ণ কোড পড়ুন](../fix.command), তারপর [fix.command ডাউনলোড](https://github.com/Degisik/bitwarden_biometric-popup-fix/raw/refs/heads/main/fix.command) করে Downloads-এ রাখুন। Apple Swift প্রয়োজন; না থাকলে `xcode-select --install` চালান। শুধু একটি অ্যাকাউন্ট ও ডিফল্ট Keychain-এর জন্য।

প্রথমে শুধু পরীক্ষা করুন:

```sh
cd ~/Downloads
bash fix.command
```

পূর্বরূপে শুধু ডেস্কটপ অ্যাপের সঙ্গে Safari অংশ যোগ হলে প্রয়োগ করুন:

```sh
bash fix.command --apply
```

শুধু macOS ডায়ালগে অনুমতি দিন। `save_acl=0`-এর পরে Safari খুলে Touch ID পরীক্ষা করুন। স্ক্রিপ্ট পাঠযোগ্য লেখা; নেটওয়ার্ক, `sudo` বা গোপন মান পড়ে না। শুধু `--apply` অনুমতি সংরক্ষণ করে। অপ্রত্যাশিত ফলে থামুন। [বিস্তারিত ও অখণ্ডতা পরীক্ষা](../README.md#quick-setup)।

---

এই নির্দেশিকায় একটি Mac-এ সফল সমাধান বর্ণনা করা হয়েছে: ডেস্কটপ Bitwarden-এ Touch ID কাজ করত, কিন্তু Safari বারবার `Bitwarden_biometric`-এর অনুমতি চাইত। ব্যবহারকারী macOS/Safari 26.5.2 এবং Bitwarden 2026.8.0-এ সাফল্য নিশ্চিত করেছেন। এটি আনুষ্ঠানিক সংশোধন বা সব সমস্যার সমাধান নয়।

অনুমতির তালিকায় ডেস্কটপ অ্যাপ ছিল, কিন্তু `/Applications/Bitwarden.app/Contents/PlugIns/safari.appex` ছিল না। শুধু এই স্বাক্ষরিত অংশটি যোগ করা হয়েছে; অন্য অনুমতি অপরিবর্তিত আছে। এতে সংবেদনশীল আইটেমে স্থায়ী প্রবেশাধিকার দেওয়া হয়। কোড গোপন মান পড়ে বা বদলায় না এবং সব অ্যাপকে অনুমতি দেয় না।

ব্যবহারকারী গ্রাফিক্যাল নির্বাচন উইন্ডো থেকে `.app`-এর ভেতরের অংশটি বেছে নিতে পারেননি। তাই সেই GUI পদ্ধতিকে যাচাইকৃত বলা হচ্ছে না।

1. ⌘Q দিয়ে Safari বন্ধ করুন এবং মাস্টার পাসওয়ার্ড দিয়ে স্বাভাবিক প্রবেশাধিকার বজায় রাখুন।
2. [Apple Swift সরঞ্জাম ও স্বাক্ষর যাচাই](../README.md#before-running) করুন। সরঞ্জাম না থাকলে শুধু Apple-এর সরঞ্জাম ব্যবহার করুন।
3. [সম্পূর্ণ কোড পড়ে স্থানীয় ফাইল তৈরি করুন](../README.md#review-and-create-the-local-source)। কোড ডাউনলোড হয় না; একই Terminal সেশন ব্যবহার করুন।
4. প্রথমে `--apply` ছাড়া চালান। প্রত্যাশিত ফল `Dry run; unchanged`; বর্তমান তালিকায় শুধু ডেস্কটপ অ্যাপ থাকবে। একাধিক মিলে যাওয়া আইটেম, একাধিক অ্যাকাউন্ট, বিশেষ Keychain বিন্যাস বা অপ্রত্যাশিত অনুমতি থাকলে থামুন।
5. পরিবর্তন গ্রহণ করলে `--apply` দিয়ে চালান। Mac/Keychain পাসওয়ার্ড শুধু macOS-এর নিজস্ব ডায়ালগে দিন। `sudo` লাগে না। অনুমোদন ব্যর্থ হলে থামুন; এটি পাসওয়ার্ড পুনরুদ্ধার করে না।
6. `save_acl=0` দেখার পর আবার `--apply` ছাড়া চালান। দুটি পথ এবং `Already present; no changes` দেখা উচিত। Safari আবার খুলে কয়েকবার লক ও আনলক পরীক্ষা করুন।

ফিরিয়ে নিতে Keychain Access → সংশ্লিষ্ট আইটেম → Access Control থেকে শুধু নতুন `safari.appex` পথের এন্ট্রি সরান; ডেস্কটপ এন্ট্রি রাখুন। এই GUI প্রত্যাবর্তন এখানে পরীক্ষা করা হয়নি। এন্ট্রি আলাদা করে চিনতে না পারলে আইটেম মুছবেন না; Bitwarden সহায়তা নিন। পাসওয়ার্ড বা Keychain ডাম্প প্রকাশ করবেন না। অনুবাদ AI-সহায়তায় তৈরি, মাতৃভাষীর স্বাধীন পর্যালোচনা হয়নি; ইংরেজি পাঠই প্রযুক্তিগত মূল উৎস।
