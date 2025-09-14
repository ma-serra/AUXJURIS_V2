#!/bin/bash

set -e

echo "🚀 Setting up AuxJuris V2 development environment..."

# Install Qdrant
echo "📥 Installing Qdrant vector database..."
wget -q https://github.com/qdrant/qdrant/releases/download/v1.7.4/qdrant-x86_64-unknown-linux-gnu.tar.gz
tar -xzf qdrant-x86_64-unknown-linux-gnu.tar.gz
sudo mv qdrant /usr/local/bin/
rm qdrant-x86_64-unknown-linux-gnu.tar.gz
echo "✅ Qdrant installed successfully"

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p public/books/uploads/extraidos
mkdir -p storage
echo "✅ Directories created"

# Create default environment file if it doesn't exist
if [ ! -f backend/.env ]; then
    echo "📝 Creating default environment file..."
    cat > backend/.env << 'EOL'
# Backend Configuration
PORT=3001
NODE_ENV=development

# Qdrant Configuration
QDRANT_URL=http://localhost:6333

# Google Gemini API (optional - add your key here)
# GOOGLE_API_KEY=your_google_api_key_here

# LM Studio Configuration (optional)
# LM_STUDIO_URL=http://localhost:1234
# LM_STUDIO_MODEL=your_model_name
EOL
    echo "✅ Default .env file created"
else
    echo "ℹ️  Using existing .env file"
fi

# Build the backend
echo "🔨 Building backend..."
cd backend
npm run build
cd ..
echo "✅ Backend built successfully"

# Create startup scripts
echo "📜 Creating startup scripts..."

# Create start-qdrant.sh
cat > start-qdrant.sh << 'EOL'
#!/bin/bash
echo "Starting Qdrant on port 6333..."
qdrant --config-path ./qdrant-config.yaml
EOL

# Create qdrant-config.yaml
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

# Create start-all.sh
cat > start-all.sh << 'EOL'
#!/bin/bash
set -e

echo "🚀 Starting AuxJuris V2..."

# Start Qdrant in background
echo "🔧 Starting Qdrant..."
./start-qdrant.sh &
QDRANT_PID=$!

# Wait for Qdrant to be ready
echo "⏳ Waiting for Qdrant to start..."
sleep 5

# Start backend in background
echo "🔧 Starting backend..."
cd backend && npm run dev &
BACKEND_PID=$!
cd ..

# Wait a bit for backend to start
sleep 3

# Start frontend
echo "🔧 Starting frontend..."
npm run dev:frontend

# Cleanup on exit
trap 'kill $QDRANT_PID $BACKEND_PID 2>/dev/null' EXIT
EOL

# Make scripts executable
chmod +x start-qdrant.sh start-all.sh

echo "✅ Startup scripts created"
echo ""
echo "🎉 Setup complete! You can now:"
echo "   • Run 'npm run dev' to start the frontend only"
echo "   • Run './start-all.sh' to start all services (Qdrant, Backend, Frontend)"
echo "   • Access the app at http://localhost:5173 when running"
echo ""
echo "📝 Don't forget to set your GOOGLE_API_KEY in backend/.env for full functionality!"