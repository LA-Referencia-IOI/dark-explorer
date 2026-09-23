# dark-explorer

Standalone **Lite Block Explorer** for any EVM-compatible blockchain network.
Point it at a running node with a single `RPC_HTTP_URL` environment variable.

> Ultra-lightweight alternative to Blockscout: **1 container**, **zero database**, instant startup.

## Container

| Service    | Role              | Notes                                                                                          |
| ---------- | ----------------- | ---------------------------------------------------------------------------------------------- |
| `explorer` | Block explorer UI | built at apply time from this checkout (`nginx:1.29-alpine` + pre-built `dist/`); listens on port `80` |

---

## Deployment

dark-explorador is deployed by the [dark-deployer](../../README.md) using the deployment v3 pipeline: an operator inventory (see [examples/operator-inventory/](../../examples/operator-inventory/)) is resolved, planned, and rendered into per-machine Docker Compose bundles, then applied with `./deploy.sh install` (locally) or `prepare`/`push`/`apply` (remote hosts). The container image is built from this component checkout when the bundle is applied, and the checkout branch (`main`) is pinned in `deployment_v3/catalog_data/dark-platform-baseline-v1.0.json`. There is no standalone docker-compose file in this component.

### How the pipeline configures the explorer

The rendered bundle writes an env file for the `explorer` service containing
exactly the deployment id and the two configuration variables below (values
derived from the inventory graph; local-ha example shown):

| Variable             | Rendered value   | Purpose                                                        |
| -------------------- | ---------------- | -------------------------------------------------------------- |
| `RPC_HTTP_URL`       | `http://rpc01:8545` | HTTP JSON-RPC endpoint of the deployment's primary Besu RPC node (`rpc01`), derived from the plan graph |
| `EXPLORER_BASE_PATH` | `/explorer`      | Public mount path, taken from the edge-proxy route that publishes the explorer |

The RPC endpoint is the primary RPC node of the deployment reached over the
deployment network — deployment v3 has no shared docker network `dark-apps` and
no `blockchain-rpc` alias. The public entry point is the edge-proxy route
(`/explorer/`); in the local-ha example the explorer container is not published
on a host port directly.

### Runtime behavior

- `docker-entrypoint.sh` validates `EXPLORER_BASE_PATH` (must be an absolute
  URL path; default `/explorer`) and patches the pre-built Vue SPA and
  `index.html` at container start so assets, the router base and the bundled
  RPC call stay under the public prefix; the bundled RPC URL is rewritten to
  `<base path>/jsonrpc`.
- nginx serves the static SPA and proxies `POST <base path>/jsonrpc` (HTTP) and
  `<base path>/jsonws` (WebSocket) to `RPC_HTTP_URL`, avoiding CORS issues;
  `/health` returns `ok`.
- The container always listens on port `80`; whether and where it is published
  on the host is decided by the deployment plan. The checked-in `.env`
  (`RPC_HTTP_URL=http://host.docker.internal:8545`, `EXPLORER_PORT=25000`) is a
  standalone-run example only — nothing in the image reads `EXPLORER_PORT`.

---

## Configuration Reference

| Variable               | Default                  | Description                                                                                       |
| ---------------------- | ------------------------ | ------------------------------------------------------------------------------------------------- |
| `RPC_HTTP_URL`         | — (must be supplied)     | HTTP JSON-RPC endpoint that the `/jsonrpc` and `/jsonws` locations proxy to. Under the deployer: the plan's primary RPC node (e.g. `http://rpc01:8545`) |
| `EXPLORER_BASE_PATH`   | `/explorer`              | Absolute public path under which the SPA is published                                              |
| `EXPLORER_WEB_ROOT`    | `/usr/share/nginx/html`  | Web root patched at startup (used by the runtime tests)                                            |
| `NGINX_ENTRYPOINT`     | `/docker-entrypoint.sh`  | Upstream nginx entrypoint chained by the wrapper (used by the runtime tests)                       |

---

## Standalone run (development)

```bash
docker build -t dark-explorer .
docker run -d --name dark-explorer -p 25000:80 --env-file .env dark-explorer
# UI: http://localhost:25000/explorer/
```

Edit `.env` to point `RPC_HTTP_URL` at any reachable EVM node. To publish the
explorer at the root instead of a sub-path, set `EXPLORER_BASE_PATH=/`.

---

## Project Structure

```
dark-explorer/
├── Dockerfile               # nginx:1.29-alpine + dist/ + nginx template + entrypoint
├── dist/                    # Pre-built Vue.js SPA assets
├── default.conf.template    # Nginx template (proxies /jsonrpc → RPC_HTTP_URL)
├── docker-entrypoint.sh     # Patches the SPA base path and RPC URL at startup
├── tests/test_runtime.py    # Entrypoint runtime tests
├── .env                     # Standalone-run example values
└── README.md
```

## How It Works

```
Browser ──GET {origin}/explorer/──────────► Edge proxy ──► Explorer nginx (port 80) ──serves patched SPA──► Browser
Browser ──POST {origin}/explorer/jsonrpc──► Edge proxy ──► Explorer /jsonrpc ──proxy_pass──► RPC_HTTP_URL (primary RPC node, port 8545)
```

## Tests

```bash
python3 tests/test_runtime.py
```

Covers the entrypoint's public-prefix patching and its rejection of
non-absolute base paths.