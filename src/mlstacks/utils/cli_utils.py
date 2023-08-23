#  Copyright (c) ZenML GmbH 2023. All Rights Reserved.
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at:
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
#  or implied. See the License for the specific language governing
#  permissions and limitations under the License.
"""CLI utilities for mlstacks."""

from pathlib import Path
from typing import TYPE_CHECKING, Any, Dict, List, NoReturn, Optional, Union

import click
from rich import box, table
from rich.console import Console
from rich.markdown import Markdown
from rich.markup import escape
from rich.prompt import Confirm
from rich.style import Style
from rich.theme import Theme

from mlstacks.constants import MLSTACKS_PACKAGE_NAME

mlstacks_style_defaults = {
    "info": Style(color="cyan", dim=True),
    "warning": Style(color="yellow"),
    "danger": Style(color="red", bold=True),
    "title": Style(color="cyan", bold=True, underline=True),
    "error": Style(color="red"),
}

mlstacks_custom_theme = Theme(mlstacks_style_defaults)

console = Console(theme=mlstacks_custom_theme, markup=True)
error_console = Console(stderr=True, theme=mlstacks_custom_theme)


if TYPE_CHECKING:
    from rich.text import Text


def title(text: str) -> None:
    """Echo a title formatted string on the CLI.

    Args:
        text: Input text string.
    """
    console.print(text.upper(), style=mlstacks_style_defaults["title"])


def confirmation(text: str, default: bool = False) -> bool:
    """Echo a confirmation string on the CLI.

    Args:
        text: Input text string.
        default: Default value for the confirmation.

    Returns:
        Boolean based on user response.
    """
    return Confirm.ask(text, console=console, default=default)


def declare(
    text: Union[str, "Text"],
    bold: Optional[bool] = None,
    italic: Optional[bool] = None,
    **kwargs: Any,
) -> None:
    """Echo a declaration on the CLI.

    Args:
        text: Input text string.
        bold: Optional boolean to bold the text.
        italic: Optional boolean to italicize the text.
        **kwargs: Optional kwargs to be passed to console.print().
    """
    base_style = mlstacks_style_defaults["info"]
    style = Style.chain(base_style, Style(bold=bold, italic=italic))
    console.print(text, style=style, **kwargs)


def error(text: str) -> NoReturn:
    """Echo an error string on the CLI.

    Args:
        text: Input text string.

    Raises:
        ClickException: when called.
    """
    raise click.ClickException(message=click.style(text, fg="red", bold=True))


def warning(
    text: str,
    bold: Optional[bool] = None,
    italic: Optional[bool] = None,
    **kwargs: Any,
) -> None:
    """Echo a warning string on the CLI.

    Args:
        text: Input text string.
        bold: Optional boolean to bold the text.
        italic: Optional boolean to italicize the text.
        **kwargs: Optional kwargs to be passed to console.print().
    """
    base_style = mlstacks_style_defaults["warning"]
    style = Style.chain(base_style, Style(bold=bold, italic=italic))
    console.print(text, style=style, **kwargs)


def print_markdown(text: str) -> None:
    """Prints a string as markdown.

    Args:
        text: Markdown string to be printed.
    """
    markdown_text = Markdown(text)
    console.print(markdown_text)


def print_markdown_with_pager(text: str) -> None:
    """Prints a string as markdown with a pager.

    Args:
        text: Markdown string to be printed.
    """
    markdown_text = Markdown(text)
    with console.pager():
        console.print(markdown_text)


def print_table(
    obj: List[Dict[str, Any]],
    title: Optional[str] = None,
    caption: Optional[str] = None,
    **columns: table.Column,
) -> None:
    """Prints the list of dicts in a table format.

    The input object should be a List of Dicts. Each item in that list
    represent a line in the Table. Each dict should have the same keys.
    The keys of the dict will be used as headers of the resulting table.

    Args:
        obj: A List containing dictionaries.
        title: Title of the table.
        caption: Caption of the table.
        columns: Optional column configurations to be used in the table.
    """
    column_keys = {key: None for dict_ in obj for key in dict_}
    column_names = [columns.get(key, key.upper()) for key in column_keys]
    rich_table = table.Table(
        box=box.HEAVY_EDGE,
        show_lines=True,
        title=title,
        caption=caption,
    )
    for col_name in column_names:
        if isinstance(col_name, str):
            rich_table.add_column(str(col_name), overflow="fold")
        else:
            rich_table.add_column(
                str(col_name.header).upper(),
                overflow="fold",
            )
    for dict_ in obj:
        values = []
        for key in column_keys:
            if key is None:
                values.append(None)
            else:
                value = str(dict_.get(key) or " ")
                # escape text when square brackets are used
                if "[" in value:
                    value = escape(value)
                values.append(value)
        rich_table.add_row(*values)
    if len(rich_table.columns) > 1:
        rich_table.columns[0].justify = "center"
    console.print(rich_table)


def pretty_print_output_vals(
    output_vals: Dict[str, str],
) -> None:
    """Prints dictionary values as a rich table.

    Args:
        output_vals: Dictionary of output values.
    """
    title: Optional[str] = "Terraform Output Values"

    stack_dicts = [
        {
            "OUTPUT_KEY": key,
            "OUTPUT_VALUE": value,
        }
        for key, value in output_vals.items()
    ]

    print_table(stack_dicts, title=title)


def _get_spec_dir(stack_name: str) -> str:
    """Gets the path to the spec directory for a given stack.

    Args:
        stack_name: The name of the stack.

    Returns:
        The path to the spec directory.
    """
    return str(
        Path(click.get_app_dir(MLSTACKS_PACKAGE_NAME))
        / "stack_specs"
        / stack_name,
    )
