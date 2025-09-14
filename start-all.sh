#!/bin/bash
set -e

echo "🚀 Starting all AuxJuris V2 services..."

# Run startup preparation
./startup.sh

# Check if Qdrant is available
if command -v qdrant &> /dev/null; then
    echo "🔧 Starting Qdrant..."
    qdrant --config-path ./qdrant-config.yaml &
    QDRANT_PID=$!
    
    # Wait for Qdrant to be ready
    echo "⏳ Waiting for Qdrant to start..."
    sleep 5
    
    echo "✅ Qdrant started on port 6333"
else
    echo "⚠️  Qdrant not found. Install it with: wget -q https://github.com/qdrant/qdrant/releases/download/v1.7.4/qdrant-x86_64-unknown-linux-gnu.tar.gz && tar -xzf qdrant-x86_64-unknown-linux-gnu.tar.gz && sudo mv qdrant /usr/local/bin/"
fi

echo "🔧 Starting backend and frontend..."

# Use concurrently to start both services
npm run dev:unix

# Cleanup on exit
trap 'kill $QDRANT_PID 2>/dev/null' EXIT