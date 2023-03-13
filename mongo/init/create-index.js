db = db.getSiblingDB('testSvr')

db.createCollection("testGrpMsg")
db.exchangeKey.createIndex({ tId: 1, ttId: 1 }, { background: true })