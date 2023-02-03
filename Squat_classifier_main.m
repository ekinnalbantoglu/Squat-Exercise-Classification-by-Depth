close all;
clc;
clear;
% for all 40 images used, apply joint detection and draw
% depth line
for i=1:40
    starter = 's';
    i2n = num2str(i);
    extension = '.png';
    imname = [starter i2n extension];
  
    sensitivity=0.92;
    a = process_and_draw(imname,sensitivity);
   
end
%% Saving figures all at once
% Get a list of all the figures
figs = findall(0, 'Type', 'figure');

% Loop over the figures
for i = 1:length(figs)
    % Get the handle of the current figure
    fig = figs(i);

    % Save the figure to a file
    saveas(fig, sprintf('figure%d.png', i), 'png');
end


