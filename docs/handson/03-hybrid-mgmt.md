# Phase 3: ハイブリッド管理

## 目的

Azure Arc に登録した VM に対して、Azure のガバナンス・監視・セキュリティ機能を適用します。

## 前提条件

- Phase 2 が完了していること（3 台が Arc 登録済み）

## 手順

### 1. Azure Policy の確認

デプロイ時に適用済みのポリシーを確認します。

Azure Portal → **Policy** → **Compliance** で以下を確認:

| ポリシー | 効果 | 対象 |
|---------|------|------|
| Allowed locations | Deny | Japan East / Japan West |
| Require tag on RG (Environment) | Deny | すべての RG |
| Inherit tag from RG (Environment) | Modify | RG 内リソース |

### 2. Azure Monitor の設定

#### VM Insights の有効化

1. Azure Portal → **Monitor** → **Insights** → **Virtual Machines**
2. Arc-enabled Server（DC01, APP01, DB01）を選択
3. **Enable** をクリック
4. Log Analytics Workspace: `log-hub` を選択

#### データ収集ルールの作成

1. Azure Portal → **Monitor** → **Data Collection Rules** → **Create**
2. 以下を設定:

| 設定 | 値 |
|------|-----|
| Rule Name | `dcr-onprem-vms` |
| Resource Group | `rg-hub` |
| Region | Japan East |
| データソース | Windows Event Logs + Performance Counters |
| 送信先 | `log-hub` (Log Analytics Workspace) |

3. リソースとして DC01, APP01, DB01 を追加

### 3. Microsoft Defender for Cloud

Azure Portal → **Defender for Cloud** → **Environment settings** で有効化状況を確認:

| プラン | 対象 | 状態 |
|--------|------|------|
| Defender for Servers P1 | Arc-enabled Servers | 有効 |
| Defender for SQL | DB01 (SQL Server) | 有効 |

### 4. Azure Update Manager

1. Azure Portal → **Update Manager** → **Machines**
2. DC01, APP01, DB01 が一覧に表示されることを確認
3. **Check for updates** を実行
4. 利用可能な更新プログラムの一覧を確認

### 5. Log Analytics クエリの実行

Azure Portal → `log-hub` → **Logs** で以下のクエリを実行:

```kusto
// Arc-enabled Server のハートビート確認
Heartbeat
| where TimeGenerated > ago(1h)
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| order by Computer asc
```

```kusto
// Windows イベントログの確認
Event
| where TimeGenerated > ago(24h)
| summarize count() by Computer, EventLevelName
| order by Computer asc
```

## 確認ポイント

- [ ] Azure Policy のコンプライアンス状態が確認できる
- [ ] VM Insights で VM のメトリクスが表示される
- [ ] Defender for Cloud で推奨事項が表示される
- [ ] Update Manager で更新プログラムの一覧が表示される
- [ ] Log Analytics でハートビートが確認できる

## 次のステップ

→ [Phase 4: 移行アセスメント](04-assessment.md)
