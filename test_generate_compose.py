#!/usr/bin/env python3
"""Unit tests for generate-compose.py. Run with: python3 -m unittest test_generate_compose.py -v"""
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent
SCRIPT = REPO_ROOT / "generate-compose.py"


def run_generator(*args, output_path=None):
    cleanup = output_path is None
    if output_path is None:
        with tempfile.NamedTemporaryFile(suffix=".yml", delete=False) as tmp:
            output_path = Path(tmp.name)
    result = subprocess.run(
        [sys.executable, str(SCRIPT), "--output", str(output_path), *args],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
    )
    content = output_path.read_text() if output_path.exists() else ""
    if cleanup:
        output_path.unlink(missing_ok=True)
    return result, content


class GenerateComposeTests(unittest.TestCase):
    def test_default_generates_three_nodes(self):
        result, content = run_generator()
        self.assertEqual(result.returncode, 0, result.stderr)
        for n in (1, 2, 3):
            self.assertIn(f"slurmnode{n}:", content)
            self.assertIn(f"container_name: ${{CLUSTER_NAME}}-node{n}", content)
            self.assertIn(f"hostname: slurmnode{n}", content)
            self.assertIn(f"SLURM_NODENAME: slurmnode{n}", content)
        self.assertNotIn("slurmnode4:", content)

    def test_custom_node_count(self):
        result, content = run_generator("--nodes", "5")
        self.assertEqual(result.returncode, 0, result.stderr)
        for n in range(1, 6):
            self.assertIn(f"slurmnode{n}:", content)
        self.assertNotIn("slurmnode6:", content)

    def test_min_and_max_bounds(self):
        for n in (1, 10):
            result, content = run_generator("--nodes", str(n))
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(f"slurmnode{n}:", content)

    def test_out_of_range_rejected(self):
        for n in (0, -1, 11):
            result, content = run_generator("--nodes", str(n))
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(content, "")

    def test_frontend_and_master_use_cluster_name(self):
        result, content = run_generator()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("slurmfrontend:", content)
        self.assertIn("container_name: ${CLUSTER_NAME}-frontend", content)
        self.assertIn("slurmmaster:", content)
        self.assertIn("container_name: ${CLUSTER_NAME}-master", content)

    def test_output_is_valid_compose_config(self):
        docker = subprocess.run(["docker", "compose", "version"], capture_output=True)
        if docker.returncode != 0:
            self.skipTest("docker compose not available")
        generated = REPO_ROOT / "docker-compose.generated-test.yml"
        result, _ = run_generator("--nodes", "2", output_path=generated)
        self.assertEqual(result.returncode, 0, result.stderr)
        try:
            check = subprocess.run(
                ["docker", "compose", "-f", str(generated), "config", "--quiet"],
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
            )
            self.assertEqual(check.returncode, 0, check.stderr)
        finally:
            generated.unlink(missing_ok=True)


if __name__ == "__main__":
    unittest.main()
