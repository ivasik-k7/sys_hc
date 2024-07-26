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

## Installation

To install `sys_hc.sh`, you can use `curl` to download the script directly from this repository. Run the following command in your terminal:

```bash
curl -o sys_hc.sh https://raw.githubusercontent.com/ivasik-k7/sys_hc/main/sys_hc.sh
```

After downloading, make the script executable:

```bash
chmod +x sys_hc.sh
```

After that you can launch it by executing the command:

```
./sys_hc.sh
```

## Contribution

Feel free to submit issues or pull requests if you have suggestions for improvements or bug fixes. Your contributions are welcome!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
