# Quick Start Guide - Databricks Free Tier Setup

**Time estimate:** 10-15 minutes

## Step 1: Create Free Databricks Account
1. Go to https://databricks.com/try
2. Click **Get started with Databricks**
3. Sign up with email or Google account
4. Verify email
5. Choose **Free** tier when prompted
6. Create a workspace name (e.g., `pokemon-learning`)
7. Select region (default is fine)
8. Click **Create workspace** → wait 2-3 minutes

## Step 2: Navigate to Databricks Workspace
1. After workspace creation, click **Sign in** to your workspace
2. You're now in the Databricks home page

## Step 3: Create a Catalog (Unity Catalog)
1. Left sidebar → **Catalog** (third icon from top)
2. Click **Create Catalog**
3. Name: `pokemon_catalog`
4. Click **Create**

## Step 4: Create Schemas (Databases)
1. Click on your new `pokemon_catalog`
2. Click **Create Schema**
3. Create three schemas:
   - Name: `bronze` → Click **Create**
   - Name: `silver` → Click **Create**
   - Name: `gold` → Click **Create**

## Step 5: Create SQL Warehouse (for querying)
1. Left sidebar → **SQL** (looks like a database icon)
2. Click **SQL Warehouses** (top menu)
3. Click **Create SQL Warehouse**
4. Name: `pokemon-warehouse`
5. Cluster size: **Starter** (default)
6. Click **Create**
7. Wait 2-3 minutes for startup (you'll see green checkmark)

## Step 6: Create a Notebook (for each project)
1. Left sidebar → **Workspace**
2. Click **+** icon → **Create** → **Notebook**
3. Name: `project-1-type-coverage`
4. Language: **SQL** (or **Python** depending on project)
5. Click **Create**

## Step 7: Import CSV Data
For each project:
1. Go to the project folder
2. Open the project README for specific datasets needed
3. In Databricks workspace:
   - Left sidebar → **Data** (folder icon)
   - Click **+** icon → **Upload** or **Add data**
   - Drag CSV files from `project-X/data/` folder
   - Select schema (usually `bronze`)
   - Click **Create table**

---

## Quick Reference: Key UI Locations

| What You Need | Where to Find It |
|---------------|------------------|
| Create catalog/schema | Left sidebar → **Catalog** |
| Create SQL warehouse | **SQL** tab → **SQL Warehouses** |
| Write notebooks | Left sidebar → **Workspace** → **Create** → **Notebook** |
| Upload data | Left sidebar → **Data** → **Upload** |
| Run queries | Open notebook → Write SQL/Python → **Ctrl+Enter** (or click ▶ Run) |
| Check table contents | Left sidebar → **Catalog** → Click table → **Data** tab |
| See query history | **SQL** tab → **Query history** |
| Manage jobs | **Workflows** (left sidebar) → **Jobs** |

---

## Tips
- **Free tier limits:** 1 SQL warehouse, up to 10GB of data
- **Data uploads:** Max 5GB per file
- **SQL editor:** Use `Ctrl+Enter` to run selected lines
- **Notebooks:** Auto-saved; no need to manually save
- **Best practice:** Attach warehouse before running queries (dropdown at top of notebook)

---

## Troubleshooting

**Q: My SQL warehouse won't start**  
A: Click the warehouse name, wait 3-5 mins, refresh page

**Q: CSV upload failed**  
A: Ensure file is < 5GB, header row exists, no special characters in filename

**Q: Can't find my data in a query**  
A: Check: (1) Right schema selected, (2) Use full name `schema.table`, (3) Attach SQL warehouse

---

## Next Steps
After setup:
1. Go to `project-1-type-coverage/README.md`
2. Follow step-by-step instructions
3. Use notebook templates provided
4. Run and learn!

