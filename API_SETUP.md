# Taco Trader API Setup

## API Server Details

**Server URL**: `http://192.168.40.209:5000`
**Auth Token**: `c7c49da0c6e73ca8aa2b799864293f796cedbb3b71641b7c3a8435fc383674c6`

## Starting the API Server

The API server is located at: `~/.openclaw/workspace/trading/taco_api_server.py`

### Manual Start
```bash
cd ~/.openclaw/workspace/trading
export TACO_API_TOKEN=c7c49da0c6e73ca8aa2b799864293f796cedbb3b71641b7c3a8435fc383674c6
.polymarket-venv/bin/python3 taco_api_server.py
```

### Background Start (persists until reboot)
```bash
cd ~/.openclaw/workspace/trading
nohup bash start_taco_api.sh > /tmp/taco_api.log 2>&1 </dev/null &
```

### Check if API is running
```bash
curl http://192.168.40.209:5000/health
# Should return: {"service":"taco-trader-api","status":"ok"}
```

### View API logs
```bash
tail -f /tmp/taco_api.log
```

### Stop the API server
```bash
pkill -f taco_api_server.py
```

## Firewall Configuration

Port 5000 has been opened for local network access:
```bash
sudo ufw allow from 192.168.40.0/24 to any port 5000
```

## Auto-start on Reboot (Optional)

Add to crontab:
```bash
crontab -e
# Add this line:
@reboot cd ~/.openclaw/workspace/trading && nohup bash start_taco_api.sh > /tmp/taco_api.log 2>&1 </dev/null &
```

## iOS App Configuration

The iOS app has been configured with:
- **Backend URL**: `http://192.168.40.209:5000`
- **Auth Token**: `c7c49da0c6e73ca8aa2b799864293f796cedbb3b71641b7c3a8435fc383674c6`

These settings are pre-configured in the app. You can view/edit them in the Settings tab.

## Available Endpoints

All endpoints require `Authorization: Bearer <token>` header:

- `GET /health` - Health check (no auth required)
- `GET /api/system` - Pi system health
- `GET /api/report` - Trading capital and PnL report
- `GET /api/engines/status` - Engine status (BTC/ETH/SOL/XRP/Coinbase)
- `GET /api/dashboard/summary` - Dashboard with positions and trades
- `GET /api/transactions` - Transaction feed
- `GET /api/redeems` - Redeem history

## Testing the API

```bash
# From your Mac or any device on the network:
curl -H "Authorization: Bearer c7c49da0c6e73ca8aa2b799864293f796cedbb3b71641b7c3a8435fc383674c6" \
  http://192.168.40.209:5000/api/engines/status
```

## Important Notes

- The API server runs in **development mode** (Flask built-in server)
- For production use, consider using **gunicorn** or **uwsgi**
- The API only **reads** data - it doesn't modify your trading engines
- Your cron jobs continue to run safely alongside the API
- The API pulls data from `journal.db` and state JSON files

## Troubleshooting

**API not responding?**
1. Check if process is running: `ps aux | grep taco_api_server`
2. Check logs: `tail -50 /tmp/taco_api.log`
3. Restart: `pkill -f taco_api_server && cd ~/.openclaw/workspace/trading && bash start_taco_api.sh`

**Can't connect from iOS app?**
1. Verify firewall allows port 5000: `sudo ufw status`
2. Test from Mac: `curl http://192.168.40.209:5000/health`
3. Check iOS app Settings tab has correct URL and token
