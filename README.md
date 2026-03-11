# dark-explorer 🔍

Standalone **Lite Block Explorer** para qualquer rede EVM-compatível.  
Aponte para qualquer node rodando, editando apenas um arquivo `.env`.

> Alternativa ultra-leve ao Blockscout: **1 container**, **zero banco de dados**, arranque imediato.

## Containers

| Container       | Função               | Porta                         |
| --------------- | -------------------- | ----------------------------- |
| `explorer-lite` | UI do Block Explorer | configurável (padrão `25000`) |

---

## Quick Start

### 1. Configure o `.env`

```env
# Endpoint HTTP JSON-RPC do node alvo
RPC_HTTP_URL=http://host.docker.internal:8545

# Porta onde a UI ficará acessível no host
EXPLORER_PORT=25000
```

> **`host.docker.internal`** resolve para o seu host a partir de dentro do Docker.  
> Use para nodes locais (ex: `docker-compose` na mesma máquina).  
> Para nodes remotos, use o IP diretamente: `http://192.168.1.100:8545`

### 2. Inicie o explorer

```bash
docker compose up -d
```

### 3. Abra a UI

```
http://localhost:25000
```

---

## Referência de Configuração

| Variável        | Padrão                             | Descrição                      |
| --------------- | ---------------------------------- | ------------------------------ |
| `RPC_HTTP_URL`  | `http://host.docker.internal:8545` | Endpoint HTTP JSON-RPC do node |
| `EXPLORER_PORT` | `25000`                            | Porta da UI no host            |

---

## Casos de Uso

### Conectar à dark-env (rede QBFT local)

```env
RPC_HTTP_URL=http://host.docker.internal:8545
EXPLORER_PORT=25000
```

### Conectar a um node remoto

```env
RPC_HTTP_URL=http://203.0.113.10:8545
EXPLORER_PORT=25000
```

### Rodar dois explorers ao mesmo tempo (redes diferentes)

```bash
cp -r dark-explorer dark-explorer-2
cd dark-explorer-2
# edite .env: EXPLORER_PORT=25001, RPC_HTTP_URL=...
docker compose -p dark-explorer-2 up -d
```

---

## Comandos Úteis

```bash
# Iniciar
docker compose up -d

# Parar
docker compose stop

# Parar e remover o container
docker compose down

# Ver logs em tempo real
docker compose logs -f explorer-lite

# Ver status
docker compose ps
```

## Estrutura do Projeto

```
dark-explorer/
├── docker-compose.yml       # Definição do serviço
├── default.conf.template    # Template Nginx (proxy /jsonrpc → node)
├── docker-entrypoint.sh     # Patch de URL no bundle JS ao iniciar
├── .env                     # ← Edite para apontar ao seu node
└── README.md
```

## Como Funciona

```
Navegador  ──GET /──►  Nginx (porta 25000)  ──serve JS/HTML──►  Navegador
Navegador  ──POST /jsonrpc──►  Nginx  ──proxy_pass──►  Node RPC (porta 8545)
```

O Nginx serve a interface estática (SPA Vue.js) e faz proxy das chamadas RPC do browser para o seu node, evitando problemas de CORS.
