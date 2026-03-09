# ---- Stage 1: Install dependencies ----
FROM node:18-alpine AS deps

WORKDIR /app

COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install

# ---- Stage 2: Build the application ----
FROM node:18-alpine AS builder
WORKDIR /app

# Copy dependencies from the previous stage
COPY --from=deps /app/node_modules ./node_modules

# Copy the rest of the source code
COPY . .

# Build the Next.js production bundle
RUN npm run build

# ---- Stage 3: Production image ----
FROM node:18-alpine AS runner
WORKDIR /app

# Set to production mode
ENV NODE_ENV=production

# Copy only what's needed to run (not source code!)
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000

# Start the Next.js server
CMD ["node", "server.js"]