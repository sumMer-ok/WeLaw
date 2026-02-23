USE enoflaw;

-- Show all tables
SHOW TABLES;

-- Count records in each table
SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'cases', COUNT(*) FROM cases
UNION ALL
SELECT 'annotations', COUNT(*) FROM annotations
UNION ALL
SELECT 'vocabulary', COUNT(*) FROM vocabulary
UNION ALL
SELECT 'decks', COUNT(*) FROM decks
UNION ALL
SELECT 'study_sets', COUNT(*) FROM study_sets
UNION ALL
SELECT 'notes', COUNT(*) FROM notes;

-- Show sample data
SELECT id, title, category, status FROM cases LIMIT 5;
SELECT id, term, chinese_meaning, field FROM vocabulary LIMIT 5;
