#!/bin/sh
set -e

echo "⏳ Waiting for Ollama at ${OLLAMA_URL} …"
until curl -sf "${OLLAMA_URL}/api/tags" > /dev/null 2>&1; do
    echo "   Ollama not reachable. Make sure 'ollama serve' is running on the host."
    sleep 5
done
echo "✅ Ollama is up."

# Auto-pull the model if it's not already available
MODELS=$(curl -sf "${OLLAMA_URL}/api/tags" | python3 -c "import sys,json; print(' '.join(m['name'] for m in json.load(sys.stdin).get('models',[])))" 2>/dev/null || echo "")
if echo "$MODELS" | grep -q "${OLLAMA_MODEL}"; then
    echo "✅ Model ${OLLAMA_MODEL} is ready."
else
    echo "📥 Pulling ${OLLAMA_MODEL} … (this may take a few minutes on first run)"
    curl -sf "${OLLAMA_URL}/api/pull" -d "{\"name\":\"${OLLAMA_MODEL}\"}" > /dev/null
    echo "✅ Model pulled."
fi

exec uvicorn main:app --host 0.0.0.0 --port 8000
