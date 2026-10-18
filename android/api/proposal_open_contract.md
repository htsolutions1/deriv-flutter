[Trading Operations](/docs/trading)

# Open Contract Status

Auth required

Get the latest status of an open contract.

## Request & Response

## Request Schema

#### `proposal_open_contract` — Required `integer | enum`

Must be `1`

Allowed values: `1`

#### `contract_id` — Optional `integer`

[Optional] Contract ID received from a `portfolio` request. If not set, you will receive stream of all open contracts.

#### `subscribe` — Optional `integer | enum`

[Optional] `1` to stream.

Allowed values: `1`

#### `passthrough` — Optional `object`

[Optional] Used to pass data through the websocket, which may be retrieved via the `echo_req` output field.

#### `req_id` — Optional `integer`

[Optional] Used to map request to response.

## Response Schema

#### `proposal_open_contract` — Optional `object`

Latest price and other details for an open contract

**Object Properties:**

  ##### `account_id` — Optional `number`

  Account Id

  ##### `app_markup_amount` — Optional `string`

  The markup amount charged on a client's stake amount

  ##### `audit_details` — Optional `null | object`

  Tick details around contract start and end time.

  **Object Properties:**

    ###### `all_ticks` — Optional `array`

    Ticks for tick expiry contract from start time till expiry.

    **Array Items:**

      ###### `epoch` — Optional `integer`

      Epoch time of a tick or the contract start or end time.

      ###### `flag` — Optional `null | string`

      A flag used to highlight the record in front-end applications.

      ###### `name` — Optional `null | string`

      A short description of the data. It could be a tick or a time associated with the contract.

      ###### `tick` — Optional `null | number`

      The spot value at the given epoch.

      ###### `tick_display_value` — Optional `null | string`

      The spot value with the correct precision at the given epoch.

    ###### `contract_end` — Optional `array`

    Ticks around contract end time.

    **Array Items:**

      ###### `epoch` — Optional `integer`

      Epoch time of a tick or the contract start or end time.

      ###### `flag` — Optional `null | string`

      A flag used to highlight the record in front-end applications.

      ###### `name` — Optional `null | string`

      A short description of the data. It could be a tick or a time associated with the contract.

      ###### `tick` — Optional `null | number`

      The spot value at the given epoch.

      ###### `tick_display_value` — Optional `null | string`

      The spot value with the correct precision at the given epoch.

    ###### `contract_start` — Optional `array`

    Ticks around contract start time.

    **Array Items:**

      ###### `epoch` — Optional `integer`

      Epoch time of a tick or the contract start or end time.

      ###### `flag` — Optional `null | string`

      A flag used to highlight the record in front-end applications.

      ###### `name` — Optional `null | string`

      A short description of the data. It could be a tick or a time associated with the contract.

      ###### `tick` — Optional `null | number`

      The spot value at the given epoch.

      ###### `tick_display_value` — Optional `null | string`

      The spot value with the correct precision at the given epoch.

  ##### `auto_run_id` — Optional `string`

  Identifier of the automated run that purchased this contract.

  ##### `barrier` — Optional `null | string`

  Barrier of the contract (if any).

  ##### `barrier_count` — Optional `number`

  The number of barriers a contract has.

  ##### `barrier_spot_distance` — Optional `string`

  [Only for accumulator] Absolute difference between high/low barrier and spot

  Pattern: `^[+-]?[0-9]+\.?[0-9]*$`

  ##### `bid_price` — Optional `string`

  Price at which the contract could be sold back to the company.

  ##### `buy_price` — Optional `string`

  Price at which contract was purchased

  ##### `cancellation` — Optional `object`

  Contains information about contract cancellation option.

  **Object Properties:**

    ###### `ask_price` — Optional `null | number`

    Ask price of contract cancellation option.

    ###### `date_expiry` — Optional `integer`

    Expiry time in epoch for contract cancellation option.

  ##### `commission` — Optional `null | string`

  Commission in payout currency amount.

  ##### `contract_id` — Optional `integer`

  The internal contract identifier

  ##### `contract_type` — Optional `string`

  Contract type.

  ##### `currency` — Optional `string`

  The currency code of the contract.

  ##### `current_spot` — Optional `string`

  Spot value if we have license to stream this symbol.

  ##### `current_spot_high_barrier` — Optional `string`

  [Applicable for accumulator] High barrier based on current spot.

  Pattern: `^[+-]?[0-9]+\.?[0-9]*$`

  ##### `current_spot_low_barrier` — Optional `string`

  [Applicable for accumulator] Low barrier based on current spot.

  Pattern: `^[+-]?[0-9]+\.?[0-9]*$`

  ##### `current_spot_time` — Optional `integer`

  The corresponding time of the current spot.

  ##### `date_expiry` — Optional `integer`

  Expiry date (epoch) of the Contract. Please note that it is not applicable for tick trade contracts.

  ##### `date_settlement` — Optional `integer`

  Settlement date (epoch) of the contract.

  ##### `date_start` — Optional `integer`

  Start date (epoch) of the contract.

  ##### `display_number_of_contracts` — Optional `string`

  [Only for vanilla or turbos options] The implied number of contracts

  ##### `entry_spot` — Optional `null | string`

  The first valid underlying spot price for the contract.

  ##### `entry_spot_time` — Optional `integer | null`

  This is the epoch time of the entry spot.

  ##### `exit_spot` — Optional `null | string`

  Exit spot can refer to the latest quote at the end time, the quote that fulfils the contract's winning or losing condition for path dependent contracts (Touch/No Touch and Stays Between/Goes Outside) or the quote at which the contract is sold before expiry.

  ##### `exit_spot_time` — Optional `integer | null`

  This is the epoch time of the exit spot. Note that since certain instruments don't tick every second, the exit spot time may be a few seconds before the end time.

  ##### `expiry_time` — Optional `integer`

  This is the expiry time.

  ##### `growth_rate` — Optional `number`

  [Only for accumulator] Growth rate of an accumulator contract.

  ##### `high_barrier` — Optional `string`

  High barrier of the contract (if any).

  Pattern: `^[+-]?[0-9]+\.?[0-9]*$`

  ##### `id` — Optional `string`

  A per-connection unique identifier. Can be passed to the `forget` API call to unsubscribe.

  ##### `is_expired` — Optional `integer | enum`

  Whether the contract is expired or not.

  Allowed values: `0`, `1`

  ##### `is_intraday` — Optional `integer | enum`

  Whether the contract is an intraday contract.

  Allowed values: `0`, `1`

  ##### `is_path_dependent` — Optional `integer | enum`

  Whether the contract expiry price will depend on the path of the market (e.g. One Touch contract).

  Allowed values: `0`, `1`

  ##### `is_settleable` — Optional `integer | enum`

  Whether the contract is settleable or not.

  Allowed values: `0`, `1`

  ##### `is_sold` — Optional `integer | enum`

  Whether the contract is sold or not.

  Allowed values: `0`, `1`

  ##### `is_valid_to_cancel` — Optional `integer | enum`

  Whether the contract can be cancelled.

  Allowed values: `0`, `1`

  ##### `is_valid_to_sell` — Optional `integer | enum`

  Whether the contract can be sold back to the company.

  Allowed values: `0`, `1`

  ##### `is_valid_to_update` — Optional `null | object`

  [Optional] Indicator whether take profit, stop loss, and/or stop out is allowed to be updated.

  **Object Properties:**

    ###### `stop_loss` — Optional `integer | null | enum`

    [Optional] 1 if stop loss is allowed to be updated and 0 if otherwise. This field is undefined if stop loss functionality is not supported by the contract.

    Allowed values: `0`, `1`

    ###### `stop_out` — Optional `integer | null | enum`

    [Optional] 1 if stop out is allowed to be updated and 0 if otherwise. This field is undefined if stop out functionality is not supported by the contract.

    Allowed values: `0`, `1`

    ###### `take_profit` — Optional `integer | null | enum`

    [Optional] 1 if take profit is allowed to be updated and 0 if otherwise. This field is undefined if take profit functionality is not supported by the contract.

    Allowed values: `0`, `1`

  ##### `limit_order` — Optional `object`

  Orders are applicable to `MULTUP` and `MULTDOWN` contracts only.

  **Object Properties:**

    ###### `stop_loss` — Optional `object`

    Contains information where the contract will be closed automatically at the loss specified by the user.

    **Object Properties:**

      ###### `display_name` — Optional `string`

      Localized display name

      ###### `display_order_amount` — Optional `null | string`

      Stop loss amount for display purpose.

      ###### `order_amount` — Optional `null | number`

      Stop loss amount. Will be deprecated soon. Please use [display_order_amount].

      ###### `order_date` — Optional `integer`

      Stop loss order epoch

      ###### `value` — Optional `null | string`

      Pip-sized barrier value

    ###### `stop_out` — Optional `object`

    Contains information where the contract will be closed automatically when the value of the contract is close to zero. This is set by the us.

    **Object Properties:**

      ###### `display_name` — Optional `string`

      Localized display name

      ###### `display_order_amount` — Optional `null | string`

      Stop out amount for display purpose.

      ###### `order_amount` — Optional `null | number`

      Stop out amount. Will be deprecated soon. Please use [display_order_amount].

      ###### `order_date` — Optional `integer`

      Stop out order epoch

      ###### `value` — Optional `string`

      Pip-sized barrier value

    ###### `take_profit` — Optional `object`

    Contain information where the contract will be closed automatically at the profit specified by the user.

    **Object Properties:**

      ###### `display_name` — Optional `string`

      Localized display name

      ###### `display_order_amount` — Optional `null | string`

      Take profit amount for display purpose.

      ###### `order_amount` — Optional `null | number`

      Take profit amount. Will be deprecated soon. Please use [display_order_amount].

      ###### `order_date` — Optional `integer`

      Take profit order epoch

      ###### `value` — Optional `null | string`

      Pip-sized barrier value

  ##### `longcode` — Optional `string`

  Text description of the contract purchased, Example: Win payout if Volatility 100 Index is strictly higher than entry spot at 10 minutes after contract start time.

  ##### `low_barrier` — Optional `string`

  Low barrier of the contract (if any).

  Pattern: `^[+-]?[0-9]+\.?[0-9]*$`

  ##### `multiplier` — Optional `number`

  [Only for lookback trades] Multiplier applies when calculating the final payoff for each type of lookback. e.g. (Exit spot - Lowest historical price) * multiplier = Payout

  ##### `payout` — Optional `string`

  Payout value of the contract.

  ##### `profit` — Optional `string`

  The latest bid price minus buy price.

  ##### `profit_percentage` — Optional `number`

  Profit in percentage.

  ##### `purchase_time` — Optional `integer`

  Epoch of purchase time, will be same as `date_start` for all contracts except forward starting contracts.

  ##### `reset_barrier` — Optional `null | string`

  [Only for reset trades i.e. RESETCALL and RESETPUT] Reset barrier of the contract.

  ##### `reset_time` — Optional `integer`

  [Only for reset trades i.e. RESETCALL and RESETPUT] The epoch time of a barrier reset.

  ##### `selected_spot` — Optional `null | string`

  Spot value at the selected tick for the contract.

  ##### `selected_tick` — Optional `integer`

  [Only for highlowticks trades i.e. TICKHIGH and TICKLOW] Selected tick for the contract.

  ##### `sell_price` — Optional `null | string`

  Price at which contract was sold, only available when contract has been sold.

  ##### `sell_time` — Optional `integer | null`

  Epoch time of when the contract was sold (only present for contracts already sold)

  ##### `shortcode` — Optional `string`

  Coded description of the contract purchased.

  ##### `status` — Optional `null | string | enum`

  Contract status. Will be `sold` if the contract was sold back before expiry, `won` if won and `lost` if lost at expiry. Otherwise will be `open`

  Allowed values: `"open"`, `"sold"`, `"won"`, `"lost"`, `"cancelled"`, `null`

  ##### `tick_count` — Optional `integer`

  Only for tick trades, number of ticks

  ##### `tick_passed` — Optional `integer`

  [Only for accumulator] Number of ticks passed since entry_tick

  ##### `tick_stream` — Optional `array`

  Tick stream from entry to end time.

  **Array Items:**

    ###### `epoch` — Optional `integer`

    Epoch time of a tick or the contract start or end time.

    ###### `tick` — Optional `null | number`

    The spot value at the given epoch.

    ###### `tick_display_value` — Optional `null | string`

    The spot value with the correct precision at the given epoch.

  ##### `transaction_ids` — Optional `object`

  Every contract has buy and sell transaction ids, i.e. when you purchase a contract we associate it with buy transaction id, and if contract is already sold we associate that with sell transaction id.

  **Object Properties:**

    ###### `buy` — Optional `integer`

    Buy transaction ID for that contract

    ###### `sell` — Optional `integer`

    Sell transaction ID for that contract, only present when contract is already sold.

  ##### `underlying_symbol` — Optional `string`

  The underlying symbol code.

  ##### `validation_error` — Optional `string`

  Error message if validation fails

  ##### `validation_error_code` — Optional `string`

  Error code if validation fails

  ##### `validation_error_code_args` — Optional `array | null`

  Error code arguments if validation fails

  ##### `validation_params` — Optional `object`

  Contains contract validation information.

  **Object Properties:**

    ###### `max_payout` — Optional `string`

    [Only for Accumulators] Maximum payout for the contract.

    ###### `max_ticks` — Optional `integer`

    [Only for Accumulators] Maximum ticks for the contract.

    ###### `stake` — Optional `object`

    Contains information for minimum and maximum stake amount for the contract.

    **Object Properties:**

      ###### `max` — Optional `string`

      Maximum stakes allowed

      ###### `min` — Optional `string`

      Minimum stakes allowed

    ###### `stop_loss` — Optional `object`

    [Only for Multipliers] Contains information for minimum and maximum stop loss amount for the contract.

    **Object Properties:**

      ###### `max` — Optional `string`

      Maximum stop loss amount

      ###### `min` — Optional `string`

      Minimum stop loss amount

    ###### `take_profit` — Optional `object`

    Contains information for minimum and maximum take profit amount for the contract.

    **Object Properties:**

      ###### `max` — Optional `string`

      Maximum take profit amount

      ###### `min` — Optional `string`

      Minimum take profit amount

#### `subscription` — Optional `object`

For subscription requests only.

**Object Properties:**

  ##### `id` — Required `string`

  A per-connection unique identifier. Can be passed to the `forget` API call to unsubscribe.

#### `echo_req` — Required `object`

Echo of the request made.

#### `msg_type` — Optional `string | enum`

Action name of the request made.

Allowed values: `"proposal_open_contract"`

#### `req_id` — Optional `integer`

Optional field sent in request to map to response, present only when request contains `req_id`.

## Examples

### Request Example

```json
{
  "proposal_open_contract": 1,
  "contract_id": 11111111,
  "subscribe": 1
}
```

### Response Example

```json
{
  "proposal_open_contract": {
    "account_id": "VRTC965733",
    "barrier": "123.55",
    "bid_price": 49.50,
    "buy_price": 51.02,
    "contract_id": 11111111,
    "contract_type": "CALL",
    "currency": "USD",
    "current_spot": 123.50,
    "current_spot_time": 1234567895,
    "date_expiry": 1234567950,
    "date_start": 1234567890,
    "entry_spot": 123.45,
    "entry_spot_time": 1234567890,
    "is_expired": 0,
    "is_sold": 0,
    "is_valid_to_sell": 1,
    "longcode": "Win payout if Volatility 100 Index is strictly higher than entry spot at 1 minute after contract start time.",
    "payout": 100,
    "profit": -1.52,
    "profit_percentage": -2.98,
    "shortcode": "CALL_R_100_100_1234567890_1234567950_S0P_0",
    "status": "open",
    "underlying_symbol": "R_100"
  },
  "msg_type": "proposal_open_contract",
  "subscription": {
    "id": "xyz123"
  }
}
```

##### Authentication Required

This endpoint requires a valid session. Ensure your WebSocket connection is authenticated before calling this endpoint.

## About proposal_open_contract

The `proposal_open_contract` endpoint: Get the latest status of an open contract.

This is a trading endpoint. Use it to get proposals, buy/sell contracts, and manage active positions. Most trading endpoints require authentication.