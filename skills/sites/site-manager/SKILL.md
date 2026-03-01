---
name: site-manager
description: Manage websites through the Website Manager API. Subcommands -- list (show all sites in table), status (detailed site info with health and analytics), deploy (push to production with confirmation), add-page (create new page matching design system), health (run health checks for uptime, SSL, DNS, build), analytics (view visitor stats, top pages, referrers), security (run security audit with severity ratings), create (launch /build-website to create from scratch). Resolves site names to IDs automatically. API at localhost:8100 or sites.grantsmiths.com.
allowed-tools: Bash, Read, Write, Edit, WebFetch, Task
---

# Website Manager Skill

Manage websites through the Website Manager API running at `http://localhost:8100`.

Parse `$ARGUMENTS` to determine which subcommand to run. The first word is the subcommand, remaining words are arguments.

## API Connectivity Check

Before running any command, verify the API is reachable:

```bash
curl -s --max-time 3 http://localhost:8100/sites > /dev/null 2>&1
```

If the API is not running, tell the user:

> Website Manager API is not running. Start it with: `cd ~/tools/website-manager && uvicorn api.main:app --host 0.0.0.0 --port 8100`

Then stop. Do not proceed with the command.

## Resolving Site Names to IDs

Many commands accept a site `<name>` but the API requires a site `id`. When you have a name, resolve it:

```bash
curl -s http://localhost:8100/sites
```

Find the site object whose `name` field matches the provided name (case-insensitive). Extract its `id` for subsequent API calls. If no match is found, list available sites and tell the user the name was not found.

---

## Commands

### /site list

Fetch all sites and display a formatted table.

**Steps:**
1. Call `GET http://localhost:8100/sites`
2. Parse the JSON response
3. Display a markdown table with columns: Name, Domain, Status, Framework, Last Deployed

```bash
curl -s http://localhost:8100/sites
```

Format the output as:

```
| Name            | Domain              | Status   | Framework | Last Deployed       |
|-----------------|---------------------|----------|-----------|---------------------|
| grantsmiths     | grantsmiths.com     | active   | Next.js   | 2026-02-25 14:30    |
```

If no sites exist, say "No sites registered. Use `/site create <description>` to create one."

---

### /site status <name>

Show detailed status for a single site.

**Steps:**
1. Resolve `<name>` to a site ID
2. Fetch site details: `GET http://localhost:8100/sites/{id}`
3. Fetch latest health check if available: `GET http://localhost:8100/sites/{id}/health`
4. Fetch analytics summary if available: `GET http://localhost:8100/sites/{id}/analytics`

Display all information in a structured format.

---

### /site deploy <name>

Deploy a site to production.

**Steps:**
1. Resolve `<name>` to a site ID
2. Ask the user for confirmation: "Deploy **{name}** ({domain}) to production? (yes/no)"
3. Wait for explicit confirmation. Do NOT proceed without it.
4. Call `POST http://localhost:8100/sites/{id}/deploy`
5. Poll for deployment status every 5 seconds (up to 5 minutes)
6. Report the result with the live URL or error message

---

### /site add-page <name> <path> <title>

Add a new page to an existing site.

**Steps:**
1. Resolve `<name>` to a site ID and get the site's `local_path`
2. Register the page in the API: `POST http://localhost:8100/sites/{id}/pages`
3. Read the site's design brief and project instructions for consistency
4. Determine the correct file location based on the site's framework
5. Create the page file, matching the design system and patterns from existing pages
6. Deploy the site
7. Report the result with the live URL for the new page

---

### /site health <name>

Run a health check on a site.

**Steps:**
1. Resolve `<name>` to a site ID
2. Trigger: `POST http://localhost:8100/sites/{id}/health/run`
3. Display results with PASS/WARN/FAIL indicators for uptime, SSL, build, DNS

---

### /site analytics <name>

View analytics for a site.

**Steps:**
1. Resolve `<name>` to a site ID
2. Fetch: `GET http://localhost:8100/sites/{id}/analytics`
3. Display summary, top pages, and top referrers

---

### /site security <name>

Run a security audit on a site.

**Steps:**
1. Resolve `<name>` to a site ID
2. Trigger: `POST http://localhost:8100/sites/{id}/security/run`
3. Display score and issues with HIGH/MEDIUM/LOW severity

---

### /site create <description>

Create a brand new website from a description.

**Steps:**
1. Tell the user: "This will launch the /build-website skill to create a new site from your description."
2. Invoke the `/build-website` skill with the provided description
3. After the site is built and deployed, register it with the API
4. Report the registered site details

---

## Error Handling

- **Connection refused / timeout**: The API is not running. Show the startup instructions.
- **404 Not Found**: The requested resource does not exist. Suggest checking the site name.
- **422 Validation Error**: Show the validation error details from the response body.
- **500 Internal Server Error**: Show the error and suggest checking API logs.

## General Formatting Rules

- Use markdown tables for tabular data
- Use bold for labels and values that need emphasis
- Use code blocks for commands and file paths
- Keep output concise -- do not dump raw JSON unless the user asks for it
- When displaying timestamps, convert to human-readable format
