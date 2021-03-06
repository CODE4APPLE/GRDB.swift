import XCTest
#if USING_SQLCIPHER
    import GRDBCipher
#elseif USING_CUSTOMSQLITE
    import GRDBCustomSQLite
#else
    import GRDB
#endif

// A type that adopts DatabaseValueConvertible but does not adopt StatementColumnConvertible
private struct IntConvertible: DatabaseValueConvertible {
    let int: Int
    init(int: Int) {
        self.int = int
    }
    var databaseValue: DatabaseValue {
        return int.databaseValue
    }
    static func fromDatabaseValue(databaseValue: DatabaseValue) -> IntConvertible? {
        guard let int = Int.fromDatabaseValue(databaseValue) else {
            return nil
        }
        return IntConvertible(int: int)
    }
}

class DatabaseValueConvertibleCrashTests: GRDBCrashTestCase {
    
    func testCrashFetchDatabaseValueConvertibleFromStatement() {
        assertCrash("could not convert NULL to IntConvertible.") {
            try dbQueue.inDatabase { db in
                try db.execute("CREATE TABLE ints (int Int)")
                try db.execute("INSERT INTO ints (int) VALUES (1)")
                try db.execute("INSERT INTO ints (int) VALUES (NULL)")
                
                let statement = try db.selectStatement("SELECT int FROM ints ORDER BY int")
                let sequence = IntConvertible.fetch(statement)
                for _ in sequence { }
            }
        }
    }
    
    func testCrashFetchAllDatabaseValueConvertibleFromStatement() {
        assertCrash("could not convert NULL to IntConvertible.") {
            try dbQueue.inDatabase { db in
                try db.execute("CREATE TABLE ints (int Int)")
                try db.execute("INSERT INTO ints (int) VALUES (1)")
                try db.execute("INSERT INTO ints (int) VALUES (NULL)")
                
                let statement = try db.selectStatement("SELECT int FROM ints ORDER BY int")
                _ = IntConvertible.fetchAll(statement)
            }
        }
    }
    
    func testCrashFetchDatabaseValueConvertibleFromDatabase() {
        assertCrash("could not convert NULL to IntConvertible.") {
            try dbQueue.inDatabase { db in
                try db.execute("CREATE TABLE ints (int Int)")
                try db.execute("INSERT INTO ints (int) VALUES (1)")
                try db.execute("INSERT INTO ints (int) VALUES (NULL)")
                
                let sequence = IntConvertible.fetch(db, "SELECT int FROM ints ORDER BY int")
                for _ in sequence { }
            }
        }
    }
    
    func testCrashFetchAllDatabaseValueConvertibleFromDatabase() {
        assertCrash("could not convert NULL to IntConvertible.") {
            try dbQueue.inDatabase { db in
                try db.execute("CREATE TABLE ints (int Int)")
                try db.execute("INSERT INTO ints (int) VALUES (1)")
                try db.execute("INSERT INTO ints (int) VALUES (NULL)")
                
                _ = IntConvertible.fetchAll(db, "SELECT int FROM ints ORDER BY int")
            }
        }
    }
    
    func testCrashDatabaseValueConvertibleInvalidConversionFromNULL() {
        assertCrash("could not convert NULL to IntConvertible.") {
            let row = Row(["int": nil])
            _ = row.value(named: "int") as IntConvertible
        }
    }
    
    func testCrashDatabaseValueConvertibleInvalidConversionFromInvalidType() {
        assertCrash("could not convert \"foo\" to IntConvertible") {
            let row = Row(["int": "foo"])
            _ = row.value(named: "int") as IntConvertible
        }
    }
    
}
