[Options Setup](/docs)

# Options Setup REST

Manage Options trading accounts and establish WebSocket connections for real-time trading.

## Overview

The Options Setup APIs allow you to create and manage Options trading accounts using REST endpoints. These endpoints handle account creation, balance management, and WebSocket authentication setup.

##### REST API

These are standard REST APIs using HTTP methods (GET, POST). All requests require the `Deriv-App-ID: YOUR_APP_ID` header and an `Authorization: Bearer YOUR_OAUTH_TOKEN` token for authenticated endpoints.

##### OpenAPI Specification

View the complete OpenAPI 3.1.0 specification for detailed schema definitions and examples:

[OpenAPI Spec →](/data/production-openapi.json)

## Typical Workflow

1. Create an Options trading account using `POST /trading/v1/options/accounts`.
2. Request a WebSocket URL via `POST /trading/v1/options/accounts/{accountId}/otp`.
3. Connect directly to the WebSocket URL returned.
4. Start trading operations through the WebSocket connection.

## Available Endpoints

[Get All Accounts Get

Get all Options trading accounts `/trading/v1/options/accounts`](/docs/options/get-accounts/)

[Create Account Post

Create a new Options trading account `/trading/v1/options/accounts`](/docs/options/create-account/)

[Reset Demo Account Balance Post

Reset balance for Options trading demo account `/trading/v1/options/accounts/{account_id}/reset-demo-balance`](/docs/options/reset-demo-balance/)

[WebSockets Post

Issues a short-lived one-time password (OTP) that authenticates a subsequent WebSocket connection for the specified account. The response includes the OTP and a ready-to-use WebSocket URL with the OTP attached as a query parameter. The OTP is valid for 120 seconds and can be used only once, so open the WebSocket connection promptly after calling this endpoint. `/trading/v1/options/accounts/{accountId}/otp`](/docs/options/websocket/)

[WebSocket Demo Endpoint Get

Upgrades the connection to a WebSocket scoped to a demo Options Trading account. Requires a valid one-time password (OTP) from the OTP endpoint, passed as the otp query parameter. Use this channel to subscribe to market data, send trading instructions, and receive order and position updates for the demo account. `/trading/v1/options/ws/demo`](/docs/options/ws-demo/)

[WebSocket Real Endpoint Get

Upgrades the connection to a WebSocket scoped to a real-money Options Trading account. Requires a valid one-time password (OTP) from the OTP endpoint, passed as the otp query parameter. Trades placed over this channel settle against the account's real balance. `/trading/v1/options/ws/real`](/docs/options/ws-real/)

[WebSocket Public Endpoint Get

Streams real-time public market data — quotes, ticks, and contract metadata — with no authentication or OTP required. Account-scoped actions such as placing trades or reading balances aren't available on this channel. `/trading/v1/options/ws/public`](/docs/options/ws-public/)

## Authentication

All authenticated endpoints require the `Deriv-App-ID` header and an `Authorization: Bearer YOUR_AUTH_TOKEN` header.

### OAuth2 Scopes

| Endpoint | Scope |
| --- | --- |
| `GET /trading/v1/options/accounts` | `trade` |
| `POST /trading/v1/options/accounts` | `account_manage` |
| `POST /.../reset-demo-balance` | `trade` |
| `POST .../{accountId}/otp` | `trade` |

```bash
curl -X POST https://api.derivws.com/trading/v1/options/accounts \
  -H "Deriv-App-ID: YOUR_APP_ID" \
  -H "Authorization: Bearer YOUR_OAUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"currency": "USD", "group": "row", "account_type": "demo"}'
```

## Response Status Codes

The API uses standard HTTP status codes to indicate success or failure:

2xx Success

**200 OK** — Request successful (existing account or OTP generated)

**201 Created** — New resource created successfully

4xx/5xx Errors

**400 Bad Request** — Invalid parameters or request body

**401 Unauthorized** — Invalid or missing authentication

**403 Forbidden** — Access denied

**404 Not Found** — Resource not found

**500 Internal Server Error** — Server-side error

**504 Gateway Timeout** — Upstream service timeout

## Error Response Format

All error responses follow a consistent structure with an errors array and metadata:

```json
{
  "errors": [
    {
      "status": 400,
      "code": "ValidationError",
      "message": "currency field is required"
    }
  ],
  "meta": {
  }
}
```

Error codes include: `ValidationError`, `FieldIsRequired`, `Unauthorized`, `UnauthorizedAccess`, `AccessDenied`, `AccountNotFound`, `BadInputRequest`, `RateLimit`, `InternalServerError`