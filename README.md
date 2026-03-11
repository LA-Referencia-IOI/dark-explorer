# dark-explorer 🔍

Standalone **Lite Block Explorer** for any EVM-compatible blockchain network.  
Point it to any running node by editing a single `.env` file.

> Ultra-lightweight alternative to Blockscout: **1 container**, **zero database**, instant startup.

## Containers

| Container       | Role              | Port                           |
| --------------- | ----------------- | ------------------------------ |
| `explorer-lite` | Block Explorer UI | configurable (default `25000`) |

---

## Quick Start

### 1. Configure `.env`

```env
# HTTP JSON-RPC endpoint of the target node
RPC_HTTP_URL=http://host.docker.internal:8545

# Port where the UI will be available on your machine
EXPLORER_PORT=25000
```

> **`host.docker.internal`** resolves to your host machine from inside Docker.  
> Use it when the node is running locally (e.g. via `docker-compose` on the same host).  
> For remote nodes, use the IP directly: `http://192.168.1.100:8545`

### 2. Start the explorer

```bash
docker compose up -d
```

### 3. Open the UI

```
http://localhost:25000
```

---

## Configuration Reference

| Variable        | Default                            | Description                   |
| --------------- | ---------------------------------- | ----------------------------- |
| `RPC_HTTP_URL`  | `http://host.docker.internal:8545` | HTTP JSON-RPC endpoint        |
| `EXPLORER_PORT` | `25000`                            | Host port for the Explorer UI |

---

## Use Cases

### Connect to dark-env (local QBFT network)

```env
RPC_HTTP_URL=http://host.docker.internal:8545
EXPLORER_PORT=25000
```

### Connect to a remote node

```env
RPC_HTTP_URL=http://203.0.113.10:8545
EXPLORER_PORT=25000
```

### Run two explorers simultaneously (different networks)

```bash
cp -r dark-explorer dark-explorer-2
cd dark-explorer-2
# Edit .env: EXPLORER_PORT=25001, RPC_HTTP_URL=...
docker compose -p dark-explorer-2 up -d
```

---

## Useful Commands

```bash
# Start
docker compose up -d

# Stop
docker compose stop

# Stop and remove containers
docker compose down

# Follow logs
docker compose logs -f explorer-lite

# Check status
docker compose ps
```

## Project Structure

```
dark-explorer/
├── docker-compose.yml       # Service definition
├── default.conf.template    # Nginx template (proxies /jsonrpc → node)
├── docker-entrypoint.sh     # Patches the JS bundle URL at startup
├── .env                     # ← Edit this to point to your node
└── README.md
```

## How It Works

```
Browser  ──GET /──►  Nginx (port 25000)  ──serves JS/HTML──►  Browser
Browser  ──POST /jsonrpc──►  Nginx  ──proxy_pass──►  Node RPC (port 8545)
```

Nginx serves the static SPA (Vue.js) and proxies all RPC calls from the browser to your node, avoiding CORS issues.
