#!/bin/bash

echo "Removing API keys from keychain..."

# Remove OpenAI API key
security delete-generic-password -a "openai_api_key" -s "ParentingAssistant" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Removed OpenAI API key from keychain"
else
    echo "ℹ️ OpenAI API key not found in keychain"
fi

# Remove Firebase API key
security delete-generic-password -a "firebase_api_key" -s "ParentingAssistant" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Removed Firebase API key from keychain"
else
    echo "ℹ️ Firebase API key not found in keychain"
fi

echo "Done!" 