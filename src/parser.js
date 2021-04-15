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

        if (def.fields.aggregate && !def.group) {
            throw "When you have aggregate expressions, there must be GROUP BY"
        }

        if (def.group) {
            const o = Object.assign({ _id: def.group }, def.fields.aggregate);
            result.push({"$group" : o});
        } else {
            if (def.fields.regular["*"]) {
                var af = {};
                var count = 0;
                for (f in def.fields.regular) {
                    if (f != "*") {
                        ++count;
                        af[f] = (def.fields.regular[f] == 1) ? "$" + f : def.fields.regular[f];
                    }
                }
                if (0 != count) {
                    result.push({"$addFields" : af});
                }
            } else {
                result.push({"$project" : def.fields.regular});
            }
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
        var o = fields ? fields : { regular: {} };
        o.regular[field.name] = field.value;
        return o;
    }

    p.parser.yy.appendAgg = function(fields, agg) {
        var o = fields ? fields : { regular: {} };
        if (!o.aggregate) {
            o.aggregate = {};
        }
        o.aggregate[agg.name] = agg.value;
        return o;
    }

    p.parser.yy.appendGroupBy = function(groupBy, expr) {
        var s = groupBy ? groupBy : [];
        s.push(expr.value);
        return s;
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

    function combineLeftRightChainable(op, isText, left, right) {
        var concats = [];
        if (left[op]) {
            left[op].forEach(element => {
                concats.push(element);
            })
        } else {
            concats.push(left);
        }
        if (right[op]) {
            right[op].forEach(element => {
                concats.push(element);
            })
        } else {
            concats.push(right);
        }

        var result = { isText: isText, value: {} }
        result.value[op] = concats;
        return result;
    }

    p.parser.yy.combineLeftRight = function(op, left, right) {
        const isText = left.isText || right.isText;
        if (op == '+') {
            const op2 = (left.isText || right.isText) ? "$concat" : "$add";
            return combineLeftRightChainable(op2, isText, left.value, right.value);
        }
        if (isText) {
            throw "With text literals, only '+' operator is supported"
        }

        if (op == "$multiply") {
            return combineLeftRightChainable(op, false, left.value, right.value);        
        }

        if (op == "$divide" || op == "$subtract" || op == "$pow" || op == "$mod") {
            var result = { value: {} }
            result.value[op] = [ left.value, right.value ];
            return result;
        }

        throw "Unknown operator " + op;
    }

    p.parser.yy.buildUnaryMinuxExpr = function(right) {
        if (right.isNumberLiteral) {
            return { value: -right.value };
        } else {
            return p.parser.yy.combineLeftRight('$subtract', { value: 0 }, right);
        }
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


