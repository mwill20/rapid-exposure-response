# Verification recipes

**Hard rule:** never run public exploit or PoC code against production. Lab only, with written approval.

## V1. Fixed version is present
- Authenticated scanner check, package manager query, or EDR software inventory.
- Check every instance: containers, images, and vendor appliances often lag hosts.
- Record version string and method per asset.

## V2. Vulnerable feature is actually disabled
- Read the effective runtime configuration (for example, the runtime's own config dump), not only the config file.
- Re-check after restarts and deployments.

## V3. Edge control blocks
- Send a benign request that matches the rule pattern. Expect block and a log entry.
- Confirm there is no route that bypasses the control (direct origin IP, alternate hostnames, internal paths).

## V4. External exposure is closed
- Re-run external attack surface scan or an unauthenticated scan from outside.
- Compare to the Step 2 exposure list.

## V5. Detection works
- Simulate the behavior safely in a lab (for example, a web runtime spawning a harmless child process).
- Confirm alert fires, reaches the right queue, and a human acknowledges it.

## V6. Temporary controls are retired correctly
- After V1 passes, remove or re-approve each temporary control.
- Re-run V4 to confirm nothing reopened.

## V7. Evidence is filed
- Store results where your audit evidence lives. Link them in the tracker's Evidence_Link column.
