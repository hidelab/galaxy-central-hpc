define(["utils/add-logging"],function(d){var e={logger:null,_logNamespace:"?",log:function(){if(this.logger){var f=this.logger.log;if(typeof this.logger.log==="object"){f=Function.prototype.bind.call(this.logger.log,this.logger)}return f.apply(this.logger,arguments)}return undefined}};d(e);var b=Backbone.Model.extend({initialize:function(g){this._checkEnabledSessionStorage();if(!g.id){throw new Error("SessionStorageModel requires an id in the initial attributes")}this.id=g.id;var f=(!this.isNew())?(this._read(this)):({});this.clear({silent:true});this.save(_.extend({},this.defaults,f,g),{silent:true});this.on("change",function(){this.save()})},_checkEnabledSessionStorage:function(){try{return sessionStorage.length}catch(f){alert("Please enable cookies in your browser for this Galaxy site");return false}},sync:function(i,g,f){if(!f.silent){g.trigger("request",g,{},f)}var h;switch(i){case"create":h=this._create(g);break;case"read":h=this._read(g);break;case"update":h=this._update(g);break;case"delete":h=this._delete(g);break}if(h!==undefined||h!==null){if(f.success){f.success()}}else{if(f.error){f.error()}}return h},_create:function(f){var g=f.toJSON(),h=sessionStorage.setItem(f.id,JSON.stringify(g));return(h===null)?(h):(g)},_read:function(f){return JSON.parse(sessionStorage.getItem(f.id))},_update:function(f){return f._create(f)},_delete:function(f){return sessionStorage.removeItem(f.id)},isNew:function(){return !sessionStorage.hasOwnProperty(this.id)},_log:function(){return JSON.stringify(this.toJSON(),null,"  ")},toString:function(){return"SessionStorageModel("+this.id+")"}});(function(){b.prototype=_.omit(b.prototype,"url","urlRoot")}());var c={hiddenUntilActivated:function(f,h){h=h||{};this.HUAVOptions={$elementShown:this.$el,showFn:jQuery.prototype.toggle,showSpeed:"fast"};_.extend(this.HUAVOptions,h||{});this.HUAVOptions.hasBeenShown=this.HUAVOptions.$elementShown.is(":visible");this.hidden=this.isHidden();if(f){var g=this;f.on("click",function(i){g.toggle(g.HUAVOptions.showSpeed)})}},isHidden:function(){return(this.HUAVOptions.$elementShown.is(":hidden"))},toggle:function(){if(this.hidden){if(!this.HUAVOptions.hasBeenShown){if(_.isFunction(this.HUAVOptions.onshowFirstTime)){this.HUAVOptions.hasBeenShown=true;this.HUAVOptions.onshowFirstTime.call(this)}}if(_.isFunction(this.HUAVOptions.onshow)){this.HUAVOptions.onshow.call(this);this.trigger("hiddenUntilActivated:shown",this)}this.hidden=false}else{if(_.isFunction(this.HUAVOptions.onhide)){this.HUAVOptions.onhide.call(this);this.trigger("hiddenUntilActivated:hidden",this)}this.hidden=true}return this.HUAVOptions.showFn.apply(this.HUAVOptions.$elementShown,arguments)}};function a(i,h){var f=Array.prototype.slice.call(arguments,0),g=f.pop();f.unshift(g);return _.defaults.apply(_,f)}return{LoggableMixin:e,SessionStorageModel:b,HiddenUntilActivatedViewMixin:c,mixin:a}});