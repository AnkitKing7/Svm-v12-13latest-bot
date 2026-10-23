# SVM Advanced AI V14 — AnkitCoder

**Production Discord VPS control plane** with automatic IP discovery, topology-aware networking, SFTP file manager, payments, WebSSH, and optional LocalAI.

| | |
|---|---|
| **Version** | 14.0 |
| **Developer** | AnkitCoder |
| **Primary install** | `sudo bash install.sh` |
| **Upgrade** | `sudo bash install.sh upgrade` |

---

## What this is

SVM manages **Linux VPS guests** (primarily **LXC / Incus**, with KVM detection) from Discord and a small web panel:

- Plan catalog, checkout, Razorpay / Stripe / UPI flows
- Port forwards, IP pools, SSH diagnostics, Termius-friendly profiles
- **V14:** host IP auto-discovery → `ips.txt` / `ips.json`, topology assessment, mapping modes A–E
- WebSSH + **SFTP file manager** + admin panel on port **5000**
- Payment webhooks on port **8787**
- Optional **LocalAI** agent (`!askai`)

It does **not** invent public IPv4 ownership, scan the public internet for free IPs, or claim external reachability from a database row alone.

---

## Requirements

**Host OS (where the bot runs):** Linux + `systemd` recommended.

| Family | Support |
|--------|---------|
| Ubuntu 20.04 / 22.04 / 24.04 | Full |
| Debian 11 / 12 / 13 | Full |
| Alma / Rocky / Fedora / RHEL-like | Best-effort |

**Tools:** `python3` (≥3.9), `pip`, `iproute2`, `nft` or `iptables`, optional `lxc`/`incus`.

Guest images: verified with `!oshealth` (see `OS_SUPPORT.md`).

---

## Install

```bash
unzip SVM-Advanced-AI-V14-AnkitCoder.zip -d SVM-Advanced-V14
cd SVM-Advanced-V14
sudo bash install.sh
```

Non-interactive:

```bash
sudo SVM_ENV_DISCORD_TOKEN=xxx SVM_ENV_MAIN_ADMIN_ID=123456789 \
  bash install.sh --non-interactive
```

### Installer behaviour

1. Detect distro / root  
2. Backup on upgrade (code + DB + `.env`)  
3. venv + `pip install -r requirements.txt`  
4. Deploy modules **without** overwriting existing `.env` values  
5. Merge **new keys only** from `.env.example`  
6. Python syntax validation (all `svm_*.py` modules)  
7. **Read-only** IP discovery → `ips.txt` / `ips.json`  
8. systemd unit; optional service start  

**Default install does not** flush firewall, replace default routes, or apply NAT.

### Subcommands

```bash
sudo bash install.sh                  # install or upgrade
sudo bash install.sh upgrade          # explicit upgrade
sudo bash install.sh backup           # snapshot only
sudo bash install.sh test             # pytest
sudo bash install.sh doctor           # health
sudo bash install.sh status           # service status
sudo bash install.sh rollback [SNAP]  # restore backup
sudo bash install.sh --configure      # wizard only
sudo bash install.sh --no-start
sudo bash install.sh --no-ai
sudo bash install.sh --apply-network  # allow limited network helpers
sudo bash install.sh ai-install|ai-status|ai-models|ai-doctor
sudo bash install.sh -h|--help
```

---

## Upgrade / rollback

```bash
sudo bash install.sh upgrade
sudo bash install.sh backup
sudo bash install.sh rollback
sudo bash install.sh rollback SNAPSHOT_NAME
```

Keep off-box copies of `.env` and `vps.db`.

---

## Configuration

```bash
sudo chmod 600 /path/to/.env
sudo nano /path/to/.env
```

| Key | Purpose |
|-----|---------|
| `DISCORD_TOKEN` | Bot token |
| `MAIN_ADMIN_ID` | Primary admin user ID |
| `YOUR_SERVER_IP` / `WEBSSH_SERVER_IP` | Link host identity |
| `IPAM_BIND_MODE` | `record` / `portfwd` / `nat` / … |
| `DNS_*` / Cloudflare keys | Optional DNS |
| `SVM_TOPOLOGY_OVERRIDE` | Force topology class |
| `SVM_EGRESS_CHECK_URL` | Optional egress observation (not ownership) |
| `LOCALAI_BASE_URL` | Optional LocalAI |

Full template: `.env.example`.

---

## Modules

| File | Role |
|------|------|
| `bot.py` | Discord + Flask WebSSH / admin / file manager |
| `svm12.py` | Payments, OS catalog, migrations |
| `svm_ipam.py` | IPAM lifecycle |
| `svm_net.py` | Firewall mapping backend |
| `svm_ssh.py` | SSH diagnose + profiles |
| `svm_files.py` | SFTP |
| `svm_dns.py` | Hostname + DNS + Cloudflare |
| `svm_tools.py` | Typed tool registry |
| `svm_topology.py` | Capability + topology |
| `svm_map.py` | Mapping modes A–E |
| `svm_ip_discovery.py` | Auto `ips.txt` / `ips.json` |
| `filemanager.html` | Browser SFTP UI |
| `webssh.html` / `admin.html` | Terminal + admin |

---

## Networking & IP discovery

1. Discover host addresses (`ip -j`)  
2. Classify (private, CGNAT, public-**candidate**, …)  
3. Merge prior inventory  
4. Atomic write `ips.txt` + `ips.json`  
5. Soft-sync IPAM without deleting ALLOCATED  

**Public-looking ≠ allocatable public.** Provider/operator confirmation required.

### Mapping modes

| Mode | Meaning |
|------|---------|
| A portfwd | Shared public IP:port → private:port |
| B nat | 1:1 when owned/authorized |
| C routed | Provider-routed (no invented gateways) |
| D wireguard | Tunnel ≠ public IPv4 |
| E record | DB only |

States: `RECORDED → INSTALLED → LOCAL_VERIFIED → EXTERNAL_VERIFIED`

---

## Web

| URL | Use |
|-----|-----|
| `http://SERVER:5000/` | WebSSH |
| `http://SERVER:5000/filemanager` | File manager |
| `http://SERVER:5000/admin` | Admin |
| Port **8787** | Payment webhooks |

---

## Discord (selected)

```text
!autoconfig
!autopool status|scan|sync|list
!autopool userping <vpsid>
!ipscan  !iplist  !ipstatus
!ipool …  !nat …  !sshinfo …
!oslist  !oshealth
!filemanager <vps>  !fm
!plans  !buy  !orders  !vpsinfo
!askai …
!botinfo
```

Admin commands check `MAIN_ADMIN_ID` server-side.

---

## LocalAI

```bash
sudo bash install.sh ai-install
sudo bash install.sh ai-status
sudo bash install.sh ai-models
```

Image generation only if endpoint + model exist. Unreachable endpoints fail cleanly.

---

## Testing

```bash
sudo bash install.sh test
python3 -m pytest tests/test_ipam_v13.py tests/test_ssh_net_v13.py \
  tests/test_map_topology_v14.py tests/test_ip_discovery_v14.py \
  tests/test_dns_tools_v13.py -q
```

External public reachability must be verified on **your** VPS — not assumed from CI.

---

## Security

- No global firewall flush  
- Secrets not written to `ips.txt` / `ips.json`  
- Live mapping needs operator confirmation  
- See `SECURITY.md` · `NETWORKING_SECURITY.md`

---

## Docs map

| File | Topic |
|------|--------|
| `V14_UPGRADE.md` | Networking upgrade |
| `AUDIT_V14.md` | Audit findings |
| `IP_DISCOVERY.md` | Inventory pipeline |
| `OS_SUPPORT.md` | Host/guest OS |
| `ARCHITECTURE.md` | Diagram |
| `CONFIGURATION.md` | Env detail |
| `WEB_ADMIN.md` | Admin UI |
| `TROUBLESHOOTING.md` | Failures |
| `TEST_EVIDENCE_V14.md` | Test notes |

---

## Troubleshooting

| Issue | Action |
|-------|--------|
| Bot down | `journalctl -u <service> -n 100`; check token |
| Empty ips.txt | `ip -j address`; `!autopool scan` |
| Port 5000 closed | Host firewall / cloud SG |
| NAT up but dead | Likely upstream NAT → prefer portfwd |
| LocalAI fail | `ai-doctor` + URL/model |

```bash
sudo bash install.sh doctor
sudo bash install.sh status
```

---

**Made by AnkitCoder** · SVM Advanced AI V14
