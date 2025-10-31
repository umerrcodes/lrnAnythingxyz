import os
import time
import uuid
from typing import Dict, Any
import requests

from prompts import get_prompt

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
BASE_URL = "https://api.openai.com/v1"

HEADERS = {
    "Authorization": f"Bearer {OPENAI_API_KEY}",
    "Content-Type": "application/json",
    "Accept": "application/json",
}


class OpenAIClient:
    def __init__(self, api_key: str | None = None, timeout: int = 90):
        key = api_key or OPENAI_API_KEY
        if not key:
            raise RuntimeError("OPENAI_API_KEY is not set")
        self.headers = dict(HEADERS)
        self.headers["Authorization"] = f"Bearer {key}"
        self.timeout = timeout

    def _post(self, path: str, json_body: Dict[str, Any]) -> Dict[str, Any]:
        url = f"{BASE_URL}/{path}"
        r = requests.post(url, json=json_body, headers=self.headers, timeout=self.timeout)
        r.raise_for_status()
        return r.json()

    def generate_article(self, topic: str, model: str, temperature: float, style: str, max_tokens: int | None = None) -> Dict[str, Any]:
        system_prompt = get_prompt(style)

        # Try Chat Completions first
        chat_payload = {
            "model": model,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": topic},
            ],
            "temperature": temperature,
        }
        if max_tokens:
            chat_payload["max_tokens"] = max_tokens

        try:
            t0 = time.time()
            data = self._post("chat/completions", chat_payload)
            content = data["choices"][0]["message"].get("content", "").strip()
            return {
                "id": str(uuid.uuid4()),
                "topic": topic,
                "title": topic.title(),
                "summary": f"Generated article on {topic}.",
                "body": content,
                "ms": int((time.time() - t0) * 1000),
                "source": "chat",
            }
        except requests.HTTPError:
            # Fallback to Responses API
            responses_payload = {
                "model": model,
                "input": [
                    {"role": "system", "content": [{"type": "input_text", "text": system_prompt}]},
                    {"role": "user", "content": [{"type": "input_text", "text": topic}]},
                ],
            }
            if max_tokens:
                responses_payload["max_output_tokens"] = max_tokens
            t0 = time.time()
            data = self._post("responses", responses_payload)
            body = self._extract_responses_text(data)
            return {
                "id": str(uuid.uuid4()),
                "topic": topic,
                "title": topic.title(),
                "summary": f"Generated article on {topic}.",
                "body": body,
                "ms": int((time.time() - t0) * 1000),
                "source": "responses",
            }

    def _extract_responses_text(self, data: Dict[str, Any]) -> str:
        if "output_text" in data and data["output_text"]:
            return data["output_text"]
        out = data.get("output") or []
        if out:
            content = out[0].get("content") or []
            if content and isinstance(content, list):
                text = content[0].get("text")
                if text:
                    return text
        raise RuntimeError("No text in responses output")

    def synthesize_tts(self, text: str, voice: str = "alloy", model: str = "tts-1") -> bytes:
        url = f"{BASE_URL}/audio/speech"
        payload = {"model": model, "input": text, "voice": voice, "format": "mp3"}
        r = requests.post(url, json=payload, headers=self.headers, timeout=self.timeout)
        r.raise_for_status()
        return r.content
