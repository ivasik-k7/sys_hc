# System Health Check Script

`sys_hc.sh` is a versatile bash script designed to provide a comprehensive snapshot of your system's health and performance. Whether you're managing a local development environment or monitoring a production server, this script offers a wide range of diagnostic information to help you keep track of system status and troubleshoot issues.

## Features

- **Service Status Checks**:

  - **Docker**: Verifies if Docker is installed and operational.
  - **kubectl**: Checks the status of Kubernetes command-line tools.
  - **Tomcat**: Checks if the Tomcat server is running or redirecting.
  - **AWS CLI**: Verifies the availability of the AWS CLI tool.
  - **RabbitMQ**: Checks the status of RabbitMQ service.

- **System Information**:

  - **Operating System**: Identifies the OS version and type.
  - **IP Address**: Retrieves the system's IP address.
  - **Memory Size**: Provides the total memory size.
  - **Installed Packages**: Counts the number of installed packages.

- **Performance Metrics**:

  - **Memory Usage**: Displays memory usage statistics.
  - **CPU Load**: Shows the system's CPU load averages.
  - **CPU Cores**: Provides details on the number of CPU cores and their utilization.

- **Resource Usage**:

  - **Top Processes**: Lists the top processes by memory and CPU usage.

- **Disk Information**:

  - **Disk Space**: Reports total, used, and available disk space.
  - **Disk Usage**: Provides disk usage percentage and a warning if usage is high.

- **Network Information**:
  - **Network Interfaces**: Displays network interface details.

## Single Use

If you prefer not to install the script and just want to run it once, you can use the following command to download and run the script directly:

```bash
curl -s https://raw.githubusercontent.com/ivasik-k7/sys_hc/main/sys_hc.sh | bash
```

Alternatively, if you want to download the script first and then run it:

```bash
curl -o sys_hc.sh https://raw.githubusercontent.com/ivasik-k7/sys_hc/main/sys_hc.sh
chmod +x sys_hc.sh
./sys_hc.sh
```

## Installation

To install `sys_hc.sh`, you can use `curl` to download the installation script directly from this repository. Follow the steps below:

1. **Download and Run the Installation Script:**

   ```bash
   curl -s https://raw.githubusercontent.com/ivasik-k7/sys_hc/main/install.sh | bash
   ```

2. **Verify Installation:**
   After running the installation script, you can use the `monitor` command to run the system monitor script from any location:
   ```bash
   monitor
   ```

## Uninstallation

To uninstall `sys_hc.sh` and remove the `monitor` command, use the following steps:

1. **Download and Run the Uninstallation Script:**

   ```bash
   curl -s https://raw.githubusercontent.com/ivasik-k7/sys_hc/main/uninstall.sh | bash
   ```

2. **Verify Uninstallation:**
   Ensure the `monitor` command is no longer available:
   ```bash
   monitor
   # Expected output: bash: monitor: command not found
   ```

## Additional Information

### System Requirements

- **Operating System**: This script is compatible with macOS and Linux distributions.
- **Permissions**: Some commands may require elevated permissions (e.g., `sudo`) to access certain system details or manage services.
- **Dependencies**: Ensure that the necessary tools (e.g., `curl`, `wget`, `df`, `top`, etc.) are installed on your system.

### Troubleshooting

- **Command Not Found**: If you encounter `command not found` errors, ensure the required tools are installed and available in your system's PATH.
- **Service Checks**: For accurate service status checks, ensure the services (Docker, kubectl, Tomcat, AWS CLI, RabbitMQ) are installed and configured correctly on your system.

### Contributing

Feel free to submit issues or pull requests if you have suggestions for improvements or bug fixes. Your contributions are welcome! Here are some ways you can contribute:

1. **Report Bugs**: If you find a bug, please report it by opening an issue.
2. **Suggest Features**: If you have an idea for a new feature, we would love to hear about it.
3. **Submit Pull Requests**: If you have made improvements to the script, submit a pull request with your changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
