var rootUser = 'admin';
var rootPassword = 'changemenow';

db.createUser(
    {
        user: "admin",
        pwd: "changemenow",
        roles: [
            {
                role: "root",
                db: "admin"
            }
        ]
    }
);
db.createUser(
    {
        user: "user0",
        pwd: "changemenow",
        roles: [
            {
                role: "readWrite",
                db: "admin"
            }
        ]
    }
);

//db.createUser({user: 'admin', pwd: 'changemenow', roles:['root'], db: "admin"});

db.getSiblingDB("$external").runCommand(
    {
        createUser: "OU=Infrastructure,O=MongoDBClient,L=SB,ST=CA,C=US,CN=mongodb-test-client1",
        roles: [
            { role: "userAdminAnyDatabase", db: "admin" }
        ],
        writeConcern: { w: "majority" , wtimeout: 5000 }
    }
)

db.getSiblingDB("$external").runCommand(
    {
        createUser: "OU=Infrastructure,O=MongoDBClient,L=SB,ST=CA,C=US,CN=mongodb-test-client2",
        roles: [
            { role: "userAdminAnyDatabase", db: "admin" }
        ],
        writeConcern: { w: "majority" , wtimeout: 5000 }
    }
)

db.shutdownServer();



