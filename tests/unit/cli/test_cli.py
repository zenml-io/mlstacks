from unittest.mock import patch

import pkg_resources
from click.testing import CliRunner

from mlstacks.cli import cli


def test_prints_version_when_package_installed():
    with patch("pkg_resources.get_distribution") as mock_get_distribution:
        mock_get_distribution.return_value.version = "1.2.3"

        runner = CliRunner()
        result = runner.invoke(cli.version)

        assert "mlstacks version: 1.2.3" in result.output


def test_handles_package_not_installed_gracefully():
    with patch("pkg_resources.get_distribution") as mock_get_distribution:
        mock_get_distribution.side_effect = pkg_resources.DistributionNotFound

        runner = CliRunner()
        result = runner.invoke(cli.version)

        assert "mlstacks package is not installed." in result.output
