<div align="center">

# 🔍 Hardware Total Diagnosis

**Um raio-X completo do seu computador em um único arquivo, em texto ou HTML.**

Sem instalar nada. Sem senha de administrador. Sem internet.

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge)
![Sem admin](https://img.shields.io/badge/Admin-n%C3%A3o%20precisa-2EA44F?style=for-the-badge)
![Licença MIT](https://img.shields.io/badge/Licen%C3%A7a-MIT-yellow?style=for-the-badge)

[Como usar](#-como-usar-passo-a-passo) •
[O que é coletado](#-o-que-é-coletado) •
[Privacidade](#-privacidade) •
[Como ler o relatório](#-como-ler-o-relatório) •
[Problemas comuns](#-problemas-comuns) •
[Glossário](#-glossário)

**[🇺🇸 Read in English](#-hardware-total-diagnosis-1)**

</div>

---

## 💡 O que é isto?

É um programa pequeno, de um único arquivo, que **pergunta ao Windows tudo o que ele sabe sobre o hardware** do computador e escreve as respostas em um arquivo de texto ou em uma página HTML, à sua escolha.

Pense nele como a ficha médica do computador: processador, memória, placa de vídeo, discos, portas USB, teclado, mouse, receptores sem fio, drivers e os erros registrados recentemente, tudo em um só lugar.

Esse arquivo serve para:

- 🧑‍🔧 enviar a um suporte técnico sem precisar descrever a máquina;
- 🔎 comparar dois computadores e achar o que há de diferente entre eles;
- 🧩 investigar por que um dispositivo funciona em uma máquina e falha em outra.

### Por que é seguro rodar?

| | |
|:--:|---|
| 👀 | **Só lê informações.** Não altera configurações, não instala e não apaga nada. |
| 🔓 | **Não pede administrador.** Funciona com um usuário comum, como o de um computador de trabalho. |
| 📴 | **Não usa a internet.** Nada é enviado a lugar nenhum. O arquivo fica no seu computador. |
| 📄 | **O código é aberto.** O programa inteiro está em [`Get-HardwareReport.ps1`](Get-HardwareReport.ps1) e pode ser conferido. |

---

## 🚀 Como usar (passo a passo)

Você não precisa saber programar. São cinco passos:

```mermaid
flowchart LR
    A["1. Baixar"] --> B["2. Extrair"]
    B --> C["3. Abrir o PowerShell"]
    C --> D["4. Colar o comando"]
    D --> E["5. Pegar o relatório"]
```

### 1️⃣ Baixe o programa

Nesta página do GitHub, clique no botão verde **`<> Code`** e depois em **Download ZIP**.

### 2️⃣ Extraia o arquivo

Na pasta de Downloads, clique com o botão direito no arquivo `.zip` e escolha **Extrair Tudo...**.

> [!WARNING]
> Não rode o programa de dentro do ZIP sem extrair. Abra a pasta extraída, onde está o arquivo `Get-HardwareReport.ps1`.

### 3️⃣ Abra o PowerShell na pasta

Com a pasta extraída aberta no Explorador de Arquivos:

1. Clique na **barra de endereço**, no alto da janela, onde aparece o caminho da pasta.
2. Apague o que estiver escrito e digite `powershell`.
3. Aperte **Enter**.

Vai abrir uma janela azul ou preta com texto. Esse é o PowerShell, já posicionado na pasta certa.

### 4️⃣ Cole o comando e aperte Enter

Copie a linha abaixo, clique com o **botão direito** dentro da janela do PowerShell para colar e aperte **Enter**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Get-HardwareReport.ps1
```

O programa pergunta o formato do relatório: digite **`TXT`** (texto puro, o padrão ao apertar Enter) ou **`HTML`** (página com menu lateral, resumo e seções recolhíveis, que abre no navegador e funciona sem internet).

Os nomes das etapas vão aparecendo na tela. A coleta costuma levar de alguns segundos a poucos minutos.

> [!NOTE]
> **O que significa `-ExecutionPolicy Bypass`?** O Windows costuma bloquear scripts por padrão. Essa opção libera a execução **somente nesta janela, somente desta vez**. Nenhuma configuração do computador é alterada, e por isso não é preciso ser administrador.

### 5️⃣ Pegue o relatório

Ao terminar, aparece uma mensagem como esta:

```text
Done in 18 s. Report: C:\Users\voce\Downloads\hardwaretotaldiagnosis\HardwareReport_MEUPC_20260115_143022.txt
```

O arquivo fica **na mesma pasta do programa** e abre no Bloco de Notas (`.txt`) ou no navegador (`.html`). Se essa pasta não permitir gravação, ele é salvo na pasta temporária do usuário, e o caminho exato aparece nessa mensagem.

> [!TIP]
> **Vai investigar teclado ou mouse sem fio?** Mexa o mouse e aperte uma tecla logo antes de rodar. Dispositivos sem fio "dormem" para poupar bateria e, nesse estado, aparecem como sem conexão.

---

## 📋 O que é coletado

| Área | O que aparece no relatório |
|---|---|
| 🖥️ **Sistema** | Versão e build do Windows, atualizações instaladas, inicialização rápida |
| 🧬 **Placa-mãe e BIOS** | Fabricante, modelo, versão da BIOS, tipo de firmware, Secure Boot |
| ⚙️ **Processador** | Modelo, núcleos, frequências, memória cache |
| 🧠 **Memória RAM** | Cada módulo: capacidade, velocidade, fabricante e slot |
| 🎮 **Vídeo e som** | Placas de vídeo, drivers, monitores, tipo de conexão, dispositivos de áudio |
| 💾 **Armazenamento** | Discos, partições, unidades e controladoras |
| 🔌 **Portas e sensores** | Slots, conectores, barramentos e sensores disponíveis |
| 🔋 **Energia** | Bateria, plano de energia, suspensão seletiva de USB, o que pode acordar o PC |
| 📶 **Rádios** | Adaptadores de rede, banda e canal do Wi-Fi, Bluetooth |
| 🌳 **Árvore USB** | Mapa de quem está ligado em quem, com a porta física de cada dispositivo |
| ⌨️ **Teclado e mouse** | Dispositivos, drivers, filtros, configurações de acessibilidade |
| 📡 **Receptores Logitech** | Quais dispositivos estão pareados em cada receptor, com modelo, serial e firmware |
| 🕰️ **Histórico** | Dispositivos que já estiveram conectados e não estão mais |
| 🛡️ **Políticas** | Restrições de instalação de dispositivos aplicadas ao computador |
| 🧰 **Software relacionado** | Programas, serviços e processos ligados a drivers e periféricos |
| 🚨 **Problemas e erros** | Dispositivos com falha e eventos de hardware dos últimos 30 dias |

<details>
<summary><b>O que o Windows não entrega sem administrador</b></summary>

<br>

Algumas informações são reservadas pelo Windows a administradores, como a saúde dos discos (SMART), a temperatura e os dados do chip TPM. Esses itens aparecem no relatório como `[unavailable]`, a coleta continua normalmente e **isso não indica defeito**.

</details>

---

## 🔒 Privacidade

O relatório foi pensado para poder ser compartilhado, mas **vale conferir antes de enviar**.

| ✅ Removido automaticamente | ⚠️ Continua no relatório |
|---|---|
| Nome de usuário e dono do computador | Nome do computador |
| Organização e domínio | Serial da BIOS e da placa-mãe |
| Endereços MAC e de Bluetooth | Serial dos discos e dos monitores |
| Nome das redes Wi-Fi | Serial dos dispositivos USB e sem fio |
| Chave e ID do produto Windows | Lista de drivers e de programas relacionados a hardware |

> [!IMPORTANT]
> Se quiser ocultar algum dado, gere o relatório em TXT, que é texto puro: abra no Bloco de Notas, apague o trecho e salve.

---

## 📖 Como ler o relatório

O arquivo é dividido em seções com títulos em inglês, o que facilita o envio a suportes técnicos internacionais. Use **Ctrl+F** no Bloco de Notas, ou o filtro do menu lateral no HTML, para ir direto ao que interessa:

| Procure por | Para ver |
|---|---|
| `TOPOLOGY` | A árvore USB: o que está conectado em cada porta |
| `PAIRING TABLE` | O que está pareado em cada receptor sem fio Logitech |
| `DEVICES WITH PROBLEMS` | Dispositivos com falha segundo o Windows |
| `EVENT LOGS` | Erros de hardware dos últimos 30 dias |
| `MEMORY` | Detalhes da memória RAM |
| `GPU` | Placa de vídeo e monitores |
| `STORAGE` | Discos e partições |

### Exemplo: tabela de pareamento

```text
##### Receiver PID C52B  rev 1211
Firmware             : 12.11.B0032
Paired device count  : 2
Slot 1 : mouse 'Wireless Mouse' wpid=4055 serial=AABBCCDD link=ONLINE (HID++ 4.5)
Slot 2 : keyboard 'K540/K545' wpid=4076 serial=11223344 link=no link now: asleep, off or out of range (error 0x09)
```

Cada `Slot` é uma "vaga" do receptor. Nesse exemplo, ele conhece um mouse e um teclado:

- **`ONLINE`**: o dispositivo respondeu no momento da coleta.
- **`no link now`**: ele está pareado, mas não respondeu. Pode estar dormindo, desligado ou fora de alcance.
- **`(empty or not reported)`**: a vaga está livre ou o receptor não informou o conteúdo.

### Marcadores que aparecem no texto

| Marcador | Significado |
|---|---|
| `[OK]` | O Windows considera que o dispositivo está funcionando |
| `[Error]` ou `[Unknown]` | O Windows detectou problema ou não sabe o estado do dispositivo |
| `[unavailable]` | Informação não disponível, em geral por falta de permissão ou de suporte no computador |
| `[cannot open]` | O Windows não permitiu acesso a esse dispositivo. É comum em chaves de segurança, por exemplo |
| `[SECTION FAILED]` | Aquela seção falhou. As demais continuam normalmente |

### Comparando dois computadores

Gere o relatório em TXT em cada máquina e abra os dois lado a lado. As seções saem sempre na mesma ordem. Para uma comparação automática, rode:

```powershell
code --diff .\relatorio_pc1.txt .\relatorio_pc2.txt
```

Esse comando precisa do [Visual Studio Code](https://code.visualstudio.com/), mas qualquer comparador de textos serve.

---

## 🩺 Problemas comuns

<details>
<summary><b>"A execução de scripts foi desabilitada neste sistema"</b></summary>

<br>

Você provavelmente tentou rodar o arquivo diretamente. Use o comando completo do [passo 4](#-como-usar-passo-a-passo), que inclui `-ExecutionPolicy Bypass`.

</details>

<details>
<summary><b>Continua bloqueado no computador da empresa</b></summary>

<br>

Se a mensagem citar política de grupo ou dizer que o programa foi bloqueado pelo administrador, a restrição foi definida pela TI da empresa. Nesse caso, **peça a liberação à equipe de TI**. O arquivo pode ser mostrado a ela, já que é texto e pode ser lido por inteiro.

</details>

<details>
<summary><b>A tabela de receptores veio como <code>[unavailable]</code></b></summary>

<br>

Alguns computadores corporativos rodam o PowerShell em "modo restrito". O relatório é gerado quase por inteiro, mas sem a tabela de pareamento e sem a lista de dispositivos desconectados. Para confirmar, procure por `Language mode` no início do arquivo: o valor esperado é `FullLanguage`.

</details>

<details>
<summary><b>Meu teclado ou mouse aparece como <code>no link now</code>, mas está funcionando</b></summary>

<br>

Ele provavelmente estava dormindo durante a coleta. Mexa o mouse, aperte uma tecla e rode de novo.

</details>

<details>
<summary><b>Abri o PowerShell, mas ele diz que não encontrou o arquivo</b></summary>

<br>

O PowerShell não está na pasta certa. Repita o [passo 3](#-como-usar-passo-a-passo) a partir da pasta onde o arquivo `Get-HardwareReport.ps1` aparece.

</details>

---

## 📚 Glossário

| Termo | Em palavras simples |
|---|---|
| **PowerShell** | O programa do Windows que executa comandos e scripts. Já vem instalado |
| **Script** | Um arquivo de texto com instruções que o computador executa |
| **Administrador** | Tipo de usuário com permissão para mudar o sistema. Este programa não precisa disso |
| **Driver** | O programa que ensina o Windows a conversar com um dispositivo |
| **Firmware** | O programa gravado dentro do próprio dispositivo |
| **BIOS / UEFI** | O programa da placa-mãe que liga o computador antes do Windows |
| **Receptor** | O pequeno adaptador USB que conversa com o teclado ou mouse sem fio |
| **Pareamento** | O vínculo que faz um receptor reconhecer um dispositivo específico |
| **Hub USB** | Um ponto que divide uma conexão USB em várias. Muitos ficam dentro do próprio PC |
| **HID** | Sigla de *Human Interface Device*, a categoria de teclados, mouses e similares |
| **VID / PID** | Códigos que identificam o fabricante e o modelo de um dispositivo USB. `046D` é o da Logitech |
| **Serial** | O número de identificação de uma peça específica |

---

## 🛠️ Para usuários avançados

| Opção | O que faz |
|---|---|
| `-Format TXT` ou `-Format HTML` | Escolhe o formato sem perguntar |
| `-OutFile <caminho>` | Define onde salvar o relatório. Sem `-Format`, o formato vem da extensão (`.html` gera HTML, qualquer outra gera TXT) |
| `-SelfTest` | Confere a decodificação das respostas dos receptores e encerra, sem gerar relatório |

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Get-HardwareReport.ps1 -OutFile C:\Temp\relatorio.txt
```

### Compatibilidade

| Item | Situação |
|---|---|
| Windows 10 com PowerShell 5.1 e 7 | ✅ Testado com usuário sem administrador |
| Windows 11 | 🟡 Usa os mesmos recursos do Windows, ainda sem teste registrado |
| Receptor Logitech Unifying (`C52B`) | ✅ Testado |
| Receptor Logitech Bolt (`C548`) | 🟡 Implementado, ainda sem teste com o aparelho. Os bytes brutos sempre saem no relatório |
| PowerShell em modo restrito | 🟡 Relatório parcial, sem tabela de pareamento e sem dispositivos desconectados |

---

## 📜 Licença

Distribuído sob a [Licença MIT](LICENSE). © 2026 Marlon Bastida.

---

<div align="center">

# 🔍 Hardware Total Diagnosis

**A complete X-ray of your computer in a single file, as text or HTML.**

Nothing to install. No administrator password. No internet.

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge)
![No admin](https://img.shields.io/badge/Admin-not%20required-2EA44F?style=for-the-badge)
![MIT License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

[How to use](#-how-to-use-step-by-step) •
[What is collected](#-what-is-collected) •
[Privacy](#-privacy) •
[How to read the report](#-how-to-read-the-report) •
[Common problems](#-common-problems) •
[Glossary](#-glossary)

</div>

---

## 💡 What is this?

It is a small, single-file program that **asks Windows everything it knows about the computer's hardware** and writes the answers to a text file or an HTML page, whichever you choose.

Think of it as the computer's medical record: processor, memory, graphics card, disks, USB ports, keyboard, mouse, wireless receivers, drivers and recently logged errors, all in one place.

You can use this file to:

- 🧑‍🔧 send to technical support without having to describe the machine;
- 🔎 compare two computers and find what differs between them;
- 🧩 investigate why a device works on one machine and fails on another.

### Why is it safe to run?

| | |
|:--:|---|
| 👀 | **It only reads information.** It does not change settings, install or delete anything. |
| 🔓 | **It does not ask for administrator rights.** It works with a standard user, such as the one on a work computer. |
| 📴 | **It does not use the internet.** Nothing is sent anywhere. The file stays on your computer. |
| 📄 | **The code is open.** The whole program is in [`Get-HardwareReport.ps1`](Get-HardwareReport.ps1) and can be reviewed. |

---

## 🚀 How to use (step by step)

You do not need to know how to program. There are five steps:

```mermaid
flowchart LR
    A["1. Download"] --> B["2. Extract"]
    B --> C["3. Open PowerShell"]
    C --> D["4. Paste the command"]
    D --> E["5. Get the report"]
```

### 1️⃣ Download the program

On this GitHub page, click the green **`<> Code`** button and then **Download ZIP**.

### 2️⃣ Extract the file

In your Downloads folder, right-click the `.zip` file and choose **Extract All...**.

> [!WARNING]
> Do not run the program from inside the ZIP without extracting it. Open the extracted folder, where the `Get-HardwareReport.ps1` file is.

### 3️⃣ Open PowerShell in the folder

With the extracted folder open in File Explorer:

1. Click the **address bar** at the top of the window, where the folder path is shown.
2. Delete what is written there and type `powershell`.
3. Press **Enter**.

A blue or black window with text will open. That is PowerShell, already in the right folder.

### 4️⃣ Paste the command and press Enter

Copy the line below, **right-click** inside the PowerShell window to paste it, and press **Enter**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Get-HardwareReport.ps1
```

The program asks for the report format: type **`TXT`** (plain text, the default when you press Enter) or **`HTML`** (a page with a side menu, summary and collapsible sections that opens in the browser and works without internet).

The name of each stage appears on the screen as it runs. Collection usually takes from a few seconds to a few minutes.

> [!NOTE]
> **What does `-ExecutionPolicy Bypass` mean?** Windows usually blocks scripts by default. This option allows the script to run **only in this window, only this time**. No computer setting is changed, which is why you do not need to be an administrator.

### 5️⃣ Get the report

When it finishes, a message like this appears:

```text
Done in 18 s. Report: C:\Users\you\Downloads\hardwaretotaldiagnosis\HardwareReport_MYPC_20260115_143022.txt
```

The file is saved **in the same folder as the program** and opens in Notepad (`.txt`) or in the browser (`.html`). If that folder cannot be written to, it is saved in the user's temporary folder, and the exact path appears in this message.

> [!TIP]
> **Investigating a wireless keyboard or mouse?** Move the mouse and press a key right before running it. Wireless devices "sleep" to save battery and, in that state, show up as not connected.

---

## 📋 What is collected

| Area | What appears in the report |
|---|---|
| 🖥️ **System** | Windows version and build, installed updates, fast startup |
| 🧬 **Motherboard and BIOS** | Manufacturer, model, BIOS version, firmware type, Secure Boot |
| ⚙️ **Processor** | Model, cores, frequencies, cache memory |
| 🧠 **RAM** | Each module: capacity, speed, manufacturer and slot |
| 🎮 **Video and sound** | Graphics cards, drivers, monitors, connection type, audio devices |
| 💾 **Storage** | Disks, partitions, drives and controllers |
| 🔌 **Ports and sensors** | Slots, connectors, buses and available sensors |
| 🔋 **Power** | Battery, power plan, USB selective suspend, what can wake the PC |
| 📶 **Radios** | Network adapters, Wi-Fi band and channel, Bluetooth |
| 🌳 **USB tree** | Map of what is connected to what, with the physical port of each device |
| ⌨️ **Keyboard and mouse** | Devices, drivers, filters, accessibility settings |
| 📡 **Logitech receivers** | Which devices are paired with each receiver, with model, serial and firmware |
| 🕰️ **History** | Devices that were once connected and no longer are |
| 🛡️ **Policies** | Device installation restrictions applied to the computer |
| 🧰 **Related software** | Programs, services and processes related to drivers and peripherals |
| 🚨 **Problems and errors** | Failing devices and hardware events from the last 30 days |

<details>
<summary><b>What Windows does not provide without administrator rights</b></summary>

<br>

Windows reserves some information for administrators, such as disk health (SMART), temperature and TPM chip data. These items appear in the report as `[unavailable]`, collection continues normally and **this does not indicate a defect**.

</details>

---

## 🔒 Privacy

The report is designed to be shareable, but **it is worth checking it before sending**.

| ✅ Removed automatically | ⚠️ Stays in the report |
|---|---|
| User name and computer owner | Computer name |
| Organization and domain | BIOS and motherboard serial |
| MAC and Bluetooth addresses | Disk and monitor serials |
| Wi-Fi network names | USB and wireless device serials |
| Windows product key and ID | List of drivers and hardware-related programs |

> [!IMPORTANT]
> To hide any data, generate the report as TXT, which is plain text: open it in Notepad, delete the passage and save.

---

## 📖 How to read the report

The file is divided into sections with English titles, which makes it easy to send to international technical support. Use **Ctrl+F** in Notepad, or the side menu filter in the HTML, to jump straight to what you need:

| Search for | To see |
|---|---|
| `TOPOLOGY` | The USB tree: what is connected to each port |
| `PAIRING TABLE` | What is paired with each Logitech wireless receiver |
| `DEVICES WITH PROBLEMS` | Devices that are failing according to Windows |
| `EVENT LOGS` | Hardware errors from the last 30 days |
| `MEMORY` | RAM details |
| `GPU` | Graphics card and monitors |
| `STORAGE` | Disks and partitions |

### Example: pairing table

```text
##### Receiver PID C52B  rev 1211
Firmware             : 12.11.B0032
Paired device count  : 2
Slot 1 : mouse 'Wireless Mouse' wpid=4055 serial=AABBCCDD link=ONLINE (HID++ 4.5)
Slot 2 : keyboard 'K540/K545' wpid=4076 serial=11223344 link=no link now: asleep, off or out of range (error 0x09)
```

Each `Slot` is a position on the receiver. In this example, it knows one mouse and one keyboard:

- **`ONLINE`**: the device responded at the time of collection.
- **`no link now`**: it is paired but did not respond. It may be asleep, off or out of range.
- **`(empty or not reported)`**: the slot is free or the receiver did not report its contents.

### Markers in the text

| Marker | Meaning |
|---|---|
| `[OK]` | Windows considers the device to be working |
| `[Error]` or `[Unknown]` | Windows detected a problem or does not know the device's state |
| `[unavailable]` | Information not available, usually due to missing permission or lack of support on the computer |
| `[cannot open]` | Windows did not allow access to this device. This is common with security keys, for example |
| `[SECTION FAILED]` | That section failed. The others continue normally |

### Comparing two computers

Generate the report as TXT on each machine and open both side by side. The sections always come out in the same order. For an automatic comparison, run:

```powershell
code --diff .\report_pc1.txt .\report_pc2.txt
```

This command requires [Visual Studio Code](https://code.visualstudio.com/), but any text comparison tool will do.

---

## 🩺 Common problems

<details>
<summary><b>"Running scripts is disabled on this system"</b></summary>

<br>

You probably tried to run the file directly. Use the full command from [step 4](#-how-to-use-step-by-step), which includes `-ExecutionPolicy Bypass`.

</details>

<details>
<summary><b>It is still blocked on a company computer</b></summary>

<br>

If the message mentions group policy or says the program was blocked by the administrator, the restriction was set by the company's IT team. In that case, **ask the IT team to allow it**. You can show them the file, since it is text and can be read in full.

</details>

<details>
<summary><b>The receiver table came back as <code>[unavailable]</code></b></summary>

<br>

Some corporate computers run PowerShell in "constrained mode". The report is generated almost entirely, but without the pairing table and the list of disconnected devices. To confirm, search for `Language mode` at the start of the file: the expected value is `FullLanguage`.

</details>

<details>
<summary><b>My keyboard or mouse shows as <code>no link now</code>, but it is working</b></summary>

<br>

It was probably asleep during collection. Move the mouse, press a key and run it again.

</details>

<details>
<summary><b>I opened PowerShell, but it says it cannot find the file</b></summary>

<br>

PowerShell is not in the right folder. Repeat [step 3](#-how-to-use-step-by-step) from the folder where the `Get-HardwareReport.ps1` file appears.

</details>

---

## 📚 Glossary

| Term | In plain words |
|---|---|
| **PowerShell** | The Windows program that runs commands and scripts. It comes preinstalled |
| **Script** | A text file with instructions the computer carries out |
| **Administrator** | A type of user allowed to change the system. This program does not need it |
| **Driver** | The program that teaches Windows how to talk to a device |
| **Firmware** | The program stored inside the device itself |
| **BIOS / UEFI** | The motherboard program that starts the computer before Windows |
| **Receiver** | The small USB adapter that talks to the wireless keyboard or mouse |
| **Pairing** | The link that makes a receiver recognize a specific device |
| **USB hub** | A point that splits one USB connection into several. Many are inside the PC itself |
| **HID** | Short for *Human Interface Device*, the category of keyboards, mice and similar devices |
| **VID / PID** | Codes that identify the manufacturer and model of a USB device. `046D` is Logitech's |
| **Serial** | The identification number of one specific unit |

---

## 🛠️ For advanced users

| Option | What it does |
|---|---|
| `-Format TXT` or `-Format HTML` | Picks the format without asking |
| `-OutFile <path>` | Sets where the report is saved. Without `-Format`, the format comes from the extension (`.html` produces HTML, anything else TXT) |
| `-SelfTest` | Checks the decoding of receiver replies and exits without generating a report |

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Get-HardwareReport.ps1 -OutFile C:\Temp\report.txt
```

### Compatibility

| Item | Status |
|---|---|
| Windows 10 with PowerShell 5.1 and 7 | ✅ Tested with a non-administrator user |
| Windows 11 | 🟡 Uses the same Windows features, no recorded test yet |
| Logitech Unifying receiver (`C52B`) | ✅ Tested |
| Logitech Bolt receiver (`C548`) | 🟡 Implemented, not yet tested with the device. The raw bytes always appear in the report |
| PowerShell in constrained mode | 🟡 Partial report, without the pairing table and disconnected devices |

---

## 📜 License

Distributed under the [MIT License](LICENSE). © 2026 Marlon Bastida.
