-- ============================================================
-- COMPLETE DATABASE SCHEMA FOR HTS BOT
-- Trading Bot Application with Deriv OAuth Integration
-- ============================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- 1. USERS & AUTHENTICATION
-- ============================================================

-- Main users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    
    -- Deriv OAuth data
    deriv_account_id TEXT UNIQUE,
    deriv_access_token TEXT, -- Encrypted
    deriv_token_expires_at TIMESTAMPTZ,
    deriv_scopes TEXT[], -- Array of granted scopes: trade, account_manage, etc.
    
    -- Account status
    is_premium BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login_at TIMESTAMPTZ
);

-- User preferences (settings screen)
CREATE TABLE IF NOT EXISTS public.user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- Trading preferences
    default_stake DECIMAL(10, 2) DEFAULT 10.00,
    default_duration_seconds INTEGER DEFAULT 60,
    auto_trade_enabled BOOLEAN DEFAULT FALSE,
    
    -- Notification preferences
    notifications_enabled BOOLEAN DEFAULT TRUE,
    signal_notifications BOOLEAN DEFAULT TRUE,
    trade_result_notifications BOOLEAN DEFAULT TRUE,
    
    -- Display preferences
    theme TEXT DEFAULT 'dark' CHECK (theme IN ('light', 'dark')),
    language TEXT DEFAULT 'en',
    currency TEXT DEFAULT 'USD',
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id)
);

-- User activity log
CREATE TABLE IF NOT EXISTS public.user_activity (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL, -- login, logout, trade_executed, settings_changed, etc.
    metadata JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. SUBSCRIPTION & PREMIUM FEATURES
-- ============================================================

-- Subscription plans
CREATE TABLE IF NOT EXISTS public.subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    billing_period TEXT NOT NULL CHECK (billing_period IN ('monthly', 'yearly', 'lifetime')),
    features JSONB, -- JSON array of feature flags
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User subscriptions
CREATE TABLE IF NOT EXISTS public.user_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES public.subscription_plans(id),
    
    -- Subscription status
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired', 'paused')),
    
    -- Billing
    started_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    
    -- Payment info
    payment_method TEXT, -- stripe, paypal, crypto, etc.
    payment_reference TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 3. TRADING BOTS
-- ============================================================

-- Bot configurations
CREATE TABLE IF NOT EXISTS public.bots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- Bot details
    name TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'idle' CHECK (status IN ('idle', 'running', 'stopped', 'error')),
    
    -- Strategy configuration
    strategy_type TEXT NOT NULL, -- martingale, fixed_stake, compound, etc.
    strategy_config JSONB NOT NULL, -- JSON object with strategy-specific settings
    
    -- Risk management
    max_daily_loss DECIMAL(10, 2),
    max_consecutive_losses INTEGER,
    stop_loss_percentage DECIMAL(5, 2),
    take_profit_percentage DECIMAL(5, 2),
    
    -- Performance tracking
    total_trades INTEGER DEFAULT 0,
    winning_trades INTEGER DEFAULT 0,
    losing_trades INTEGER DEFAULT 0,
    total_profit DECIMAL(10, 2) DEFAULT 0.00,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    last_run_at TIMESTAMPTZ,
    error_message TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bot performance metrics (time series data)
CREATE TABLE IF NOT EXISTS public.bot_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bot_id UUID NOT NULL REFERENCES public.bots(id) ON DELETE CASCADE,
    
    -- Metrics snapshot
    metric_date DATE NOT NULL,
    trades_count INTEGER DEFAULT 0,
    win_rate DECIMAL(5, 2),
    profit_loss DECIMAL(10, 2),
    sharpe_ratio DECIMAL(5, 2),
    max_drawdown DECIMAL(5, 2),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(bot_id, metric_date)
);

-- ============================================================
-- 4. SIGNALS
-- ============================================================

-- Trading signals
CREATE TABLE IF NOT EXISTS public.signals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Signal details
    direction TEXT NOT NULL CHECK (direction IN ('buy', 'sell')),
    source TEXT, -- indicator name, bot name, manual, etc.
    symbol TEXT NOT NULL, -- R_10, R_25, etc.
    confidence_score DECIMAL(3, 2), -- 0.00 to 1.00
    
    -- Signal metadata
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'executed', 'failed', 'expired')),
    metadata JSONB, -- Additional signal data
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    executed_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ
);

-- User signal subscriptions (which signals they want to receive)
CREATE TABLE IF NOT EXISTS public.user_signal_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    signal_source TEXT NOT NULL,
    is_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, signal_source)
);

-- ============================================================
-- 5. TRADES
-- ============================================================

-- Active and historical trades
CREATE TABLE IF NOT EXISTS public.trades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    bot_id UUID REFERENCES public.bots(id) ON DELETE SET NULL,
    signal_id UUID REFERENCES public.signals(id) ON DELETE SET NULL,
    
    -- Trade details
    direction TEXT NOT NULL CHECK (direction IN ('buy', 'sell')),
    symbol TEXT NOT NULL, -- R_10, R_25, etc.
    contract_type TEXT NOT NULL, -- DIGITDIFF, CALL, PUT, etc.
    
    -- Trade parameters
    stake DECIMAL(10, 2) NOT NULL,
    entry_price DECIMAL(10, 6),
    exit_price DECIMAL(10, 6),
    duration_seconds INTEGER,
    
    -- Risk management
    take_profit DECIMAL(10, 2),
    stop_loss DECIMAL(10, 2),
    
    -- Trade outcome
    outcome TEXT NOT NULL DEFAULT 'open' CHECK (outcome IN ('open', 'win', 'loss')),
    pnl DECIMAL(10, 2) DEFAULT 0.00, -- Profit/Loss
    pnl_percentage DECIMAL(5, 2),
    
    -- Deriv contract reference
    deriv_contract_id TEXT UNIQUE,
    deriv_transaction_id TEXT,
    
    -- Status
    is_manual BOOLEAN DEFAULT FALSE, -- Manual vs automated trade
    notes TEXT,
    
    -- Timestamps
    opened_at TIMESTAMPTZ DEFAULT NOW(),
    closed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trade execution log (detailed audit trail)
CREATE TABLE IF NOT EXISTS public.trade_execution_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trade_id UUID NOT NULL REFERENCES public.trades(id) ON DELETE CASCADE,
    
    -- Execution details
    action TEXT NOT NULL, -- opened, closed, stop_loss_hit, take_profit_hit, etc.
    price DECIMAL(10, 6),
    metadata JSONB,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 6. NOTIFICATIONS
-- ============================================================

-- User notifications
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- Notification content
    type TEXT NOT NULL, -- signal, trade_result, bot_status, system, etc.
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    
    -- Notification data
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    metadata JSONB, -- Additional data (trade_id, bot_id, etc.)
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    
    -- Delivery channels
    sent_via_push BOOLEAN DEFAULT FALSE,
    sent_via_email BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 7. API CONNECTIONS (Deriv OAuth & WebSocket)
-- ============================================================

-- API connection status tracking
CREATE TABLE IF NOT EXISTS public.api_connections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- Connection details
    connection_type TEXT NOT NULL CHECK (connection_type IN ('oauth', 'websocket', 'rest_api')),
    status TEXT NOT NULL DEFAULT 'disconnected' CHECK (status IN ('connected', 'disconnected', 'connecting', 'error')),
    
    -- Connection metadata
    connected_at TIMESTAMPTZ,
    disconnected_at TIMESTAMPTZ,
    error_message TEXT,
    metadata JSONB,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- OAuth state tracking (for PKCE flow)
CREATE TABLE IF NOT EXISTS public.oauth_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- PKCE parameters
    state TEXT NOT NULL UNIQUE,
    code_verifier TEXT NOT NULL,
    code_challenge TEXT NOT NULL,
    
    -- OAuth flow tracking
    redirect_uri TEXT NOT NULL,
    scopes TEXT[] NOT NULL,
    is_signup BOOLEAN DEFAULT FALSE,
    
    -- UTM parameters (for partner attribution)
    utm_source TEXT,
    utm_medium TEXT,
    utm_campaign TEXT,
    tracking_token TEXT,
    
    -- Status
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'expired')),
    authorization_code TEXT,
    error_message TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '10 minutes',
    completed_at TIMESTAMPTZ
);

-- ============================================================
-- 8. ANALYTICS & REPORTING
-- ============================================================

-- Analytics events
CREATE TABLE IF NOT EXISTS public.analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- Event details
    event_name TEXT NOT NULL,
    event_category TEXT, -- user_action, trade, bot, system, etc.
    event_data JSONB,
    
    -- Context
    screen_name TEXT,
    session_id TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================

-- Users
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_deriv_account_id ON public.users(deriv_account_id);
CREATE INDEX IF NOT EXISTS idx_users_is_premium ON public.users(is_premium);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON public.users(created_at);

-- User Activity
CREATE INDEX IF NOT EXISTS idx_user_activity_user_id ON public.user_activity(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_type ON public.user_activity(activity_type);
CREATE INDEX IF NOT EXISTS idx_user_activity_created_at ON public.user_activity(created_at);

-- Subscriptions
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON public.user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON public.user_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_expires_at ON public.user_subscriptions(expires_at);

-- Bots
CREATE INDEX IF NOT EXISTS idx_bots_user_id ON public.bots(user_id);
CREATE INDEX IF NOT EXISTS idx_bots_status ON public.bots(status);
CREATE INDEX IF NOT EXISTS idx_bots_is_active ON public.bots(is_active);

-- Bot Metrics
CREATE INDEX IF NOT EXISTS idx_bot_metrics_bot_id ON public.bot_metrics(bot_id);
CREATE INDEX IF NOT EXISTS idx_bot_metrics_metric_date ON public.bot_metrics(metric_date);

-- Signals
CREATE INDEX IF NOT EXISTS idx_signals_status ON public.signals(status);
CREATE INDEX IF NOT EXISTS idx_signals_symbol ON public.signals(symbol);
CREATE INDEX IF NOT EXISTS idx_signals_created_at ON public.signals(created_at);
CREATE INDEX IF NOT EXISTS idx_signals_expires_at ON public.signals(expires_at);

-- Trades
CREATE INDEX IF NOT EXISTS idx_trades_user_id ON public.trades(user_id);
CREATE INDEX IF NOT EXISTS idx_trades_bot_id ON public.trades(bot_id);
CREATE INDEX IF NOT EXISTS idx_trades_signal_id ON public.trades(signal_id);
CREATE INDEX IF NOT EXISTS idx_trades_outcome ON public.trades(outcome);
CREATE INDEX IF NOT EXISTS idx_trades_opened_at ON public.trades(opened_at);
CREATE INDEX IF NOT EXISTS idx_trades_closed_at ON public.trades(closed_at);
CREATE INDEX IF NOT EXISTS idx_trades_deriv_contract_id ON public.trades(deriv_contract_id);

-- Notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON public.notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at);

-- API Connections
CREATE INDEX IF NOT EXISTS idx_api_connections_user_id ON public.api_connections(user_id);
CREATE INDEX IF NOT EXISTS idx_api_connections_status ON public.api_connections(status);

-- OAuth Sessions
CREATE INDEX IF NOT EXISTS idx_oauth_sessions_state ON public.oauth_sessions(state);
CREATE INDEX IF NOT EXISTS idx_oauth_sessions_user_id ON public.oauth_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_oauth_sessions_status ON public.oauth_sessions(status);
CREATE INDEX IF NOT EXISTS idx_oauth_sessions_expires_at ON public.oauth_sessions(expires_at);

-- Analytics
CREATE INDEX IF NOT EXISTS idx_analytics_events_user_id ON public.analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_event_name ON public.analytics_events(event_name);
CREATE INDEX IF NOT EXISTS idx_analytics_events_created_at ON public.analytics_events(created_at);

-- ============================================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscription_plans_updated_at BEFORE UPDATE ON public.subscription_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_subscriptions_updated_at BEFORE UPDATE ON public.user_subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bots_updated_at BEFORE UPDATE ON public.bots
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_trades_updated_at BEFORE UPDATE ON public.trades
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_api_connections_updated_at BEFORE UPDATE ON public.api_connections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bot_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.signals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_signal_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trade_execution_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.oauth_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

-- Users: can only view/update their own record
CREATE POLICY users_select_own ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY users_update_own ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- User Preferences: can only access their own
CREATE POLICY user_preferences_all_own ON public.user_preferences
    FOR ALL USING (auth.uid() = user_id);

-- User Activity: can only view their own
CREATE POLICY user_activity_select_own ON public.user_activity
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY user_activity_insert_own ON public.user_activity
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Subscription Plans: everyone can view, no one can modify (managed by admin)
CREATE POLICY subscription_plans_select_all ON public.subscription_plans
    FOR SELECT USING (true);

-- User Subscriptions: can only access their own
CREATE POLICY user_subscriptions_all_own ON public.user_subscriptions
    FOR ALL USING (auth.uid() = user_id);

-- Bots: can only access their own
CREATE POLICY bots_all_own ON public.bots
    FOR ALL USING (auth.uid() = user_id);

-- Bot Metrics: can only view their own bots' metrics
CREATE POLICY bot_metrics_select_own ON public.bot_metrics
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.bots
            WHERE bots.id = bot_metrics.bot_id
            AND bots.user_id = auth.uid()
        )
    );

CREATE POLICY bot_metrics_insert_own ON public.bot_metrics
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.bots
            WHERE bots.id = bot_metrics.bot_id
            AND bots.user_id = auth.uid()
        )
    );

-- Signals: everyone can view active signals
CREATE POLICY signals_select_all ON public.signals
    FOR SELECT USING (status IN ('pending', 'executed'));

-- User Signal Subscriptions: can only access their own
CREATE POLICY user_signal_subscriptions_all_own ON public.user_signal_subscriptions
    FOR ALL USING (auth.uid() = user_id);

-- Trades: can only access their own
CREATE POLICY trades_all_own ON public.trades
    FOR ALL USING (auth.uid() = user_id);

-- Trade Execution Log: can only view their own trades' logs
CREATE POLICY trade_execution_log_select_own ON public.trade_execution_log
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.trades
            WHERE trades.id = trade_execution_log.trade_id
            AND trades.user_id = auth.uid()
        )
    );

CREATE POLICY trade_execution_log_insert_own ON public.trade_execution_log
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.trades
            WHERE trades.id = trade_execution_log.trade_id
            AND trades.user_id = auth.uid()
        )
    );

-- Notifications: can only access their own
CREATE POLICY notifications_all_own ON public.notifications
    FOR ALL USING (auth.uid() = user_id);

-- API Connections: can only access their own
CREATE POLICY api_connections_all_own ON public.api_connections
    FOR ALL USING (auth.uid() = user_id);

-- OAuth Sessions: can access their own or orphaned sessions by state
CREATE POLICY oauth_sessions_all_own ON public.oauth_sessions
    FOR ALL USING (
        auth.uid() = user_id OR user_id IS NULL
    );

-- Analytics Events: can only insert their own
CREATE POLICY analytics_events_insert_own ON public.analytics_events
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- SEED DATA (Optional)
-- ============================================================

-- Insert default subscription plans
INSERT INTO public.subscription_plans (name, description, price, billing_period, features) VALUES
    ('Free', 'Basic trading features', 0.00, 'monthly', '["basic_trading", "manual_signals", "1_bot"]'),
    ('Premium', 'Advanced trading features', 29.99, 'monthly', '["advanced_trading", "auto_signals", "5_bots", "priority_support"]'),
    ('Professional', 'Full trading suite', 99.99, 'monthly', '["unlimited_bots", "custom_strategies", "api_access", "dedicated_support"]')
ON CONFLICT (name) DO NOTHING;

-- ============================================================
-- COMMENTS
-- ============================================================

COMMENT ON TABLE public.users IS 'Main users table extending Supabase auth.users';
COMMENT ON TABLE public.user_preferences IS 'User settings and preferences';
COMMENT ON TABLE public.bots IS 'Trading bot configurations and status';
COMMENT ON TABLE public.trades IS 'All trading transactions (active and historical)';
COMMENT ON TABLE public.signals IS 'Trading signals from various sources';
COMMENT ON TABLE public.notifications IS 'User notifications and alerts';
COMMENT ON TABLE public.oauth_sessions IS 'OAuth PKCE flow state tracking';
