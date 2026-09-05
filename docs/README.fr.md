# Bitwarden Safari Touch ID : autorisation ciblée du trousseau

[English](../README.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [हिन्दी](README.hi.md) · [Español](README.es.md) · [العربية](README.ar.md) · [Français](README.fr.md) · [বাংলা](README.bn.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Bahasa Indonesia](README.id.md)

## Installation guidée

[ZIP](https://github.com/Degisik/bitwarden_biometric-popup-fix/releases/download/v1.0.0/bitwarden-biometric-installer-v1.0.0.zip) · [Source](../install.command) · [SHA-256](../INSTALLER-SHA256SUMS)

Extrayez le ZIP, lisez le code, quittez Safari puis ouvrez `install.command`. Il vérifie d’abord ; tapez `APPLY` pour appliquer. Sans `sudo`, avec Swift Apple. Si macOS le bloque, ne désactivez pas les protections ; utilisez la méthode manuelle ou demandez de l’aide.

## Installation rapide

Quittez Safari (⌘Q). [Lisez le code](../fix.command), puis [téléchargez fix.command](https://github.com/Degisik/bitwarden_biometric-popup-fix/raw/refs/heads/main/fix.command) dans Téléchargements. Swift Apple est requis ; sinon, lancez `xcode-select --install`. Pour un seul compte et le trousseau par défaut.

Vérification seule :

```sh
cd ~/Downloads
bash fix.command
```

Si l’aperçu ajoute uniquement le composant Safari à l’application principale :

```sh
bash fix.command --apply
```

Autorisez uniquement dans la fenêtre macOS. Après `save_acl=0`, ouvrez Safari et testez Touch ID. Le script est lisible, sans réseau, `sudo` ni lecture du secret. Seul `--apply` enregistre le changement. Arrêtez-vous si le résultat est inattendu. [Détails et intégrité](../README.md#quick-setup).

---

Ce guide décrit une solution confirmée sur un Mac : Touch ID fonctionnait dans Bitwarden pour ordinateur, mais Safari répétait la demande d’accès à `Bitwarden_biometric`. Versions : macOS/Safari 26.5.2, Bitwarden 2026.8.0. Ce n’est pas un correctif officiel ni une solution universelle.

La liste autorisait l’application principale, mais pas `/Applications/Bitwarden.app/Contents/PlugIns/safari.appex`. Seul ce composant signé a été ajouté, en conservant les autres permissions. Cette autorisation est persistante et concerne une donnée sensible. Le code ne lit ni ne modifie le secret et n’autorise pas toutes les applications.

L’utilisateur n’a pas pu sélectionner le composant dans le paquet `.app` via le sélecteur graphique ; cette méthode n’est donc pas présentée comme vérifiée.

1. Quittez Safari avec ⌘Q et conservez votre accès habituel par mot de passe maître.
2. Effectuez les [vérifications des outils Swift Apple et de la signature](../README.md#before-running). Si nécessaire, utilisez uniquement les outils fournis par Apple.
3. Lisez le [code intégral et créez le fichier local](../README.md#review-and-create-the-local-source), sans téléchargement. Gardez la même session Terminal.
4. Exécutez sans `--apply`. Le résultat attendu est `Dry run; unchanged`, avec seulement l’application principale dans la liste actuelle. Arrêtez-vous en présence de plusieurs éléments correspondants, de plusieurs comptes, d’un trousseau personnalisé ou de permissions inattendues.
5. Si vous acceptez la modification, exécutez avec `--apply`. Saisissez le mot de passe Mac/trousseau uniquement dans la fenêtre macOS. Aucun `sudo`. En cas de refus, arrêtez-vous.
6. Après `save_acl=0`, relancez sans `--apply` : les deux chemins et `Already present; no changes` doivent apparaître. Relancez Safari et testez plusieurs verrouillages et déverrouillages.

Pour annuler, dans Trousseaux d’accès → élément concerné → Contrôle d’accès, retirez uniquement l’entrée ajoutée dont le chemin est `safari.appex`, en gardant celle de l’application principale. Cette annulation graphique n’a pas été testée ici. Si les entrées sont impossibles à distinguer, contactez Bitwarden au lieu de supprimer l’élément. Ne publiez aucun mot de passe ni export du trousseau. Traduction assistée par IA, sans relecture indépendante par une personne de langue maternelle ; l’anglais fait référence.
