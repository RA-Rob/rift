#!/bin/bash

# Dashboard command for Rift - Add Grafana dashboards to controller node

# Source common functions
if [ -f "/usr/libexec/rift/commands/common.sh" ]; then
    source "/usr/libexec/rift/commands/common.sh"
else
    source "$(dirname "$0")/common.sh"
fi

# Function to add dashboard to Grafana
add_dashboard() {
    local inventory_file="$1"
    local dashboard_file="$2"
    local grafana_url="$3"
    local grafana_user="$4"
    local grafana_password="$5"
    local verbose="$6"
    
    # Check requirements
    check_requirements "$inventory_file"
    
    # Validate dashboard file
    if [ ! -f "$dashboard_file" ]; then
        echo "Error: Dashboard file not found: $dashboard_file"
        exit 1
    fi
    
    # Validate JSON format
    if ! python3 -m json.tool "$dashboard_file" > /dev/null 2>&1; then
        echo "Error: Invalid JSON format in dashboard file: $dashboard_file"
        exit 1
    fi
    
    # Set default Grafana URL if not provided
    if [ -z "$grafana_url" ]; then
        grafana_url="http://localhost:3000"
    fi
    
    # Set default credentials if not provided
    if [ -z "$grafana_user" ]; then
        grafana_user="admin"
    fi
    
    if [ -z "$grafana_password" ]; then
        grafana_password="admin"
    fi
    
    echo "Adding Grafana dashboard to controller node..."
    echo "Dashboard file: $dashboard_file"
    echo "Grafana URL: $grafana_url"
    
    # Create temporary playbook for dashboard deployment
    local temp_playbook=$(mktemp)
    cat > "$temp_playbook" << 'EOF'
---
- name: Add Grafana Dashboard
  hosts: controller
  become: true
  vars:
    dashboard_file: "{{ dashboard_file_path }}"
    grafana_url: "{{ grafana_url }}"
    grafana_user: "{{ grafana_user }}"
    grafana_password: "{{ grafana_password }}"
  
  tasks:
    - name: Check if Grafana is running
      uri:
        url: "{{ grafana_url }}/api/health"
        method: GET
        status_code: 200
      register: grafana_health
      failed_when: false
      
    - name: Fail if Grafana is not accessible
      fail:
        msg: "Grafana is not accessible at {{ grafana_url }}. Please ensure Grafana is running on the controller node."
      when: grafana_health.status != 200
      
    - name: Read dashboard JSON file
      slurp:
        src: "{{ dashboard_file }}"
      register: dashboard_content
      delegate_to: localhost
      become: false
      
    - name: Parse dashboard JSON
      set_fact:
        dashboard_raw: "{{ dashboard_content.content | b64decode | from_json }}"
        
    - name: Determine dashboard format and prepare payload
      set_fact:
        dashboard_payload: |
          {%- if 'dashboard' in dashboard_raw -%}
            {# Wrapped format - use as is #}
            {{ {
              'dashboard': dashboard_raw.dashboard,
              'overwrite': true,
              'inputs': []
            } }}
          {%- else -%}
            {# Direct format - wrap it #}
            {{ {
              'dashboard': dashboard_raw,
              'overwrite': true,
              'inputs': []
            } }}
          {%- endif -%}
          
    - name: Import dashboard to Grafana
      uri:
        url: "{{ grafana_url }}/api/dashboards/db"
        method: POST
        body: "{{ dashboard_payload | to_json }}"
        body_format: json
        user: "{{ grafana_user }}"
        password: "{{ grafana_password }}"
        force_basic_auth: yes
        headers:
          Content-Type: "application/json"
        status_code: 200
      register: dashboard_import
      
    - name: Display import result
      debug:
        msg: "Dashboard imported successfully. Dashboard ID: {{ dashboard_import.json.id }}, UID: {{ dashboard_import.json.uid }}"
        
    - name: Save dashboard information
      copy:
        content: |
          Dashboard Import Information
          ==========================
          File: {{ dashboard_file }}
          Import Date: {{ ansible_date_time.iso8601 }}
          Grafana URL: {{ grafana_url }}
          Dashboard ID: {{ dashboard_import.json.id }}
          Dashboard UID: {{ dashboard_import.json.uid }}
          Dashboard URL: {{ grafana_url }}/d/{{ dashboard_import.json.uid }}
        dest: "/var/log/rift/dashboard-{{ dashboard_import.json.uid }}.log"
        mode: '0644'
      when: dashboard_import.json.id is defined
EOF
    
    # Run the playbook
    ansible-playbook $verbose "$temp_playbook" \
        -i "$inventory_file" \
        -e "dashboard_file_path=$dashboard_file" \
        -e "grafana_url=$grafana_url" \
        -e "grafana_user=$grafana_user" \
        -e "grafana_password=$grafana_password"
    
    local result=$?
    
    # Clean up temporary playbook
    rm -f "$temp_playbook"
    
    if [ $result -eq 0 ]; then
        echo "Dashboard successfully added to Grafana!"
    else
        echo "Failed to add dashboard. Check Grafana connectivity and credentials."
        exit 1
    fi
}

# Function to list dashboards
list_dashboards() {
    local inventory_file="$1"
    local grafana_url="$2"
    local grafana_user="$3"
    local grafana_password="$4"
    local verbose="$5"
    
    check_requirements "$inventory_file"
    
    # Set defaults
    if [ -z "$grafana_url" ]; then
        grafana_url="http://localhost:3000"
    fi
    
    if [ -z "$grafana_user" ]; then
        grafana_user="admin"
    fi
    
    if [ -z "$grafana_password" ]; then
        grafana_password="admin"
    fi
    
    echo "Listing Grafana dashboards on controller node..."
    
    # Create temporary playbook for listing dashboards
    local temp_playbook=$(mktemp)
    cat > "$temp_playbook" << 'EOF'
---
- name: List Grafana Dashboards
  hosts: controller
  become: true
  vars:
    grafana_url: "{{ grafana_url }}"
    grafana_user: "{{ grafana_user }}"
    grafana_password: "{{ grafana_password }}"
  
  tasks:
    - name: Get list of dashboards
      uri:
        url: "{{ grafana_url }}/api/search?query=&type=dash-db"
        method: GET
        user: "{{ grafana_user }}"
        password: "{{ grafana_password }}"
        force_basic_auth: yes
        headers:
          Content-Type: "application/json"
        status_code: 200
      register: dashboards_list
      
    - name: Display dashboards
      debug:
        msg: |
          Found {{ dashboards_list.json | length }} dashboard(s):
          {% for dashboard in dashboards_list.json %}
          - Title: {{ dashboard.title }}
            UID: {{ dashboard.uid }}
            URL: {{ grafana_url }}/d/{{ dashboard.uid }}
            Tags: {{ dashboard.tags | join(', ') if dashboard.tags else 'None' }}
          {% endfor %}
EOF
    
    # Run the playbook
    ansible-playbook $verbose "$temp_playbook" \
        -i "$inventory_file" \
        -e "grafana_url=$grafana_url" \
        -e "grafana_user=$grafana_user" \
        -e "grafana_password=$grafana_password"
    
    local result=$?
    
    # Clean up temporary playbook
    rm -f "$temp_playbook"
    
    return $result
}

# Function to validate dashboard JSON
validate_dashboard() {
    local dashboard_file="$1"
    
    if [ ! -f "$dashboard_file" ]; then
        echo "Error: Dashboard file not found: $dashboard_file"
        return 1
    fi
    
    echo "Validating dashboard file: $dashboard_file"
    
    # Check JSON syntax
    if ! python3 -m json.tool "$dashboard_file" > /dev/null 2>&1; then
        echo "Error: Invalid JSON format"
        return 1
    fi
    
    # Check for required fields
    local dashboard_content=$(cat "$dashboard_file")
    
    # Check if this is a wrapped dashboard (with "dashboard" field) or direct dashboard
    if echo "$dashboard_content" | python3 -c "import sys, json; data = json.load(sys.stdin); print('dashboard' in data)" | grep -q "True"; then
        # Wrapped format - check nested fields within dashboard
        echo "Detected wrapped dashboard format"
        local required_fields=("title" "panels")
        for field in "${required_fields[@]}"; do
            if ! echo "$dashboard_content" | python3 -c "import sys, json; data = json.load(sys.stdin); print('$field' in data.get('dashboard', {}))" | grep -q "True"; then
                echo "Warning: Dashboard JSON missing recommended field: dashboard.$field"
            fi
        done
    else
        # Direct format - check root level fields
        echo "Detected direct dashboard format"
        local required_fields=("title" "panels")
        for field in "${required_fields[@]}"; do
            if ! echo "$dashboard_content" | python3 -c "import sys, json; data = json.load(sys.stdin); print('$field' in data)" | grep -q "True"; then
                echo "Warning: Dashboard JSON missing recommended field: $field"
            fi
        done
    fi
    
    echo "Dashboard validation completed"
    return 0
}

# Main dashboard command handler
handle_dashboard_command() {
    local subcommand="$1"
    shift
    
    # Dashboard command usage
    dashboard_usage() {
        echo "Dashboard Management for Rift"
        echo
        echo "Usage: rift dashboard <subcommand> [options]"
        echo
        echo "Subcommands:"
        echo "  add       Add a dashboard from JSON file to Grafana"
        echo "  list      List existing dashboards in Grafana"
        echo "  validate  Validate a dashboard JSON file"
        echo "  help      Show this help message"
        echo
        echo "Add Dashboard Options:"
        echo "  -d, --dashboard   Dashboard JSON file path (required)"
        echo "  -u, --url         Grafana URL (default: http://localhost:3000)"
        echo "  --user            Grafana username (default: admin)"
        echo "  --password        Grafana password (default: admin)"
        echo
        echo "Examples:"
        echo "  rift dashboard add -d my-dashboard.json"
        echo "  rift dashboard add -d dashboard.json -u http://grafana.example.com:3000"
        echo "  rift dashboard list"
        echo "  rift dashboard validate -d dashboard.json"
    }
    
    case "$subcommand" in
        add)
            local dashboard_file=""
            local grafana_url=""
            local grafana_user=""
            local grafana_password=""
            
            # Parse add command arguments
            while [[ $# -gt 0 ]]; do
                case $1 in
                    -d|--dashboard)
                        dashboard_file="$2"
                        shift 2
                        ;;
                    -u|--url)
                        grafana_url="$2"
                        shift 2
                        ;;
                    --user)
                        grafana_user="$2"
                        shift 2
                        ;;
                    --password)
                        grafana_password="$2"
                        shift 2
                        ;;
                    *)
                        echo "Unknown option: $1"
                        dashboard_usage
                        exit 1
                        ;;
                esac
            done
            
            if [ -z "$dashboard_file" ]; then
                echo "Error: Dashboard file is required"
                dashboard_usage
                exit 1
            fi
            
            add_dashboard "$INVENTORY_FILE" "$dashboard_file" "$grafana_url" "$grafana_user" "$grafana_password" "$VERBOSE"
            ;;
            
        list)
            local grafana_url=""
            local grafana_user=""
            local grafana_password=""
            
            # Parse list command arguments
            while [[ $# -gt 0 ]]; do
                case $1 in
                    -u|--url)
                        grafana_url="$2"
                        shift 2
                        ;;
                    --user)
                        grafana_user="$2"
                        shift 2
                        ;;
                    --password)
                        grafana_password="$2"
                        shift 2
                        ;;
                    *)
                        echo "Unknown option: $1"
                        dashboard_usage
                        exit 1
                        ;;
                esac
            done
            
            list_dashboards "$INVENTORY_FILE" "$grafana_url" "$grafana_user" "$grafana_password" "$VERBOSE"
            ;;
            
        validate)
            local dashboard_file=""
            
            # Parse validate command arguments
            while [[ $# -gt 0 ]]; do
                case $1 in
                    -d|--dashboard)
                        dashboard_file="$2"
                        shift 2
                        ;;
                    *)
                        echo "Unknown option: $1"
                        dashboard_usage
                        exit 1
                        ;;
                esac
            done
            
            if [ -z "$dashboard_file" ]; then
                echo "Error: Dashboard file is required"
                dashboard_usage
                exit 1
            fi
            
            validate_dashboard "$dashboard_file"
            ;;
            
        help|--help|-h)
            dashboard_usage
            ;;
            
        "")
            echo "Error: Dashboard subcommand is required"
            dashboard_usage
            exit 1
            ;;
            
        *)
            echo "Error: Unknown dashboard subcommand: $subcommand"
            dashboard_usage
            exit 1
            ;;
    esac
} 