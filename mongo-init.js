

db.createUser(
    {
        user: "admin",
        pwd: "changeme",
        roles: [
            {
                role: "readWrite",
                db: "admin"
            }
        ]
    }
);