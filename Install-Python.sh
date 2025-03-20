#!/bin/bash

# Log file
LOG_FILE="python_install_new1.log"

# Logging function
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    log "Please run the script as root or with sudo."
    exit 1
fi

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
    else
        log "Cannot detect OS. Exiting."
        exit 1
    fi
}

# Install Python on Ubuntu/Debian
install_python_apt() {
    log "Detected Ubuntu/Debian OS."
    log "Updating package list..."
    apt update -y >> "$LOG_FILE" 2>&1

    log "Installing prerequisites..."
    apt install -y software-properties-common >> "$LOG_FILE" 2>&1

    log "Adding Python PPA..."
    add-apt-repository -y ppa:deadsnakes/ppa >> "$LOG_FILE" 2>&1

    log "Installing Python..."
    apt update -y >> "$LOG_FILE" 2>&1
    apt install -y python3 python3-pip python3-venv >> "$LOG_FILE" 2>&1
}

# Install Python on CentOS/RHEL
install_python_yum() {
    log "Detected CentOS/RHEL OS."
    log "Installing prerequisites..."
    yum install -y gcc openssl-devel bzip2 bzip2-devel libffi-devel >> "$LOG_FILE" 2>&1

    log "Installing Python..."
    yum install -y python3 python3-pip >> "$LOG_FILE" 2>&1
}

# Verify Python installation
verify_python() {
    if command -v python3 &>/dev/null; then
        PYTHON_VERSION=$(python3 --version)
        log "✅ Python installed successfully: $PYTHON_VERSION"
    else
        log "❌ Python installation failed."
        exit 1
    fi
}

# Main execution
log "Starting Python installation..."
detect_os

case "$OS" in
    ubuntu|debian)
        install_python_apt
        ;;
    centos|rhel)
        install_python_yum
        ;;
    *)
        log "Unsupported OS: $OS"
        exit 1
        ;;
esac

verify_python
log "Python installation completed successfully!"
