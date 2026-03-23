# Phase 1: 現状確認

## 目的

疑似オンプレ環境（DC01 / APP01 / DB01）に接続し、既存アプリケーションの動作を確認します。

## 前提条件

- Phase 0 のデプロイが完了していること

## 構成

| VM 名 | 役割 | IP アドレス | OS |
|-------|------|------------|-----|
| DC01 | AD DS / DNS | 10.0.1.10 | Windows Server 2022 |
| APP01 | IIS + ASP.NET MVC 5 | 10.0.1.11 | Windows Server 2019 |
| DB01 | SQL Server 2019 | 10.0.1.12 | Windows Server 2019 |

## 手順

### 1. Azure Bastion で APP01 に RDP 接続

1. Azure Portal → `rg-onprem` → `APP01` → **接続** → **Bastion**
2. ユーザー名: `azureadmin`、パスワード: デプロイ時に設定した値を入力
3. **接続** をクリック

### 2. サンプルアプリ（在庫管理システム）の動作確認

1. APP01 上のブラウザで `http://localhost` にアクセス
2. 在庫管理システムのトップページが表示されることを確認
3. 以下の操作を試す:
   - 商品一覧の表示
   - 新規商品の登録
   - 商品情報の編集
   - 商品の削除

### 3. AD DS の確認（DC01）

1. Bastion で DC01 に RDP 接続
2. **Server Manager** → **Tools** → **Active Directory Users and Computers**
3. ドメイン `contoso.local` の構成を確認
   - OU=Servers、OU=ServiceAccounts

### 4. SQL Server の確認（DB01）

1. Bastion で DB01 に RDP 接続
2. **SQL Server Management Studio** を開く
3. Windows 認証で接続
4. `InventoryDB` データベースの存在とテーブルを確認

### 5. ネットワーク疎通の確認

APP01 から以下の疎通を確認:

```powershell
# DC01 への疎通
Test-NetConnection -ComputerName 10.0.1.10 -Port 53

# DB01 (SQL Server) への疎通
Test-NetConnection -ComputerName 10.0.1.12 -Port 1433
```

## 確認ポイント

- [ ] APP01 でサンプルアプリが正常動作すること
- [ ] DC01 で AD DS が構成されていること
- [ ] DB01 で SQL Server と InventoryDB が存在すること
- [ ] APP01 → DB01 間の疎通が確認できること

## 次のステップ

→ [Phase 2: Arc 接続](02-arc-onboard.md)
