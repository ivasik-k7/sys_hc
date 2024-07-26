#!/usr/bin/env bash
# -*- coding: utf-8 -*-

NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'

print_header() {
    local title="$1"
    local length=${#title}
    local border=$(printf '%0.s-' $(seq 1 $((length + 8))))

    echo -e "${YELLOW}${BOLD}${UNDERLINE}${border}${NC}"
    echo -e "${YELLOW}${BOLD}${UNDERLINE}   $title   ${NC}"
    echo -e "${YELLOW}${BOLD}${UNDERLINE}${border}${NC}"
}

check_service() {
    local service_name="$1"
    local check_command="$2"
    local success_string="$3"

    echo -e "${YELLOW}${service_name}${NC}"
    if eval "$check_command" | grep -q "$success_string"; then
        echo -e "   Status: ${GREEN}UP${NC}"
    else
        echo -e "   Status: ${RED}DOWN${NC}"
    fi
    echo ""
}

check_docker_status() {
    echo -e "${YELLOW}5) Docker${NC}"
    if systemctl is-active --quiet docker; then
        echo -e "   Status: ${GREEN}UP${NC}"
    else
        echo -e "   Status: ${RED}DOWN${NC}"
    fi
}

display_system_info() {
    local user hostname ip os kernel_architecture cpu_cores memory_size disk_usage system_time uptime
    local distro_version hostnamectl_version
    local installed_packages

    print_header "Server details:"

    user=$(whoami)
    hostname=$(hostname)
    ip=$(hostname -I | awk '{print $1}')
    os=$(grep -E '^PRETTY_NAME=' /etc/os-release | awk -F= '{print $2}' | tr -d '"')
    kernel_architecture=$(uname -m)
    cpu_cores=$(nproc)
    memory_size=$(free -h | grep Mem: | awk '{print $2}')
    disk_usage=$(df -h / | awk '/\// {print $5}')
    system_time=$(date)
    uptime=$(uptime -p)
    distro_version=$(lsb_release -d | awk -F':' '{print $2}' | xargs)
    hostnamectl_version=$(hostnamectl | grep "Operating System:" | awk -F: '{print $2}' | xargs)

    if command -v dpkg >/dev/null; then
        installed_packages=$(dpkg --get-selections | grep -v deinstall | wc -l)
    elif command -v rpm >/dev/null; then
        installed_packages=$(rpm -qa | wc -l)
    else
        installed_packages="N/A (Unsupported package manager)"
    fi

    echo -e "${CYAN}User:${NC} $user"
    echo -e "${CYAN}Hostname:${NC} $hostname"
    echo -e "${CYAN}IP Address:${NC} $ip"
    echo -e "${CYAN}OS:${NC} $os"
    echo -e "${CYAN}Kernel Architecture:${NC} $kernel_architecture"
    echo -e "${CYAN}CPU Cores:${NC} $cpu_cores"
    echo -e "${CYAN}Memory Size:${NC} $memory_size"
    echo -e "${CYAN}Disk Usage (Root):${NC} $disk_usage"
    echo -e "${CYAN}System Time:${NC} $system_time"
    echo -e "${CYAN}System Uptime:${NC} $uptime"
    echo -e "${CYAN}Distribution Version:${NC} $distro_version"
    echo -e "${CYAN}Hostnamectl Version:${NC} $hostnamectl_version"
    echo -e "${CYAN}Installed Packages:${NC} $installed_packages"
}

display_memory_cpu_info() {
    echo -e "\n${CYAN}Memory Usage:${NC}\n"

    free -h

    # loadaverage=$(awk -F'[:, ]+' '/load average:/ {print $12, $13, $14}' /proc/loadavg)
    # echo -e "\n${CYAN}Load Average:${NC}\n $loadaverage"

    read -r one five fifteen </proc/loadavg
    echo -e "\n${CYAN}Load Average:${NC}\n1m: $one, 5m: $five, 15m: $fifteen"
}

display_top_services() {
    echo -e "\n${CYAN}High Resource Usage (TOP10):${NC}\n"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
}

display_disk_info() {
    total_space=$(df -h --total | grep 'total' | awk '{print $2}')
    used_space=$(df -h --total | grep 'total' | awk '{print $3}')
    available_space=$(df -h --total | grep 'total' | awk '{print $4}')
    usage_percentage=$(df -h --total | grep 'total' | awk '{print $5}')

    echo -e "${CYAN}Total Disk Space:${NC} $total_space"
    echo -e "${CYAN}Used Disk Space:${NC} $used_space"
    echo -e "${CYAN}Available Disk Space:${NC} $available_space"
    echo -e "${CYAN}Disk Usage Percentage:${NC} $usage_percentage"

    usage_percentage_value=$(echo "$usage_percentage" | tr -d '%')
    if [ "$usage_percentage_value" -ge 80 ]; then
        echo -e "${RED}Warning: Disk usage is high (${usage_percentage}). Please free up some space.${NC}"
    fi

    print_header "Disk Space Usage"
    df -h
}

# check_service() {
#     local service_name="$1"
#     local service_command="$2"

#     echo -e "${CYAN}Checking ${service_name}...${NC}"

#     if command -v "$service_command" &>/dev/null; then
#         echo -e "${CYAN}${service_name} is installed.${NC}"

#         # Check if the service is running
#         if systemctl is-active --quiet "$service_command" || service "$service_command" status &>/dev/null; then
#             echo -e "${CYAN}${service_name} status: ${GREEN}RUNNING${NC}"
#         else
#             echo -e "${CYAN}${service_name} status: ${RED}NOT RUNNING${NC}"
#         fi
#     else
#         echo -e "${RED}${service_name} is not installed.${NC}"
#     fi
# }

# detect_and_check_services() {
#     print_header "Service Detection and Status Check"

#     local services=(
#         "Docker|docker"
#         "Tomcat|tomcat"
#         "AWS CLI|aws"
#         "Nginx|nginx"
#         "MySQL|mysql"
#         "PostgreSQL|postgres"
#         "Apache|apache2"
#         "Redis|redis-server"
#     )

#     for service in "${services[@]}"; do
#         IFS='|' read -r service_name service_command <<<"$service"
#         check_service "$service_name" "$service_command"
#     done
# }

check_service() {
    local service_name="$1"
    local service_command="$2"
    local service_status_cmd="$3"
    local status="UNKNOWN"

    if command -v "$service_command" &>/dev/null; then
        if [ -n "$service_status_cmd" ]; then
            if eval "$service_status_cmd" | grep -q 'active (running)'; then
                status="UP"
            elif eval "$service_status_cmd" | grep -q 'inactive (dead)\|failed'; then
                status="DOWN"
            else
                status="UNKNOWN"
            fi
        else
            if systemctl is-active --quiet "$service_command" || pgrep -x "$service_command" >/dev/null; then
                status="UP"
            else
                status="DOWN"
            fi
        fi
    else
        status="UNKNOWN"
    fi

    case $status in
    UP)
        echo -e "${CYAN}${service_name} status: ${GREEN}UP${NC}"
        ;;
    DOWN)
        echo -e "${CYAN}${service_name} status: ${RED}DOWN${NC}"
        ;;
    UNKNOWN)
        echo -e "${CYAN}${service_name} status: ${RED}UNKNOWN${NC}"
        ;;
    esac
}
check_services() {

    if command -v aws &>/dev/null; then
        if aws --version &>/dev/null; then
            echo -e "${CYAN}AWS CLI status: ${GREEN}WORKING${NC}"
        else
            echo -e "${CYAN}AWS CLI status: ${RED}NOT WORKING${NC}"
        fi
    else
        echo -e "${RED}AWS CLI is not installed.${NC}"
    fi

    check_service "Docker" "docker" "systemctl status docker"
    check_service "Tomcat" "tomcat" "systemctl status tomcat"
    check_service "MySQL" "mysql" "systemctl status mysql"
    check_service "PostgreSQL" "postgres" "systemctl status postgresql"
    check_service "Apache HTTP Server" "httpd" "systemctl status httpd"
    check_service "Nginx" "nginx" "systemctl status nginx"
    check_service "Jenkins" "jenkins" "systemctl status jenkins"
    check_service "Redis" "redis-server" "systemctl status redis-server"
    check_service "MongoDB" "mongod" "systemctl status mongod"
    check_service "Elasticsearch" "elasticsearch" "systemctl status elasticsearch"
    check_service "Grafana" "grafana-server" "systemctl status grafana-server"
    check_service "Prometheus" "prometheus" "systemctl status prometheus"
    check_service "RabbitMQ" "rabbitmq-server" "systemctl status rabbitmq-server"

}

display_network_info() {
    echo -e "\n${CYAN}Network Information:${NC}\n"
    ip -br addr
}

display_system_info

print_header "Services Status"
check_services

print_header "System Information"
display_network_info
display_memory_cpu_info
display_top_services

print_header "Disk Usage Summary:"
display_disk_info
