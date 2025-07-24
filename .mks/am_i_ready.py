#!/usr/bin/env python3
"""
Verifies that all required tools and dependencies are available for the project.
Rich-CLI style output for better user experience.
"""

import os
import subprocess
import sys


# ANSI Color Codes
class Colors:
    RESET = "\033[0m"
    BOLD = "\033[1m"
    DIM = "\033[2m"

    # Basic Colors
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    WHITE = "\033[37m"

    # Bold Colors
    BOLD_RED = "\033[1;31m"
    BOLD_GREEN = "\033[1;32m"
    BOLD_YELLOW = "\033[1;33m"
    BOLD_BLUE = "\033[1;34m"
    BOLD_MAGENTA = "\033[1;35m"
    BOLD_CYAN = "\033[1;36m"
    BOLD_WHITE = "\033[1;37m"

    # Bright Colors
    BRIGHT_GREEN = "\033[1;92m"
    BRIGHT_YELLOW = "\033[1;93m"
    BRIGHT_BLUE = "\033[1;94m"
    BRIGHT_MAGENTA = "\033[1;95m"
    BRIGHT_CYAN = "\033[1;96m"


class Requirements:
    # Define checks
    tools = {
        "git": "Version control system",
        "conda": "Package manager",
        "python3": "Python interpreter",
    }

    optional_tools = {
        "mamba": "Fast conda alternative",
        "uv": "Fast Python package manager",
        "snakemake": "Workflow management system",
    }

    python_packages = {
        "yaml": "YAML parsing library",
        "pathlib": "Path handling utilities",
        "subprocess": "Process management",
    }

    project_dirs = ["data", "workflow", "src", "tests", "logs", "results", "reports"]

    env_files = ["environment.yml", "environment-r.yml"]


def print_header(title, width=60):
    """Print a rich-style header."""
    border = "─" * width
    print(f"{Colors.BOLD_WHITE}╭{border}╮{Colors.RESET}")

    # Calculate visual width of title (accounting for emoji)
    # "🔍 SYSTEM READINESS CHECK" = emoji(2) + space(1) + text(21) = 24 chars visually
    title_visual_width = (
        len(title) + 1
    )  # +1 because emoji takes 2 spaces but len() counts it as 1
    title_padding = (width - title_visual_width) // 2
    remaining_padding = width - title_visual_width - title_padding

    # Adjust for perfect centering
    if title_padding + title_visual_width + remaining_padding < width:
        remaining_padding += 1

    print(
        f"{Colors.BOLD_WHITE}│{Colors.RESET}{' ' * title_padding}{Colors.BRIGHT_MAGENTA}{title}{Colors.RESET}{' ' * remaining_padding}{Colors.BOLD_WHITE}│{Colors.RESET}"
    )
    print(f"{Colors.BOLD_WHITE}╰{border}╯{Colors.RESET}")


def print_section(title, emoji="", width=60):
    """Print a section header."""
    # Empty line
    print()

    # Section title line
    section_text = f"{emoji} {title}" if emoji else title
    print(f"{Colors.BRIGHT_CYAN}{section_text}{Colors.RESET}")

    # Underline
    visual_width = len(title) + (3 if emoji else 0)  # emoji(2) + space(1) = 3
    print(f"{Colors.DIM}{Colors.WHITE}{'─' * visual_width}{Colors.RESET}")


def print_item(name, description, status, name_width=18, width=60):
    """Print an item with status."""
    if status == "ok":
        icon = "✅"
        name_color = Colors.BOLD_GREEN
    elif status == "missing":
        icon = "❌"
        name_color = Colors.BOLD_RED
    elif status == "warning":
        icon = "⚠️"
        name_color = Colors.BOLD_YELLOW
    else:
        icon = "❓"
        name_color = Colors.WHITE

    # Ensure name fits in allocated width
    truncated_name = name[:name_width].ljust(name_width)

    print(
        f"{icon} {name_color}{truncated_name}{Colors.RESET} {Colors.WHITE}{description}{Colors.RESET}"
    )


def print_footer(width=60):
    """Print the footer border."""
    print()


def check_command(cmd):
    """Check if a command is available in PATH."""
    try:
        subprocess.run([cmd, "--version"], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        try:
            subprocess.run(["which", cmd], capture_output=True, check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False


def check_python_package(package):
    """Check if a Python package is importable."""
    try:
        __import__(package)
        return True
    except ImportError:
        return False


def main(report_width=60):
    """Main function with Rich-CLI style output."""
    name_field_width = 18

    print()
    header_title = "🔍 SYSTEM READINESS CHECK"
    print_header(title=header_title, width=report_width)

    all_good = True

    # Check essential tools
    print_section(title="Essential Tools", emoji="🛠️", width=report_width)
    for tool, description in Requirements.tools.items():
        if check_command(tool):
            print_item(
                name=tool,
                description=description,
                status="ok",
                name_width=name_field_width,
                width=report_width,
            )
        else:
            print_item(
                name=tool,
                description=f"{description} (MISSING)",
                status="missing",
                name_width=name_field_width,
                width=report_width,
            )
            all_good = False

    # Check optional tools
    print_section("Optional Tools", "📦", width=report_width)
    for tool, description in Requirements.optional_tools.items():
        if check_command(tool):
            print_item(
                name=tool,
                description=description,
                status="ok",
                name_width=name_field_width,
                width=report_width,
            )
        else:
            print_item(
                name=tool,
                description=f"{description} (recommended)",
                status="warning",
                name_width=name_field_width,
                width=report_width,
            )

    # Check Python packages
    print_section("Python Packages", "🐍", width=report_width)
    for package, description in Requirements.python_packages.items():
        if check_python_package(package):
            print_item(
                name=package,
                description=description,
                status="ok",
                name_width=name_field_width,
                width=report_width,
            )
        else:
            print_item(
                name=package,
                description=f"{description} (MISSING)",
                status="missing",
                name_width=name_field_width,
                width=report_width,
            )
            all_good = False

    # Check project structure
    print_section("Project Structure", "📁", width=report_width)
    for directory in Requirements.project_dirs:
        if os.path.exists(directory):
            print_item(
                name=directory,
                description="Directory exists",
                status="ok",
                name_width=name_field_width,
                width=report_width,
            )
        else:
            print_item(
                name=directory,
                description="Directory missing (will be created)",
                status="warning",
                name_width=name_field_width,
                width=report_width,
            )

    # Check environment files
    print_section("Environment Files", "🔧", width=report_width)
    for env_file in Requirements.env_files:
        if os.path.exists(env_file):
            print_item(
                name=env_file,
                description="Environment file exists",
                status="ok",
                name_width=name_field_width,
                width=report_width,
            )
        else:
            print_item(
                name=env_file,
                description="Environment file missing",
                status="missing",
                name_width=name_field_width,
                width=report_width,
            )
            all_good = False

    # Final footer
    print_footer(width=report_width)
    print()

    if all_good:
        print(f"{Colors.BRIGHT_GREEN}🎉 System is ready for analysis!{Colors.RESET}")
        print(
            f"{Colors.BRIGHT_GREEN}🥳 Everything looks good! You're ready to start. 🚀{Colors.RESET}"
        )
        print()
        print(f"{Colors.BOLD_WHITE}👉 Next steps:{Colors.RESET}")
        print(
            f"   {Colors.BOLD_CYAN}ℹ️ make help{Colors.RESET}       - View all available commands"
        )
        print(
            f"   {Colors.BOLD_CYAN}📦 make full_setup{Colors.RESET} - Initialize the complete project"
        )
        print()
        sys.exit(0)
    else:
        print(f"{Colors.BOLD_RED}⚠️ Issues found that need attention{Colors.RESET}")
        print(f"{Colors.BOLD_WHITE}👉 Next steps:{Colors.RESET}")
        print(
            f"   {Colors.BOLD_YELLOW}1.{Colors.RESET} Install missing dependencies listed above"
        )
        print(
            f"   {Colors.BOLD_YELLOW}2.{Colors.RESET} Check the installation guide in README.md"
        )
        print(
            f"   {Colors.BOLD_YELLOW}3.{Colors.RESET} Run {Colors.BOLD_CYAN}make am_i_ready{Colors.RESET} again to verify"
        )
        print(
            f"\n{Colors.DIM}🔧 Don't worry, these issues are easy to fix!{Colors.RESET}"
        )
        print()
        sys.exit(1)


if __name__ == "__main__":
    main()
