-- ====================================
-- creating db and schema
-- ====================================

DROP DATABASE IF EXISTS DWH_project WITH (FORCE); -- to drop the current db, we need to move to other db and run this cmd

Create database DWH_project;

-- to select db, open new query tool under new db or select the db under the opened querytool

SELECT current_database(); -- to check which db is using

DO $$
BEGIN

	create Schema bronze;
	RAISE NOTICE 'created Bronze';

	create Schema silver;
	RAISE NOTICE 'created silver';

	create Schema gold;
    RAISE NOTICE 'created gold';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error: %', SQLERRM;
        RAISE NOTICE 'Error code: %', SQLSTATE;
	
END $$;

