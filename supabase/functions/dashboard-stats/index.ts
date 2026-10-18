import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get auth token from header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('No authorization header')
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: authHeader },
        },
      }
    )

    // Get current user
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) throw new Error('Unauthorized')

    // Get active bots count
    const { count: activeBotsCount } = await supabase
      .from('bots')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', user.id)
      .eq('status', 'running')

    // Get active trades count
    const { count: activeTradesCount } = await supabase
      .from('trades')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', user.id)
      .eq('outcome', 'open')

    // Get today's trades stats
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    const { data: todayTrades } = await supabase
      .from('trades')
      .select('pnl, outcome')
      .eq('user_id', user.id)
      .gte('opened_at', today.toISOString())

    const todayTradesCount = todayTrades?.length || 0
    const todayProfit = todayTrades?.reduce((sum, trade) => sum + (trade.pnl || 0), 0) || 0
    const todayWins = todayTrades?.filter((t) => t.outcome === 'win').length || 0
    const todayWinRate = todayTradesCount > 0 ? (todayWins / todayTradesCount) * 100 : 0

    // Get connection status (check latest connection)
    const { data: latestConnection } = await supabase
      .from('api_connections')
      .select('status')
      .eq('user_id', user.id)
      .eq('connection_type', 'websocket')
      .order('created_at', { ascending: false })
      .limit(1)
      .single()

    // Get recent signals (last 5)
    const { data: recentSignals } = await supabase
      .from('signals')
      .select('*')
      .eq('status', 'pending')
      .order('created_at', { ascending: false })
      .limit(5)

    // Get total balance (sum of all bot profits)
    const { data: allTrades } = await supabase
      .from('trades')
      .select('pnl')
      .eq('user_id', user.id)
      .neq('outcome', 'open')

    const totalBalance = allTrades?.reduce((sum, trade) => sum + (trade.pnl || 0), 0) || 0

    return new Response(
      JSON.stringify({
        connection_status: latestConnection?.status || 'disconnected',
        active_bots_count: activeBotsCount || 0,
        active_trades_count: activeTradesCount || 0,
        today_trades: todayTradesCount,
        today_profit: parseFloat(todayProfit.toFixed(2)),
        win_rate_today: parseFloat(todayWinRate.toFixed(2)),
        total_balance: parseFloat(totalBalance.toFixed(2)),
        recent_signals: recentSignals || [],
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
