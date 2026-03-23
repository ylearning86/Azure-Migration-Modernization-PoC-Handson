# Phase 2: Azure Arc 接続

## 目的

疑似オンプレ VM（DC01 / APP01 / DB01）を Azure Arc に登録し、Azure からの一元管理を可能にします。

## 前提条件

- Phase 1 が完了していること
- 各 VM から Azure エンドポイントへの HTTPS 通信が可能であること

## 重要: IMDS ブロックの設定

疑似オンプレ VM は実際には Azure VM であるため、Azure Arc Agent をインストールする前に **IMDS（Instance Metadata Service）へのアクセスをブロック** する必要があります。

各 VM（DC01, APP01, DB01）で以下を実行:

```powershell
# IMDS エンドポイントをブロック（Azure VM 上で Arc Agent を動作させるために必須）
New-NetFirewallRule -Name "BlockIMDS" -DisplayName "Block IMDS" `
    -Direction Outbound -RemoteAddress 169.254.169.254 -Action Block
```

## 手順

### 1. Arc Agent のインストール（各 VM で実施）

Bastion で各 VM に RDP 接続し、以下のスクリプトを実行します。

```powershell
# Azure Arc Connected Machine Agent のインストール
# Azure Portal → Azure Arc → Servers → Add → Generate script で生成されるスクリプトを使用

# 例: インタラクティブにログインする場合
$env:SUBSCRIPTION_ID = "<your-subscription-id>"
$env:RESOURCE_GROUP = "rg-onprem"
$env:TENANT_ID = "<your-tenant-id>"
$env:LOCATION = "japaneast"

# Agent ダウンロードとインストール
Invoke-WebRequest -Uri "https://aka.ms/azcmagent-windows" -OutFile "$env:TEMP\install_windows_azcmagent.ps1"
& "$env:TEMP\install_windows_azcmagent.ps1"

# Arc に接続
azcmagent connect `
    --resource-group $env:RESOURCE_GROUP `
    --tenant-id $env:TENANT_ID `
    --location $env:LOCATION `
    --subscription-id $env:SUBSCRIPTION_ID `
    --tags "Environment=PoC,Project=Migration-Handson,SecurityControl=Ignore"
```

### 2. 登録対象

| VM | 登録先 RG | 備考 |
|----|----------|------|
| DC01 | rg-onprem | IMDS ブロック必須 |
| APP01 | rg-onprem | IMDS ブロック必須 |
| DB01 | rg-onprem | IMDS ブロック必須 + SQL Server 拡張 |

### 3. Arc-enabled SQL Server の設定（DB01）

DB01 では追加で SQL Server 用の Azure Extension をインストール:

1. Azure Portal → Azure Arc → SQL Server → DB01 を選択
2. **SQL Server 用 Azure 拡張機能** をインストール
3. SQL Best Practices Assessment を有効化

### 4. 登録の確認

Azure Portal → **Azure Arc** → **Servers** で 3 台の VM が表示されることを確認。

```text
Azure Arc - Servers
├── DC01   (Connected) - rg-onprem
├── APP01  (Connected) - rg-onprem
└── DB01   (Connected) - rg-onprem
```

## 確認ポイント

- [ ] 3 台すべてが Arc に登録済み（Status: Connected）
- [ ] タグが正しく設定されていること
- [ ] DB01 で SQL Server 拡張機能が有効であること

## 次のステップ

→ [Phase 3: ハイブリッド管理](03-hybrid-mgmt.md)
