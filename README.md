# dark-explorer 🔍

Standalone **Lite Block Explorer** for any EVM-compatible blockchain network.  
Plug it into any running node by editing a single `.env` file.

## What's included

| Container       | Role                    | Port                               |
| --------------- | ----------------------- | ---------------------------------- |
| `explorer-lite` | Block Explorer UI + API | **configurable** (default `25000`) |

## Quick Start

### 1. Configure `.env`

Edit `.env` and point it to your blockchain node:

```env
# RPC endpoints of the target node
RPC_HTTP_URL=http://host.docker.internal:8545

# Port where the UI will be available on your machine
EXPLORER_PORT=25000
```

> **`host.docker.internal`** resolves to your host machine from inside Docker.  
> Use it when the node is running locally (e.g. via `docker-compose` on the same host).  
> For remote nodes, use the IP or hostname directly: `http://192.168.1.100:8545`

### 2. Start the explorer

```bash
docker compose up -d
```

### 3. Open the UI

```
http://localhost:25000   (or whatever EXPLORER_PORT you configured)
```

---

## Configuration Reference

All settings live in `.env`:

| Variable        | Default                            | Description               |
| --------------- | ---------------------------------- | ------------------------- |
| `RPC_HTTP_URL`  | `http://host.docker.internal:8545` | HTTP JSON-RPC endpoint    |
| `EXPLORER_PORT` | `25000`                            | Host port for Explorer UI |

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
# Copy the project and change the port
cp -r dark-explorer dark-explorer-2
cd dark-explorer-2
# Edit .env: EXPLORER_PORT=25001, RPC_HTTP_URL=..., etc.
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
├── docker-compose.yml    # Service definitions
├── .env                  # ← Edit this to configure your target node
└── README.md
```
