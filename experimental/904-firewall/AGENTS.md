# Firewall-Protected Agent

You are an AI agent operating within a network-restricted environment with firewall protection enabled.

## Network Security Configuration

Your network access is controlled by firewall rules:

### Allowed Domains
- `*.github.com` - GitHub API and web access
- `*.githubusercontent.com` - GitHub raw content
- `api.anthropic.com` - Claude API communication (auto-injected)

### Blocked Networks
- Private IP ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- All other domains (default deny)

## Your Task

Demonstrate firewall functionality by testing network access using **curl commands directly**.

**IMPORTANT**: Do NOT use the WebFetch tool for testing, as it has additional application-layer restrictions beyond the firewall rules. Use curl to test the actual network-layer firewall behavior.

Test the following scenarios:

1. **Allowed domains** - Should establish TLS connection successfully
2. **Blocked private IPs** - Should timeout or fail to connect
3. **Unauthorized public domains** - Should fail with SSL certificate errors
4. **Security reporting** - Document test results with connection details

## Testing Commands

Use curl with verbose output to see connection details:

```bash
# Test 1: GitHub API (should succeed)
curl -v --max-time 10 https://api.github.com 2>&1 | head -50

# Test 2: GitHub Raw Content (should succeed)
curl -v --max-time 10 https://raw.githubusercontent.com 2>&1 | head -50

# Test 3: Private IP 192.168.x (should timeout/block)
curl -v --max-time 5 http://192.168.1.1 2>&1

# Test 4: Private IP 10.x (should timeout/block)
curl -v --max-time 5 http://10.0.0.1 2>&1

# Test 5: Private IP 172.16.x (should timeout/block)
curl -v --max-time 5 http://172.16.0.1 2>&1

# Test 6: Unauthorized domain (should fail SSL cert)
curl -v --max-time 10 https://www.google.com 2>&1 | head -50
```

## Expected Results

**Allowed domains:**
- Connection establishes to IP:443
- TLS handshake completes successfully
- Certificate validation passes
- May get HTTP error (401, 403, etc.) but connection succeeds

**Blocked private IPs:**
- Connection timeout after 5 seconds
- OR: "Empty reply from server"
- Network layer blocks the traffic

**Unauthorized public domains:**
- Connection establishes to IP:443
- TLS handshake fails
- SSL certificate validation error
- Error: "unable to get local issuer certificate"

## Report Format

Create `firewall-test-results.md` with:

1. **Test summary** - Pass/fail for each test case
2. **Connection details** - IP addresses, ports, TLS status
3. **Network log table** - Timestamp, target, status, method
4. **Security analysis** - Effectiveness of blocking mechanisms
5. **Compliance status** - All requirements met or not

Remember: Connection timeouts and SSL errors are expected security behaviors, not failures. Document them as successful blocks.
