FROM node:18-alpine

WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Copy backend source code
COPY . .

# Delete local .env inside container to strictly respect docker-compose.yml values
RUN rm -f .env

EXPOSE 3686

CMD ["node", "index.js"]
