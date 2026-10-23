# DiLinkDesk

Fork do [RustDesk](https://github.com/rustdesk/rustdesk) Android ajustado para o
BYD Dolphin GS (DiLink 3.0, Android 10, arm64). O carro entra como **cliente**
para controlar o PC, não como host.

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
desligado em **Configurações → Configurações de exibição → Modo carro**.

Com o modo carro ligado:

- navegação lateral (`NavigationRail`) em vez da barra inferior, aproveitando a
  tela larga;
- texto e teclas de ajuda maiores;
- **teclado do carro**: painel QWERTY embutido na sessão, com Ctrl, Alt, Shift,
  Win, setas, Enter, Backspace, Tab e Esc, sem depender do teclado do sistema;
- tela cheia imersiva e tela sempre ligada;
- sessão segue em paisagem (o manifesto já força `sensorLandscape`).

O botão de teclado na barra da sessão abre o teclado do carro. O botão de
teclado dentro do painel abre o teclado do Android para acentos e IME.

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
