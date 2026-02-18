#!/bin/bash
set -e

N8N_DIR="/data/n8n/workflows"
mkdir -p "$N8N_DIR"

# === WORKFLOW 1 : PLANIFICATEUR ===
cat > "$N8N_DIR/01-planificateur.json" << 'EOF'
{
  "name": "Caballarius - Planificateur missions",
  "nodes": [
    {
      "name": "Cron 4h",
      "type": "n8n-nodes-base.cron",
      "position": [250, 300],
      "parameters": {
        "triggerTimes": {
          "item": [
            { "hour": 6 }, { "hour": 10 }, { "hour": 14 },
            { "hour": 18 }, { "hour": 22 }, { "hour": 2 }
          ]
        }
      }
    },
    {
      "name": "Query Pending Localities",
      "type": "n8n-nodes-base.mySql",
      "position": [450, 300],
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT l.id, l.name, l.lat, l.lng, c.name_fr AS country, c.priority FROM localities l JOIN regions r ON l.region_id = r.id JOIN countries c ON r.country_id = c.id WHERE l.scrape_status = 'pending' ORDER BY c.priority ASC, l.id ASC LIMIT 20"
      }
    },
    {
      "name": "Send to OpenClaw",
      "type": "n8n-nodes-base.httpRequest",
      "position": [650, 300],
      "parameters": {
        "method": "POST",
        "url": "http://127.0.0.1:18789/api/agent",
        "authentication": "genericCredentialType",
        "body": {
          "message": "Scrape les localites suivantes avec le skill 01-scrape-google : {{ $json.localities }}",
          "session_id": "planificateur-{{ $now.format('yyyy-MM-dd-HH') }}"
        },
        "headers": {
          "Authorization": "Bearer cblrs-openclaw-bunker-2026",
          "Content-Type": "application/json"
        }
      }
    },
    {
      "name": "Log Job",
      "type": "n8n-nodes-base.mySql",
      "position": [850, 300],
      "parameters": {
        "operation": "executeQuery",
        "query": "INSERT INTO scrape_jobs (job_type, target_type, target_id, status) VALUES ('google_places', 'locality', {{ $json.id }}, 'pending')"
      }
    }
  ],
  "connections": {
    "Cron 4h": { "main": [[ { "node": "Query Pending Localities" } ]] },
    "Query Pending Localities": { "main": [[ { "node": "Send to OpenClaw" } ]] },
    "Send to OpenClaw": { "main": [[ { "node": "Log Job" } ]] }
  }
}
EOF

# === WORKFLOW 2 : CONTROLE QUALITE ===
cat > "$N8N_DIR/02-controle-qualite.json" << 'EOF'
{
  "name": "Caballarius - Controle qualite",
  "nodes": [
    {
      "name": "Cron 2h",
      "type": "n8n-nodes-base.cron",
      "position": [250, 300],
      "parameters": {
        "triggerTimes": { "item": [{ "mode": "everyX", "value": 2, "unit": "hours" }] }
      }
    },
    {
      "name": "Query Recent Establishments",
      "type": "n8n-nodes-base.mySql",
      "position": [450, 300],
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT e.id, e.name, e.category, e.lat, e.lng, e.google_rating, e.price_level, e.address, l.name AS locality, l.lat AS loc_lat, l.lng AS loc_lng, (6371 * ACOS(COS(RADIANS(e.lat)) * COS(RADIANS(l.lat)) * COS(RADIANS(l.lng) - RADIANS(e.lng)) + SIN(RADIANS(e.lat)) * SIN(RADIANS(l.lat)))) AS distance_km FROM establishments e JOIN localities l ON e.locality_id = l.id WHERE e.created_at > NOW() - INTERVAL 2 HOUR ORDER BY e.created_at DESC LIMIT 50"
      }
    },
    {
      "name": "Check Duplicates",
      "type": "n8n-nodes-base.mySql",
      "position": [450, 500],
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT e1.id AS id1, e2.id AS id2, e1.name, e1.address FROM establishments e1 JOIN establishments e2 ON e1.name = e2.name AND e1.address = e2.address AND e1.id < e2.id WHERE e1.created_at > NOW() - INTERVAL 24 HOUR"
      }
    },
    {
      "name": "Filter Suspects",
      "type": "n8n-nodes-base.code",
      "position": [650, 300],
      "parameters": {
        "jsCode": "// Filter establishments with issues:\n// - distance_km > 1 (wrong location)\n// - name empty or 'Unknown'\n// - price_level suspicious for category\nconst suspects = [];\nfor (const item of $input.all()) {\n  const d = item.json;\n  if (d.distance_km > 1) suspects.push({...d, issue: 'wrong_location', severity: 'critical'});\n  if (!d.name || d.name === 'Unknown') suspects.push({...d, issue: 'missing_data', severity: 'warning'});\n  if (d.category === 'albergue' && d.price_level >= 4) suspects.push({...d, issue: 'incoherent_price', severity: 'warning'});\n  if (d.category === 'hotel' && d.price_level === 0) suspects.push({...d, issue: 'incoherent_price', severity: 'info'});\n}\nreturn suspects.map(s => ({json: s}));"
      }
    },
    {
      "name": "Ask Kimi K2.5",
      "type": "n8n-nodes-base.httpRequest",
      "position": [850, 300],
      "parameters": {
        "method": "POST",
        "url": "https://openrouter.ai/api/v1/chat/completions",
        "headers": {
          "Authorization": "Bearer {{$credentials.openrouterApiKey}}",
          "Content-Type": "application/json"
        },
        "body": {
          "model": "moonshotai/kimi-k2.5",
          "messages": [{"role": "user", "content": "Analyse ces etablissements suspects du Camino de Santiago. Pour chacun, reponds OK ou PROBLEME avec une explication courte en francais:\n{{ JSON.stringify($json) }}"}]
        }
      }
    },
    {
      "name": "Insert Quality Checks",
      "type": "n8n-nodes-base.mySql",
      "position": [1050, 300],
      "parameters": {
        "operation": "executeQuery",
        "query": "INSERT INTO quality_checks (check_type, establishment_id, severity, description) VALUES ('{{ $json.issue }}', {{ $json.id }}, '{{ $json.severity }}', '{{ $json.kimi_analysis }}')"
      }
    }
  ],
  "connections": {
    "Cron 2h": { "main": [[ { "node": "Query Recent Establishments" }, { "node": "Check Duplicates" } ]] },
    "Query Recent Establishments": { "main": [[ { "node": "Filter Suspects" } ]] },
    "Filter Suspects": { "main": [[ { "node": "Ask Kimi K2.5" } ]] },
    "Ask Kimi K2.5": { "main": [[ { "node": "Insert Quality Checks" } ]] }
  }
}
EOF

# === WORKFLOW 3 : RAPPORT QUOTIDIEN ===
cat > "$N8N_DIR/03-rapport-quotidien.json" << 'EOF'
{
  "name": "Caballarius - Rapport quotidien",
  "nodes": [
    {
      "name": "Cron 20h",
      "type": "n8n-nodes-base.cron",
      "position": [250, 300],
      "parameters": {
        "triggerTimes": { "item": [{ "hour": 20, "minute": 0 }] }
      }
    },
    {
      "name": "Stats Today",
      "type": "n8n-nodes-base.mySql",
      "position": [450, 300],
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT (SELECT COUNT(*) FROM establishments WHERE DATE(created_at) = CURDATE()) AS new_today, (SELECT COUNT(*) FROM establishments) AS total_establishments, (SELECT COUNT(*) FROM establishments WHERE scrape_status='scraped') AS scraped, (SELECT COUNT(*) FROM establishments WHERE scrape_status='enriched') AS enriched, (SELECT COUNT(*) FROM establishments WHERE scrape_status='site_generated') AS sites_generated, (SELECT COUNT(*) FROM establishments WHERE scrape_status='synced') AS synced, (SELECT COUNT(*) FROM localities WHERE scrape_status='done') AS localities_done, (SELECT COUNT(*) FROM localities WHERE scrape_status='pending') AS localities_pending, (SELECT COUNT(*) FROM scrape_jobs WHERE status='error' AND DATE(created_at) = CURDATE()) AS errors_today, (SELECT COUNT(*) FROM quality_checks WHERE DATE(created_at) = CURDATE()) AS qc_today, (SELECT COUNT(*) FROM quality_checks WHERE severity='critical' AND auto_resolved=FALSE) AS qc_critical_open, (SELECT COUNT(*) FROM pro_sites WHERE is_live=TRUE) AS sites_live"
      }
    },
    {
      "name": "Top Localities",
      "type": "n8n-nodes-base.mySql",
      "position": [450, 500],
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT l.name, c.name_fr AS country, COUNT(e.id) AS nb_establishments FROM localities l JOIN regions r ON l.region_id = r.id JOIN countries c ON r.country_id = c.id LEFT JOIN establishments e ON e.locality_id = l.id GROUP BY l.id ORDER BY nb_establishments DESC LIMIT 5"
      }
    },
    {
      "name": "Generate Report (Kimi)",
      "type": "n8n-nodes-base.httpRequest",
      "position": [700, 300],
      "parameters": {
        "method": "POST",
        "url": "https://openrouter.ai/api/v1/chat/completions",
        "headers": {
          "Authorization": "Bearer {{$credentials.openrouterApiKey}}",
          "Content-Type": "application/json"
        },
        "body": {
          "model": "moonshotai/kimi-k2.5",
          "messages": [{"role": "user", "content": "Redige un rapport quotidien Caballarius en francais. Concis, professionnel, avec emojis pour les chiffres cles. Voici les stats:\n{{ JSON.stringify($json) }}\nTop localites:\n{{ JSON.stringify($node['Top Localities'].json) }}"}]
        }
      }
    },
    {
      "name": "Send Telegram",
      "type": "n8n-nodes-base.telegram",
      "position": [900, 300],
      "parameters": {
        "chatId": "{{$credentials.telegramChatId}}",
        "text": "{{ $json.choices[0].message.content }}"
      }
    }
  ],
  "connections": {
    "Cron 20h": { "main": [[ { "node": "Stats Today" }, { "node": "Top Localities" } ]] },
    "Stats Today": { "main": [[ { "node": "Generate Report (Kimi)" } ]] },
    "Generate Report (Kimi)": { "main": [[ { "node": "Send Telegram" } ]] }
  }
}
EOF

# === WORKFLOW 4 : WATCHDOG ===
cat > "$N8N_DIR/04-watchdog.json" << 'EOF'
{
  "name": "Caballarius - Watchdog",
  "nodes": [
    {
      "name": "Cron 30min",
      "type": "n8n-nodes-base.cron",
      "position": [250, 300],
      "parameters": {
        "triggerTimes": { "item": [{ "mode": "everyX", "value": 30, "unit": "minutes" }] }
      }
    },
    {
      "name": "Check OpenClaw",
      "type": "n8n-nodes-base.executeCommand",
      "position": [450, 200],
      "parameters": {
        "command": "docker ps --filter name=openclaw-bunker --format '{{.Status}}' | grep -q 'Up' && echo 'UP' || echo 'DOWN'"
      }
    },
    {
      "name": "Check Stuck Jobs",
      "type": "n8n-nodes-base.mySql",
      "position": [450, 400],
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT id, job_type, target_type, target_id, started_at FROM scrape_jobs WHERE status = 'running' AND started_at < NOW() - INTERVAL 1 HOUR"
      }
    },
    {
      "name": "Check Disk",
      "type": "n8n-nodes-base.executeCommand",
      "position": [450, 600],
      "parameters": {
        "command": "df -h /data | tail -1 | awk '{print $5}' | sed 's/%//'"
      }
    },
    {
      "name": "Check OpenRouter",
      "type": "n8n-nodes-base.httpRequest",
      "position": [450, 800],
      "parameters": {
        "method": "GET",
        "url": "https://openrouter.ai/api/v1/models",
        "options": { "timeout": 5000 }
      }
    },
    {
      "name": "Process Alerts",
      "type": "n8n-nodes-base.code",
      "position": [700, 400],
      "parameters": {
        "jsCode": "const alerts = [];\n\n// OpenClaw down?\nconst clawStatus = $node['Check OpenClaw'].json.stdout?.trim();\nif (clawStatus !== 'UP') alerts.push('CRITICAL: OpenClaw container DOWN!');\n\n// Stuck jobs?\nconst stuckJobs = $node['Check Stuck Jobs'].json;\nif (stuckJobs && stuckJobs.length > 0) {\n  for (const j of stuckJobs) alerts.push(`WARNING: Job #${j.id} (${j.job_type}) stuck since ${j.started_at}`);\n}\n\n// Disk full?\nconst diskUsage = parseInt($node['Check Disk'].json.stdout?.trim() || '0');\nif (diskUsage > 80) alerts.push(`WARNING: Disk usage ${diskUsage}%`);\nif (diskUsage > 95) alerts.push(`CRITICAL: Disk almost full ${diskUsage}%!`);\n\n// OpenRouter down?\nconst orStatus = $node['Check OpenRouter'].json?.statusCode;\nif (orStatus !== 200) alerts.push('WARNING: OpenRouter API not responding');\n\nif (alerts.length === 0) return [{json: {status: 'OK', message: 'All systems nominal'}}];\nreturn alerts.map(a => ({json: {status: 'ALERT', message: a}}));"
      }
    },
    {
      "name": "Fix Stuck Jobs",
      "type": "n8n-nodes-base.mySql",
      "position": [700, 600],
      "parameters": {
        "operation": "executeQuery",
        "query": "UPDATE scrape_jobs SET status = 'error', error_log = 'Timeout: stuck > 1 hour, marked by watchdog' WHERE status = 'running' AND started_at < NOW() - INTERVAL 1 HOUR"
      }
    },
    {
      "name": "Alert Telegram",
      "type": "n8n-nodes-base.telegram",
      "position": [900, 400],
      "parameters": {
        "chatId": "{{$credentials.telegramChatId}}",
        "text": "🚨 WATCHDOG ALERT\n{{ $json.message }}"
      }
    }
  ],
  "connections": {
    "Cron 30min": { "main": [[ { "node": "Check OpenClaw" }, { "node": "Check Stuck Jobs" }, { "node": "Check Disk" }, { "node": "Check OpenRouter" } ]] },
    "Check OpenClaw": { "main": [[ { "node": "Process Alerts" } ]] },
    "Check Stuck Jobs": { "main": [[ { "node": "Process Alerts" }, { "node": "Fix Stuck Jobs" } ]] },
    "Check Disk": { "main": [[ { "node": "Process Alerts" } ]] },
    "Check OpenRouter": { "main": [[ { "node": "Process Alerts" } ]] },
    "Process Alerts": { "main": [[ { "node": "Alert Telegram" } ]] }
  }
}
EOF

echo "=== N8N WORKFLOWS ==="
ls -la "$N8N_DIR"
echo "=== DONE ==="
