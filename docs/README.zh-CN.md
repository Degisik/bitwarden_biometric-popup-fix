# Bitwarden Safari Touch ID：限定范围的钥匙串权限修复

[English](../README.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [हिन्दी](README.hi.md) · [Español](README.es.md) · [العربية](README.ar.md) · [Français](README.fr.md) · [বাংলা](README.bn.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Bahasa Indonesia](README.id.md)

## 快速设置

退出 Safari（⌘Q）。[阅读全部脚本](../fix.command)，再将 [fix.command 下载](https://github.com/Degisik/bitwarden_biometric-popup-fix/raw/refs/heads/main/fix.command)到“下载”文件夹。需要 Apple Swift 工具；缺少时先运行 `xcode-select --install`。仅适用于单账户和默认钥匙串配置。

先只检查：

```sh
cd ~/Downloads
bash fix.command
```

预览仅将 Safari 组件加入桌面应用的访问列表时，再应用：

```sh
bash fix.command --apply
```

仅在 macOS 系统对话框中授权。出现 `save_acl=0` 后打开 Safari 测试 Touch ID。脚本为可读文本，不联网、不使用 `sudo`、不读取秘密值；只有 `--apply` 会保存权限。结果异常时请停止。[详情与完整性检查](../README.md#quick-setup)。

---

本文记录了在一台 Mac 上成功的方法：桌面版 Bitwarden 的 Touch ID 正常，但 Safari 反复请求访问 `Bitwarden_biometric`。用户在 macOS/Safari 26.5.2、Bitwarden 2026.8.0 上确认问题已解决。这不是官方修复，也不保证适用于所有类似问题。

原有访问列表包含桌面应用，却没有 `/Applications/Bitwarden.app/Contents/PlugIns/safari.appex`。我们只添加了这个已签名组件，并保留其他权限。这会授予对敏感项目的持久访问权；代码不会读取或修改秘密值，也不会允许所有应用访问。

用户无法通过图形文件选择器进入 `.app` 并选择该组件，因此本文不把图形界面添加方法当作已验证的方案。

1. 按 ⌘Q 完全退出 Safari，并保留使用主密码正常访问账户的能力。
2. 完成英文指南中的 [Apple Swift 工具和签名检查](../README.md#before-running)。如果缺少工具，仅使用 Apple 官方工具。
3. 阅读[全部代码并创建本地文件](../README.md#review-and-create-the-local-source)。无需下载代码；后续命令使用同一个终端会话。
4. 先不加 `--apply` 运行。预期输出为 `Dry run; unchanged`，原列表应只有桌面应用。如果存在多个匹配项目、多个账户、自定义钥匙串配置或异常权限，请停止。
5. 接受所示变更后，才加 `--apply` 运行。只在 macOS 系统对话框中输入 Mac/钥匙串密码；不需要 `sudo`。授权失败时请停止，本方法不能找回或绕过密码。
6. 出现 `save_acl=0` 后，再次不加 `--apply` 运行。应看到两个路径和 `Already present; no changes`。重新打开 Safari，多次测试锁定和 Touch ID 解锁。

如需撤销，在“钥匙串访问”→相关项目→“访问控制”中，仅移除路径为 `safari.appex` 的新增项，保留桌面应用。本文尚未测试这一图形界面撤销步骤。如果无法区分项目，请联系 Bitwarden 支持，不要猜测或删除整个钥匙串项目。不要公开密码或钥匙串转储。译文由 AI 辅助生成，未经母语人士独立审校；英文版为技术依据。
