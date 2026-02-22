#!/bin/bash

echo "Starting Rust and Cargo setup..."

# 1. Install Rustup non-interactively (if not already installed)
if ! command -v rustup &> /dev/null; then
    echo "Installing Rustup..."
    # The -y flag skips the interactive prompts
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
    echo "Rustup is already installed. Skipping base installation."
fi

# 2. Source the Cargo environment so the script can use 'cargo' immediately
source "$HOME/.cargo/env"

# 3. Update Rust to the latest stable version
echo "Updating Rust toolchain..."
rustup update

# 4. Install your essential Cargo binaries
# Add or remove packages from this list as needed
echo "Installing Cargo packages..."
cargo install \
    fnm \
    ripgrep \
    fd-find \
    eza \
    bat

echo "Rust and Cargo setup complete!"
