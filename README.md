# Computer-Organization
# Testttttt

## 製作 ssl key
- 利用 openssl 產生 https 所需的金鑰
```bash
openssl req -nodes -new -x509 -keyout key/server.key -out key/server.cert
```

## 設定並執行 server
- 安裝 npm 所需套件
```bash
npm install
```
- 建立預設的 `config.js`
```bash
npm run pre-build
```
- 請填寫剛建立出的`config.js`
- 執行server
```bash
npm run develop
```

- 只支援 https
- https server 的預設 port 為 4430
- Example: https://localhost:4430/auth/login
- 可以修改 `config.js` 裡的 `server.port` 來自訂 port
