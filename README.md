# MetaData in ThingSpeak

This example demonstrates the use of ThingSpeak's metadata capability to enrich a channel's fields with additional information. Metadata can be used to provide context to your data that is accessible from all the same places as the data and is easily configurable through your channel dashboard or the ThingSpeak API.

I will be enriching my temperature/humidity sensor channel that has been collecting data in the MathWorks office and I will display the result using MATLAB Visualizations. The channel has two fields: humidity is recorded into field 1 and temperature into field 2.

For an example of metadata's use in a completed project, check out the [Smart Humidity Sensor](https://www.hackster.io/matlab-iot/smart-humidity-sensor-thingspeak-matlab-and-ifttt-1a8495).

## How it's done

In the metadata section of my channel configuration, I have included a JSON object containing two sub-objects, each with three key-value pairs.

```json
{
  "field1": {
    "unit": "% RH",
    "sensor": "DHT11",
    "image": "https://cdn-shop.adafruit.com/970x728/386-00.jpg"
  },
  "field2": {
    "unit": "°F",
    "sensor": "DHT11",
    "image": "https://cdn-shop.adafruit.com/970x728/386-00.jpg"
  }
}
```

Each top-level object refers to a field denoted by the object's name, and each object contains an entry for the field's unit, sensor name, and image.

I display the enriched data using two MATLAB Visualizations on my channel. The visualizations differ only in the field variable assigned at the top of the file.

```matlab
%% Channel Info %%
channelID = 426924;
channelReadKey = ''; % Not needed for public channel
field = 1; % Field to annotate

%% Fetch Data %%
lastValue = thingSpeakRead(channelID, 'ReadKey', channelReadKey)';
channelData = webread(strcat('https://api.thingspeak.com/channels/', ...
                                num2str(channelID), ...
                                '/feeds.json?metadata=true&api_key=', ...
                                channelReadKey));

%% Extract & Prepare Data %%
metadata = jsondecode(channelData.channel.metadata);
fieldData = metadata.('field' + string(field));
% Read the sensor image from the URL provided in the metadata
img = websave('field-img.jpg', fieldData.image);

sensorText = fieldData.sensor;
readingText = string(lastValue(field)) + fieldData.unit;

%% Display Data %%
% Create an empty figure
figure('Color', 'white', 'Menu', 'none');
axis off
% Place the sensor name and data
text(0.1, 0.8, sensorText, 'FontSize', 40, 'VerticalAlignment', 'Middle');
text(0.1, 0.5, readingText, 'FontSize', 40, 'VerticalAlignment', 'Middle');

% Create new axes to assist in placing the image
% Positioning is [bottomLeftX bottomLeftY width height]
axes('pos', [.1 .1 .5 .3]);
axis off
% Place the image
imshow(img);
```

After variable setup, the visualization makes two different calls to the ThingSpeak API—one using the `thingSpeakRead` function and the other using the `webread` function. Since the `thingSpeakRead` function does not allow access to the metadata field of the channel, the `webread` function is used with the `metadata=true` flag in the request URL.

Using the `jsonparse` MATLAB function, the channel's metadata is decoded into MATLAB structs with the same content. Once the metadata has been extracted, the image can be fetched from the provided URL, concluding the data collection & preparation phase.

The enriched data is drawn onscreen using an empty MATLAB figure. That figure is then annotated with the sensor name and reading + unit. Another set of axes are created to position the image, and the image is drawn.