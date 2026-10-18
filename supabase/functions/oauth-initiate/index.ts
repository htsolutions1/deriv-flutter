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
    const { action, redirect_uri, utm_params } = await req.json()

    // Generate PKCE parameters
    const codeVerifier = generateCodeVerifier()
    const codeChallenge = await generateCodeChallenge(codeVerifier)
    const state = generateState()

    // Store OAuth session in database
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { error } = await supabase.from('oauth_sessions').insert({
      state,
      code_verifier: codeVerifier,
      code_challenge: codeChallenge,
      redirect_uri,
      scopes: ['trade', 'account_manage'],
      is_signup: action === 'signup',
      utm_source: utm_params?.utm_source,
      utm_medium: utm_params?.utm_medium,
      utm_campaign: utm_params?.utm_campaign,
      tracking_token: utm_params?.tracking_token,
    })

    if (error) throw error

    // Build authorization URL
    const authUrl = new URL('https://auth.deriv.com/oauth2/auth')
    authUrl.searchParams.set('response_type', 'code')
    authUrl.searchParams.set('client_id', Deno.env.get('DERIV_CLIENT_ID') ?? '')
    authUrl.searchParams.set('redirect_uri', redirect_uri)
    authUrl.searchParams.set('scope', 'trade account_manage')
    authUrl.searchParams.set('state', state)
    authUrl.searchParams.set('code_challenge', codeChallenge)
    authUrl.searchParams.set('code_challenge_method', 'S256')

    if (action === 'signup') {
      authUrl.searchParams.set('prompt', 'registration')
      if (utm_params?.tracking_token) {
        authUrl.searchParams.set('t', utm_params.tracking_token)
      }
      if (utm_params?.utm_campaign) {
        authUrl.searchParams.set('utm_campaign', utm_params.utm_campaign)
      }
      if (utm_params?.utm_medium) {
        authUrl.searchParams.set('utm_medium', utm_params.utm_medium)
      }
      if (utm_params?.utm_source) {
        authUrl.searchParams.set('utm_source', utm_params.utm_source)
      }
    }

    return new Response(
      JSON.stringify({
        authorization_url: authUrl.toString(),
        state,
        expires_at: new Date(Date.now() + 10 * 60 * 1000).toISOString(),
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

// Helper functions
function generateCodeVerifier(): string {
  const array = new Uint8Array(64)
  crypto.getRandomValues(array)
  return Array.from(array)
    .map((v) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~'[v % 66])
    .join('')
}

async function generateCodeChallenge(verifier: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(verifier)
  const hash = await crypto.subtle.digest('SHA-256', data)
  return btoa(String.fromCharCode(...new Array.from(new Uint8Array(hash))))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '')
}

function generateState(): string {
  const array = new Uint8Array(16)
  crypto.getRandomValues(array)
  return Array.from(array)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
}
