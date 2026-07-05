FROM node:20-alpine AS builder

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy Prisma schema and replace it with prod schema
COPY prisma ./prisma
COPY prisma/schema.prod.prisma ./prisma/schema.prisma

# Generate Prisma client for MariaDB
RUN pnpm prisma generate

# Copy the rest of the application code
COPY . .

# Build the NestJS app
RUN pnpm run build

# --- Production Image ---
FROM node:20-alpine

WORKDIR /app

RUN npm install -g pnpm

# Copy only the necessary files from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

# Set production environment variables
ENV NODE_ENV=production
ENV PORT=8080

EXPOSE 8080

# Start the application
CMD ["pnpm", "run", "start:prod"]
