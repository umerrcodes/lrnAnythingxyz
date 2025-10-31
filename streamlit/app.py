import os
import textwrap
import streamlit as st
from dotenv import load_dotenv

from services import OpenAIClient
from storage import RecentsStore, Article

load_dotenv()

st.set_page_config(page_title="Learn Anything – Web Test", page_icon="∞", layout="centered")

st.title("Learn Anything – Web Test")

with st.sidebar:
    st.header("Settings")
    model = st.selectbox("Model", ["gpt-4o-mini", "gpt-4o"], index=0)
    temperature = st.slider("Temperature", 0.0, 1.0, 0.7, 0.1)
    style = st.radio("Style", ["storyMan", "curiousGeorge"], index=0)
    max_tokens = st.number_input("Max output tokens (optional)", min_value=0, value=900, step=50)
    enable_tts = st.checkbox("Enable TTS preview", value=False)
    show_raw = st.checkbox("Show raw timing", value=True)

client = None
try:
    client = OpenAIClient()
except Exception as e:
    st.error(str(e))

recents = RecentsStore()

# Topic input and generate
col1, col2 = st.columns([3, 1])
with col1:
    topic = st.text_input("Topic", placeholder="Search a topic here", label_visibility="collapsed")
with col2:
    generate = st.button("Search", use_container_width=True)

# Recent chips
if recents.items:
    st.caption("Recent")
    chip_cols = st.columns(4)
    for i, a in enumerate(recents.items[:12]):
        with chip_cols[i % 4]:
            if st.button(a.topic.title(), key=f"recent_{a.id}"):
                topic = a.topic
                generate = True

if generate and topic and client:
    with st.spinner("Generating article…"):
        try:
            result = client.generate_article(topic=topic, model=model, temperature=temperature, style=style, max_tokens=(max_tokens or None))
        except Exception as e:
            st.error(f"Error: {e}")
            st.stop()

    if show_raw:
        st.success(f"Done in {result.get('ms', 0)} ms via {result.get('source')} API")

    st.subheader(result["title"])  # title
    st.caption(result["summary"])  # summary

    body = result["body"].strip()
    st.markdown(body)

    # Save to recents
    article = Article(id=result["id"], topic=result["topic"], title=result["title"], summary=result["summary"], body=body)
    recents.add(article)

    # Actions
    st.download_button("Download .md", data=body.encode("utf-8"), file_name=f"{result['topic']}.md", mime="text/markdown")

    # Optional TTS preview
    if enable_tts:
        with st.spinner("Synthesizing audio…"):
            try:
                audio_bytes = client.synthesize_tts(text=body)
                st.audio(audio_bytes, format="audio/mp3")
            except Exception as e:
                st.warning(f"TTS preview failed: {e}")

st.markdown("\n\n")
st.caption("Pro tip: deploy this folder to Streamlit Cloud and set OPENAI_API_KEY in project secrets.")
