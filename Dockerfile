FROM node:18-alpine

WORKDIR /app

# Build Backend
COPY Backend/package*.json ./Backend/
RUN cd Backend && npm install --production

# Build Frontend
COPY Frontend/package*.json ./Frontend/
RUN cd Frontend && npm install && npm run build

# Copy source code
COPY Backend /app/Backend
COPY Frontend /app/Frontend

# Expose port
EXPOSE 5000

# Start Backend server
CMD ["node", "Backend/server.js"]
