const sqlite = require('sqlite-sync');
const appRoot = require('app-root-path');
const testHelper = require(appRoot + '/helpers/testHelper.js');
const top = require(appRoot + "/helpers/top.js");
const auth = require(appRoot + "/api/accessLevels.js");

test('Delete multiple entities with auth check test', () =>
{
    const dbPath = testHelper.getSqliteFileName(__filename);
    top.dbPath = dbPath;

    const funcName = 'sqlChange';
    const tableName = 'company';

    const setup = require(__dirname.replace(funcName, 'graphqlExecute') + '/authCommonSetup.js');
    const authLevels = {
        [auth.accessLevels.DEFAULT_KEY]: auth.accessLevels.USER_READ,
        company: auth.accessLevels.USER_WRITE_OWN | auth.accessLevels.USER_READ
    };

    sqlite.connect(dbPath);
    sqlite.run(setup.createSql());
    sqlite.run(setup.setAuthSql(authLevels));
    sqlite.close();

    testHelper.runSqlite(funcName, __filename);

    sqlite.connect(dbPath);

    const items = sqlite.run(`SELECT * FROM ${tableName} WHERE id IN (1, 3)`);

    expect(items.filter(x => x.id === 1).length).toBe(0);
    expect(items.filter(x => x.id === 3).length).toBe(1);
    
    sqlite.run(setup.dropSql());
    sqlite.close();
});
