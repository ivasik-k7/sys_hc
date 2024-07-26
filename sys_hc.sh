#!/usr/bin/env bash
# -*- coding: utf-8 -*-

GREEN='\033[32m'
RED='\033[31m'
CYAN='\033[36m'
YELLOW='\033[33m'
GREY='\033[90m'
NC='\033[0m'

print_header() {
    local title="$1"
    local border_char='─'
    local padding=4

    local title_length=${#title}
    local border_length=$((title_length + padding * 2 + 2))

    # shellcheck disable=SC2155
    local border=$(printf "%${border_length}s" | tr ' ' "$border_char")

    echo -e "${YELLOW}${BOLD}${UNDERLINE}${border}${NC}"
    echo -e "${YELLOW}${BOLD}${UNDERLINE}${border_char} ${border_char} ${title} ${border_char} ${border_char}${NC}"
    echo -e "${YELLOW}${BOLD}${UNDERLINE}${border}${NC}"
}
verify_installation() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

check_docker() {
    if verify_installation "docker"; then
        if docker info >/dev/null 2>&1; then
            echo -e "${YELLOW}Docker:${NC} ${GREEN}UP${NC}"
        else
            echo -e "${YELLOW}Docker:${NC} ${RED}DOWN${NC}"
        fi
    else
        echo -e "${YELLOW}Docker:${NC} ${GREY}N/A${NC}"
    fi
}

check_kubectl() {
    if command -v "kubectl" >/dev/null 2>&1 || command -v "kubectx" >/dev/null 2>&1; then
        if kubectl cluster-info >/dev/null 2>&1; then
            echo -e "${YELLOW}kubectl:${NC} ${GREEN}UP${NC}"
        else
            echo -e "${YELLOW}kubectl:${NC} ${RED}DOWN${NC}"
        fi
    else
        echo -e "${YELLOW}kubectl:${NC} ${GREY}N/A${NC}"
    fi
}
check_tomcat() {
    local tomcat_url="http://localhost:8080"
    if curl -s --head "$tomcat_url" | grep "200 OK" >/dev/null; then
        echo -e "${YELLOW}Tomcat:${NC} ${GREEN}UP${NC}"
    elif curl -s --head "$tomcat_url" | grep "301 Moved Permanently" >/dev/null; then
        echo -e "${YELLOW}Tomcat:${NC} ${GREEN}UP (Redirecting)${NC}"
    else
        echo -e "${YELLOW}Tomcat:${NC} ${RED}DOWN${NC}"
    fi
}

check_aws() {
    if verify_installation "aws"; then
        if aws sts get-caller-identity >/dev/null 2>&1; then
            echo -e "${YELLOW}AWS CLI:${NC} ${GREEN}UP${NC}"
        else
            echo -e "${YELLOW}AWS CLI:${NC} ${RED}DOWN${NC}"
        fi
    else
        echo -e "${YELLOW}AWS CLI:${NC} ${GREY}N/A${NC}"
    fi
}

check_rabbitmq() {
    local rabbitmq_url="http://localhost:15672"
    if verify_installation "rabbitmqctl"; then
        if rabbitmqctl status >/dev/null 2>&1; then
            echo -e "${YELLOW}RabbitMQ:${NC} ${GREEN}UP${NC}"
        else
            echo -e "${YELLOW}RabbitMQ:${NC} ${RED}DOWN${NC}"
        fi
    elif curl -s --head "$rabbitmq_url" | grep "200 OK" >/dev/null; then
        echo -e "${YELLOW}RabbitMQ:${NC} ${GREEN}UP${NC}"
    else
        echo -e "${YELLOW}RabbitMQ:${NC} ${RED}DOWN${NC}"
    fi
}

get_os_info() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        os=$(sw_vers --productName)
    else
        os=$(grep -E '^PRETTY_NAME=' /etc/os-release | awk -F= '{print $2}' | tr -d '"')
    fi
    echo "$os"
}

get_ip() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        ip=$(ipconfig getifaddr en0)
    else
        ip=$(hostname -I | awk '{print $1}')
    fi
    echo "$ip"
}

get_memory_size() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        memory_size=$(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 "G"}')
    else
        memory_size=$(free -h | grep Mem: | awk '{print $2}')
    fi
    echo "$memory_size"
}

get_installed_packages() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &>/dev/null; then
            installed_packages=$(brew list --formula | wc -l | tr -d ' ')
        else
            installed_packages="N/A (Homebrew not installed)"
        fi
    else
        if command -v dpkg >/dev/null; then
            installed_packages=$(dpkg --get-selections | grep -v deinstall | wc -l)
        elif command -v rpm >/dev/null; then
            installed_packages=$(rpm -qa | wc -l)
        else
            installed_packages="N/A (Unsupported package manager)"
        fi
    fi
    echo "$installed_packages"
}

display_system_info() {
    local user hostname ip os kernel_architecture cpu_cores memory_size disk_usage system_time uptime distro_version
    local installed_packages

    print_header "Server details:"

    user=$(whoami)
    hostname=$(hostname)
    ip=$(get_ip)
    os=$(get_os_info)
    kernel_architecture=$(uname -m)
    cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null || nproc)
    memory_size=$(get_memory_size)
    disk_usage=$(df -h / | awk '/\// {print $5}')
    system_time=$(date)
    uptime=$(uptime | awk -F'(up |,)' '{print $2}' | xargs)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        distro_version=$(sw_vers -productVersion)
    else
        distro_version=$(lsb_release -d 2>/dev/null | awk -F':' '{print $2}' | xargs || echo "N/A")
    fi
    installed_packages=$(get_installed_packages)

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
    echo -e "${CYAN}Installed Packages:${NC} $installed_packages"
}

display_memory_cpu_info() {
    echo -e "\n${CYAN}Memory Usage:${NC}\n"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        vm_stat
    else
        free -h
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
        load_averages=$(uptime | awk -F'averages: ' '{ print $2 }' | awk '{ print $1, $2, $3 }')
        one=$(echo "$load_averages" | awk '{print $1}')
        five=$(echo "$load_averages" | awk '{print $2}')
        fifteen=$(echo "$load_averages" | awk '{print $3}')

    else
        read -r one five fifteen </proc/loadavg
    fi

    echo -e "\n${CYAN}Load Average:${NC}\n1m: $one, 5m: $five, 15m: $fifteen"

}

display_core_info() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_header "CPU Core Information"
        echo -e "${GREY}$(sysctl -a | grep -E '^machdep.cpu' |
            sed -E -e 's/^machdep.cpu.cores_per_package: /Cores per Package: /' \
                -e 's/^machdep.cpu.core_count: /Total Cores: /' \
                -e 's/^machdep.cpu.logical_per_package: /Logical Cores per Package: /' \
                -e 's/^machdep.cpu.thread_count: /Total Threads: /' \
                -e 's/^machdep.cpu.brand_string: /CPU Brand: /')${NC}"

        print_header "Current CPU Usage Per Core"
        echo -e "${GREY}$(top -l 1 | grep "CPU usage:" |
            sed -E 's/CPU usage: ([0-9.]+)% user, ([0-9.]+)% sys, ([0-9.]+)% idle/\
User: \1%\nSystem: \2%\nIdle: \3%/')${NC}"
    else
        print_header "CPU Core Information"
        echo -e "${GREY}$(lscpu |
            sed -E -e 's/^CPU\(s\): /Total Cores: /' \
                -e 's/^Thread\(s\) per core: /Threads per Core: /' \
                -e 's/^Core\(s\) per socket: /Cores per Socket: /' \
                -e 's/^Socket\(s\): /Sockets: /')${NC}"

        print_header "Current CPU Usage Per Core"
        echo -e "${GREY}$(mpstat -P ALL 1 1 | awk '
        NR==1 { next }
        NR==2 { next }
        {
            printf "CPU %s: User: %.2f%%, System: %.2f%%, Idle: %.2f%%\n", $2, $4, $6, $12
        }')${NC}"
    fi
}

display_top_services() {
    echo -e "\n${CYAN}High Resource Usage (TOP10):${NC}\n"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${CYAN}PID    PPID   CMD                       %MEM    %CPU${NC}"
        top -o mem -l 1 | awk 'NR>12 && NR<=22 {printf "%-6s %-6s %-25s %-6s %-6s\n", $1, $2, $12, $8, $3}'
    else
        echo -e "${CYAN}PID    PPID   CMD                       %MEM    %CPU${NC}"
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 11 | awk 'NR>1 {printf "%-6s %-6s %-25s %-6s %-6s\n", $1, $2, $3, $4, $5}'
    fi
}

display_disk_info() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        total_space=$(df -h / | awk 'NR==2{print $2}')
        used_space=$(df -h / | awk 'NR==2{print $3}')
        available_space=$(df -h / | awk 'NR==2{print $4}')
        usage_percentage=$(df -h / | awk 'NR==2{print $5}')
    else
        total_space=$(df -h --total 2>/dev/null | grep 'total' | awk '{print $2}' || df -h / | awk 'NR==2{print $2}')
        used_space=$(df -h --total 2>/dev/null | grep 'total' | awk '{print $3}' || df -h / | awk 'NR==2{print $3}')
        available_space=$(df -h --total 2>/dev/null | grep 'total' | awk '{print $4}' || df -h / | awk 'NR==2{print $4}')
        usage_percentage=$(df -h --total 2>/dev/null | grep 'total' | awk '{print $5}' || df -h / | awk 'NR==2{print $5}')
    fi

    echo -e "${CYAN}Total Disk Space:${NC} $total_space"
    echo -e "${CYAN}Used Disk Space:${NC} $used_space"
    echo -e "${CYAN}Available Disk Space:${NC} $available_space"
    echo -e "${CYAN}Disk Usage Percentage:${NC} $usage_percentage"

    usage_percentage_value=$(echo "$usage_percentage" | tr -d '%')
    if [ "$usage_percentage_value" -ge 80 ]; then
        echo -e "${RED}Warning: Disk usage is high (${usage_percentage}). Please free up some space.${NC}"
    fi
}

display_network_info() {
    echo -e "\n${CYAN}Network Information:${NC}\n"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        ifconfig -a
    else
        ip -br addr
    fi
}

display_system_info

print_header "Services Status"
check_aws
check_docker
check_kubectl
check_tomcat
check_rabbitmq

print_header "System Information"
display_network_info
display_memory_cpu_info

display_core_info
display_top_services

print_header "Disk Usage Summary:"
display_disk_info

print_header "Disk Space Usage"
df -h
