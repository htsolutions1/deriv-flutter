-- ============================================================
-- QUICK SCHEMA OVERVIEW - Run this first
-- Copy results to share with development team
-- ============================================================

-- Show all tables with their columns and types
SELECT 
    t.table_name,
    json_agg(
        json_build_object(
            'column', c.column_name,
            'type', c.data_type,
            'nullable', c.is_nullable,
            'default', c.column_default
        ) ORDER BY c.ordinal_position
    ) AS columns
FROM information_schema.tables t
JOIN information_schema.columns c 
    ON t.table_name = c.table_name
WHERE t.table_schema = 'public'
GROUP BY t.table_name
ORDER BY t.table_name;

-- Show all relationships
SELECT 
    tc.table_name || '.' || kcu.column_name AS from_field,
    ' -> ' AS relationship,
    ccu.table_name || '.' || ccu.column_name AS to_field
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name;

-- Show RLS policies summary
SELECT 
    tablename,
    COUNT(*) AS policy_count,
    array_agg(DISTINCT cmd) AS operations
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;
