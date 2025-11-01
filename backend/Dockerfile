# BillMint Backend API
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Install app dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy app source
COPY src ./src

# Create data directory
RUN mkdir -p /data

# Environment variables
ENV PORT=3000
ENV DB_PATH=/data/billmint.sqlite
ENV NODE_ENV=production

# Expose port
EXPOSE 3000

# Run migration on startup and start server
CMD ["sh", "-c", "node src/migrate.js && node src/index.js"]
