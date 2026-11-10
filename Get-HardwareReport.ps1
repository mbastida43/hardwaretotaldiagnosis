<#
.SYNOPSIS
    Read-only, full hardware report for Windows 10/11. Does not need administrator rights.
.DESCRIPTION
    Writes a plain-text or a self-contained HTML report. Anything Windows refuses to a standard user is recorded
    in the report as unavailable and the run continues.
    The only device I/O is HID++ read/ping queries to Logitech receivers; nothing is changed.
.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\Get-HardwareReport.ps1
#>
[CmdletBinding()]
param([string]$OutFile, [ValidateSet('TXT', 'HTML')][string]$Format, [switch]$SelfTest)

$ErrorActionPreference = 'Continue'

# Personal or network identity: never written to the report.
$DropAlways = '^(PS(Path|ParentPath|ChildName|Drive|Provider|ComputerName)|Cim.*|UserName|PrimaryOwner.*|Registered(User|Owner|Organization)|Organization|InstalledBy|ProductId|DigitalProductId\d?|Domain|Workgroup|DNSHostName|MACAddress|PermanentAddress|NetworkAddresses|OEMLogoBitmap|SupportContactDescription)$'

function Props {
    param([Parameter(ValueFromPipeline)]$Item, [string[]]$Drop)
    process {
        foreach ($p in $Item.PSObject.Properties) {
            if ($p.Name -match $DropAlways -or $Drop -contains $p.Name) { continue }
            $v = $p.Value
            if ($null -eq $v -or "$v" -eq '') { continue }
            if ($v -is [byte[]]) {
                $v = (($v | Select-Object -First 64 | ForEach-Object { '{0:X2}' -f $_ }) -join ' ')
            } elseif ($v -is [array]) { $v = $v -join ', ' }
            '{0,-36}: {1}' -f $p.Name, $v
        }
        ''
    }
}

function Cim {
    param([string]$Class, [string]$Ns = 'root/cimv2', [string]$Filter, [string[]]$Drop)
    "--- $Class ($Ns) ---"
    $a = @{ ClassName = $Class; Namespace = $Ns; ErrorAction = 'Stop' }
    if ($Filter) { $a.Filter = $Filter }
    try { $r = @(Get-CimInstance @a) } catch { "[unavailable] $($_.Exception.Message)"; ''; return }
    if (-not $r.Count) { '(no instances)'; ''; return }
    $r | Props -Drop $Drop
}

function Reg {
    param([string]$Path)
    "--- $Path ---"
    if (-not (Test-Path -LiteralPath $Path)) { '(not present)'; ''; return }
    try { Get-ItemProperty -LiteralPath $Path -ErrorAction Stop | Props }
    catch { "[unavailable] $($_.Exception.Message)"; '' }
}

function Native {
    param([string]$Label, [scriptblock]$Command)
    "--- $Label ---"
    try { & $Command 2>&1 | ForEach-Object { "$_" } } catch { "[unavailable] $($_.Exception.Message)" }
    ''
}

function Tbl { param([Parameter(ValueFromPipeline)]$Row) end { $input | Format-Table -AutoSize -Wrap | Out-String -Width 400 } }

function Section {
    param([string]$Title, [scriptblock]$Body)
    Write-Host "  $Title"
    $line = '=' * 100
    $text = try { & $Body 2>&1 | Out-String -Width 400 } catch { "[SECTION FAILED] $($_.Exception.Message)" }
    if ($Format -eq 'HTML') {
        $id = "s$($script:htmlNav.Count)"
        $html = ConvertTo-HtmlBody $text
        $flag = if ($html -match 'class="bad"') { ' class="flag"' }
        $script:htmlNav += "<a href=`"#$id`"$flag>$(Esc $Title)</a>"
        $script:htmlMain += "<details id=`"$id`"><summary$flag>$(Esc $Title)</summary><div class=`"body`">$html</div></details>"
        return
    }
    "`r`n$line`r`n$Title`r`n$line`r`n$text" | Out-File -FilePath $OutFile -Append -Encoding utf8
}

# String operators only: System.Web and similar types are refused in constrained language mode.
function Esc { param([string]$s) $s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' }

function Mark {
    param([string]$s)
    $s -creplace '\[OK\]|\bONLINE\b', '<b class="ok">$0</b>' -creplace '\[(unavailable|cannot open[^\]]*|Unknown)\]|\bno link now\b', '<b class="w">$0</b>' -creplace '\[(Error|Degraded|SECTION FAILED)\]', '<b class="bad">$0</b>'
}

# Turns the text of one section into HTML: headings, key/value lists, and <pre> for everything else (tables, trees).
function ConvertTo-HtmlBody {
    param([string]$Text)
    $close = @{ '' = ''; dl = '</dl>'; pre = '</pre>' }
    $kind = ''
    $out = foreach ($line in ($Text -split '\r?\n')) {
        $line = $line.TrimEnd()
        if (-not $line) { $new = if ($kind -eq 'pre') { 'pre' } else { '' }; $row = '' }
        elseif ($line -match '^--- (.*[^-\s].*) ---$') { $new = ''; $row = "<h3>$(Esc $Matches[1])</h3>" }
        elseif ($line -match '^##### (.+)$') { $new = ''; $row = "<h4>$(Esc $Matches[1])</h4>" }
        elseif ($line -match '^([^\s:\[][^:]{0,47}?)\s*: (.*)$') { $new = 'dl'; $row = "<dt>$(Esc $Matches[1])</dt><dd>$(Mark (Esc $Matches[2]))</dd>" }
        else { $new = 'pre'; $row = Mark (Esc $line) }
        if ($new -ne $kind) { $close[$kind]; if ($new) { "<$new>" }; $kind = $new }
        $row
    }
    (@($out) + $close[$kind]) -join "`n" -replace '<pre>\n+', '<pre>' -replace '\n+</pre>', '</pre>' -replace '<pre></pre>', ''
}

function Hex { param($Bytes) if ($null -eq $Bytes) { '(no reply)' } else { ($Bytes | ForEach-Object { '{0:X2}' -f $_ }) -join ' ' } }

function HexJoin { param($Bytes, [int[]]$At) -join ($At | ForEach-Object { '{0:X2}' -f $Bytes[$_] }) }

function Text { param($Bytes, [int]$Start, [int]$Len) if ($Len -le 0) { return '' } -join ($Bytes[$Start..($Start + $Len - 1)] | ForEach-Object { [char]$_ }) }

function KindName {
    param([int]$Code)
    $k = @{ 0 = 'unknown'; 1 = 'keyboard'; 2 = 'mouse'; 3 = 'numpad'; 4 = 'presenter'; 7 = 'remote'; 8 = 'trackball'; 9 = 'touchpad'; 10 = 'tablet'; 11 = 'gamepad'; 12 = 'joystick'; 13 = 'headset' }
    if ($k.ContainsKey($Code)) { $k[$Code] } else { "kind_$Code" }
}

function IsOk { param($Reply) $null -ne $Reply -and $Reply[2] -ne 0x8F }

# Reply layouts are byte offsets into the full HID++ message (report id at 0).
function Read-Slot {
    param([bool]$Bolt, $Pair, $Ext, $Name)
    $s = [ordered]@{ Paired = (IsOk $Pair); WirelessPid = ''; Kind = ''; Serial = ''; Name = '' }
    if (-not $s.Paired) { return [pscustomobject]$s }
    if ($Bolt) {
        $s.WirelessPid = HexJoin $Pair 7, 6
        $s.Kind = KindName ($Pair[5] -band 0x0F)
        $s.Serial = HexJoin $Pair 8, 9, 10, 11
        if (IsOk $Name) { $s.Name = Text $Name 7 ([Math]::Min(13, [int]$Name[6])) }
    } else {
        $s.WirelessPid = HexJoin $Pair 7, 8
        $s.Kind = KindName ($Pair[11] -band 0x0F)
        if (IsOk $Ext) { $s.Serial = HexJoin $Ext 5, 6, 7, 8 }
        if (IsOk $Name) { $s.Name = Text $Name 6 ([Math]::Min(14, [int]$Name[5])) }
    }
    [pscustomobject]$s
}

function Read-Ping {
    param($Reply)
    if ($null -eq $Reply) { return 'no reply' }
    if ($Reply[2] -eq 0x00) { return "ONLINE (HID++ $($Reply[4]).$($Reply[5]))" }
    if ($Reply[2] -eq 0x8F -and $Reply[5] -eq 0x01) { return 'ONLINE (HID++ 1.0)' }
    if ($Reply[2] -eq 0x8F) { return ('no link now: asleep, off or out of range (error 0x{0:X2})' -f $Reply[5]) }
    'unexpected reply'
}

# Applies one key press to a menu: returns the new 0-based position and whether the choice is confirmed.
function Step-Menu {
    param([int]$At, [int]$Count, [int]$Key, [string]$Char)
    if ($Char -match '^[1-9]$' -and [int]$Char -le $Count) { return ([int]$Char - 1), $true }
    if ($Key -eq 38) { $At = ($At + $Count - 1) % $Count }
    elseif ($Key -eq 40) { $At = ($At + 1) % $Count }
    $At, ($Key -eq 13)
}

# Throws where nobody can answer (redirected input, -NonInteractive); the caller falls back.
function Select-Format {
    if ([Console]::IsInputRedirected -or [Environment]::GetCommandLineArgs() -match '^[-/]noni') { throw 'no console' }
    $ui = $Host.UI.RawUI
    $names = 'TXT', 'HTML'
    $hints = 'plain text, opens in Notepad', 'page with side menu and summary, opens in the browser'
    $at = 0
    $draw = {
        foreach ($i in 0..($names.Count - 1)) {
            $color = if ($i -eq $at) { @{ ForegroundColor = 'Cyan' } } else { @{} }
            Write-Host ('{0} {1}. {2,-5} {3}' -f $(if ($i -eq $at) { '>' } else { ' ' }), ($i + 1), $names[$i], $hints[$i]) @color
        }
    }
    Write-Host 'Report format (Up/Down + Enter, or press the number):'
    & $draw
    # Read after drawing: the window may have scrolled.
    $origin = $ui.CursorPosition
    $origin.Y -= $names.Count
    do {
        $key = $ui.ReadKey('NoEcho,IncludeKeyDown')
        $at, $done = Step-Menu $at $names.Count $key.VirtualKeyCode "$($key.Character)"
        $ui.CursorPosition = $origin
        & $draw
    } until ($done)
    $names[$at]
}

if ($SelfTest) {
    # Reply layout captured from a Unifying receiver (C52B), serial replaced.
    $pair = [byte[]](0x11,0xFF,0x83,0xB5,0x20,0x07,0x08,0x40,0x55,0x04,0x02,0x02,0x0C,0,0,0,0,0,0,0)
    $ext  = [byte[]](0x11,0xFF,0x83,0xB5,0x30,0xAA,0xBB,0xCC,0xDD,0x04,0,0,0,0x01,0,0,0,0,0,0)
    $name = [byte[]](0x11,0xFF,0x83,0xB5,0x40,0x0E,0x57,0x69,0x72,0x65,0x6C,0x65,0x73,0x73,0x20,0x4D,0x6F,0x75,0x73,0x65)
    $slot = Read-Slot $false $pair $ext $name
    $checks = @(
        ($slot.Paired -eq $true),
        ($slot.WirelessPid -eq '4055'),
        ($slot.Kind -eq 'mouse'),
        ($slot.Serial -eq 'AABBCCDD'),
        ($slot.Name -eq 'Wireless Mouse'),
        (-not (Read-Slot $false ([byte[]](0x10,0xFF,0x8F,0x83,0xB5,0x03,0)) $null $null).Paired),
        ((Read-Ping ([byte[]](0x10,1,0,0x1D,4,5,0x5A))) -eq 'ONLINE (HID++ 4.5)'),
        ((Read-Ping ([byte[]](0x10,1,0x8F,0,0x1D,1,0))) -eq 'ONLINE (HID++ 1.0)'),
        ((Read-Ping ([byte[]](0x10,1,0x8F,0,0x1D,9,0))) -like 'no link now*'),
        ((Read-Ping $null) -eq 'no reply')
    )
    $h = ConvertTo-HtmlBody "--- Win32_BIOS (root/cimv2) ---`r`nName     : A<i>&`r`n`r`n[unavailable] denied: x`r`n--- --- ---`r`n  [OK] ONLINE Online`r`n"
    $checks += @(
        ($h -like '*<h3>Win32_BIOS (root/cimv2)</h3>*'),
        ($h -like '*<dl>*<dt>Name</dt><dd>A&lt;i&gt;&amp;</dd>*</dl>*'),
        ($h -like '*<pre><b class="w">`[unavailable`]</b> denied: x*'),
        ($h -like '*--- --- ---*'),
        ($h -clike '*<b class="ok">`[OK`]</b> <b class="ok">ONLINE</b> Online</pre>*'),
        ($h -notlike '*<i>*'),
        ((Step-Menu 0 2 40 '') -join ',' -eq '1,False'),
        ((Step-Menu 0 2 38 '') -join ',' -eq '1,False'),
        ((Step-Menu 1 2 40 '') -join ',' -eq '0,False'),
        ((Step-Menu 1 2 13 "`r") -join ',' -eq '1,True'),
        ((Step-Menu 0 2 50 '2') -join ',' -eq '1,True'),
        ((Step-Menu 0 2 51 '3') -join ',' -eq '0,False')
    )
    if ($checks -contains $false) { Write-Host "SELFTEST FAILED: $($checks -join ',')"; exit 1 }
    Write-Host 'SELFTEST OK'; exit 0
}

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
if (-not $Format) {
    if ($OutFile) { $Format = if ($OutFile -match '\.html?$') { 'HTML' } else { 'TXT' } }
    else {
        try { $Format = Select-Format }
        catch {
            # Read-Host throws under -NonInteractive; TXT is the default there too.
            try { do { $answer = "$(Read-Host 'Report format - type TXT or HTML (Enter = TXT)')".Trim() } until ($answer -in '', 'TXT', 'HTML') } catch { $answer = '' }
            $Format = if ($answer) { $answer } else { 'TXT' }
        }
    }
}
$htmlNav = @(); $htmlMain = @()
$fileName = "HardwareReport_${env:COMPUTERNAME}_$stamp.$($Format.ToLower())"
if (-not $OutFile) { $OutFile = Join-Path $PSScriptRoot $fileName }
try { "HARDWARE REPORT" | Out-File -FilePath $OutFile -Encoding utf8 -ErrorAction Stop }
catch { $OutFile = Join-Path $env:TEMP $fileName; "HARDWARE REPORT" | Out-File -FilePath $OutFile -Encoding utf8 }

$started = Get-Date
Write-Host "Collecting (usually 1-3 minutes):"

Section 'RUN CONTEXT' {
    "Generated            : $($started.ToString('yyyy-MM-dd HH:mm:ss zzz'))"
    "Computer             : $env:COMPUTERNAME"
    "PowerShell           : $($PSVersionTable.PSVersion) ($($PSVersionTable.PSEdition))"
    "Language mode        : $($ExecutionContext.SessionState.LanguageMode)"
    "Elevated             : $([bool](whoami /groups | Select-String 'S-1-16-12288'))"
    "Architecture         : $env:PROCESSOR_ARCHITECTURE"
    ''
    Get-ExecutionPolicy -List | Tbl
}

Section 'OPERATING SYSTEM' {
    Cim Win32_OperatingSystem -Drop SerialNumber
    Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
    Cim Win32_QuickFixEngineering
}

Section 'SYSTEM, BIOS, MOTHERBOARD, CHASSIS' {
    Cim Win32_ComputerSystem
    Cim Win32_ComputerSystemProduct
    Cim Win32_BIOS
    Cim Win32_BaseBoard
    Cim Win32_SystemEnclosure
    'Firmware type (PEFirmwareType 1=BIOS 2=UEFI) and Secure Boot state:'
    Reg 'HKLM:\SYSTEM\CurrentControlSet\Control'
    Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State'
}

Section 'CPU' {
    Cim Win32_Processor
    Cim Win32_CacheMemory
}

Section 'MEMORY' {
    Cim Win32_PhysicalMemoryArray
    Cim Win32_PhysicalMemory
    Cim Win32_PageFileUsage
    Cim Win32_PageFileSetting
}

Section 'GPU, DISPLAYS, AUDIO' {
    Cim Win32_VideoController
    $video = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    Get-ChildItem -LiteralPath $video -ErrorAction SilentlyContinue |
        Where-Object PSChildName -match '^\d{4}$' | ForEach-Object { Reg "$video\$($_.PSChildName)" }
    Cim Win32_DesktopMonitor
    '--- WmiMonitorID (decoded) ---'
    try {
        Get-CimInstance -Namespace root/wmi -ClassName WmiMonitorID -ErrorAction Stop | ForEach-Object {
            $d = { param($c) -join [char[]]($c -ne 0) }
            $_ | Select-Object InstanceName, YearOfManufacture, WeekOfManufacture,
                @{ n = 'Manufacturer'; e = { & $d $_.ManufacturerName } }, @{ n = 'Model'; e = { & $d $_.UserFriendlyName } },
                @{ n = 'ProductCode'; e = { & $d $_.ProductCodeID } }, @{ n = 'Serial'; e = { & $d $_.SerialNumberID } } | Props
        }
    } catch { "[unavailable] $($_.Exception.Message)"; '' }
    Cim WmiMonitorBasicDisplayParams -Ns root/wmi
    Cim WmiMonitorConnectionParams -Ns root/wmi
    Cim WmiMonitorListedSupportedSourceModes -Ns root/wmi -Drop MonitorSourceModes
    Cim Win32_SoundDevice
}

Section 'STORAGE' {
    Cim Win32_DiskDrive
    Cim Win32_DiskPartition
    Cim Win32_LogicalDisk
    Cim Win32_CDROMDrive
    Cim Win32_IDEController
    Cim Win32_SCSIController
    Cim MSFT_PhysicalDisk -Ns root/Microsoft/Windows/Storage
    Cim MSFT_Disk -Ns root/Microsoft/Windows/Storage
    Cim MSFT_StorageReliabilityCounter -Ns root/Microsoft/Windows/Storage
    Cim MSStorageDriver_FailurePredictStatus -Ns root/wmi
}

Section 'BOARD BUSES, PORTS, SLOTS, SENSORS' {
    foreach ($c in 'Win32_SystemSlot', 'Win32_PortConnector', 'Win32_OnBoardDevice', 'Win32_Bus', 'Win32_SerialPort',
        'Win32_ParallelPort', 'Win32_PCMCIAController', 'Win32_1394Controller', 'Win32_InfraredDevice', 'Win32_Fan',
        'Win32_TemperatureProbe', 'Win32_VoltageProbe', 'Win32_CurrentProbe', 'Win32_DeviceMemoryAddress') { Cim $c }
    Cim MSAcpi_ThermalZoneTemperature -Ns root/wmi
    Cim Win32_TPM -Ns root/cimv2/Security/MicrosoftTpm
}

Section 'POWER' {
    Cim Win32_Battery
    Cim Win32_PortableBattery
    Cim Win32_PowerPlan -Ns root/cimv2/power
    Native 'powercfg /list' { powercfg /list }
    Native 'powercfg /getactivescheme' { powercfg /getactivescheme }
    Native 'powercfg /a (sleep states)' { powercfg /a }
    Native 'USB power settings of active plan (selective suspend)' { powercfg /q SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 }
    Native 'powercfg /devicequery wake_armed' { powercfg /devicequery wake_armed }
    Native 'powercfg /devicequery wake_programmable' { powercfg /devicequery wake_programmable }
    Native 'powercfg /lastwake' { powercfg /lastwake }
}

# Win32_PnPEntity directly: the PnpDevice module does not load in every language mode.
$allDevices = @(Get-CimInstance Win32_PnPEntity -ErrorAction SilentlyContinue | Select-Object @{ n = 'InstanceId'; e = { $_.DeviceID } }, @{ n = 'FriendlyName'; e = { $_.Name } }, @{ n = 'Class'; e = { $_.PNPClass } }, Status, Present, @{ n = 'Cim'; e = { $_ } })

Section 'NETWORK AND RADIOS' {
    Cim Win32_NetworkAdapter -Filter 'PhysicalAdapter=TRUE' -Drop GUID
    Native 'netsh wlan show drivers' { netsh wlan show drivers }
    # Band and channel matter for 2.4 GHz coexistence; network names and addresses do not.
    Native 'netsh wlan show interfaces (identifiers removed)' {
        netsh wlan show interfaces | Where-Object { $_ -notmatch 'SSID|Profile|Perfil|([0-9a-f]{2}[:-]){5}[0-9a-f]{2}' }
    }
    $allDevices | Where-Object Class -eq 'Bluetooth' |
        Select-Object Status, Present, FriendlyName, InstanceId | Tbl
}

Write-Host '  (reading USB/HID device properties)'
$present = @($allDevices | Where-Object Present)
$busDevices = @($present | Where-Object {
    $_.InstanceId -match '^(USB|HID|BTH\w*)\\' -or $_.Class -in 'USB', 'HIDClass', 'Keyboard', 'Mouse', 'Bluetooth'
})
$devProps = @{}
foreach ($d in $busDevices) {
    $devProps[$d.InstanceId] = @((Invoke-CimMethod -InputObject $d.Cim -MethodName GetDeviceProperties -ErrorAction SilentlyContinue).deviceProperties |
        Where-Object { $_.KeyName -like 'DEVPKEY*' -and $null -ne $_.Data -and "$($_.Data)" -ne '' })
}
function DevProp { param($Id, $Key) ($devProps[$Id] | Where-Object KeyName -eq $Key | Select-Object -First 1).Data }

Section 'USB CONTROLLERS AND HUBS' {
    Cim Win32_USBController
    Cim Win32_USBHub
}

Section 'USB / HID / BLUETOOTH TOPOLOGY (TREE OF CONNECTED DEVICES)' {
    $byId = @{}; $children = @{}; $roots = @()
    foreach ($d in $busDevices) { $byId[$d.InstanceId] = $d }
    foreach ($d in $busDevices) {
        $parent = DevProp $d.InstanceId 'DEVPKEY_Device_Parent'
        if ($parent -and $byId.ContainsKey($parent)) {
            if (-not $children.ContainsKey($parent)) { $children[$parent] = @() }
            $children[$parent] += $d.InstanceId
        } else { $roots += $d.InstanceId }
    }
    function Walk {
        param($Id, [int]$Depth)
        $d = $byId[$Id]
        $loc = DevProp $Id 'DEVPKEY_Device_LocationInfo'
        $desc = DevProp $Id 'DEVPKEY_Device_BusReportedDeviceDesc'
        ('  ' * $Depth) + "[$($d.Status)] $($d.FriendlyName) {$($d.Class)}" + $(if ($desc) { " bus='$desc'" }) + $(if ($loc) { " @ $loc" })
        ('  ' * $Depth) + "      $Id"
        foreach ($c in ($children[$Id] | Sort-Object)) { Walk $c ($Depth + 1) }
    }
    foreach ($r in ($roots | Sort-Object)) { Walk $r 0 }
}

Section 'USB / HID / KEYBOARD / MOUSE / BLUETOOTH DEVICES (ALL PROPERTIES)' {
    foreach ($d in ($busDevices | Sort-Object InstanceId)) {
        "##### $($d.InstanceId)"
        "Status / Class / Name : $($d.Status) / $($d.Class) / $($d.FriendlyName)"
        foreach ($p in $devProps[$d.InstanceId]) {
            $value = if ($p.Data -is [array]) { $p.Data -join ' | ' } else { $p.Data }
            '{0,-48}: {1}' -f ($p.KeyName -replace '^DEVPKEY_', ''), $value
        }
        $params = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($d.InstanceId)\Device Parameters"
        if (Test-Path -LiteralPath $params) {
            '[Device Parameters]'
            Get-ItemProperty -LiteralPath $params -ErrorAction SilentlyContinue | Props
        } else { '' }
    }
}

Section 'HID COLLECTIONS (FROM HID.DLL)' {
    $script:hidInfos = @(); $script:hidReady = $false
    try {
        Add-Type -ErrorAction Stop -TypeDefinition @'
using System;
using System.ComponentModel;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Win32.SafeHandles;

public class HidInfo {
    public string Id, Path, Manufacturer, Product, Serial;
    public int Vid, ProductId, Version, UsagePage, Usage, InputLength, OutputLength, FeatureLength;
}

public static class HidApi {
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    static extern SafeFileHandle CreateFile(string name, uint access, uint share, IntPtr sec, uint mode, uint flags, IntPtr tmpl);
    [DllImport("hid.dll")] static extern bool HidD_GetAttributes(SafeFileHandle h, [In, Out] ushort[] a);
    [DllImport("hid.dll")] static extern bool HidD_GetPreparsedData(SafeFileHandle h, out IntPtr p);
    [DllImport("hid.dll")] static extern bool HidD_FreePreparsedData(IntPtr p);
    [DllImport("hid.dll")] static extern int HidP_GetCaps(IntPtr p, [Out] ushort[] c);
    [DllImport("hid.dll")] static extern bool HidD_GetManufacturerString(SafeFileHandle h, byte[] b, int n);
    [DllImport("hid.dll")] static extern bool HidD_GetProductString(SafeFileHandle h, byte[] b, int n);
    [DllImport("hid.dll")] static extern bool HidD_GetSerialNumberString(SafeFileHandle h, byte[] b, int n);

    public static SafeFileHandle Open(string path, uint access, uint flags) {
        SafeFileHandle h = CreateFile(path, access, 3, IntPtr.Zero, 3, flags, IntPtr.Zero);
        if (h.IsInvalid) throw new Win32Exception(Marshal.GetLastWin32Error());
        return h;
    }

    static string Decode(bool ok, byte[] b) { return ok ? Encoding.Unicode.GetString(b).Split('\0')[0] : null; }

    public static HidInfo Read(string id, string path) {
        HidInfo i = new HidInfo(); i.Id = id; i.Path = path;
        using (SafeFileHandle h = Open(path, 0, 0)) {
            ushort[] a = new ushort[6]; a[0] = 12;
            if (HidD_GetAttributes(h, a)) { i.Vid = a[2]; i.ProductId = a[3]; i.Version = a[4]; }
            IntPtr p;
            if (HidD_GetPreparsedData(h, out p)) {
                ushort[] c = new ushort[32];
                HidP_GetCaps(p, c);
                HidD_FreePreparsedData(p);
                i.Usage = c[0]; i.UsagePage = c[1]; i.InputLength = c[2]; i.OutputLength = c[3]; i.FeatureLength = c[4];
            }
            byte[] b = new byte[254]; i.Manufacturer = Decode(HidD_GetManufacturerString(h, b, b.Length), b);
            b = new byte[254]; i.Product = Decode(HidD_GetProductString(h, b, b.Length), b);
            b = new byte[254]; i.Serial = Decode(HidD_GetSerialNumberString(h, b, b.Length), b);
        }
        return i;
    }
}

public sealed class HidppChannel : IDisposable {
    readonly FileStream s, l;
    readonly byte[] bs = new byte[7], bl = new byte[20];
    Task<int> rs, rl;

    public HidppChannel(string shortPath, string longPath) {
        s = new FileStream(HidApi.Open(shortPath, 0xC0000000, 0x40000000), FileAccess.ReadWrite, 1, true);
        l = new FileStream(HidApi.Open(longPath, 0x80000000, 0x40000000), FileAccess.Read, 1, true);
    }

    static bool Match(byte[] q, byte[] b) {
        if (b[1] != q[1]) return false;
        if ((b[2] == 0x8F || b[2] == 0xFF) && b[3] == q[2] && b[4] == q[3]) return true;
        if (b[2] != q[2] || b[3] != q[3]) return false;
        return (q[3] != 0xB5 && q[3] != 0xF1) || b[4] == q[4];
    }

    public byte[] Send(byte[] q, int timeoutMs) {
        DateTime until = DateTime.UtcNow.AddMilliseconds(timeoutMs);
        try {
            if (!s.WriteAsync(q, 0, q.Length).Wait(timeoutMs)) return null;
            while (true) {
                int left = (int)(until - DateTime.UtcNow).TotalMilliseconds;
                if (left <= 0) return null;
                if (rs == null) rs = s.ReadAsync(bs, 0, bs.Length);
                if (rl == null) rl = l.ReadAsync(bl, 0, bl.Length);
                int i = Task.WaitAny(new Task[] { rs, rl }, left);
                if (i < 0) return null;
                bool done = (i == 0 ? rs : rl).Status == TaskStatus.RanToCompletion;
                if (i == 0) rs = null; else rl = null;
                if (!done) return null;
                byte[] b = i == 0 ? bs : bl;
                if (Match(q, b)) return (byte[])b.Clone();
            }
        } catch (AggregateException) { return null; }
    }

    public void Dispose() { s.Dispose(); l.Dispose(); }
}
'@
    } catch {
        "[unavailable] Cannot compile the HID helper (language mode: $($ExecutionContext.SessionState.LanguageMode)): $($_.Exception.Message)"
        return
    }
    $script:hidReady = $true
    foreach ($d in ($present | Where-Object InstanceId -like 'HID\*')) {
        $path = '\\?\' + ($d.InstanceId -replace '\\', '#') + '#{4d1e55b2-f16f-11cf-88cb-001111000030}'
        try { $script:hidInfos += [HidApi]::Read($d.InstanceId, $path) }
        catch { "[cannot open] $($d.InstanceId): $($_.Exception.Message)" }
    }
    $script:hidInfos | Sort-Object Vid, ProductId, Id | Select-Object `
        @{ n = 'VID'; e = { '{0:X4}' -f $_.Vid } }, @{ n = 'PID'; e = { '{0:X4}' -f $_.ProductId } }, @{ n = 'Rev'; e = { '{0:X4}' -f $_.Version } },
        @{ n = 'UsagePage'; e = { '{0:X4}' -f $_.UsagePage } }, @{ n = 'Usage'; e = { '{0:X4}' -f $_.Usage } },
        @{ n = 'In'; e = { $_.InputLength } }, @{ n = 'Out'; e = { $_.OutputLength } }, @{ n = 'Feat'; e = { $_.FeatureLength } },
        Manufacturer, Product, Serial, Id | Tbl
}

Section 'VENDOR 046D WIRELESS RECEIVERS (PAIRING TABLE, READ-ONLY HID++ QUERIES)' {
    if (-not $script:hidReady) { '[unavailable] HID helper not loaded, see the previous section. Pairing table not read.'; return }
    $vendor = @($script:hidInfos | Where-Object { $_.Vid -eq 0x046D -and $_.UsagePage -eq 0xFF00 })
    $groups = $vendor | Group-Object { ($_.Id -replace '^HID\\', '') -replace '&MI_.*\\', '|' -replace '&[0-9A-F]{4}$', '' }
    $found = 0
    foreach ($g in $groups) {
        $short = $g.Group | Where-Object Usage -eq 1 | Select-Object -First 1
        $long = $g.Group | Where-Object Usage -eq 2 | Select-Object -First 1
        if (-not ($short -and $long)) { continue }
        $found++
        "##### Receiver PID {0:X4}  rev {1:X4}  {2}" -f $short.ProductId, $short.Version, $short.Id
        $bolt = $short.ProductId -eq 0xC548
        try { $ch = New-Object HidppChannel($short.Path, $long.Path) }
        catch { "[cannot open HID++ channel] $($_.Exception.Message)"; ''; continue }
        try {
            $read = { param($b3, $b4, $b5 = 0) $ch.Send([byte[]](0x10, 0xFF, 0x81, $b3, $b4, $b5, 0), 1500) }
            $readLong = { param($sub, $p = 0) $ch.Send([byte[]](0x10, 0xFF, 0x83, 0xB5, $sub, $p, 0), 1500) }
            $fw = & $read 0xF1 0x01; $build = & $read 0xF1 0x02
            if (IsOk $fw) { 'Firmware             : {0:X2}.{1:X2}{2}' -f $fw[5], $fw[6], $(if (IsOk $build) { '.B{0:X2}{1:X2}' -f $build[5], $build[6] }) }
            $info = & $readLong 0x03
            if (IsOk $info) { "Receiver serial      : $(HexJoin $info 5, 6, 7, 8)"; "Max paired devices   : $($info[10])" }
            "Receiver info raw    : $(Hex $info)"
            $conn = & $read 0x02 0
            if (IsOk $conn) { "Paired device count  : $($conn[5])" }
            "Connection raw       : $(Hex $conn)"
            foreach ($n in 1..6) {
                if ($bolt) { $p = & $readLong (0x50 + $n); $e = $null; $nm = & $readLong (0x60 + $n) 1 }
                else { $p = & $readLong (0x20 + $n - 1); $e = & $readLong (0x30 + $n - 1); $nm = & $readLong (0x40 + $n - 1) }
                $slot = Read-Slot $bolt $p $e $nm
                $ping = Read-Ping $ch.Send([byte[]](0x10, [byte]$n, 0x00, 0x1D, 0x00, 0x00, 0x5A), 2500)
                if ($slot.Paired) {
                    "Slot $n : $($slot.Kind) '$($slot.Name)' wpid=$($slot.WirelessPid) serial=$($slot.Serial) link=$ping"
                } else { "Slot $n : (empty or not reported) link=$ping" }
                "   raw pair=$(Hex $p)"
                if ($slot.Paired) { "   raw ext =$(Hex $e)"; "   raw name=$(Hex $nm)" }
            }
        } finally { $ch.Dispose() }
        ''
    }
    if (-not $found) { '(no 046D receiver exposing the FF00 short/long collections is connected)' }
}

Section 'DEVICE HISTORY FOR VENDOR 046D (REGISTRY, INCLUDES DISCONNECTED)' {
    Get-ChildItem -Path 'HKLM:\SYSTEM\CurrentControlSet\Enum\USB' -ErrorAction SilentlyContinue |
        Where-Object PSChildName -match 'VID_046D' | ForEach-Object {
            $vidPid = $_.PSChildName
            Get-ChildItem -LiteralPath $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object {
                $base = "HKLM:\SYSTEM\CurrentControlSet\Enum\USB\$vidPid\$($_.PSChildName)"
                Reg $base
                Reg "$base\Device Parameters"
            }
        }
    Get-ChildItem -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\usbflags' -ErrorAction SilentlyContinue |
        Where-Object PSChildName -match '^046D' | ForEach-Object { Reg "HKLM:\SYSTEM\CurrentControlSet\Control\usbflags\$($_.PSChildName)" }
}

Section 'DISCONNECTED (GHOST) USB / HID / KEYBOARD / MOUSE DEVICES' {
    # Win32_PnPEntity omits disconnected devices, so this one section needs the PnpDevice module.
    Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { -not $_.Present -and ($_.InstanceId -match '^(USB|HID)\\' -or $_.Class -in 'Keyboard', 'Mouse', 'HIDClass') } |
        Sort-Object InstanceId | Select-Object Class, FriendlyName, InstanceId | Tbl
}

Section 'INPUT STACK' {
    Cim Win32_Keyboard
    Cim Win32_PointingDevice
    foreach ($c in @{ Keyboard = '{4d36e96b-e325-11ce-bfc1-08002be10318}'; Mouse = '{4d36e96f-e325-11ce-bfc1-08002be10318}'; HIDClass = '{745a17a0-74d3-11d0-b6fe-00a0c90f57da}'; USB = '{36fc9e60-c465-11cf-8056-444553540000}'; Bluetooth = '{e0cbf06c-cd8b-4647-bb8a-263b43f0f974}' }.GetEnumerator()) {
        "Class filters: $($c.Key)"
        Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Class\$($c.Value)"
    }
    '--- Core driver files ---'
    'hidclass', 'hidusb', 'hidparse', 'kbdhid', 'mouhid', 'kbdclass', 'mouclass', 'usbccgp', 'usbhub', 'usbhub3', 'usbxhci', 'usbport', 'ucx01000', 'winusb', 'i8042prt', 'hidbth', 'bthusb', 'bthport' |
        ForEach-Object { Join-Path "$env:windir\System32\drivers" "$_.sys" } | Where-Object { Test-Path $_ } | ForEach-Object {
            Get-Item $_ | Select-Object Name, @{ n = 'Version'; e = { $_.VersionInfo.ProductVersion } }, Length, LastWriteTime
        } | Tbl
    foreach ($k in 'Control Panel\Accessibility\Keyboard Response', 'Control Panel\Accessibility\MouseKeys', 'Control Panel\Accessibility\StickyKeys', 'Control Panel\Accessibility\ToggleKeys', 'Control Panel\Keyboard', 'Control Panel\Mouse', 'Keyboard Layout\Preload') { Reg "HKCU:\$k" }
    Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\HidUsb'
    Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\usbhub\HubG'
    Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\USB'
}

Section 'DEVICE POLICIES' {
    foreach ($k in 'SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions', 'SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Settings', 'SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices', 'SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs', 'SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceClasses', 'SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\AllowDeviceIDs', 'SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\AllowDeviceClasses') { Reg "HKLM:\$k" }
}

Section 'RELATED SOFTWARE, SERVICES AND PROCESSES' {
    # ponytail: name filter keeps the rest of the machine's software out of a vendor report; extend the regex if a product is missed.
    $rx = 'Logi|Unifying|SetPoint|G HUB|Options\+|USB|HID|Bluetooth|Chipset|Razer|Corsair|SteelSeries|Keyboard|Mouse|Synaptics|ELAN|Driver|Citrix|VMware|Parallels|DisplayLink|CrowdStrike|Symantec|McAfee|Trend Micro|Forcepoint|Digital Guardian|Endpoint|DLP|Kaspersky|Sophos|Dock'
    $uninstall = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    @($uninstall | ForEach-Object { "HKLM:\$_" }) + "HKCU:\$($uninstall[0])" |
        ForEach-Object { Get-ItemProperty -Path $_ -ErrorAction SilentlyContinue } |
        Where-Object DisplayName -match $rx | Sort-Object DisplayName |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Tbl
    Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'Logi|LGHUB|Setpoint|usb|hid|bth|bluetooth' -or $_.DisplayName -match 'Logi|Setpoint|USB|Bluetooth' } |
        Sort-Object Name | Select-Object Name, DisplayName, State, StartMode, PathName | Tbl
    Get-Process -ErrorAction SilentlyContinue | Where-Object ProcessName -match 'logi|lghub|setpoint|unifying' |
        Select-Object ProcessName, Id, Path, StartTime | Tbl
}

Section 'ALL KERNEL DRIVERS' {
    Get-CimInstance Win32_SystemDriver -ErrorAction SilentlyContinue | Sort-Object Name |
        Select-Object Name, State, StartMode, DisplayName, PathName | Tbl
}

Section 'DEVICES WITH PROBLEMS' {
    $bad = @(Get-CimInstance Win32_PnPEntity -ErrorAction SilentlyContinue | Where-Object ConfigManagerErrorCode -ne 0)
    if ($bad.Count) { $bad | Select-Object ConfigManagerErrorCode, Status, PNPClass, Name, DeviceID | Tbl } else { '(none)' }
}

Section 'ALL PRESENT PLUG AND PLAY DEVICES' {
    $present | Sort-Object Class, FriendlyName | Select-Object Class, Status, FriendlyName, InstanceId | Tbl
}

Section 'ALL SIGNED DRIVERS' {
    Get-CimInstance Win32_PnPSignedDriver -ErrorAction SilentlyContinue | Sort-Object DeviceClass, DeviceName |
        Select-Object DeviceClass, DeviceName, DriverVersion, DriverDate, Manufacturer, InfName, IsSigned, Signer, DeviceID | Tbl
}

Section 'EVENT LOGS, LAST 30 DAYS' {
    $since = (Get-Date).AddDays(-30)
    function EventTable {
        param($Events)
        if (-not $Events) { '(none or unavailable)'; return }
        $Events | Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, @{ n = 'Message'; e = { $_.Message -replace '\s+', ' ' -replace '([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}', '<address>' } } | Tbl
    }
    '--- System: hardware-related errors and warnings ---'
    try {
        EventTable (Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 1, 2, 3; StartTime = $since } -MaxEvents 5000 -ErrorAction Stop |
            Where-Object ProviderName -match 'Kernel-Power|WHEA|USB|Hid|BTH|i8042|UserPnp|Kernel-PnP|DriverFrameworks|^disk$|Ntfs|^Display$|nvlddmkm|amdkmdag' | Select-Object -First 400)
    } catch { "[unavailable] $($_.Exception.Message)" }
    '--- Kernel-PnP/Configuration: USB, HID and vendor 046D ---'
    try {
        EventTable (Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-Kernel-PnP/Configuration'; StartTime = $since } -MaxEvents 2000 -ErrorAction Stop |
            Where-Object Message -match 'VID_046D|USB\\|HID\\' | Select-Object -First 400)
    } catch { "[unavailable] $($_.Exception.Message)" }
}

$elapsed = [int]((Get-Date) - $started).TotalSeconds
if ($Format -eq 'HTML') {
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $cards = [ordered]@{
        Computer = $env:COMPUTERNAME
        Windows = "$($os.Caption) (build $($os.BuildNumber))"
        Processor = @(Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | ForEach-Object Name) -join ', '
        Memory = '{0:N0} GB' -f ((Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object Capacity -Sum).Sum / 1GB)
        Graphics = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | ForEach-Object Name) -join ', '
        'Devices with problems' = @(Get-CimInstance Win32_PnPEntity -ErrorAction SilentlyContinue | Where-Object ConfigManagerErrorCode -ne 0).Count
    }
    $cardHtml = foreach ($k in $cards.Keys) {
        $cls = if ($k -eq 'Devices with problems' -and $cards[$k] -gt 0) { ' class="alert"' }
        "<div$cls><span>$(Esc $k)</span><strong>$(Esc $cards[$k])</strong></div>"
    }
    # No external fonts or scripts: the report must open offline and send nothing anywhere.
    $css = @'
:root{color-scheme:light dark;--bg:#f3f4f0;--panel:#fff;--ink:#1b2220;--dim:#626d68;--line:#dde1db;--accent:#0a7565;--ok:#10734f;--w:#955400;--bad:#bf2f28;--code:#f8f9f6}
@media (prefers-color-scheme:dark){:root{--bg:#0f1312;--panel:#171d1b;--ink:#e6ebe8;--dim:#94a19c;--line:#29322f;--accent:#3fcfb5;--ok:#4cd6a0;--w:#f0b35a;--bad:#ff7a70;--code:#121715}}
*{box-sizing:border-box}[hidden]{display:none!important}
body{margin:0;display:grid;grid-template-columns:310px minmax(0,1fr);min-height:100vh;background:var(--bg);color:var(--ink);font:15px/1.5 "Segoe UI Variable Text","Segoe UI",system-ui,sans-serif}
aside{position:sticky;top:0;height:100vh;display:flex;flex-direction:column;gap:12px;padding:24px 16px;background:var(--panel);border-right:1px solid var(--line)}
.brand{font-weight:700;font-size:17px;letter-spacing:-.01em}.brand small{display:block;font-weight:400;font-size:12.5px;color:var(--dim)}
input,button{font:inherit;color:inherit;background:var(--bg);border:1px solid var(--line);border-radius:7px;padding:7px 10px}
input{width:100%}button{flex:1;cursor:pointer;font-size:13px}button:hover{border-color:var(--accent)}
input:focus-visible,button:focus-visible,a:focus-visible,summary:focus-visible{outline:2px solid var(--accent);outline-offset:1px}
.tools{display:flex;gap:8px}
nav{overflow-y:auto;flex:1;margin:0 -6px}
nav a{display:block;padding:5px 8px;border-radius:6px;color:var(--dim);text-decoration:none;font-size:12.5px;line-height:1.35}
nav a:hover{background:var(--bg);color:var(--ink)}
.flag::after{content:"";display:inline-block;width:7px;height:7px;margin-left:7px;border-radius:50%;background:var(--bad);vertical-align:1px}
main{padding:32px clamp(16px,4vw,48px) 64px;max-width:1500px}
h1{margin:0;font-size:clamp(24px,3vw,32px);letter-spacing:-.02em;line-height:1.15}
.meta{margin:6px 0 24px;color:var(--dim)}
.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:12px;margin-bottom:28px}
.cards div{padding:14px 16px;background:var(--panel);border:1px solid var(--line);border-radius:10px}
.cards span{display:block;font-size:12px;color:var(--dim)}.cards strong{display:block;margin-top:3px;font-weight:600;overflow-wrap:anywhere}
.cards .alert{border-color:var(--bad)}.cards .alert strong{color:var(--bad)}
details{margin-bottom:8px;background:var(--panel);border:1px solid var(--line);border-radius:10px;scroll-margin-top:12px}
summary{padding:12px 16px;font-weight:600;cursor:pointer;border-radius:10px}summary:hover{color:var(--accent)}
.body{padding:0 16px 16px;border-top:1px solid var(--line)}
h3{margin:22px 0 8px;font-size:13.5px;color:var(--accent);font-family:"Cascadia Mono",Consolas,monospace;font-weight:600;overflow-wrap:anywhere}
h4{margin:22px 0 8px;font-size:13.5px;overflow-wrap:anywhere}
dl{display:grid;grid-template-columns:minmax(150px,300px) minmax(0,1fr);margin:0 0 12px;border:1px solid var(--line);border-radius:8px;overflow:hidden}
dt,dd{margin:0;padding:4px 10px;font-size:13px;border-bottom:1px solid var(--line);overflow-wrap:anywhere}
dt{color:var(--dim);background:var(--code)}dl>:nth-last-child(-n+2){border-bottom:0}
pre{margin:10px 0;padding:12px;background:var(--code);border:1px solid var(--line);border-radius:8px;overflow-x:auto;font:12.5px/1.5 "Cascadia Mono",Consolas,monospace}
b.ok{color:var(--ok)}b.w{color:var(--w)}b.bad{color:var(--bad)}
@media (max-width:820px){body{display:block}aside{position:static;height:auto;border-right:0;border-bottom:1px solid var(--line)}nav{max-height:35vh}dl{grid-template-columns:1fr}dt{border-bottom:0;padding-bottom:0;background:none}}
@media print{aside{display:none}body{display:block}pre{white-space:pre-wrap}details{break-inside:auto}}
'@
    $js = @'
const secs=[...document.querySelectorAll('details')],links=[...document.querySelectorAll('nav a')],q=document.getElementById('q');
const all=o=>secs.forEach(d=>{d.open=o});
document.getElementById('open').onclick=()=>all(true);document.getElementById('close').onclick=()=>all(false);
links.forEach((a,i)=>a.onclick=()=>{secs[i].open=true});
q.oninput=()=>{const t=q.value.trim().toLowerCase();secs.forEach((d,i)=>{const hit=!t||d.textContent.toLowerCase().includes(t);d.hidden=links[i].hidden=!hit;d.open=!!t&&hit})};
onbeforeprint=()=>all(true);
'@
    @"
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Hardware Report - $(Esc $env:COMPUTERNAME)</title><style>$css</style></head>
<body><aside><div class="brand">Hardware Total Diagnosis<small>$($htmlNav.Count) sections</small></div>
<input id="q" type="search" placeholder="Filter sections..." aria-label="Filter sections">
<div class="tools"><button id="open" type="button">Expand all</button><button id="close" type="button">Collapse all</button></div>
<nav>$($htmlNav -join '')</nav></aside>
<main><h1>Hardware Report</h1><p class="meta">$(Esc $env:COMPUTERNAME) &middot; $($started.ToString('yyyy-MM-dd HH:mm:ss zzz')) &middot; collected in $elapsed s</p>
<div class="cards">$($cardHtml -join '')</div>
$($htmlMain -join "`n")
</main><script>$js</script></body></html>
"@ | Out-File -FilePath $OutFile -Encoding utf8
} else {
    "`r`nEND OF REPORT ($elapsed s)" | Out-File -FilePath $OutFile -Append -Encoding utf8
}
Write-Host "`nDone in $elapsed s. Report: $OutFile"
