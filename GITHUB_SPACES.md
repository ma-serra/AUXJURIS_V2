# 🚀 GitHub Spaces Deployment Guide

This document provides instructions for running AuxJuris V2 in GitHub Codespaces or similar cloud development environments.

## Quick Start with GitHub Codespaces

### 1. Open in GitHub Codespaces

1. Go to the repository on GitHub
2. Click the green "Code" button
3. Select "Codespaces" tab
4. Click "Create codespace on main"

### 2. Automatic Setup

The devcontainer will automatically:
- Install Node.js and dependencies
- Download and install Qdrant vector database
- Create necessary directories
- Build the backend
- Configure environment variables

### 3. Manual Steps After Setup

1. **Configure API Key** (Required for full functionality):
   ```bash
   # Edit the environment file
   nano backend/.env
   
   # Add your Google Gemini API key
   GOOGLE_API_KEY=your_api_key_here
   ```

2. **Start the Application**:
   ```bash
   # Option 1: Start all services at once
   ./start-all.sh
   
   # Option 2: Start individually
   npm run dev:unix  # Both frontend and backend
   ```

### 4. Access the Application

- **Frontend**: The app will be available on port 5173
- **Backend API**: Available on port 3001
- **Qdrant Database**: Running on port 6333

GitHub Codespaces will automatically forward these ports and provide URLs.

## Available Scripts

- `npm run dev:frontend` - Start frontend only
- `npm run dev:backend` - Start backend only  
- `npm run dev:unix` - Start both frontend and backend
- `npm run build` - Build both frontend and backend
- `npm run start` - Build and start in production mode
- `./startup.sh` - Run initial setup
- `./start-all.sh` - Start all services including Qdrant

## Environment Variables

Create `backend/.env` with these variables:

```env
# Backend Configuration
PORT=3001
NODE_ENV=development

# Qdrant Vector Database
QDRANT_URL=http://localhost:6333

# Google Gemini API (required)
GOOGLE_API_KEY=your_google_api_key_here

# LM Studio (optional)
LM_STUDIO_URL=http://localhost:1234
LM_STUDIO_MODEL=your_model_name
```

## Troubleshooting

### Port Issues
If ports are not accessible:
```bash
# Check if services are running
ps aux | grep -E "(node|qdrant|vite)"

# Check port usage
netstat -tulpn | grep -E ":(3001|5173|6333)"
```

### Qdrant Issues
If Qdrant fails to start:
```bash
# Check if Qdrant is installed
which qdrant

# Manual installation
wget -q https://github.com/qdrant/qdrant/releases/download/v1.7.4/qdrant-x86_64-unknown-linux-gnu.tar.gz
tar -xzf qdrant-x86_64-unknown-linux-gnu.tar.gz
sudo mv qdrant /usr/local/bin/
```

### Build Issues
If the build fails:
```bash
# Clean install
rm -rf node_modules backend/node_modules
npm install
cd backend && npm install
```

## Production Deployment

### Using Docker

1. **Build the Docker image**:
   ```bash
   docker build -t auxjuris-v2 .
   ```

2. **Run the container**:
   ```bash
   docker run -p 3001:3001 -p 6333:6333 \
     -e GOOGLE_API_KEY=your_key_here \
     auxjuris-v2
   ```

### Environment Configuration

For production, ensure these environment variables are set:
- `NODE_ENV=production`
- `GOOGLE_API_KEY=your_actual_key`
- `PORT=3001`
- `QDRANT_URL=http://localhost:6333`

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review the logs in the terminal
3. Ensure all required environment variables are set
4. Make sure ports 3001, 5173, and 6333 are available