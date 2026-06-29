FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y gcc git python3-dev rsync && \
    rm -rf /var/lib/apt/lists/*

# Clone pinned version
RUN git clone --depth 1 --branch v0.12.52 https://github.com/run-llama/llama_index.git /app/llama_index && \
    rm -rf /app/llama_index/.git

# Install all Python dependencies before copying project code
# (so code changes don't invalidate these cached layers)
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir torch==2.2.0 --index-url https://download.pytorch.org/whl/cu121

# Copy only requirements first to leverage layer cache
COPY requirements.txt /app/LRG/requirements.txt
RUN pip install --no-cache-dir -r /app/LRG/requirements.txt 

# Copy project and apply patches
COPY . /app/LRG
RUN rsync -a /app/LRG/llama_index_extra/ /app/llama_index/

# Install LlamaIndex editable packages
RUN pip install --no-cache-dir \
    -e /app/llama_index/llama-index-core \
    -e /app/llama_index/llama-index-integrations/embeddings/llama-index-embeddings-cohere \
    -e /app/llama_index/llama-index-integrations/embeddings/llama-index-embeddings-huggingface \
    -e /app/llama_index/llama-index-integrations/indices/llama-index-indices-managed-bge-m3 \
    -e /app/llama_index/llama-index-integrations/indices/llama-index-indices-managed-colbert \
    -e /app/llama_index/llama-index-integrations/retrievers/llama-index-retrievers-bm25

# Version Pin    
RUN pip install --no-cache-dir "langchain==0.1.20" "transformers==4.49.0"

# Run the Python script to download and preprocess data
RUN mv /app/LRG/test_data /app
RUN python /app/LRG/setup_data.py

# Set the entrypoint to /app/LRG
# ENTRYPOINT ["/app"]

CMD ["bash"]