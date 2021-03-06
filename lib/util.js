// Generated by CoffeeScript 1.10.0
(function() {
  var clamp, divide, objectValueMax, objectValueTotal;

  clamp = function(number, min, max) {
    return Math.max(Math.min(max, number), min);
  };

  divide = function(numerator, denominator) {
    if (denominator) {
      return numerator / denominator;
    } else {
      return 0;
    }
  };

  objectValueTotal = function(obj) {
    return Object.keys(obj).reduce(function(memo, key) {
      memo += obj[key];
      return memo;
    }, 0);
  };

  objectValueMax = function(obj) {
    return Object.keys(obj).reduce(function(memo, key) {
      var val;
      val = obj[key];
      if (val > memo) {
        memo = val;
      }
      return memo;
    }, 0);
  };

  module.exports = {
    clamp: clamp,
    divide: divide,
    objectValueMax: objectValueMax,
    objectValueTotal: objectValueTotal
  };

}).call(this);
