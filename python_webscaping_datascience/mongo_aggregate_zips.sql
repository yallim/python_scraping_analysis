use zip_db

//db.zips.drop()
db.zips.find({}).limit(20)
//1. SQL: SELECT COUNT(*) AS count FROM zip
db.zips.aggregate([
    {
        $group:{
            _id:null,
            count: {$sum:1}
        }
    }
])
//2. SQL: SELECT SUM(pop) as total_pop AS count FROM zip
db.zips.aggregate([
    {
        $group:{
            _id:null,
            total_pop: {$sum:"$pop"}
        }
    }
])
//3. SQL: SELECT state, SUM(pop) as total_pop FROM zip GROUP BY state
//5. SQL: SELECT state, SUM(pop) as total_pop FROM zip GROUP BY state ORDER BY total_pop
db.zips.aggregate([
    {
        $group:{
            _id:"$state",
            total_pop:{$sum:"$pop"}
        }
    },
    {
        $sort:{total_pop:-1}
    }
])
//4. SQL : select city, sum(pop) as total_pop from zip group by city order by total_pop desc
db.zips.aggregate([
    {$group:{
        _id:"$city",
        total_pop:{$sum:"$pop"}
    }},
    {$sort:{total_pop:-1}},
    {$project:{
        city_name:"$_id",
        _id:0,
        total_pop:1
    }},
    {$limit:10}
])

//select state,count(*) as cnt from zip group by state
db.zips.aggregate([
    {
        $group:{
            _id:"$state",
            cnt:{$sum:1}
        }
    }
])
//6. # SQL: SELECT COUNT(*) as cnt FROM zip WHERE state = 'CA'  1516
db.zips.aggregate([
    {$match:{state:'CA'}},
    {$group:{
        _id:null,
        cnt:{$sum:1}
    }}
])

db.zips.find({state:'CA'},{city:1,pop:1})

db.zips.count({state:'CA'})

//7. select city,sum(pop) as total_pop from zip where state = 'CA' group by city
db.zips.aggregate([
    {$match:{state:'CA'}},
    {$group:{
        _id:"$city",
        total_pop:{$sum:"$pop"}
    }},
    {$sort:{total_pop:-1}}
])
//7.1 select state,sum(pop) as total_pop from zip where state in ('DE', 'MS') group by state
db.zips.aggregate([
  {$match:{state:{$in:['DE','MS']}}},
  {$group:{_id:"$state",total_pop:{$sum:"$pop"}}}
])
//7.2 select state,city,sum(pop) as total from zip
//where state in ('DE', 'MS') group by state,city
db.zips.aggregate([
    {$match:{state:{$in:['DE','MS']}}},
    {$group:{
        _id:{
            state:"$state",
            city:"$city"
        },
        total:{$sum:"$pop"}
    }},
    {$sort:{total:-1}}
])
//12. select state, city, sum(pop) as total_pop from zip group by state,city
db.zips.aggregate([
    {$group:{
        _id:{
            state:"$state",
            city:"$city"
        },
        total:{$sum:"$pop"}
    }},
    {$sort:{total:-1}}
])

//8. SELECT state, SUM(pop) as total_pop FROM zip GROUP BY state HAVING SUM(pop) > 10000000
db.zips.aggregate([
    {$group:{
        _id:"$state",
        total_pop:{$sum:"$pop"}
    }},
    {$match:{total_pop:{$gte:10*1000*1000}}},
    {$sort:{total_pop:-1}}
])
//9.1000만 이상의 state 별 총 인구를 state_pop 필드명으로 출력하고 _id는 출력하지 않기
db.zips.aggregate([
    {$group:{
        _id:"$state",
        state_pop:{$sum:"$pop"}
    }},
    {$match:{state_pop:{$gte:10*1000*1000}}},
    {$sort:{state_pop:-1}},
    {$project:{_id:0}}
])
//_id 필드명을 state로 변경해서 state, state_pop 출력하기
db.zips.aggregate([
    {$group:{
        _id:"$state",
        state_pop:{$sum:"$pop"}
    }},
    {$match:{state_pop:{$gte:10*1000*1000}}},
    {$sort:{state_pop:-1}},
    {$project:{state:"$_id",_id:0,state_pop:1}}
])

//11.1000만 이상의 state 별 총 인구를 state_pop 필드명으로 출력하고,
// _id는 출력하지 않으며, 가장 많은 인구를 가진 3개만 출력하기

//10.1000만 이상의 state만 내림차순 정렬하여 3개만 가져오기
db.zips.aggregate([
    {$group:{
        _id:"$state",
        state_pop:{$sum:"$pop"}
    }},
    {$match:{state_pop:{$gte:10*1000*1000}}},
    {$sort:{state_pop:-1}},
    {$project:{state:"$_id",_id:0,state_pop:1}},
    {$limit:3}
])

//12. select state, city, sum(pop) as total_pop from zip group by state,city
db.zips.aggregate([
    {
        $group:{
            _id:{state:"$state",city:"$city"},
            total_pop:{$sum:"$pop"}
        }
    }
])

//13. select state, city, sum(pop) as total_pop from zip GROUP BY state, city HAVING city = 'POINT BAKER'
db.zips.aggregate([
    {
        $group:{
            _id:{state:"$state",city:"$city"},
            total_pop:{$sum:"$pop"}
        }
    },
    {
        $match:{'_id.city':'POINT BAKER'}
    }
])
//13.1 select state, city, sum(pop) as total_pop from zip
//GROUP BY state, city HAVING state = 'TX'
db.zips.aggregate([
    {
        $group:{
            _id:{state:"$state",city:"$city"},
            total_pop:{$sum:"$pop"}
        }
    },
    {
        $match:{'_id.state':'TX'}
    }
])

//14. SELECT AVG(pop) avg_pop FROM zip
db.zips.aggregate([
    {
        $group:{
            _id:null,
            avg_pop:{$avg:"$pop"}
        }
    }
])
//14.1 SELECT state,city, AVG(pop) avg_pop FROM zip GROUP BY state, city
db.zips.aggregate([
    {
        $group:{
            _id:{
                state:"$state",
                city:"$city"
            },
            avg_pop:{$avg:"$pop"}
        }
    }
])
//15. select state,city, avg(pop) as avg_pop from zip  GROUP BY state, city  having avg_pop > 30000
//주별 도시 인구 평균이 30000 이 넘는 곳의  state 와 city 이름만 출력하고 평균을 출력하지 않기 (3개만 출력하기)
db.zips.aggregate([
    {$group:{
        _id:{state:"$state",city:"$city"},
        avg_pop:{$avg:"$pop"}
    }},
    {$match:{avg_pop:{$gt:30000}}},
    {$project:{avg_pop:0}},
    {$limit:3}
])
//15.1 select state,city,avg(pop) avg_pop from zip where state = 'CA' group by state,city
//having avg_pop >= 30000 order by avg_pop desc
//필드명 _id를 state_city로 변경한 후에 출력하고, avg_pop 필드도 출력하세요
//5개만 출력하기
//$match, $group, $sort, $project, $limit
db.zips.aggregate([
    {$match:{state:'CA'}},
    {$group:{
        _id:{state:"$state",city:"$city"},
        avg_pop:{$avg:"$pop"}
    }},
    {$match:{avg_pop:{$gte:30*1000}}},
    {$sort:{avg_pop:-1}},
    {$project:{state_city:"$_id",_id:0,avg_pop:1}},
    {$limit:5}
])
