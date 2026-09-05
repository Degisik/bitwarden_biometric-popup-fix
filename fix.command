#!/bin/bash
# Readable local wrapper; no network calls, downloads, sudo, or password input.
# Default: inspect only. --apply: add the signed embedded Safari component.
set -euo pipefail
case "${1:-}" in
  --help|-h)
    echo 'Usage: bash fix.command [--apply]'
    echo 'No argument: inspect only. --apply: persist the scoped Safari permission.'
    echo 'Requires macOS, Apple Swift tools, and Bitwarden in /Applications.'
    echo 'Only for a single matching biometric item in the default Keychain setup.'
    exit 0 ;;
  ''|--apply) ;;
  *) echo 'Unknown option. Use --help.' >&2; exit 2 ;;
esac
if [ "$#" -gt 1 ]; then echo 'Too many arguments.' >&2; exit 2; fi
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
trap '/bin/rm -rf -- "$bw_fix_dir"' EXIT
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
/usr/bin/swift -suppress-warnings "$bw_fix_dir/repair.swift" "$@"
