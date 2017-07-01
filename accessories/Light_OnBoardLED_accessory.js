// *****************************************************************************
// Some variables, don't worry about these ones
// *****************************************************************************
var cmd = require('node-cmd');
var Accessory = require('../').Accessory;
var Service = require('../').Service;
var Characteristic = require('../').Characteristic;
var uuid = require('../').uuid;

// *****************************************************************************
// This will create our onboard LED controller, which is a LightController.
// *****************************************************************************
var LightController = {
  name: "Onboard LED",                  // Name of accessory
  pincode: "999-99-999",                // Pincode used for initialisation in the app
  username: "FA:3C:1E:5A:1A:1A",        // MAC like address used by HomeKit to differentiate accessories (must be UNIQUE)
  manufacturer: "Kevin De Koninck",     // Manufacturer (optional)
  model: "v1.0",                        // Model (optional)
  serialNumber: "A12S345KGB",           // Serial number (optional)

  power: false,                         // Curent power status
  outputLogs: false,                    // Enable or disable output logs

  // SETPOWER function
  //------------------
  setPower: function(status) {
    if(this.outputLogs) console.log("Turning the '%s' %s", this.name, status ? "on" : "off");

    this.power = status;
    cmd.run('sudo python ~/HAP-NodeJS/python/onboard-LED.py ' + Number(status));
  },

  // GETPOWER function
  //------------------
  getPower: function() {
    if(this.outputLogs) console.log("'%s' is %s.", this.name, this.power ? "on" : "off");

    return this.power; // Return boolean
  },

  // IDENTIFY function
  //------------------
  identify: function() {
    if(this.outputLogs) console.log("Identify the '%s'", this.name);
  }
}


// *****************************************************************************
// Create a constant UUID
// *****************************************************************************

// Generate a consistent UUID for our light Accessory that will remain
// the same even when restarting our server. We use the `uuid.generate`
// helper function to create a deterministic UUID based on an arbitrary
// "namespace" and the word "light".
var lightUUID = uuid.generate('hap-nodejs:accessories:light' + LightController.name);


// *****************************************************************************
// Create the accessory and return it to HAP-NodeJS
// *****************************************************************************

// This is the Accessory that represents our light
var lightAccessory = exports.accessory = new Accessory(LightController.name, lightUUID);

// Add properties for publishing (in case we're using Core.js and not BridgedCore.js)
lightAccessory.username = LightController.username;
lightAccessory.pincode = LightController.pincode;

lightAccessory
  .getService(Service.AccessoryInformation)
    .setCharacteristic(Characteristic.Manufacturer, LightController.manufacturer)
    .setCharacteristic(Characteristic.Model, LightController.model)
    .setCharacteristic(Characteristic.SerialNumber, LightController.serialNumber);

lightAccessory.on('identify', function(paired, callback) {
  LightController.identify();
  callback();
});

lightAccessory
  .addService(Service.Lightbulb, LightController.name)
  .getCharacteristic(Characteristic.On)
  .on('set', function(value, callback) {
    LightController.setPower(value);
    callback();
  })
  .on('get', function(callback) {
    callback(null, LightController.getPower());
  });
