[Trading Operations](/docs/trading)

# Contract Update History

Auth required

Get history of updates for a contract.

## Request & Response

## Request Schema

#### `contract_update_history` — Required `integer | enum`

Must be `1`

Allowed values: `1`

#### `contract_id` — Required `integer`

Internal unique contract identifier.

#### `limit` — Optional `number`

[Optional] Maximum number of historical updates to receive.

Min: 1 · Max: 999 · Default: `500`

#### `passthrough` — Optional `object`

[Optional] Used to pass data through the websocket, which may be retrieved via the `echo_req` output field.

#### `req_id` — Optional `integer`

[Optional] Used to map request to response.

## Response Schema

#### `contract_update_history` — Optional `array`

Contains the historical and the most recent update status of the contract

**Array Items:**

  ##### `display_name` — Optional `string`

  Display name of the changed parameter.

  ##### `order_amount` — Optional `string`

  The amount.

  ##### `order_date` — Optional `integer`

  The epoch when the changed was done.

  ##### `order_type` — Optional `string`

  The contract parameter updated.

  ##### `value` — Optional `null | string`

  The pip-sized barrier value.

#### `echo_req` — Required `object`

Echo of the request made.

#### `msg_type` — Required `string | enum`

Action name of the request made.

Allowed values: `"contract_update_history"`

#### `req_id` — Optional `integer`

Optional field sent in request to map to response, present only when request contains `req_id`.

## Examples

### Request Example

```json
{
  "contract_update_history": 1,
  "contract_id": 123
}
```

### Response Example

```json
{
  "contract_update_history": [
    {
      "order_date": 1234567890,
      "order_type": "take_profit",
      "value": "1.50"
    }
  ],
  "msg_type": "contract_update_history"
}
```

##### Authentication Required

This endpoint requires a valid session. Ensure your WebSocket connection is authenticated before calling this endpoint.

## About contract_update_history

The `contract_update_history` endpoint: Get history of updates for a contract.

This is a trading endpoint. Use it to get proposals, buy/sell contracts, and manage active positions. Most trading endpoints require authentication.