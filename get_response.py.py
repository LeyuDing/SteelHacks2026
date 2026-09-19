import sys
from openai import OpenAI

client = OpenAI(
    base_url="http://nvidia.com",
    api_key="not-needed-for-local-nim"  # A dummy key is required by the SDK
)

MODEL_NAME = "nvidia/nemotron-3.5-lightning"

messages = [
    {"role": "system", "content": "Hi :)"}
]

