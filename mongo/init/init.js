// 创建数据库
db = db.getSiblingDB('test');

// 创建用户
db.createUser({
    user: 'admin',
    pwd: 'admin',
    roles: [
        { role: 'readWrite', db: 'test' }
    ]
});

// 创建示例集合
db.createCollection('users');
db.users.createIndex({ "email": 1 }, { unique: true });
db.users.createIndex({ "username": 1 }, { unique: true });

// 插入示例数据
db.users.insertOne({
    username: "admin",
    email: "admin@example.com",
    created_at: new Date(),
    updated_at: new Date()
}); 