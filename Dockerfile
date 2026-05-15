FROM node:22-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy source code
COPY src ./src

# Use the non-root user provided by the node image
USER node

EXPOSE 8080

CMD ["npm", "start"]
