# DevOps and Deployment Guide

## Running Backend on Ubuntu Server

### Prerequisites

Install Node.js 18+:
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Manual Installation

1. Clone repository:
```bash
git clone <repo-url>
cd BillMint/backend
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment:
```bash
cp .env.example .env
nano .env
```

Set:
```
PORT=3000
DB_PATH=/var/lib/billmint/db.sqlite
NODE_ENV=production
```

4. Create data directory:
```bash
sudo mkdir -p /var/lib/billmint
sudo chown $USER:$USER /var/lib/billmint
```

5. Initialize database:
```bash
npm run migrate
```

6. Start server:
```bash
npm start
```

### Docker Deployment

1. Build image:
```bash
cd backend
docker build -t billmint-backend .
```

2. Run container:
```bash
docker run -d \
  --name billmint-backend \
  -p 3000:3000 \
  -v /var/lib/billmint:/data \
  --restart unless-stopped \
  billmint-backend
```

3. Check logs:
```bash
docker logs billmint-backend
```

4. Stop container:
```bash
docker stop billmint-backend
```

### Systemd Service

1. Copy service file:
```bash
sudo cp backend/billmint-backend.service /etc/systemd/system/
```

2. Edit service file paths:
```bash
sudo nano /etc/systemd/system/billmint-backend.service
```

3. Reload systemd:
```bash
sudo systemctl daemon-reload
```

4. Enable and start:
```bash
sudo systemctl enable billmint-backend
sudo systemctl start billmint-backend
```

5. Check status:
```bash
sudo systemctl status billmint-backend
```

6. View logs:
```bash
sudo journalctl -u billmint-backend -f
```

### PM2 Process Manager

1. Install PM2:
```bash
sudo npm install -g pm2
```

2. Start with PM2:
```bash
cd backend
pm2 start ecosystem.config.js
```

3. Save PM2 configuration:
```bash
pm2 save
```

4. Setup PM2 startup script:
```bash
pm2 startup
```

5. Monitor processes:
```bash
pm2 monit
```

6. View logs:
```bash
pm2 logs billmint-backend
```

## Nginx Reverse Proxy

1. Install Nginx:
```bash
sudo apt-get install nginx
```

2. Create configuration:
```bash
sudo nano /etc/nginx/sites-available/billmint
```

Paste:
```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

3. Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/billmint /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

4. Optional: Add SSL with Let's Encrypt:
```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d api.yourdomain.com
```

## Exposing Backend

### Option 1: Private Access with Tailscale (Recommended for Private Use)

1. Install Tailscale on server:
```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

2. Start Tailscale:
```bash
sudo tailscale up
```

3. Get Tailscale IP:
```bash
tailscale ip -4
```
Example output: `100.101.102.103`

4. In Flutter app, use:
```
http://100.101.102.103:3000
```

5. Install Tailscale on your phone from App Store/Play Store and connect

Benefits:
- Completely private, no public exposure
- Encrypted connection
- Works from anywhere
- No firewall configuration needed

### Option 2: Public Tunnel with Cloudflare Tunnel

1. Install cloudflared:
```bash
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
```

2. Login to Cloudflare:
```bash
cloudflared tunnel login
```

3. Create tunnel:
```bash
cloudflared tunnel create billmint
```

4. Create configuration file:
```bash
nano ~/.cloudflared/config.yml
```

Paste:
```yaml
tunnel: billmint
credentials-file: /home/YOUR_USER/.cloudflared/TUNNEL_ID.json

ingress:
  - hostname: billmint.yourdomain.com
    service: http://localhost:3000
  - service: http_status:404
```

5. Route DNS:
```bash
cloudflared tunnel route dns billmint billmint.yourdomain.com
```

6. Run tunnel:
```bash
cloudflared tunnel run billmint
```

7. Run as service:
```bash
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

Use in app: `https://billmint.yourdomain.com`

### Option 3: Public Tunnel with ngrok

1. Install ngrok:
```bash
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install ngrok
```

2. Add auth token (sign up at ngrok.com):
```bash
ngrok config add-authtoken YOUR_TOKEN
```

3. Start tunnel:
```bash
ngrok http 3000
```

4. Use the HTTPS forwarding URL in your app (e.g., `https://abc123.ngrok.io`)

Note: Free ngrok URLs change on restart. Consider paid plan for static domain.

5. Run in background:
```bash
nohup ngrok http 3000 > ngrok.log 2>&1 &
```

## Backup and Maintenance

### Database Backup

1. Backup database file:
```bash
cp /var/lib/billmint/db.sqlite /backup/db-$(date +%Y%m%d).sqlite
```

2. Use API backup endpoint:
```bash
curl http://localhost:3000/api/backup > backup-$(date +%Y%m%d).json
```

### Automated Backups

Create cron job:
```bash
crontab -e
```

Add daily backup at 2 AM:
```
0 2 * * * curl http://localhost:3000/api/backup > /backup/billmint-$(date +\%Y\%m\%d).json
```

### Update Application

```bash
cd BillMint
git pull
cd backend
npm install
sudo systemctl restart billmint-backend
```

## Monitoring

### Check Service Status
```bash
sudo systemctl status billmint-backend
```

### View Logs
```bash
# Systemd logs
sudo journalctl -u billmint-backend -f

# PM2 logs
pm2 logs billmint-backend

# Docker logs
docker logs -f billmint-backend
```

### Monitor Resources
```bash
htop
```

## Troubleshooting

### Port Already in Use
```bash
# Find process using port 3000
sudo lsof -i :3000

# Kill process
sudo kill -9 <PID>
```

### Permission Errors
```bash
# Fix ownership
sudo chown -R $USER:$USER /var/lib/billmint
```

### Database Locked
```bash
# Stop all services
sudo systemctl stop billmint-backend

# Remove lock files
rm /var/lib/billmint/db.sqlite-shm
rm /var/lib/billmint/db.sqlite-wal

# Restart
sudo systemctl start billmint-backend
```
