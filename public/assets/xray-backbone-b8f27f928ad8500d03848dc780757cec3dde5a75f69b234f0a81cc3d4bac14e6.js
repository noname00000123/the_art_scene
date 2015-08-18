(function() {
  var _ensureElement, _remove;

  if (!(window.Backbone && window.Xray)) {
    return;
  }

  _ensureElement = Backbone.View.prototype._ensureElement;

  Backbone.View.prototype._ensureElement = function() {
    _.defer((function(_this) {
      return function() {
        var info;
        if (info = Xray.constructorInfo(_this.constructor)) {
          return Xray.ViewSpecimen.add(_this.el, info);
        }
      };
    })(this));
    return _ensureElement.apply(this, arguments);
  };

  _remove = Backbone.View.prototype.remove;

  Backbone.View.prototype.remove = function() {
    Xray.ViewSpecimen.remove(this.el);
    return _remove.apply(this, arguments);
  };

}).call(this);
