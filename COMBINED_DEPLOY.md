# Combined Deployment Guide — The Fox Suite
## Deploy ReplyFox + PostPilot + DescFox on shared infrastructure

## Why Combine?

All 3 products use the same stack (Node.js + Supabase + Groq + Stripe). Deploying them together means:
- ONE Supabase project (one database, one set of credentials)
- ONE Groq API key (shared across all 3)
- ONE Stripe account (3 products, one webhook endpoint)
- Lower total cost, simpler management

## Step 1: Supabase (serves all 3 products)

1. Create ONE Supabase project: "fox-suite"
2. Run ALL 3 schema files:
```sql
-- Run these in Supabase SQL Editor, one after another:
-- 1. ReplyFox tables
\i replyfox/src/schema.sql
-- 2. PostPilot tables  
\i postpilot/src/schema.sql
-- 3. DescFox tables
\i descfox/src/schema.sql
```
Or paste the contents of each file sequentially.

3. Copy: Project URL, service_role key, anon key

## Step 2: Groq (shared LLM)

You already have a Groq key from the First Light blog. Use the SAME key for all 3 products.

## Step 3: Stripe (3 products, 1 account)

Create 4 products in Stripe:
1. "ReplyFox Pro" — $29/month recurring
2. "PostPilot Pro" — $29/month recurring
3. "DescFox Pro" — $29/month recurring
4. "Fox Suite Bundle" — $59/month recurring (all 3)

Create ONE webhook endpoint per deployed product (or one shared endpoint that routes based on product metadata).

## Step 4: Deploy (3 options)

### Option A: 3 Render services (recommended)
Deploy each product as a separate Render web service, all pointing to the same Supabase project:
- `replyfox.onrender.com` → ReplyFox
- `postpilot.onrender.com` → PostPilot
- `descfox.onrender.com` → DescFox

Each has the same env vars (same Supabase/Groq keys) but different STRIPE_PRO_PRICE_ID.

### Option B: One monorepo server
Combine all 3 into one Node.js server with path-based routing:
- `/replyfox/api/*` → ReplyFox API
- `/postpilot/api/*` → PostPilot API
- `/descfox/api/*` → DescFox API

### Option C: Vercel (frontend) + Render (API)
Deploy each product's landing/dashboard to Vercel (free static hosting), deploy the API to Render.

## Environment Variables (shared across all 3)

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...
SUPABASE_ANON_KEY=eyJhbGci...
GROQ_API_KEY=gsk_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

Product-specific (different per deployment):
```env
# ReplyFox
STRIPE_PRO_PRICE_ID=price_replyfox...

# PostPilot
STRIPE_PRO_PRICE_ID=price_postpilot...

# DescFox
STRIPE_PRO_PRICE_ID=price_descfox...
```

## Post-Deploy: Set Up Cross-Selling

1. Add a banner in each product's dashboard:
   ```html
   <div class="cross-sell-banner">
     📦 Get all 3 Fox tools for $59/month (save $28) →
   </div>
   ```

2. After a customer signs up for one product, send an email:
   ```
   Subject: You're live on ReplyFox! Want to add social media + product copy?

   Hi {name},

   Your ReplyFox chatbot is now live! 

   Did you know we also have:
   - PostPilot — generates 30 days of social media content ($29/mo)
   - DescFox — writes product descriptions for Amazon/Shopify ($29/mo)

   Get all 3 as the Fox Suite bundle for $59/month (save $28/month).

   → Upgrade to the Fox Suite
   ```

3. Track cross-sell conversion in the ops dashboard.

## Total Monthly Cost at 100 Bundle Customers

- Supabase: $0 (free tier handles 50k+ users)
- Groq: ~$20-50 (LLM calls for all 3 products)
- Render: $0 (3 free-tier services)
- Stripe: $0 (percentage per sale)
- **Total: ~$20-50/month**
- **Revenue: $5,900/month (100 × $59)**
- **Profit: ~$5,850/month (99% margin)**
