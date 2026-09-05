# Bitwarden Safari Touch ID: permiso específico del Llavero

[English](../README.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [हिन्दी](README.hi.md) · [Español](README.es.md) · [العربية](README.ar.md) · [Français](README.fr.md) · [বাংলা](README.bn.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Bahasa Indonesia](README.id.md)

## Instalador guiado

[ZIP](https://github.com/Degisik/bitwarden_biometric-popup-fix/releases/download/v1.0.0/bitwarden-biometric-installer-v1.0.0.zip) · [Source](../install.command) · [SHA-256](../INSTALLER-SHA256SUMS)

Extrae el ZIP, lee el código, cierra Safari y abre `install.command`. Primero comprueba; para aplicar debes escribir `APPLY`. No requiere `sudo`; necesita Swift de Apple. Si macOS lo bloquea, no desactives las protecciones; usa el método manual o solicita ayuda.

## Configuración rápida

Cierra Safari (⌘Q). [Lee el código](../fix.command) y [descarga fix.command](https://github.com/Degisik/bitwarden_biometric-popup-fix/raw/refs/heads/main/fix.command) en Descargas. Requiere Swift de Apple; si falta, usa `xcode-select --install`. Solo para una cuenta y el Llavero predeterminado.

Primero, solo comprobar:

```sh
cd ~/Downloads
bash fix.command
```

Si la vista previa añade únicamente el componente Safari a la aplicación de escritorio:

```sh
bash fix.command --apply
```

Autoriza solo en el diálogo de macOS. Tras `save_acl=0`, abre Safari y prueba Touch ID. El script es texto legible, sin red, `sudo` ni lectura del secreto. Solo `--apply` guarda el permiso. Ante resultados inesperados, detente. [Detalles e integridad](../README.md#quick-setup).

---

Esta guía describe una solución que funcionó en un Mac donde Touch ID abría Bitwarden de escritorio, pero Safari repetía la solicitud de acceso a `Bitwarden_biometric`. Confirmada por el usuario con macOS/Safari 26.5.2 y Bitwarden 2026.8.0; no es una corrección oficial ni universal.

La lista de acceso incluía la aplicación de escritorio, pero no `/Applications/Bitwarden.app/Contents/PlugIns/safari.appex`. Añadir únicamente ese componente firmado conservó los demás permisos. Es un permiso persistente sobre un elemento sensible. El código no lee ni cambia el secreto y no permite el acceso a todas las aplicaciones.

El usuario no pudo seleccionar el componente dentro de `.app` mediante el selector gráfico. No presentamos esa vía como verificada.

1. Cierra Safari con ⌘Q y conserva el acceso normal mediante tu contraseña maestra.
2. Sigue las [comprobaciones de Swift de Apple y de firma](../README.md#before-running). Si faltan herramientas, usa únicamente las de Apple.
3. Lee el [código completo y crea el archivo local](../README.md#review-and-create-the-local-source). No se descarga código; usa la misma sesión de Terminal.
4. Ejecuta primero sin `--apply`: debe terminar con `Dry run; unchanged` y mostrar solo la aplicación de escritorio en la lista actual. Detente si hay varios elementos coincidentes, cuentas, llaveros personalizados o permisos inesperados.
5. Solo si aceptas el cambio, ejecuta con `--apply`. Introduce la contraseña de Mac/Llavero únicamente en el diálogo de macOS. No uses `sudo`. Si la autorización falla, detente.
6. Después de `save_acl=0`, vuelve a ejecutar sin `--apply`: deben aparecer ambas rutas y `Already present; no changes`. Reinicia Safari y prueba varios bloqueos y desbloqueos.

Para revertir, en Acceso a Llaveros → elemento afectado → Control de acceso, elimina únicamente la entrada añadida cuya ruta es `safari.appex`, conservando la de escritorio. Esta reversión gráfica no se ha probado aquí. Si no puedes distinguirlas, consulta al soporte de Bitwarden; no borres el elemento. No publiques contraseñas ni volcados del Llavero. Traducción asistida por IA, sin revisión independiente de un hablante nativo; el inglés es la referencia técnica.
