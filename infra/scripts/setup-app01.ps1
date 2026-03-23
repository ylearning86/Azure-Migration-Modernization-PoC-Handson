# ============================================================
# APP01 セットアップスクリプト
# IIS + .NET Framework 4.8 + サンプルアプリデプロイ
# ============================================================

$ErrorActionPreference = 'Stop'

# IIS と ASP.NET 4.8 のインストール
Install-WindowsFeature -Name Web-Server, Web-Asp-Net45, Web-Mgmt-Tools -IncludeManagementTools

# .NET Framework 4.8 は Windows Server 2019 にプリインストール済み

# サンプルアプリ用ディレクトリ作成
$appDir = 'C:\inetpub\wwwroot\InventoryApp'
New-Item -Path $appDir -ItemType Directory -Force

# IIS サイトの構成
Import-Module WebAdministration

# 既定の Web サイトを停止
Stop-Website -Name 'Default Web Site' -ErrorAction SilentlyContinue

# サンプルアプリ用サイト作成
New-Website -Name 'InventoryApp' `
    -PhysicalPath $appDir `
    -Port 80 `
    -ApplicationPool 'DefaultAppPool' `
    -Force

# アプリケーションプールを .NET 4.0 (CLR v4.0) に設定
Set-ItemProperty -Path 'IIS:\AppPools\DefaultAppPool' -Name 'managedRuntimeVersion' -Value 'v4.0'

# DNS 設定（DC01 を DNS サーバーとして使用）
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet*' -ServerAddresses '10.0.1.10' -ErrorAction SilentlyContinue

Write-Output 'APP01 setup completed. Deploy InventoryApp via Visual Studio or publish package.'
