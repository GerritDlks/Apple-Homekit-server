// *****************************************************************************
// Some variables, don't worry about these ones
// *****************************************************************************
var Accessory = require('../').Accessory;
var Service = require('../').Service;
var Characteristic = require('../').Characteristic;
var uuid = require('../').uuid;
var mqtt = require('mqtt');
var mqttMSG = false;


// *****************************************************************************
// Some variables - change these
// *****************************************************************************
// Homekit settings
var name = "Sonoff Outlet";                   // Name of accessory
var pincode = "999-99-999",                   // Pincode used for initialisation in the app
var sonoffUsername = "1A:2B:3C:4D:5E:FF";     // MAC like address used by HomeKit to differentiate accessories (must be UNIQUE)

// MQTT settings
var MQTT_NAME = 'kitchenlights'               // MQTT topic (name) that was set on the Sonoff website
                                              // NO spaces
var MQTT_IP = 'localhost'                     // IP address of the MQTT broker
                                              // Change this if your MQTT broker is not your Raspberry Pi
var options = {
  port: 1883,
  host: MQTT_IP,
//  username: 'pi', enable only if you have authentication on your MQTT broker
//  password: 'raspberry', enable only if you have authentication on your MQTT broker
  clientId: MQTT_NAME+'HAP'
};


// *****************************************************************************
// Create a constant UUID
// *****************************************************************************

// Generate a consistent UUID for our light Accessory that will remain
// the same even when restarting our server. We use the `uuid.generate`
// helper function to create a deterministic UUID based on an arbitrary
// "namespace" and the word "sonoff".
var sonoffUUID = uuid.generate('hap-nodejs:accessories:sonoffstand' + name);


// *****************************************************************************
// Create the Sonoff object
// *****************************************************************************
var sonoffObject = {
  powerOn: false,

  // SETPOWER function
  //------------------
  setPowerOn: function(on) {
    sonoffObject.powerOn = on;
    if (on) {
      // MQTT command (like seen on the terminal on the webinterface of the Sonoff device)
      // No need to change this
      client.publish('cmnd/'+MQTT_NAME+'/power', 'on');
    } else {
      client.publish('cmnd/'+MQTT_NAME+'/power', 'off');
    }
  },

  // IDENTIFY function
  //------------------
  identify: function() {
    console.log(name + " Identified!");
  }
}


// *****************************************************************************
// Connect to the client
// *****************************************************************************
var client = mqtt.connect(options);

client.on('message', function(topic, message) {
//  console.log(message.toString());
  message = message.toString();
  mqttMSG = true;
  if (message.includes('ON')){
    sonoffObject.powerOn = true;
  }
  else{
    sonoffObject.powerOn = false;
  }
  sonoff
    .getService(Service.Outlet)
    .setCharacteristic(Characteristic.On,sonoffObject.powerOn);
});

client.on('connect', function () {
  client.subscribe('stat/'+MQTT_NAME+'/POWER')
});


// *****************************************************************************
// Create the accessory and return it to HAP-NodeJS
// *****************************************************************************

var sonoff = exports.accessory = new Accessory(name, uuid.generate(sonoffUUID));

sonoff.username = sonoffUsername;
sonoff.pincode = pincode;

// listen for the "identify" event for this Accessory
sonoff.on('identify', function(paired, callback) {
  sonoffObject.identify();
  callback();
});

sonoff
  .addService(Service.Outlet, name)
  .getCharacteristic(Characteristic.On)
  .on('set', function(value, callback) {
    if(mqttMSG){
      mqttMSG = false;
      callback();
    }
    else {
      sonoffObject.setPowerOn(value);
      callback();
    }
  });

sonoff
  .getService(Service.Outlet)
  .getCharacteristic(Characteristic.On)
  .on('get', function(callback) {
    client.publish('cmnd/'+MQTT_NAME+'/power', '')
    callback(undefined, sonoffObject.powerOn);
  });
