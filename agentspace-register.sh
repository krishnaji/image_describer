#!/bin/bash

# Load environment variables from .env file
# Ensure you have a .env file with the required variables
source .env

# Check for required variables
if [ -z "$GOOGLE_CLOUD_PROJECT" ] || [ -z "$PROJECT_NUMBER" ] || [ -z "$GOOGLE_CLOUD_LOCATION" ] || [ -z "$REASONING_ENGINE_ID" ] || [ -z "$AGENTSPACE_APP_ID" ]; then
    echo "Error: One or more required environment variables are not set in .env"
    echo "Please set: GOOGLE_CLOUD_PROJECT, PROJECT_NUMBER, GOOGLE_CLOUD_LOCATION, REASONING_ENGINE_ID, AGENTSPACE_APP_ID"
    exit 1
fi

# Construct the full reasoning engine resource name from environment variables
export REASONING_ENGINE="projects/${GOOGLE_CLOUD_PROJECT}/locations/${GOOGLE_CLOUD_LOCATION}/reasoningEngines/${REASONING_ENGINE_ID}"

echo "--- Configuration ---"
echo "Project ID:         $GOOGLE_CLOUD_PROJECT"
echo "Project Number:     $PROJECT_NUMBER"
echo "Reasoning Engine:   $REASONING_ENGINE"
echo "Agent Search App ID: $AGENTSPACE_APP_ID"
echo "Agent Display Name: $AGENT_DISPLAY_NAME"
echo "---------------------"
echo

echo "Patching Agent Search Assistant to register the Reasoning Engine..."
curl -X PATCH -H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
-H "x-goog-user-project: ${GOOGLE_CLOUD_PROJECT}" \
https://discoveryengine.googleapis.com/v1alpha/projects/${PROJECT_NUMBER}/locations/global/collections/default_collection/engines/${AGENTSPACE_APP_ID}/assistants/default_assistant?updateMask=agent_configs -d '{
    "name": "projects/'"${PROJECT_NUMBER}"'/locations/global/collections/default_collection/engines/'"${AGENTSPACE_APP_ID}"'/assistants/default_assistant",
    "displayName": "Default Assistant",
    "agentConfigs": [{
      "displayName": "'"${AGENT_DISPLAY_NAME}"'",
      "vertexAiSdkAgentConnectionInfo": {
        "reasoningEngine": "'"${REASONING_ENGINE}"'"
      },
      "toolDescription": "'"${AGENT_DESCRIPTION}"'",
      "icon": {
        "uri": "https://fonts.gstatic.com/s/i/short-term/release/googlesymbols/corporate_fare/default/24px.svg"
      },
      "id": "'"${AGENT_ID}"'"
    }]
  }'

echo
echo "Verifying the Agent Search Assistant configuration..."
curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
-H "x-goog-user-project: ${GOOGLE_CLOUD_PROJECT}" \
"https://discoveryengine.googleapis.com/v1alpha/projects/${PROJECT_NUMBER}/locations/global/collections/default_collection/engines/${AGENTSPACE_APP_ID}/assistants/"