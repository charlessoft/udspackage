var db = connect('10.211.55.18:27017/admin');
var cfg={
        "_id":"testrs",
        "members":[

        {
        "_id":0,
        "host":"10.211.55.18:27017",
        "priority":100
        }

        ,{
        "_id":1,
        "host":"10.211.55.21:27017",
        "priority":99
        }

        ,{
        "_id":2,
        "host":"10.211.55.22:27017",
        "arbiterOnly":true
        }
]}
printjson(rs.initiate(cfg));
printjson(rs.config());
