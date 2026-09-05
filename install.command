#!/bin/bash
# Transparent standalone installer: all Bash and Swift source is in this file.
# No downloads, network calls, sudo, background service, or secret-value reads.
set -euo pipefail
bw_mode="${1:-interactive}"
case "$bw_mode" in
  --help|-h)
    echo 'Usage: bash install.command [--check]'
    echo 'Default: preview, then require typing APPLY before saving the permission.'
    echo '--check: inspect only, never request an ACL change.'
    exit 0 ;;
  interactive|--check) ;;
  *) echo 'Unknown option. Use --help.' >&2; exit 2 ;;
esac
if [ "$#" -gt 1 ]; then echo 'Too many arguments.' >&2; exit 2; fi
if [ "$EUID" -eq 0 ]; then
  echo 'Run as your normal Mac user, without sudo; the target is your user Keychain.' >&2
  exit 2
fi
bw_fix_dir=''
bw_finish() {
  bw_result=$?
  trap - EXIT
  if [ -n "$bw_fix_dir" ]; then /bin/rm -rf -- "$bw_fix_dir"; fi
  if [ "$bw_result" -ne 0 ]; then echo "Stopped (status $bw_result). Do not bypass failed checks." >&2; fi
  if [ "$bw_mode" = interactive ] && [ -t 0 ]; then
    read -r -p 'Press Return to close this installer. ' bw_close || true
  fi
  exit "$bw_result"
}
trap bw_finish EXIT
echo 'Bitwarden Safari biometric popup fix — community workaround'
echo 'Quit Safari first. For one matching biometric item in the default Keychain setup.'
echo 'Adds only Bitwarden’s signed embedded Safari component to the existing access list.'
echo 'Your vault secret is never requested by this script. Review this file before proceeding.'
if [ "$(/usr/bin/uname -s)" != Darwin ]; then echo 'macOS is required.' >&2; exit 2; fi
if ! /usr/bin/xcrun --find swift >/dev/null 2>&1; then
  echo 'Apple Swift tools are missing. Install through Apple: xcode-select --install' >&2
  exit 2
fi
# Require valid Apple-anchored code with Bitwarden's team and extension identifier.
/usr/bin/codesign --verify --strict -R '=anchor apple generic and identifier "com.bitwarden.desktop.safari"' /Applications/Bitwarden.app/Contents/PlugIns/safari.appex
# App Store signing certificates need not carry the developer team in leaf OU.
# Read the TeamIdentifier embedded in the verified code signature instead.
bw_signature="$(/usr/bin/codesign -dv /Applications/Bitwarden.app/Contents/PlugIns/safari.appex 2>&1)"
bw_team_ok=false
while IFS= read -r bw_line; do
  case "$bw_line" in TeamIdentifier=LTZ2PFU5D6) bw_team_ok=true ;; esac
done <<< "$bw_signature"
if [ "$bw_team_ok" != true ]; then echo 'Unexpected signing team; stopped.' >&2; exit 2; fi
bw_fix_dir="$(/usr/bin/mktemp -d -t bitwarden-safari-acl)"
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

echo 'Checking the current permissions (no changes)...'
if bw_preview="$(/usr/bin/swift -suppress-warnings "$bw_fix_dir/repair.swift")"; then
  printf '%s\n' "$bw_preview"
else
  printf '%s\n' "$bw_preview"
  exit 1
fi
case "$bw_preview" in
  *'Already present; no changes'*)
    echo 'The permission already exists. Reopen Safari and try Touch ID.'
    exit 0 ;;
esac
if [ "$bw_mode" = --check ]; then exit 0; fi
if [ ! -t 0 ]; then echo 'Interactive Terminal required. No changes made.' >&2; exit 2; fi
echo 'This grants persistent access to the sensitive Bitwarden_biometric item to:'
echo '/Applications/Bitwarden.app/Contents/PlugIns/safari.appex'
read -r -p 'Type APPLY to save this exact change, or press Return to cancel: ' bw_answer
if [ "$bw_answer" != APPLY ]; then echo 'Cancelled. No changes made.'; exit 0; fi
echo 'If macOS asks, enter your Keychain password only into its own system dialog.'
/usr/bin/swift -suppress-warnings "$bw_fix_dir/repair.swift" --apply
echo 'Verifying the saved permission...'
bw_after="$(/usr/bin/swift -suppress-warnings "$bw_fix_dir/repair.swift")"
printf '%s\n' "$bw_after"
case "$bw_after" in
  *'Already present; no changes'*) echo 'Permission verified. Reopen Safari and test Touch ID.' ;;
  *) echo 'Post-save verification did not match. Stop and seek support.' >&2; exit 1 ;;
esac
