#!/bin/bash

set -e

echo "🚀 Starting AuxJuris V2 for GitHub Spaces..."

# Create necessary directories
mkdir -p public/books/uploads/extraidos
mkdir -p storage

# Create Qdrant configuration if it doesn't exist
if [ ! -f qdrant-config.yaml ]; then
    echo "📝 Creating Qdrant configuration..."
    cat > qdrant-config.yaml << 'EOL'
log_level: INFO
storage:
  path: "./storage"
service:
  http_port: 6333
  grpc_port: 6334
  host: "0.0.0.0"
telemetry:
  disabled: true
EOL
fi

# Create default environment file if it doesn't exist
if [ ! -f backend/.env ]; then
    echo "📝 Creating default environment file..."
    cp backend/.env.example backend/.env
    echo "⚠️  Please update backend/.env with your GOOGLE_API_KEY for full functionality"
fi

# Build the backend if not already built
if [ ! -d backend/dist ]; then
    echo "🔨 Building backend..."
    cd backend && npm run build && cd ..
fi

echo "🎉 AuxJuris V2 is ready for GitHub Spaces!"
echo ""
echo "📝 Available commands:"
echo "   • npm run dev:frontend    - Start frontend only"
echo "   • npm run dev:backend     - Start backend only"
echo "   • npm run dev:unix        - Start both frontend and backend"
echo "   • ./start-all.sh          - Start all services including Qdrant"
echo ""
echo "🔧 Make sure to:"
echo "   1. Set your GOOGLE_API_KEY in backend/.env"
echo "   2. Install Qdrant binary for vector database functionality"