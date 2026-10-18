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
    const { code, state } = await req.json()

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Verify state and get code_verifier
    const { data: oauthSession, error: sessionError } = await supabase
      .from('oauth_sessions')
      .select('*')
      .eq('state', state)
      .eq('status', 'pending')
      .single()

    if (sessionError || !oauthSession) {
      throw new Error('Invalid or expired state')
    }

    // Exchange code for token
    const tokenResponse = await fetch('https://auth.deriv.com/oauth2/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        client_id: Deno.env.get('DERIV_CLIENT_ID') ?? '',
        code,
        code_verifier: oauthSession.code_verifier,
        redirect_uri: oauthSession.redirect_uri,
      }),
    })

    const tokenData = await tokenResponse.json()

    if (!tokenResponse.ok) {
      throw new Error(tokenData.error_description || 'Token exchange failed')
    }

    // Get user info from Deriv API
    const userInfoResponse = await fetch('https://api.derivws.com/trading/v1/accounts', {
      headers: { Authorization: `Bearer ${tokenData.access_token}` },
    })

    const userInfo = await userInfoResponse.json()

    // Create or update user in Supabase Auth
    let userId: string

    // Try to find existing user by email
    const { data: existingUsers } = await supabase
      .from('users')
      .select('id')
      .eq('email', userInfo.email)
      .single()

    if (existingUsers) {
      // User exists, update
      userId = existingUsers.id
      await supabase
        .from('users')
        .update({
          deriv_access_token: tokenData.access_token,
          deriv_token_expires_at: new Date(Date.now() + tokenData.expires_in * 1000).toISOString(),
          deriv_scopes: oauthSession.scopes,
          last_login_at: new Date().toISOString(),
        })
        .eq('id', userId)
    } else {
      // New user, create
      const { data: authData, error: authError } = await supabase.auth.admin.createUser({
        email: userInfo.email,
        email_confirm: true,
        user_metadata: {
          full_name: userInfo.name,
          deriv_account_id: userInfo.account_id,
        },
      })

      if (authError) throw authError

      userId = authData.user.id

      // Insert user data
      await supabase.from('users').insert({
        id: userId,
        email: userInfo.email,
        full_name: userInfo.name,
        deriv_account_id: userInfo.account_id,
        deriv_access_token: tokenData.access_token,
        deriv_token_expires_at: new Date(Date.now() + tokenData.expires_in * 1000).toISOString(),
        deriv_scopes: oauthSession.scopes,
      })

      // Create default preferences
      await supabase.from('user_preferences').insert({
        user_id: userId,
      })
    }

    // Mark OAuth session as completed
    await supabase
      .from('oauth_sessions')
      .update({
        status: 'completed',
        completed_at: new Date().toISOString(),
      })
      .eq('state', state)

    // Generate session token
    const { data: sessionData, error: sessionError2 } = await supabase.auth.admin.generateLink({
      type: 'magiclink',
      email: userInfo.email,
    })

    if (sessionError2) throw sessionError2

    return new Response(
      JSON.stringify({
        access_token: sessionData.properties.access_token,
        refresh_token: sessionData.properties.refresh_token,
        user: {
          id: userId,
          email: userInfo.email,
          full_name: userInfo.name,
          deriv_account_id: userInfo.account_id,
        },
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
