# Learn Anything — Streamlit Test Environment

A lightweight web sandbox to iterate on article generation (and optional TTS) without opening Xcode.

## Quick start

1) Prereqs: Python 3.10+

2) Create a virtualenv and install deps:

```
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\\Scripts\\activate
pip install -r requirements.txt
```

3) Set your OpenAI key in the environment:

```
export OPENAI_API_KEY=OPENAI_KEY_REMOVED
# On Windows (PowerShell):
# $env:OPENAI_API_KEY="OPENAI_KEY_REMOVED"
```

4) Run Streamlit:

```
streamlit run app.py
```

Then open http://localhost:8501

## What’s inside

- `app.py` — Streamlit UI: topic input, generate button, rendered article, recents, optional TTS preview.
- `services.py` — OpenAI client using `requests` with Chat Completions and Responses fallback.
- `prompts.py` — Centralized system prompts (same intent as the iOS app).
- `storage.py` — Simple JSON store for recent topics/articles.
- `requirements.txt` — Python deps.

## Notes

- Keys are read from the `OPENAI_API_KEY` env var (no secrets committed).
- The app caches recents to `recents.json` alongside these files.
- You can deploy this folder to Streamlit Cloud; set the `OPENAI_API_KEY` as a secret in the cloud project.
