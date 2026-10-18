[Trading Operations](/docs/trading)

# Buy Contract

Auth required

Buy a contract using a proposal ID, or pass contract parameters directly.

## Request & Response

## Examples

### Request Example

```json
{
  "buy": "uw2mk7no3oktoRVVsB4Dz7TQnFfABuFDgO95dlxfMxRuPUsz",
  "price": 100
}
```

### Response Example

```json
{
  "buy": {
    "balance_after": 9900.00,
    "buy_price": 51.02,
    "contract_id": 11542203588,
    "longcode": "Win payout if Volatility 100 Index...",
    "payout": 100,
    "purchase_time": 1234567890,
    "shortcode": "CALL_R_100_100_1234567890_1234567950_S0P_0",
    "start_time": 1234567890,
    "transaction_id": 12345678
  },
  "msg_type": "buy"
}
```

##### Authentication Required

This endpoint requires a valid session. Ensure your WebSocket connection is authenticated before calling this endpoint.

## About buy

The `buy` endpoint: Buy a contract using a proposal ID, or pass contract parameters directly.

This is a trading endpoint. Use it to get proposals, buy/sell contracts, and manage active positions. Most trading endpoints require authentication.