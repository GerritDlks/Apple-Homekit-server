// *****************************************************************************
// Some variables, don't worry about these ones
// *****************************************************************************
var cmd = require('node-cmd');
var Accessory = require('../').Accessory;
var Service = require('../').Service;
var Characteristic = require('../').Characteristic;
var uuid = require('../').uuid;

// *****************************************************************************
// This will define the physical pin number on which the LED is connected
// *****************************************************************************
var pinNr = 16;

// *****************************************************************************
// This will create our onboard LED controller, which is a LightController.
// *****************************************************************************
var LightController = {
  name: "LED 1",                        // Name of accessory
  pincode: "031-99-154",                // Pincode used for initialisation in the app
  username: "FA:3C:ED:5A:1A:1B",        // MAC like address used by HomeKit to differentiate accessories (make it unique)
  manufacturer: "Kevin De Koninck",     // Manufacturer (optional)
  model: "v1.1",                        // Model (optional)
  serialNumber: "A12S345gGB",           // Serial number (optional)

  power: false,                         // Curent power status
  outputLogs: false,                    // Enable or disable output logs

  // SETPOWER function
  //------------------
  setPower: function(status) {
    if(this.outputLogs) console.log("Turning the '%s' %s", this.name, status ? "on" : "off");

    this.power = status;
    cmd.run('sudo python /home/pi/HAP-NodeJS/python/set-GPIO.py ' int(pinNr), int(status));
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
