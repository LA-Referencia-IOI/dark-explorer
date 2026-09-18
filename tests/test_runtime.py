import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]


class ExplorerRuntimeTests(unittest.TestCase):
    def test_entrypoint_applies_public_prefix_and_rpc_route(self):
        with tempfile.TemporaryDirectory() as temporary:
            web_root = Path(temporary)
            (web_root / "js").mkdir()
            (web_root / "index.html").write_text(
                '<link href=/css/app.css><script src=/js/app.js></script>',
                encoding="utf-8",
            )
            (web_root / "js" / "app.test.js").write_text(
                'https://mainnet.infura.io/alethio c.p="/" '
                'mode:"history",routes: BASE_URL:"/"',
                encoding="utf-8",
            )
            environment = os.environ | {
                "EXPLORER_BASE_PATH": "/custom-explorer/",
                "EXPLORER_WEB_ROOT": str(web_root),
                "NGINX_ENTRYPOINT": "/bin/true",
            }

            subprocess.run(
                ["sh", str(ROOT / "docker-entrypoint.sh")],
                env=environment,
                check=True,
            )

            html = (web_root / "index.html").read_text(encoding="utf-8")
            javascript = (web_root / "js" / "app.test.js").read_text(encoding="utf-8")
            self.assertIn("href=/custom-explorer/css/app.css", html)
            self.assertIn("src=/custom-explorer/js/app.js", html)
            self.assertIn("/custom-explorer/jsonrpc", javascript)
            self.assertIn('c.p="/custom-explorer/"', javascript)
            self.assertIn('base:"/custom-explorer/",mode:"history"', javascript)

    def test_entrypoint_rejects_non_absolute_base_path(self):
        with tempfile.TemporaryDirectory() as temporary:
            result = subprocess.run(
                ["sh", str(ROOT / "docker-entrypoint.sh")],
                env=os.environ | {
                    "EXPLORER_BASE_PATH": "relative/path",
                    "EXPLORER_WEB_ROOT": temporary,
                    "NGINX_ENTRYPOINT": "/bin/true",
                },
                capture_output=True,
                text=True,
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("absolute URL path", result.stderr)


if __name__ == "__main__":
    unittest.main()
