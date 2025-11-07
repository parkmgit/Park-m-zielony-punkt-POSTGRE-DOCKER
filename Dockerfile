# Use Node.js 18 LTS for Windows Server
FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS base

# Install Node.js
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Invoke-WebRequest -UseBasicParsing -Uri https://nodejs.org/dist/v18.19.0/node-v18.19.0-x64.msi -OutFile node.msi; \
    Start-Process msiexec.exe -ArgumentList '/i', 'node.msi', '/quiet', '/norestart' -NoNewWindow -Wait; \
    Remove-Item -Force node.msi

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy application files
COPY . .

# Build the application
RUN npm run build

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

EXPOSE 3000

CMD ["node", ".next/standalone/server.js"]
