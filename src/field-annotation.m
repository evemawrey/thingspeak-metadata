%% Channel Info %%
channelID = 426924;
channelReadKey = '';
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
figure('Color', 'white', 'Menu', 'none')
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
