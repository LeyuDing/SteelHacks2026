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

"""
$ curl -X POST "global.prd.ga.run.brev.nvidia.com:17953/v1/chat/completions"      -H "Content-Type: application/json"      -d '{
       "model": "nvidia/nemotron-3.5-lightning",
       "messages": [{"role": "user", "content": "What was the last thing I said. No thinking"}],
       "temperature": 0.5,
       "max_tokens": 10000
     }'
"""