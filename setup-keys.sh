#!/bin/bash

echo "Loading API keys..."

# Get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_PATH="$DIR/Config.xcconfig"

if [ ! -f "$CONFIG_PATH" ]; then
    CONFIG_PATH="$DIR/ParentingAssistant/Config.xcconfig"
    if [ ! -f "$CONFIG_PATH" ]; then
        echo "❌ Config.xcconfig not found!"
        exit 1
    fi
fi

echo "✅ Found config file: $CONFIG_PATH"

# Extract API keys
OPENAI_KEY=$(grep -E "^OPENAI_API_KEY=" "$CONFIG_PATH" | cut -d '=' -f 2-)
FIREBASE_KEY=$(grep -E "^FIREBASE_KEY=" "$CONFIG_PATH" | cut -d '=' -f 2-)

echo "Extracted OPENAI API Key (truncated): ${OPENAI_KEY:0:10}..."
echo "Extracted FIREBASE API Key (truncated): ${FIREBASE_KEY:0:10}..."

# Store in keychain using security command
security delete-generic-password -a "openai_api_key" -s "ParentingAssistant" 2>/dev/null
security add-generic-password -a "openai_api_key" -s "ParentingAssistant" -w "$OPENAI_KEY"

security delete-generic-password -a "firebase_api_key" -s "ParentingAssistant" 2>/dev/null
security add-generic-password -a "firebase_api_key" -s "ParentingAssistant" -w "$FIREBASE_KEY"

echo "✅ API keys stored in keychain" 