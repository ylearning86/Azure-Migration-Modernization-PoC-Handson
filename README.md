# Azure Migration & Modernization PoC ハンズオン

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/TODO)

## 概要

オンプレミスから Azure への移行・モダナイズの一連の流れを体験できるハンズオンコンテンツです。
Azure 上に疑似オンプレ環境（DC01 / APP01 / DB01）を構築し、4 つの移行パターンを比較できます。

## 対象者

- Azure を提案するパートナー
- Azure への移行を検討しているお客様（インフラ経験者）

## シナリオ

| Phase | タイトル | 内容 |
|-------|---------|------|
| 0 | [環境デプロイ](docs/handson/00-deploy.md) | Deploy to Azure で全環境を構築 |
| 1 | [現状確認](docs/handson/01-explore-onprem.md) | 疑似オンプレ環境のアプリ動作確認 |
| 2 | [Arc 接続](docs/handson/02-arc-onboard.md) | オンプレ VM を Azure Arc に登録 |
| 3 | [ハイブリッド管理](docs/handson/03-hybrid-mgmt.md) | Policy / Monitor / Defender / Update Manager |
| 4 | [移行アセスメント](docs/handson/04-assessment.md) | Azure Migrate でアセスメント |
| 5a | [Rehost](docs/handson/05a-rehost.md) | Spoke1: VM を Lift & Shift |
| 5b | [DB PaaS 化](docs/handson/05b-db-paas.md) | Spoke2: VM + Azure SQL |
| 5c | [コンテナ化](docs/handson/05c-containerize.md) | Spoke3: Container Apps + Azure SQL |
| 5d | [フル PaaS](docs/handson/05d-full-paas.md) | Spoke4: App Service + Azure SQL |
| 6 | [比較・まとめ](docs/handson/06-compare.md) | 移行パターンの比較検討 |

## 移行パターン比較

| Spoke | パターン | AP 基盤 | DB 基盤 | コスト/月 | 主要ツール |
|-------|---------|---------|---------|----------|--------|
| Spoke1 | Rehost | Azure VM | Azure VM | ~$90 | Copilot 移行 Agent + Migrate |
| Spoke2 | DB PaaS 化 | Azure VM | Azure SQL | ~$42 | Copilot App Mod + DMS |
| Spoke3 | コンテナ化 | Container Apps | Azure SQL | ~$17 | Copilot App Mod + Docker |
| Spoke4 | フル PaaS | App Service | Azure SQL | ~$25 | Copilot App Mod |

## アーキテクチャ

詳細は [アーキテクチャ設計書](docs/architecture-design.md) を参照。

```text
  On-Prem VNet (rg-onprem)    Hub VNet (rg-hub)        Spoke VNets
  10.0.0.0/16                 10.10.0.0/16
 ┌───────────────────────┐   ┌──────────────┐   ┌── Spoke1 (10.20.0.0/16) Rehost
 │ DC01   (AD DS / DNS)  │   │ Azure FW     │   │   VM + VM
 │ APP01  (IIS / .NET)   │   │ (Basic)      │   │
 │ DB01   (SQL Server)   │   │              │   ├── Spoke2 (10.21.0.0/16) DB PaaS
 │                       │S2S│ VPN Gateway  │   │   VM + Azure SQL
 │                       ├──►│              │◄──┤
 │                       │VPN│ Bastion      │   ├── Spoke3 (10.22.0.0/16) Container
 │                       │   │              │   │   Container Apps + Azure SQL
 │                       │   │ Log Analytics│   │
 └───────────────────────┘   └──────────────┘   └── Spoke4 (10.23.0.0/16) Full PaaS
                                                     App Service + Azure SQL
```

## コスト

| 状態 | 月額概算 |
|------|---------|
| 基盤のみ常時稼働 | ~$900/月 |
| 利用時のみ起動 | ~$100-150/月 |
| Spoke 全部追加時 | +~$174/月 |

> Firewall / VPN GW / Bastion / VM はパラメータまたはスクリプトで ON/OFF 可能

## 前提条件

- Azure サブスクリプション（Owner 権限推奨）
- GitHub Copilot ライセンス（Phase 5b, 5c, 5d で使用）

## クイックスタート

1. 上部の「Deploy to Azure」ボタンをクリック
2. パラメータを入力（リージョン、管理者パスワード等）
3. デプロイ完了まで約 60-90 分待機
4. [Phase 1](docs/handson/01-explore-onprem.md) から順にハンズオンを開始
