# DiLinkDesk

Fork do [RustDesk](https://github.com/rustdesk/rustdesk) Android ajustado para o
BYD Dolphin GS (DiLink 3.0, Android 10, arm64). O carro entra como **cliente**
para controlar o PC e também como **host**, para o PC acessar a multimídia do
carro.

## Download

O APK mais recente é publicado em:

<https://github.com/johnnykennedycr/DiLinkDesk/releases/download/dilink-latest/DiLinkDesk-arm64.apk>

- Pacote: `com.dilinkdesk.rustdesk`
- ABI: `arm64-v8a`
- `targetSdkVersion` 33 (o instalador do DiLink rejeita valores maiores)
- Assinatura estável gerada pelo CI, então atualizações instalam por cima

## Instalação no DiLink

1. Copie o APK para um pendrive e abra pelo gerenciador de arquivos do carro,
   ou use ADB:

   ```
   adb connect 192.168.10.10:5555
   adb install -r DiLinkDesk-arm64.apk
   ```

2. A senha mestra do modo desenvolvedor do DiLink é `BYD6125F`.

## Modo carro

O modo carro é ativado automaticamente quando o aparelho se identifica como
BYD/DiLink (`Build.MANUFACTURER`, `BRAND` ou `MODEL`). Também pode ser ligado e
desligado em **Configurações → Configurações de exibição → Modo carro**. Na
mesma tela, a opção **Tela cheia** esconde as barras superior e inferior do
DiLink e vem ligada por padrão.

Com o modo carro ligado:

- navegação lateral (`NavigationRail`) em vez da barra inferior, aproveitando a
  tela larga;
- texto e teclas de ajuda maiores;
- **teclado do carro**: painel QWERTY embutido na sessão, com Ctrl, Alt, Shift,
  Win, setas, Enter, Backspace, Tab e Esc, sem depender do teclado do sistema;
- tela sempre ligada;
- sessão segue em paisagem (o manifesto já força `sensorLandscape`).

Com **Tela cheia** ligada, as barras superior e inferior do DiLink ficam
escondidas em todas as telas do app e só reaparecem temporariamente ao deslizar
a partir da borda. Desligue a opção para mostrá-las novamente.

O botão de teclado na barra da sessão abre o teclado do carro. O botão de
teclado dentro do painel abre o teclado do Android para acentos e IME.

## Acessar a multimídia do carro pelo PC

O DiLinkDesk também funciona como **host**: com o compartilhamento ativo, o PC
abre o RustDesk, conecta ao ID do carro e controla a tela e o toque da
multimídia.

1. No carro, abra a aba **Compartilhar Tela** e toque em **Iniciar serviço**.
   Autorize a captura de tela no aviso do Android.
2. Toque em **Ativar controle remoto** e habilite o **RustDesk Input** em
   Acessibilidade. Sem esse serviço o PC vê a tela, mas não consegue tocar.
3. Anote o **ID** e a **senha** mostrados no cartão **Acessar esta multimídia pelo PC**.
4. No PC, abra o RustDesk, digite o ID do carro, clique em **Conectar** e informe
   a senha.
5. Durante a sessão, no PC: o **botão do meio** do mouse abre a tela inicial do
   DiLink e, mantido pressionado, abre os recentes. O **botão lateral de voltar**
   (botão 4) aciona **Voltar**. O **botão direito** faz uma pressão longa no
   ponto do cursor.

O compartilhamento continua com o app em segundo plano (notificação
"RustDesk Service"), então dá para abrir o rádio ou o player de vídeo no carro
enquanto o PC controla. Para encerrar, volte ao app e toque em **Parar serviço**.

O áudio do carro pode ser compartilhado em **Permissões → Captura de áudio**
(Android 10 ou superior). Apps protegidos por DRM podem aparecer pretos; é uma
restrição do sistema.

### Senha permanente

A senha de uso único muda a cada início do serviço. Para não precisar voltar ao
carro para lê-la, toque em **Configurar senha permanente** no cartão e defina uma
senha fixa. Depois use essa senha no PC. A senha permanente fica salva apenas no
carro.

### Se a tela de acessibilidade não abrir

Alguns firmwares do DiLink escondem a tela de acessibilidade. Com ADB habilitado
no carro, ative o serviço manualmente:

```
adb shell settings put secure enabled_accessibility_services com.dilinkdesk.rustdesk/com.carriez.flutter_hbb.InputService
adb shell settings put secure accessibility_enabled 1
```

O comando substitui a lista de serviços de acessibilidade ativos; use apenas se
não houver outros serviços configurados.

## Build

Somente o workflow **DiLinkDesk APK** está ativo. Ele:

1. gera o bridge do Flutter (Flutter 3.22.3 + flutter_rust_bridge 1.80.1);
2. compila as dependências vcpkg para `arm64-v8a`;
3. compila `librustdesk.so` com Rust 1.75 + cargo-ndk;
4. monta e assina o APK com os secrets `ANDROID_KEYSTORE_BASE64`,
   `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` e `ANDROID_KEY_PASSWORD`;
5. publica na release `dilink-latest`.

Os demais workflows do upstream estão desativados neste fork.

## Notas

- `flutter/lib/generated_bridge.dart`, `src/bridge_generated*.rs` são gerados no
  CI e não são versionados.
- O keystore de assinatura nunca é commitado; fica apenas nos secrets do
  repositório.
