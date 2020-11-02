//데이터 집계 (aggregation)
//해당 DB가 없으면 생성을 해주고, DB가 있으면 해당 DB를 사용하겠다.
use employee_db
//컬렉션 목록 확인하기
show collections
//orders 라는 컬렉션 생성하기
db.createCollection("orders")
//insertMany()
db.orders.insertMany([
{
      cust_id: "abc123",
      ord_date: ISODate("2012-01-02T17:04:11.102Z"),
      status: 'A',
      price: 100,
      items: [ { sku: "xxx", qty: 25, price: 1 },
               { sku: "yyy", qty: 25, price: 1 } ]
    },
    {
      cust_id: "abc123",
      ord_date: ISODate("2012-01-02T17:04:11.102Z"),
      status: 'A',
      price: 500,
      items: [ { sku: "xxx", qty: 25, price: 1 },
               { sku: "yyy", qty: 25, price: 1 } ]
    },
    {
      cust_id: "abc123",
      ord_date: ISODate("2012-01-02T17:04:11.102Z"),
      status: 'B',
      price: 130,
      items: [ { sku: "jkl", qty: 35, price: 2 },
               { sku: "abv", qty: 35, price: 1 } ]
    },
    {
      cust_id: "abc123",
      ord_date: ISODate("2012-01-02T17:04:11.102Z"),
      status: 'A',
      price: 130,
      items: [ { sku: "xxx", qty: 15, price: 1 },
               { sku: "yyy", qty: 15, price: 1 } ]
    },
    {
      cust_id: "abc456",
      ord_date: ISODate("2012-02-02T17:04:11.102Z"),
      status: 'C',
      price: 70,
      items: [ { sku: "jkl", qty: 45, price: 2 },
               { sku: "abv", qty: 45, price: 3 } ]
    },
    {
      cust_id: "abc456",
      ord_date: ISODate("2012-02-02T17:04:11.102Z"),
      status: 'A',
      price: 150,
      items: [ { sku: "xxx", qty: 35, price: 4 },
               { sku: "yyy", qty: 35, price: 5 } ]
    },
    {
      cust_id: "abc456",
      ord_date: ISODate("2012-02-02T17:04:11.102Z"),
      status: 'B',
      price: 20,
      items: [ { sku: "jkl", qty: 45, price: 2 },
               { sku: "abv", qty: 45, price: 1 } ]
    },
    {
      cust_id: "abc780",
      ord_date: ISODate("2012-02-02T17:04:11.102Z"),
      status: 'B',
      price: 260,
      items: [ { sku: "jkl", qty: 50, price: 2 },
               { sku: "abv", qty: 35, price: 1 } ]
    }
])

db.orders.find()
//1.select count(*) as cnt from orders
db.orders.aggregate([
    {
        $group:{
            _id:null,
            cnt:{$sum:1}
        }
    }
])
//_id 필드 보이지 않게 하려면?
db.orders.aggregate([
    {
        $group:{
            _id:null,
            cnt:{$sum:1}
        }
    },
    {
        $project:{_id:0}
    }
])

//2.select sum(price) as total from orders
db.orders.aggregate([{
    $group:{
        _id:null,
        total:{$sum:"$price"}
    }
}])

db.orders.aggregate([
    {
        $group:{
            _id:null,
            total:{$sum:"$price"}
        }
    },
    {
        $project:{_id:0}
    }
])
//3.select cust_id,sum(price) as total from orders group by cust_id
db.orders.aggregate([{
    $group:{
        _id:"$cust_id",
        total:{$sum:"$price"}
    }
}])
//_id 필드명을 cust_id 로 변경하기
db.orders.aggregate([
    {
        $group:{
            _id:"$cust_id",
            total:{$sum:"$price"}
        }
    },
    {
        $project:{
            cust_id:"$_id",
            _id:0,
            total:1
        }
    }
])
//3.select cust_id,sum(price) as total from orders group by cust_id order by total asc
db.orders.aggregate([
    {$group:{
        _id:"$cust_id",
        total:{$sum:"$price"}
    }},
    {$sort:{total:-1}}
])
db.orders.find()
//4.select cust_id,status,sum(price) as total from orders group by cust_id,status
db.orders.aggregate([{
    $group:{
        _id:{
            cust_id:"$cust_id",
            status:"$status"
        },
        total:{$sum:"$price"}
    }
}])
//4.1 select cust_id,ord_date,sum(price) as total from orders group by cust_id,ord_date
db.orders.aggregate([
    {
        $group:{
            _id:{
                cust_id:"$cust_id",
                ord_date:{$dateToString:{format:"%Y-%m-%d",date:"$ord_date"}}
            },
            total:{$sum:"$price"}
        }
    }
])
//SELECT cust_id,count(*) as count FROM orders
//GROUP BY cust_id HAVING count(*) > 1
db.orders.aggregate([
    {
        $group:{
            _id:"$cust_id",
            count:{$sum:1}
        }
    }
])

db.orders.aggregate([
    {
        $group:{
            _id:"$cust_id",
            count:{$sum:1}
        }
    },
    {
        $match:{count:{$gt:1}}
    }
])
//select status,sum(price) as total from orders group by status
db.orders.aggregate([
    {
        $group:{
            _id:"$status",
            total:{$sum:"$price"}
        }
    }
])

db.orders.aggregate([
    {
        $group:{
            _id:"$status",
            total:{$sum:"$price"}
        }
    },
    {
        $match:{
            total:{$gt:100}
        }
    },
    {
        $sort:{total:-1}
    },
    {
        $project:{
            status:"$_id",
            _id:0,
            total:1
        }
    }
])

//4.1 select cust_id,ord_date,sum(price) as total from orders group by cust_id,ord_date
//having total > 250
db.orders.aggregate([
    {
        $group:{
            _id:{
                cust_id:"$cust_id",
                ord_date:{$dateToString:{format:"%Y-%m-%d",date:"$ord_date"}}
            },
            total:{$sum:"$price"}
        }
    },
    {
        $match:{
            total:{$gt:250}
        }
    }
])
/*
SELECT cust_id,
       SUM(price) as total
FROM orders
WHERE status = 'A'
GROUP BY cust_id
*/
db.orders.aggregate([
    {$match:{status:'A'}},
    {
        $group:{
            _id:"$cust_id",
            total:{$sum:"$price"}
        }
    }
])

db.orders.find({},{_id:0,items:0}).sort({status:1})
/*
SELECT cust_id,
       SUM(price) as total
FROM orders
WHERE status = 'A'
GROUP BY cust_id
HAVING total > 250
*/
db.orders.aggregate([
    {$match:{status:'A'}},
    {$group:{
        _id:"$cust_id",
        total:{$sum:"$price"}
    }},
    {$match:{total:{$gt:250}}}
])

/*
SELECT cust_id, ord_date
       SUM(price) as total
FROM orders
WHERE status = 'B'
GROUP BY cust_id, ord_date
HAVING total > 250
*/
//ord_date의 날짜와 시간이 모두 출력된다.
db.orders.aggregate([
    {$match:{status:'B'}},
    {$group:{
        _id:{
           cust_id:"$cust_id",
           ord_date:"$ord_date"
        },
        total:{$sum:"$price"}
    }},
    {$match:{total:{$gt:250}}}
])

db.orders.aggregate([
    {$match:{status:'B'}},
    {$group:{
        _id:{
           cust_id:"$cust_id",
           ord_date:{$dateToString:{format:"%Y-%m-%d",date:"$ord_date"}}
        },
        total:{$sum:"$price"}
    }},
    {$match:{total:{$gt:250}}}
])

db.orders.find()

db.createCollection("inventory")
db.inventory.insert({_id:100,item:"abc",sizes:['S','M','L']})
db.inventory.find()
db.inventory.aggregate([
    {
        $unwind:"$sizes"
    }
])
db.orders.find()

db.orders.aggregate([
    {
        $unwind:"$items"
    },
    {
        $group:{
            _id:"$cust_id",
            qty:{$sum:"$items.qty"}
        }
    }
])
