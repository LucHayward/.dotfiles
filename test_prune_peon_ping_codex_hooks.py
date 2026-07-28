import unittest

from prune_peon_ping_codex_hooks import BLOCK_END, BLOCK_START, prune_config


def managed_block(install_dir: str, events: list[str]) -> str:
    sections = [BLOCK_START, f"# install_dir = {install_dir}"]
    for event in events:
        sections.extend(
            [
                f"[[hooks.{event}]]",
                "",
                f"[[hooks.{event}.hooks]]",
                'type = "command"',
                f'command = "{install_dir}/{event}"',
                "",
            ]
        )
    sections.append(BLOCK_END)
    return "\n".join(sections) + "\n"


class PruneConfigTest(unittest.TestCase):
    def test_removes_disabled_hooks_and_state(self) -> None:
        config = managed_block(
            "/latest",
            ["SessionStart", "PermissionRequest", "UserPromptSubmit", "Stop"],
        ).replace(
            BLOCK_END,
            """[hooks.state."/tmp/config.toml:permission_request:0:0"]
trusted_hash = "permission"

[hooks.state."/tmp/config.toml:stop:0:0"]
trusted_hash = "stop"

"""
            + BLOCK_END,
        )

        result = prune_config(config)

        self.assertIn("[[hooks.SessionStart]]", result)
        self.assertIn("[[hooks.Stop]]", result)
        self.assertIn(":stop:0:0", result)
        self.assertNotIn("PermissionRequest", result)
        self.assertNotIn("UserPromptSubmit", result)
        self.assertNotIn(":permission_request:0:0", result)

    def test_keeps_only_latest_managed_block(self) -> None:
        config = (
            managed_block("/old", ["SessionStart", "Stop"])
            + "\n[tui]\npet = \"disabled\"\n\n"
            + managed_block(
                "/latest",
                ["SessionStart", "SubagentStart", "PreCompact", "Stop"],
            )
        )

        result = prune_config(config)

        self.assertEqual(1, result.count(BLOCK_START))
        self.assertEqual(1, result.count(BLOCK_END))
        self.assertNotIn("/old", result)
        self.assertIn("/latest", result)
        self.assertNotIn("SubagentStart", result)
        self.assertIn("[tui]", result)

    def test_leaves_unmanaged_config_unchanged(self) -> None:
        config = "[tui]\npet = \"disabled\"\n"

        self.assertEqual(config, prune_config(config))

    def test_is_idempotent(self) -> None:
        config = managed_block("/latest", ["SessionStart", "PreCompact", "Stop"])
        pruned = prune_config(config)

        self.assertEqual(pruned, prune_config(pruned))


if __name__ == "__main__":
    unittest.main()
