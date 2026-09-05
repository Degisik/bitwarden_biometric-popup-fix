# Bitwarden Safari Touch ID: a scoped Keychain permission workaround

Touch ID works in the Bitwarden desktop app, but Safari repeatedly asks for access to `Bitwarden_biometric`? This documents a workaround that resolved that symptom on one Mac.

**Independent community documentation, not an official Bitwarden fix. An optional readable setup script is available; the manual method requires no script download.** The complete local source is visible below. It changes permission to read a sensitive Keychain item, so review it before running it.

[English](README.md) · [Türkçe](docs/README.tr.md) · [简体中文](docs/README.zh-CN.md) · [हिन्दी](docs/README.hi.md) · [Español](docs/README.es.md) · [العربية](docs/README.ar.md) · [Français](docs/README.fr.md) · [বাংলা](docs/README.bn.md) · [Português](docs/README.pt.md) · [Русский](docs/README.ru.md) · [Bahasa Indonesia](docs/README.id.md)

## Quick setup

**For the single-account/default-Keychain case described below.** Requires Apple's Swift tools; if missing, run `xcode-select --install` first. Keep your normal master-password access.

1. Quit Safari (⌘Q). [Read the complete script](fix.command), then [download fix.command](https://github.com/Degisik/bitwarden_biometric-popup-fix/raw/refs/heads/main/fix.command) into Downloads.
2. Open Terminal and run the **check only**:

   ```sh
   cd ~/Downloads
   bash fix.command
   ```

3. If the preview shows only Bitwarden desktop → desktop + its Safari component, apply:

   ```sh
   bash fix.command --apply
   ```

4. Authorize in macOS's own dialog if requested. After `save_acl=0`, reopen Safari and try Touch ID. `Already present; no changes` means the permission already exists.

**What you are running:** one readable Bash file containing the same Swift repair used successfully here. It verifies the installed Safari component's signature, team and identifier; it does not read the secret value, contact a server, install a background service, or use `sudo`. Only `--apply` persists the permission. Unexpected results or rejected authorization: stop; do not broaden access. Multiple matching Keychain items/accounts are outside this script's scope.

Optional integrity check: download [SHA256SUMS](https://github.com/Degisik/bitwarden_biometric-popup-fix/raw/refs/heads/main/SHA256SUMS) into the same folder and run `shasum -a 256 -c SHA256SUMS`. This checks consistency with the published file, **not independent proof that it is safe**. Review the source. The longer copy-and-paste method below remains available without downloading a script.

## What was actually confirmed

- macOS 26.5.2; Safari 26.5.2; Bitwarden desktop and bundled Safari extension 2026.8.0.
- Desktop Touch ID worked. Safari showed repeated Keychain prompts; the user reported that the Mac password did not work and Deny caused another prompt.
- The item's decrypt ACL trusted `/Applications/Bitwarden.app`, but did not list the bundled Safari extension.
- Adding only `/Applications/Bitwarden.app/Contents/PlugIns/safari.appex` to that existing ACL succeeded. A fresh metadata-only read confirmed the addition and unchanged other ACLs. The user confirmed normal operation on 6 September 2026.

This establishes a successful workaround for this configuration, not the cause of every similar failure or proof that macOS rejected the password itself. The related issue also contains reports of a separate WebCrypto problem.

## Why a separate permission can matter

The extension lives **inside** Bitwarden.app; it is not a separate app in Applications. Its bundle ID is `com.bitwarden.desktop.safari`. The desktop bundle ID is `com.bitwarden.desktop`.

The matching release source uses `SecKeychainFindGenericPassword` even in `getBiometricsStatusForUser`. That status query requests the stored value, so a Keychain authorization prompt can happen before the expected Touch ID step. The actual unlock flow also reads the item after biometric authentication. An existing desktop permission does not establish that the extension has access.

The tested item's partition ACL already contained Bitwarden's team ID `LTZ2PFU5D6`. This workaround preserves it. It does not grant access to all applications, disable Touch ID, reset the Keychain, or modify the stored secret. Adding a trusted application still grants persistent access to this sensitive item; the extension's signed identity matters.

## Why this is not a GUI-only recipe

The affected user could not navigate inside the `.app` bundle and select `safari.appex` in Keychain Access's application picker. We have **not verified a working GUI-only add procedure**. Merely selecting Bitwarden.app again does not reproduce the tested change. The source below uses Apple's Security framework to add the exact embedded component.

## Before running

1. Keep access to your Bitwarden master password and normal account recovery methods. Do not paste any password or vault export into this repository or an issue.
2. Quit Safari with ⌘Q. Leave Bitwarden installed at the exact path used below.
3. Run `xcrun --find swift`. This requires Apple's Xcode Command Line Tools or Xcode. A standard macOS installation may not already have them. If missing, install them through Apple's own tools (`xcode-select --install`) or stop here; this guide supplies no compiler download.
4. Verify the installed extension using Apple's command:

```sh
/usr/bin/codesign --verify --strict /Applications/Bitwarden.app/Contents/PlugIns/safari.appex
/usr/bin/codesign -dv /Applications/Bitwarden.app/Contents/PlugIns/safari.appex
```

The first command must succeed. Check that the second shows identifier `com.bitwarden.desktop.safari` and team `LTZ2PFU5D6`. If either differs, stop and investigate; do not bypass signature errors.

## Review and create the local source

Read the entire source. Copy the following block into Terminal only if you accept the described change. It creates a local temporary directory and source file; it does not fetch anything. Keep the same Terminal session for the later commands.

```sh
bw_fix_dir="$(mktemp -d -t bitwarden-safari-acl)"
cat > "$bw_fix_dir/repair.swift" <<'SWIFT'
import Foundation
import Security
func check(_ s: OSStatus, _ step: String) { print("\(step)=\(s)"); fflush(stdout); if s != errSecSuccess { exit(1) } }
let svc = "Bitwarden_biometric"
let target = "/Applications/Bitwarden.app/Contents/PlugIns/safari.appex"
var item: SecKeychainItem?
check(svc.withCString { SecKeychainFindGenericPassword(nil, UInt32(svc.utf8.count), $0, 0, nil, nil, nil, &item) }, "find_metadata")
guard let item else { exit(1) }
var access: SecAccess?
check(SecKeychainItemCopyAccess(item, &access), "copy_access")
guard let access else { exit(1) }
var list: CFArray?
check(SecAccessCopyACLList(access, &list), "copy_acl_list")
guard let list else { exit(1) }
let candidates = (list as! [SecACL]).filter { (SecACLCopyAuthorizations($0) as! [String]).contains("ACLAuthorizationDecrypt") }
guard candidates.count == 1 else { print("Unexpected ACL shape; no changes"); exit(2) }
let acl = candidates[0]
var apps: CFArray?
var desc: CFString?
var selector = SecKeychainPromptSelector()
check(SecACLCopyContents(acl, &apps, &desc, &selector), "copy_decrypt_acl")
guard let apps else { print("Unrestricted ACL; no changes"); exit(2) }
var trusted = apps as! [SecTrustedApplication]
var paths = [String]()
for app in trusted {
 var data: CFData?
 check(SecTrustedApplicationCopyData(app, &data), "copy_trusted_path")
 guard let data else { exit(2) }
 paths.append(String(decoding:data as Data,as:UTF8.self).replacingOccurrences(of:"\0",with:""))
}
print("Before: \(paths)")
if paths.contains(target) { print("Already present; no changes"); exit(0) }
guard paths == ["/Applications/Bitwarden.app"] else { print("Unexpected existing apps; no changes"); exit(2) }
var safari: SecTrustedApplication?
check(target.withCString { SecTrustedApplicationCreateFromPath($0, &safari) }, "create_signed_safari_trust")
guard let safari else { exit(2) }
trusted.append(safari)
print("Proposed: \(paths + [target]); preserve flags, authorization tags and all other ACLs")
fflush(stdout)
if !CommandLine.arguments.contains("--apply") { print("Dry run; unchanged"); exit(0) }
guard let desc else { exit(2) }
check(SecACLSetContents(acl, trusted as CFArray, desc, selector), "prepare_acl")
check(SecKeychainItemSetAccess(item, access), "save_acl")
print("Saved scoped Safari access; secret value never requested")
SWIFT
```

### Inspect first — no permission changes

```sh
/usr/bin/swift -suppress-warnings "$bw_fix_dir/repair.swift"
```

Expected for the tested case: `Before` contains only `/Applications/Bitwarden.app`, `Proposed` adds its embedded `safari.appex`, and the last line is `Dry run; unchanged`. The API calls retrieve item references and access metadata; the code passes no output buffers for the stored secret.

The code refuses an unexpected decrypt ACL or an unexpected existing application list. An unrestricted ACL is not handled. It uses the first matching `Bitwarden_biometric` item in the user's Keychain search list: **it is not designed for multiple matching items, accounts, or custom Keychain layouts.** If you know you have those, stop and obtain account-specific help. Do not remove guards to make it run.

### Apply the reviewed change

Only after the dry run matches:

```sh
/usr/bin/swift -suppress-warnings "$bw_fix_dir/repair.swift" --apply
```

macOS may require authorization to save the access change. Enter your Mac/Keychain password only into macOS's own dialog, never into a Terminal command or chat. No `sudo` is needed. If that authorization fails, stop: this workaround does not recover or bypass a forgotten Keychain password.

Success is `save_acl=0`. The existing decrypt ACL's authorization tags, prompt selector and other entries are preserved. The program adds one signed trusted application to its application list. It does not change the authorizations on that ACL, including any already present alongside decrypt.

### Verify

Run the same command without `--apply` again. The `Before` list should include both paths and the program should report `Already present; no changes`. Restart Safari and test Touch ID. Then lock and unlock the extension again. If a prompt or another error persists, record the error text and versions; do not broaden access.

## Undo and limitations

This adds a persistent trust entry. To undo it, open Keychain Access → the affected `Bitwarden_biometric` item → Access Control. Remove **only the entry whose path is the embedded `safari.appex`**, retain the desktop entry, and save through macOS authorization. Removal through this GUI has not been tested for this guide. If the entries have indistinguishable labels or the control is unavailable, stop and ask Bitwarden support for a targeted ACL rollback rather than deleting the item or guessing. Disabling biometric unlock is not a verified rollback of this ACL change.

The applied code and macOS version are recorded above; future versions may change the layout or behavior. Apple's legacy SecKeychain/SecACL APIs used here are deprecated, matching the relevant Bitwarden implementation. An official fix may supersede this workaround. The optional setup script makes no network requests and has no telemetry or binary payloads. It creates and removes only its own temporary source directory. Avoid posting account identifiers or unredacted Keychain dumps.

## Sources and translations

- [Related Bitwarden issue #15129](https://github.com/bitwarden/clients/issues/15129): similar symptoms; multiple possible causes.
- [Bitwarden 2026.8.0 Safari native handler](https://github.com/bitwarden/clients/blob/desktop-v2026.8.0/apps/browser/src/safari/safari/SafariWebExtensionHandler.swift): status and unlock behavior.
- [Official biometric setup](https://bitwarden.com/help/biometrics/): try normal supported setup before an ACL workaround.
- [Apple SecKeychainItemSetAccess](https://developer.apple.com/documentation/security/seckeychainitemsetaccess(_:_:)): the save operation used here.

English is the canonical technical source. The localized guides below cover the same workflow and link to one shared code block to prevent translated code from diverging. They are AI-assisted translations and have not been independently reviewed by native speakers.

Language coverage uses total speakers (first plus second language), based on the [2025 Ethnologue ranking reported here](https://indianexpress.com/article/trending/top-10-listing/top-10-most-spoken-languages-globally-in-2025-5-indian-languages-ranked-9999661/lite/): English, Mandarin Chinese, Hindi, Spanish, Standard Arabic, French, Bengali, Portuguese, Russian and Indonesian. Turkish is additional: **11 distinct languages**, not a claim of a live 2026 ranking.
