/**
 * cordova is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright (c) Matt Kane 2010
 * Copyright (c) 2011, IBM Corporation
 */

var exec = require("cordova/exec");

/**
 * Constructor.
 *
 * @returns {Permissions}
 */
var PermissionsOutSystems = function Permissions() {};

PermissionsOutSystems.prototype.checkPermission = function (successCallBack, failureCallBack, permission) {
    cordova.plugins.permissions.checkPermission(permission, successCallBack, failureCallBack);
};

PermissionsOutSystems.prototype.checkBatteryOptimization = function (successCallBack, failureCallBack) {
    exec(successCallBack, failureCallBack, "Permissions", "checkBatteryOptimization");
};

module.exports = new PermissionsOutSystems();
