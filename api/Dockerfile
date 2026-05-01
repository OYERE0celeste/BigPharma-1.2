# Base stage for dependencies
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./

# Dependencies stage
FROM base AS dependencies
RUN npm install --production

# Build stage (if needed, but here it's plain JS)
FROM dependencies AS release
COPY . .

# Expose the API port
EXPOSE 5000

# Start command
CMD ["node", "server.js"]
