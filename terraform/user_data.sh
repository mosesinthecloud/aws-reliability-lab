#!/bin/bash
set -euxo pipefail
exec > /var/log/user-data.log 2>&1
# 1 Bring web server up ASAP (health checks depend on this)
dnf install -y nginx curl-minimal
systemctl enable nginx
systemctl start nginx
cat > /usr/share/nginx/html/index.html <<'HTML'
<!doctype html>
<html><head><meta charset="utf-8"/><title>aws-reliability-lab</title></head>
<body style="font-family:system-ui;margin:40px">
<h1>aws-reliability-lab ✅</h1>
<p>ALB + ASG healthy. Rendering instance details...</p>
</body></html>
HTML
# 2 Render swag-lite in background (won't block health checks)
cat > /usr/local/bin/render_swag.sh <<'SH'
#!/bin/bash
set -euo pipefail
# IMDSv2 with timeouts so it can't hang
TOKEN=$(curl -sS --connect-timeout 1 --max-time 2 \
 -X PUT "http://169.254.169.254/latest/api/token" \
 -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" || true)
HDR=()
if [ -n "${TOKEN:-}" ]; then
 HDR=(-H "X-aws-ec2-metadata-token:${TOKEN}")
fi
INSTANCE_ID=$(curl -sS --connect-timeout 1 --max-time 2 "${HDR[@]}" http://169.254.169.254/latest/meta-data/instance-id || echo "unknown")
AZ=$(curl -sS --connect-timeout 1 --max-time 2 "${HDR[@]}" http://169.254.169.254/latest/meta-data/placement/availability-zone || echo "unknown")
LOCAL_IP=$(curl -sS --connect-timeout 1 --max-time 2 "${HDR[@]}" http://169.254.169.254/latest/meta-data/local-ipv4 || echo "unknown")
NOW=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
cat > /usr/share/nginx/html/index.html <<HTML
<!doctype html>
<html>
<head>
<meta charset="utf-8"/>
<title>aws-reliability-lab</title>
<style>
   body { font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial; margin: 40px; }
   .card { max-width: 760px; padding: 24px; border: 1px solid #ddd; border-radius: 16px; }
   .pill { display:inline-block; padding:6px 10px; border-radius:999px; background:#f4f4f4; margin-right:8px; }
   code { background:#f7f7f7; padding: 2px 6px; border-radius: 6px; }
</style>
</head>
<body>
<div class="card">
<h1>aws-reliability-lab ✅</h1>
<p>
<span class="pill">ALB</span>
<span class="pill">ASG</span>
<span class="pill">Terraform</span>
<span class="pill">CPU Auto Scaling</span>
</p>
<h3>Instance info (swag-lite)</h3>
<ul>
<li>Instance ID: <code>${INSTANCE_ID}</code></li>
<li>AZ: <code>${AZ}</code></li>
<li>Local IP: <code>${LOCAL_IP}</code></li>
<li>Rendered: <code>${NOW}</code></li>
</ul>
<p>If the Instance ID changes, the ASG replaced the node.</p>
</div>
</body>
</html>
HTML
SH
chmod +x /usr/local/bin/render_swag.sh
nohup /usr/local/bin/render_swag.sh >/var/log/render_swag.log 2>&1 &