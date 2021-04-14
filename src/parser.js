const p = require('./sql_parser.js');

exports.run = function(input) {
    p.parser.yy.buildSelect = function(def) {
        var result = [];
        if (def.where) {
            result.push({"$match" : def.where});
        };

        if (def.from.lookups) {
            def.from.lookups.forEach(element => {
                result.push({ "$lookup": element });
            });
        }

        if (def.fields) {
            result.push({"$project" : def.fields});
        }

        if (null != def.top) {
            result.push({ "$limit": def.top });
        }

        if (def.sort) {
            result.push({"$sort" : def.sort});
        }

        if (null != def.skip) {
            result.push({ "$skip": def.skip });
        }

        if (null != def.limit) {
            result.push({ "$limit": def.limit });
        }

        return "db." + def.from.main + ".aggregate(" + JSON.stringify(result, null, 2) + ")";
    }

    p.parser.yy.addLookup = function(collection, foreign, coll1, field1, coll2, field2) {
        var lookup = { from: foreign, as: foreign + "_array" };
        if (!collection.lookups) {
            collection.lookups = [];
        }
        
        if (coll1 == collection.main) {
            lookup.localField = field1;
        } else if (coll1 == foreign) {
            lookup.foreignField = field1;
        }

        if (coll2 == collection.main) {
            lookup.localField = field2;
        } else if (coll2 == foreign) {
            lookup.foreignField = field2;
        }

        if (!lookup.localField || !lookup.foreignField) {
            throw "see README for join limitations";
        }

        collection.lookups.push(lookup);
        return collection;
    }

    p.parser.yy.appendField = function(fields, field) {
        var o = fields ? fields : {};
        o[field.name] = field.value;
        return o;
    }

    p.parser.yy.combineConditions = function(left, op, right) {
        var conds = [];
        if (left[op]) {
            left[op].forEach(element => {
                conds.push(element);
            })
        } else {
            conds.push(left);
        }

        if (right[op]) {
            right[op].forEach(element => {
                conds.push(element);
            })
        } else {
            conds.push(right);
        }

        var result = {};
        result[op] = conds;
        return result;
    }

    p.parser.yy.combineConcats = function(left, right) {
        var concats = [];
        if (left["$concat"]) {
            left["$concat"].forEach(element => {
                concats.push(element);
            })
        } else {
            concats.push(left);
        }
        if (right["$concat"]) {
            right["$concat"].forEach(element => {
                concats.push(element);
            })
        } else {
            concats.push(right);
        }
        return { "$concat": concats };
    }

    p.parser.yy.notCondition = function(cond) {
        return { "$not": cond };
    }

    p.parser.yy.appendBetweenCondition = function(field, val1, val2) {
        var result = {};
        result[field] = {};
        result[field]["$gte"] = val1;
        result[field]["$lte"] = val2;
        return result;
    }

    p.parser.yy.appendInListCondition = function(field, list) {
        // This is to replace "in" with a list of "$eq"
        // if (list.length == 1) {
        //     return p.parser.yy.appendCondition(field, "$eq", list[0]);
        // } else {
        //     return { "$or": list.map(element => p.parser.yy.appendCondition(field, "$eq", element)) };
        // }

        return { "$in": [ "$" + field, list] };
    }

    p.parser.yy.appendLikeCondition = function(field, like) {
        var result = {};
        result[field] = { "$regex": "^" + like
            .replace("_", ".")
            .replace("%", ".*") + "$" };
        return result;
    }

    p.parser.yy.appendCondition = function(left, op, right) {
        var result = {};
        result[op] = {};
        result[op][left] = right;
        return result;
    }

    p.parser.yy.toPositiveInt = function(number, annotation) {
        const n = Number(number);
        if (!Number.isInteger(n) || n <= 0) {
            throw annotation + " must be positive non-zero integer";
        }
        return n;
    }

    p.parser.yy.appendOrderBySpec = function(field, asc) {
        var result = {};
        result[field] = asc;
        return result;
    }

    return p.parser.parse(input);
}


