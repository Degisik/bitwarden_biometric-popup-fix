# Bitwarden Safari Touch ID: permissão específica do Acesso às Chaves

[English](../README.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [हिन्दी](README.hi.md) · [Español](README.es.md) · [العربية](README.ar.md) · [Français](README.fr.md) · [বাংলা](README.bn.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Bahasa Indonesia](README.id.md)

## Configuração rápida

Encerre o Safari (⌘Q). [Leia o código](../fix.command) e [baixe fix.command](https://github.com/Degisik/bitwarden_biometric-popup-fix/raw/refs/heads/main/fix.command) em Downloads. Requer Swift da Apple; se faltar, use `xcode-select --install`. Apenas para uma conta e a configuração padrão de chaves.

Primeiro, apenas verificar:

```sh
cd ~/Downloads
bash fix.command
```

Se a prévia adicionar somente o componente Safari ao aplicativo desktop:

```sh
bash fix.command --apply
```

Autorize somente na janela do macOS. Após `save_acl=0`, abra o Safari e teste Touch ID. O script é texto legível, sem rede, `sudo` ou leitura do segredo. Só `--apply` grava a permissão. Pare diante de resultados inesperados. [Detalhes e integridade](../README.md#quick-setup).

---

Este guia documenta uma solução confirmada em um Mac: Touch ID funcionava no Bitwarden para desktop, mas o Safari repetia o pedido de acesso a `Bitwarden_biometric`. Versões: macOS/Safari 26.5.2 e Bitwarden 2026.8.0. Não é uma correção oficial nem universal.

A lista autorizava o aplicativo desktop, mas não `/Applications/Bitwarden.app/Contents/PlugIns/safari.appex`. Adicionamos somente esse componente assinado e preservamos as outras permissões. Isso concede acesso persistente a um item sensível. O código não lê nem altera o segredo e não autoriza todos os aplicativos.

O usuário não conseguiu selecionar o componente dentro do pacote `.app` pela interface gráfica. Esse caminho não é apresentado como verificado.

1. Encerre o Safari com ⌘Q e mantenha seu acesso normal com a senha mestra.
2. Faça as [verificações das ferramentas Swift da Apple e da assinatura](../README.md#before-running). Se faltarem ferramentas, utilize apenas as fornecidas pela Apple.
3. Leia o [código completo e crie o arquivo local](../README.md#review-and-create-the-local-source). Não há download de código; mantenha a mesma sessão do Terminal.
4. Execute primeiro sem `--apply`. Espere `Dry run; unchanged`, com apenas o aplicativo desktop na lista atual. Pare se houver vários itens correspondentes, várias contas, configuração personalizada de chaves ou permissões inesperadas.
5. Se aceitar a alteração, execute com `--apply`. Digite a senha do Mac/chaves somente na janela do macOS. Não é necessário `sudo`. Se a autorização falhar, pare.
6. Após `save_acl=0`, execute novamente sem `--apply`: devem aparecer os dois caminhos e `Already present; no changes`. Reabra o Safari e teste vários bloqueios e desbloqueios.

Para desfazer, em Acesso às Chaves → item afetado → Controle de Acesso, remova somente a entrada adicionada cujo caminho é `safari.appex`, mantendo a do desktop. Essa reversão pela interface não foi testada aqui. Se não conseguir distinguir as entradas, procure o suporte do Bitwarden em vez de excluir o item. Não publique senhas nem dumps das chaves. Tradução assistida por IA, sem revisão independente por falante nativo; o inglês é a referência técnica.
