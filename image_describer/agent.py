from __future__ import annotations

import logging

from google.genai import types

from google.adk.agents import Agent
from google.adk.agents import RunConfig
from google.adk.runners import InMemoryRunner
from google.adk.tools import load_artifacts
 
# Configure logging to see the agent's thought process.
logging.basicConfig(level=logging.INFO)


root_agent = Agent(
    name="image_describer",
    model="gemini-1.5-flash",
    instruction=(
        "You are an expert at describing images. A user will provide an image "
        "file. First, use the `load_artifacts` tool to load the content of "
        "the uploaded file. Once you have the image content, provide a "
        "detailed description of what you see."
    ),
    tools=[
        load_artifacts,
    ],
)