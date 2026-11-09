<div align="center">

# 🔍 Hardware Total Diagnosis

**Um raio-X completo do seu computador em um único arquivo de texto.**

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

</div>

---

## 💡 O que é isto?

É um programa pequeno, de um único arquivo, que **pergunta ao Windows tudo o que ele sabe sobre o hardware** do computador e escreve as respostas em um arquivo de texto.

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

Os nomes das etapas vão aparecendo na tela. A coleta costuma levar de alguns segundos a poucos minutos.

> [!NOTE]
> **O que significa `-ExecutionPolicy Bypass`?** O Windows costuma bloquear scripts por padrão. Essa opção libera a execução **somente nesta janela, somente desta vez**. Nenhuma configuração do computador é alterada, e por isso não é preciso ser administrador.

### 5️⃣ Pegue o relatório

Ao terminar, aparece uma mensagem como esta:

```text
Done in 18 s. Report: C:\Users\voce\Downloads\hardwaretotaldiagnosis\HardwareReport_MEUPC_20260115_143022.txt
```

O arquivo fica **na mesma pasta do programa** e abre no Bloco de Notas. Se essa pasta não permitir gravação, ele é salvo na pasta temporária do usuário, e o caminho exato aparece nessa mensagem.

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
> O arquivo é texto puro. Se quiser ocultar algum dado, abra no Bloco de Notas, apague o trecho e salve.

---

## 📖 Como ler o relatório

O arquivo é dividido em seções com títulos em inglês, o que facilita o envio a suportes técnicos internacionais. Use **Ctrl+F** no Bloco de Notas para ir direto ao que interessa:

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

Gere o relatório em cada máquina e abra os dois lado a lado. As seções saem sempre na mesma ordem. Para uma comparação automática, rode:

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
| `-OutFile <caminho>` | Define onde salvar o relatório |
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
