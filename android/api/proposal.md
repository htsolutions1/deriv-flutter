[Trading Operations](/docs/trading)

# Price Proposal

No auth

Get a price proposal for a specific contract.

## Request & Response

## Request Schema

#### `proposal` — Required `integer | enum`

Must be `1`

Allowed values: `1`

#### `amount` — Optional `number`

[Optional] Proposed contract payout or stake.

Min: 0

#### `barrier` — Optional `string`

[Optional] Barrier for the contract (or last digit prediction for digit contracts). Contracts less than 24 hours in duration would need a relative barrier (barriers which need +/-), where entry spot would be adjusted accordingly with that amount to define a barrier, except for Synthetic Indices as they support both relative and absolute barriers. Not needed for lookbacks.

Pattern: `^(?=.{1,20}$)[+-]?[0-9]+\.?[0-9]*$`

#### `barrier2` — Optional `string`

[Optional] Low barrier for the contract (for contracts with two barriers). Contracts less than 24 hours in duration would need a relative barrier (barriers which need +/-), where entry spot would be adjusted accordingly with that amount to define a barrier, except for Synthetic Indices as they support both relative and absolute barriers. Not needed for lookbacks.

Pattern: `^(?=.{1,20}$)[+-]?[0-9]+\.?[0-9]*$`

#### `basis` — Optional `string | enum`

[Optional] Indicates type of the `amount`.

Allowed values: `"payout"`, `"stake"`

#### `cancellation` — Optional `string`

Cancellation duration option (only for `MULTUP` and `MULTDOWN` contracts).

Pattern: `^\w+$`

#### `contract_type` — Required `string | enum`

The proposed contract type

Allowed values: `"HIGHER"`, `"LOWER"`, `"MULTUP"`, `"MULTDOWN"`, `"UPORDOWN"`, `"EXPIRYRANGE"`, `"ONETOUCH"`, `"CALLE"`, `"ASIAND"`, `"EXPIRYRANGEE"`, `"DIGITDIFF"`, `"DIGITMATCH"`, `"DIGITOVER"`, `"PUTE"`, `"DIGITUNDER"`, `"NOTOUCH"`, `"CALL"`, `"RANGE"`, `"DIGITODD"`, `"PUT"`, `"ASIANU"`, `"EXPIRYMISSE"`, `"EXPIRYMISS"`, `"DIGITEVEN"`, `"TICKHIGH"`, `"TICKLOW"`, `"RESETCALL"`, `"RESETPUT"`, `"RUNHIGH"`, `"RUNLOW"`, `"ACCU"`, `"VANILLALONGCALL"`, `"VANILLALONGPUT"`, `"TURBOSLONG"`, `"TURBOSSHORT"`

#### `currency` — Required `string`

This can only be the account-holder's currency (obtained from `payout_currencies` call).

Pattern: `^[a-zA-Z0-9]{2,20}$`

#### `date_expiry` — Optional `integer`

[Optional] Epoch value of the expiry time of the contract. Either date_expiry or duration is required.

Min: 0 · Max: 9999999999

#### `duration` — Optional `integer`

[Optional] Duration quantity. Either date_expiry or duration is required.

Min: 0 · Max: 99999999

#### `duration_unit` — Optional `string | enum`

[Optional] Duration unit - `s`: seconds, `m`: minutes, `h`: hours, `d`: days, `t`: ticks.

Default: `"s"`

Allowed values: `"d"`, `"m"`, `"s"`, `"h"`, `"t"`

#### `growth_rate` — Optional `number`

[Optional] Growth rate of an accumulator contract.

#### `limit_order` — Optional `object`

Add an order to close the contract once the order condition is met (only for `MULTUP` and `MULTDOWN` and 'ACCU' contracts). Supported orders: `take_profit`, `stop_loss`.

**Object Properties:**

  ##### `stop_loss` — Optional `number`

  Contract will be automatically closed when the value of the contract reaches a specific loss.

  ##### `take_profit` — Optional `number`

  Contract will be automatically closed when the value of the contract reaches a specific profit.

#### `multiplier` — Optional `number`

[Optional] The multiplier for non-binary options. E.g. lookbacks.

Min: 0

#### `payout_per_point` — Optional `number`

[Optional] Clients can provide payout_per_point directly, and the barrier will be calculated based on this payout_per_point value.

#### `selected_tick` — Optional `integer`

[Optional] The tick that is predicted to have the highest/lowest value - for `TICKHIGH` and `TICKLOW` contracts.

#### `subscribe` — Optional `integer | enum`

[Optional] 1 - to initiate a realtime stream of prices. Note that tick trades (without a user-defined barrier), digit trades and less than 24 hours at-the-money contracts for the following underlying symbols are not streamed: `R_10`, `R_25`, `R_50`, `R_75`, `R_100`, `RDBULL`, `RDBEAR` (this is because their price is constant).

Allowed values: `1`

#### `underlying_symbol` — Required `string`

The symbol code (obtained from `active_symbols` call).

Pattern: `^\w{2,30}$`

#### `passthrough` — Optional `object`

[Optional] Used to pass data through the websocket, which may be retrieved via the `echo_req` output field.

#### `req_id` — Optional `integer`

[Optional] Used to map request to response.

## Response Schema

#### `proposal` — Optional `object`

Latest price and other details for a given contract

**Object Properties:**

  ##### `ask_price` — Required `number`

  The ask price.

  ##### `barrier_choices` — Optional `array`

  [Only for vanilla options] The choices of predefined strike price for client to choose

  ##### `barrier_spot_distance` — Optional `string`

  [Only for Turbos] The relative distance between current spot and the barrier.

  ##### `cancellation` — Optional `object`

  Contains information about contract cancellation option.

  **Object Properties:**

    ###### `ask_price` — Optional `number`

    Ask price of contract cancellation option.

    ###### `date_expiry` — Optional `integer`

    Expiry time in epoch for contract cancellation option.

  ##### `commission` — Optional `null | number`

  Commission changed in percentage (%).

  ##### `contract_details` — Optional `object`

  Contains contract information.

  **Object Properties:**

    ###### `app_markup_amount` — Optional `string`

    The markup amount charged on a client's stake amount

    ###### `barrier` — Optional `string`

    Barrier of the contract.

    Pattern: `^[+-]?[0-9]+\.?[0-9]*$`

    ###### `barrier_spot_distance` — Optional `string`

    Absolute difference between high/low barrier and spot

    Pattern: `^[+-]?[0-9]+\.?[0-9]*$`

    ###### `high_barrier` — Optional `string`

    High barrier calculated based on current spot

    Pattern: `^[+-]?[0-9]+\.?[0-9]*$`

    ###### `last_tick_epoch` — Optional `integer`

    Epoch of last tick considered for stat chart

    ###### `low_barrier` — Optional `string`

    Low barrier calculated based on current spot

    Pattern: `^[+-]?[0-9]+\.?[0-9]*$`

    ###### `maximum_payout` — Optional `number`

    Maximum payout that user can get out of a contract, contract will close automatically if payout reaches this number

    ###### `maximum_stake` — Optional `string`

    Maximum stake that user can set to buy a contract

    ###### `maximum_ticks` — Optional `integer`

    Maximum duration that a contract can last, contract will close automatically after this number of ticks

    ###### `minimum_stake` — Optional `string`

    Minimum stake that user can set to buy a contract

    ###### `tick_size_barrier` — Optional `number`

    Tick size barrier for Accumulator contracts

    ###### `tick_size_barrier_percentage` — Optional `string`

    [Accumulator] Tick size barrier in percentage, rounded off to 5 decimal places

    ###### `ticks_stayed_in` — Optional `array`

    An array of numbers  to build a stat chart - each number represents the duration that spot stayed between barries

  ##### `date_expiry` — Optional `integer`

  The end date of the contract.

  ##### `date_start` — Required `integer`

  The start date of the contract.

  ##### `display_number_of_contracts` — Optional `string`

  [Only for vanilla or turbos options] The implied number of contracts

  ##### `id` — Required `string`

  A per-connection unique identifier. Can be passed to the `forget` API call to unsubscribe.

  ##### `limit_order` — Optional `object`

  Contains limit order information. (Only applicable for contract with limit order).

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

    Contains information where the contract will be closed automatically at the profit specified by the user.

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

  ##### `longcode` — Required `string`

  Example: Win payout if Random 100 Index is strictly higher than entry spot at 15 minutes after contract start time.

  ##### `max_stake` — Optional `number`

  [Only for vanilla or turbos options] Maximum stakes allowed

  ##### `min_stake` — Optional `number`

  [Only for vanilla or turbos options] Minimum stakes allowed

  ##### `multiplier` — Optional `number`

  [Only for lookback trades] Multiplier applies when calculating the final payoff for each type of lookback. e.g. (Exit spot - Lowest historical price) * multiplier = Payout

  ##### `payout` — Required `number`

  The payout amount of the contract.

  ##### `payout_choices` — Optional `array`

  [Only for Turbos] The choices of predefined payout per point for client to choose

  ##### `spot` — Required `number`

  Spot value (if there are no Exchange data-feed licensing restrictions for the underlying symbol).

  ##### `spot_time` — Required `integer`

  The corresponding time of the spot value.

  ##### `validation_params` — Optional `object`

  Contains contract validation information.

  **Object Properties:**

    ###### `max_payout` — Optional `string`

    [Only for Accumulators] Maximum payout for the contract.

    ###### `max_ticks` — Optional `integer`

    [Only for Accumulators] Maximum ticks for the contract.

    ###### `payout` — Optional `object`

    Contains information for minimum and maximum payout amount for the contract.

    **Object Properties:**

      ###### `max` — Optional `string`

      Maximum payout allowed

    ###### `stake` — Optional `object`

    Contains information for minimum and maximum stake amount for the contract.

    **Object Properties:**

      ###### `max` — Optional `string`

      Maximum stake allowed

      ###### `min` — Optional `string`

      Minimum stake allowed

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

#### `msg_type` — Required `string | enum`

Action name of the request made.

Allowed values: `"proposal"`

#### `req_id` — Optional `integer`

Optional field sent in request to map to response, present only when request contains `req_id`.

## Examples

### Request Example

```json
{
  "proposal": 1,
  "amount": 100,
  "barrier": "+0.1",
  "basis": "payout",
  "contract_type": "HIGHER",
  "currency": "USD",
  "duration": 60,
  "duration_unit": "s",
  "underlying_symbol": "R_100"
}
```

### Response Example

```json
{
  "proposal": {
    "ask_price": 51.02,
    "date_start": 1234567890,
    "id": "uw2mk7no3oktoRVVsB4Dz7TQnFfABuFDgO95dlxfMxRuPUsz",
    "longcode": "Win payout if Volatility 100 Index...",
    "payout": 100,
    "spot": 123.45,
    "spot_time": 1234567890
  },
  "msg_type": "proposal"
}
```

## About proposal

The `proposal` endpoint: Get a price proposal for a specific contract.

This is a trading endpoint. Use it to get proposals, buy/sell contracts, and manage active positions. Most trading endpoints require authentication.