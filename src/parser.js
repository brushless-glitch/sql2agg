const p = require('./sql_parser.js');

exports.run = function(input) {
    p.parser.yy.buildSelect = function(fields, filters, collection) {
        var result = [];
        if (filters) {
            result.push({"$match" : filters});
        };

        if (fields) {
            result.push({"$project" : fields});
        }

        return "db." + collection + ".aggregate(" + JSON.stringify(result, null, 2) + ")";
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

    return p.parser.parse(input);
}


