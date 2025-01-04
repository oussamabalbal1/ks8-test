#!/bin/bash

# Define variables
GIT_REPO_URL="https://github.com/oussamabalbal1/project-zero"
PROJECT_DIR="/home/ubuntu/project-zero"
PLAYBOOKS_DIR="$PROJECT_DIR/ansible/"
INVENTORY_FILE="$PLAYBOOKS_DIR/inventory"
SLEEP_DURATION=5  # Sleep duration in seconds

# Clone the Git repository
# echo "Cloning the repository..."
# if git clone "$GIT_REPO_URL" ; then
#   echo "Repository cloned successfully to $PROJECT_DIR."
# else
#   echo "Failed to clone repository. Exiting."
#   exit 1  
# fi

# Change to the playbooks directory
cd "$PLAYBOOKS_DIR" || { echo "Playbooks directory not found. Exiting."; exit 1; }


# ===========
# STORE PLAYBOOKS IN A VARIBALE

# Check if the directory exists
if [[ -d "$PLAYBOOKS_DIR" ]]; then
  echo "Will execute playbooks that inside $PLAYBOOKS_DIR..."

  # List files, sort numerically and alphabetically, and store in a variable
  PLAYBOOKS=($(ls -1 "$PLAYBOOKS_DIR" | grep -i yaml | sort -V | head -10))

  # Print the sorted files
  echo "Execute playbooks in ordred way like this :"
  echo "$PLAYBOOKS"
else
  echo "Directory $PLAYBOOKS_DIR does not exist. Exiting."
  exit 1
fi

# ===========
# EXECUTE PLAYBOOKS
for playbook in "${PLAYBOOKS[@]}"; do
    echo "Running $playbook..."
    if [[ "$playbook" == "5-k8s-install-dependencies.yaml" ]]; then
        sleep 4m
        ansible-playbook "$playbook" -i "$INVENTORY_FILE"
    else
        ansible-playbook "$playbook" -i "$INVENTORY_FILE"
        echo "Finished running $playbook. Sleeping for $SLEEP_DURATION seconds..."
        sleep "$SLEEP_DURATION"
    fi
done

echo "All tasks completed."
