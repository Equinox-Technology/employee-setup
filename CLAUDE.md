# Equinox Technology — Employee Workspace

## About Equinox
DTC furniture and home goods company based in Jakarta, ~20 employees. 6 brands targeting the US market. 2026 target: $3M/month revenue (~$36M/year).

## Brands

| Brand | Platform | Domain |
|-------|----------|--------|
| Sohnne | WooCommerce | sohnne.com |
| The Panel Hub | Shopify | thepanelhub.com |
| Enigwatch | Shopify | enigwatch.com |
| Sofatica | Shopify | sofatica.com |
| Vertu Living | Shopify | vertuliving.com |
| Designito | Shopify | designito.com |

## Your API Access
Your gateway key is in `.env` as `EQX_GATEWAY_KEY`. All API calls go through the Equinox Gateway at `api.equinoxcell.com`.

**Never share your gateway key.** If compromised, notify Laurent immediately.

### How to use the gateway
```bash
# Get TPH Shopify orders
curl -H "x-gateway-key: $EQX_GATEWAY_KEY" \
  https://api.equinoxcell.com/api/proxy/tph-shopify/orders.json

# Get Sohnne WooCommerce orders (read only)
curl -H "x-gateway-key: $EQX_GATEWAY_KEY" \
  https://api.equinoxcell.com/api/proxy/sohnne-woo-read-only/wp-json/wc/v3/orders

# Or use the helper script
./gateway.sh tph-shopify orders.json
./gateway.sh list    # see all services
```

### Available Services
| Service ID | Description |
|---|---|
| `sohnne-woo-read-only` | Sohnne orders, products, customers (view only) |
| `tph-shopify` | The Panel Hub Shopify |
| `enigwatch-shopify` | Enigwatch Shopify |
| `sofatica-shopify` | Sofatica Shopify |
| `vertu-shopify` | Vertu Living Shopify |
| `designito-shopify` | Designito Shopify |
| `sohnne-ga4` | Sohnne Google Analytics 4 |
| `gsc` | Google Search Console |
| `gmc` | Google Merchant Center |
| `pagespeed` | Google PageSpeed Insights |
| `stripe` | Stripe payments |
| `klaviyo` | Klaviyo email marketing |
| `clarity-sohnne` | Microsoft Clarity (Sohnne) |
| `clarity-sofatica` | Microsoft Clarity (Sofatica) |
| `clarity-enigwatch` | Microsoft Clarity (Enigwatch) |
| `cloudflare` | Cloudflare DNS/CDN |

## MCP Tools (what Claude can do for you)
Claude has 27 tools connected through the Equinox MCP server. Just ask in natural language:

**Orders:** "Show me Sohnne orders this week" / "Get TPH revenue last 30 days"
**Products:** "Show Enigwatch products" / "Search Sohnne products for 'Eames'"
**Analytics:** "Get GA4 sessions for Sohnne" / "Run PageSpeed on sofatica.com"
**SEO:** "Get GSC search queries for sohnne.com" / "Semrush overview of thepanelhub.com"
**Email:** "Show recent Klaviyo campaigns" / "Get Klaviyo flows"
**Payments:** "Check Stripe balance" / "Show recent Stripe charges"
**Performance:** "Get Clarity dashboard for Sofatica" / "Check GMC product issues"
**Summary:** "Revenue across all 6 brands this week"

## Work Guidelines
- English for all docs and code
- Data-driven — back decisions with numbers
- Never hardcode credentials — use `.env` files
- Mobile-first frontend, Core Web Vitals: <2.5s LCP, <100ms INP, <0.1 CLS
- SEO: unique title (60ch), meta desc (155ch), H1, schema on every page
- CRM escalation: proof → apology → store credit → partial refund → replacement → full refund

## Dashboard
https://api.equinoxcell.com (Google sign-in with @equinoxcell.com)

## Need Help?
Message Laurent on Slack or ask Claude.
