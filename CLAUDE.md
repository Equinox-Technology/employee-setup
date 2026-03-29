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
You have a personal gateway key (`EQX_GATEWAY_KEY` in your `.env`). This key gives you access to company services through the Equinox Gateway at `api.equinoxcell.com`.

**Never share your gateway key.** If you leave the company, it gets revoked instantly. If you suspect it's compromised, notify Laurent immediately.

### How to use the gateway
All API calls go through the gateway. You never need (or have) raw API keys.

```bash
# Example: Get TPH Shopify orders
curl -H "x-gateway-key: $EQX_GATEWAY_KEY" \
  https://api.equinoxcell.com/api/proxy/tph-shopify/orders.json

# Example: Get Sohnne WooCommerce orders (read only)
curl -H "x-gateway-key: $EQX_GATEWAY_KEY" \
  https://api.equinoxcell.com/api/proxy/sohnne-woo-read-only/wp-json/wc/v3/orders

# Example: Get GA4 data
curl -H "x-gateway-key: $EQX_GATEWAY_KEY" \
  https://api.equinoxcell.com/api/proxy/sohnne-ga4/properties/321024703:runReport
```

### Available services
Check your permissions at https://api.equinoxcell.com (sign in with your @equinoxcell.com Google account).

| Service ID | Description |
|---|---|
| `sohnne-woo-read-only` | Sohnne orders, products, customers (view only) |
| `sohnne-woo-read-write` | Sohnne orders, products (create/edit — admin only) |
| `tph-shopify` | The Panel Hub Shopify Admin API |
| `enigwatch-shopify` | Enigwatch Shopify Admin API |
| `sofatica-shopify` | Sofatica Shopify Admin API |
| `vertu-shopify` | Vertu Living Shopify Admin API |
| `designito-shopify` | Designito Shopify Admin API |
| `sohnne-ga4` | Sohnne Google Analytics 4 |
| `pagespeed` | Google PageSpeed Insights |
| `stripe` | Stripe payments |
| `cloudflare` | Cloudflare DNS/CDN |
| `paypal` | PayPal payments |
| `klaviyo` | Klaviyo email marketing |
| `simplesat` | SimpleSat customer satisfaction |
| `tavily` | Tavily search API |

## Work Guidelines

### Communication
- English for all documentation and code
- Be data-driven — back decisions with numbers
- Concise and actionable — no fluff

### Code Standards
- Never hardcode credentials — use `.env` files
- Test before pushing to production
- WooCommerce: always test on staging first
- Shopify: use Shopify CLI for theme changes

### SEO Standards
- Every page: unique title (60 chars), meta description (155 chars), H1, schema
- Products: Product schema with price, availability, reviews, materials
- Ask: is this the best result for its target keyword?

### Frontend Standards
- Mobile-first design
- Core Web Vitals targets: <2.5s LCP, <100ms INP, <0.1 CLS
- Max 2 fonts per brand, high-contrast CTAs

### CRM Escalation Ladder
proof → apology → store credit → partial refund → replacement → full refund

## Dashboard
View service health, your API key status, and audit logs:
https://api.equinoxcell.com (sign in with Google)

## Need Help?
- API access issues → message Laurent on Slack
- New service access → request through the dashboard
- Technical questions → ask Claude (that's why you're here)
