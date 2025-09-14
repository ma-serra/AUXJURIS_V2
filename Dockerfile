# Multi-stage build for AuxJuris V2

# Build stage for frontend
FROM node:18-alpine AS frontend-build
WORKDIR /app

# Copy package files and install frontend dependencies
COPY package*.json ./
COPY tsconfig.json ./
COPY vite.config.ts ./
RUN npm ci

# Copy frontend source code
COPY index.html ./
COPY index.tsx ./
COPY App.tsx ./
COPY constants.ts ./
COPY types.ts ./
COPY utils.ts ./
COPY predefined-books.ts ./
COPY index.css ./
COPY components/ ./components/
COPY hooks/ ./hooks/
COPY src/ ./src/
COPY public/ ./public/

# Build frontend
RUN npm run build:frontend

# Build stage for backend
FROM node:18-alpine AS backend-build
WORKDIR /app

# Copy backend package files and install dependencies
COPY backend/package*.json ./
COPY backend/tsconfig.json ./
RUN npm ci

# Copy backend source code
COPY backend/src/ ./src/

# Build backend
RUN npm run build

# Production stage
FROM node:18-alpine AS production
WORKDIR /app

# Install Qdrant (using docker approach for Alpine Linux)
RUN apk add --no-cache wget bash && \
    wget https://github.com/qdrant/qdrant/releases/download/v1.7.4/qdrant-x86_64-unknown-linux-musl.tar.gz && \
    tar -xzf qdrant-x86_64-unknown-linux-musl.tar.gz && \
    mv qdrant /usr/local/bin/ && \
    rm qdrant-x86_64-unknown-linux-musl.tar.gz

# Copy backend production files
COPY backend/package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy built backend
COPY --from=backend-build /app/dist ./dist

# Copy built frontend (to be served statically)
COPY --from=frontend-build /app/dist ./public

# Copy necessary static files
COPY --from=frontend-build /app/public/books ./public/books

# Create necessary directories
RUN mkdir -p ./public/books/uploads/extraidos && \
    mkdir -p ./storage

# Copy storage if it exists
COPY storage/ ./storage/ 2>/dev/null || true

# Create startup script
RUN echo '#!/bin/bash\nset -e\n\n# Start Qdrant in background\necho "Starting Qdrant..."\nqdrant --config-path /app/qdrant-config.yaml &\nQDRANT_PID=$!\n\n# Wait for Qdrant to be ready\necho "Waiting for Qdrant to start..."\nsleep 10\n\n# Start the backend server\necho "Starting backend server..."\nexec node dist/server.js' > /app/start.sh

# Create Qdrant config
RUN echo 'log_level: INFO\nstorage:\n  path: "./storage"\nservice:\n  http_port: 6333\n  grpc_port: 6334\n  host: "0.0.0.0"\ntelemetry:\n  disabled: true' > /app/qdrant-config.yaml

RUN chmod +x /app/start.sh

# Expose ports
EXPOSE 3001 6333

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3001
ENV QDRANT_URL=http://localhost:6333

CMD ["/app/start.sh"]