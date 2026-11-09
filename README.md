# hardwaretotaldiagnosis

Relatorio completo de hardware para Windows 10/11, em PowerShell, sem precisar de administrador.

```
powershell -NoProfile -ExecutionPolicy Bypass -File .\Get-HardwareReport.ps1
```

Gera `HardwareReport_<COMPUTADOR>_<data>.txt` na pasta do script (ou em `%TEMP%` se a pasta for somente leitura).
O que o Windows negar a um usuario comum fica registrado como `[unavailable]` e a coleta continua.

Check de decodificacao: `.\Get-HardwareReport.ps1 -SelfTest`
