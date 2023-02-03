clear;
close all;
clc;
for v=1:10
    if v==1 vname='sq6.mp4'; elseif v==2 vname='sq7_8.mp4'; elseif v==3 vname='sq8_1.mp4'; elseif v==4 vname='v_BodyWeightSquats_g07_c03.avi'; elseif v==5 vname='v_BodyWeightSquats_g10_c05.avi'; elseif v==6 vname='v_BodyWeightSquats_g12_c02.avi'; elseif v==7 vname='v_BodyWeightSquats_g13_c02.avi'; elseif v==8 vname='v_BodyWeightSquats_g15_c01.avi'; elseif v==9 vname='v_BodyWeightSquats_g19_c03.avi'; elseif v==10 vname='sq4_1.mp4'; end
    % Read the frames into vidReader
    vidReader = VideoReader(vname);
    
    opticFlow = opticalFlowHS;
    h = figure;
    movegui(h);
    Panel = uipanel(h,'Position',[0 0 1 1],'Title','Detected Optical Flow');
    hPlot = axes(Panel);
    % counter is counting the frames
    counter = 0;
    % detected motion vector magnitudes are stored in this
    % array
    motion_arr=[];
    % vertical vectors with directions are stored in this
    % array
    vy_arr = [];
    while hasFrame(vidReader)
        total_motion = 0;
        total_vy = 0;
        counter = counter+1;
        %**
        colorframe = readFrame(vidReader);
        grayframe = im2gray(colorframe);  
        flow = estimateFlow(opticFlow,grayframe);
        imshow(colorframe)
        hold on
        plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
        hold off
        pause(0.001);
        %**   
        %row and column are obtained
        [r,c] = size(flow.Magnitude);
        %motion as a magnitude scalar, is obtained
        total_motion = sum(flow.Magnitude(:));
        % vertical vector values are obtained
        total_vy = sum(flow.Vy(:));
        
        % arrays are appended with the newly found values
        motion_arr = [motion_arr total_motion];
        vy_arr = [vy_arr total_vy];
    end

    % lowest 10 magnitudes are extracted, these frames have
    % much higher possibilities of person being at the max
    % squat depth position
    [sortedVals,indexes] = sort(motion_arr);
    smallest10Indexes = indexes(1:10);
  
    reference_arr=zeros(1,length(indexes));
    reference_arr(:) = 3;
    % first 3 frames should not reference any other before
    % since initial frames might be deceiving due to high
    % megnitude of vectors suddenly appearing.
    reference_arr(1:3) = 0;
    for i=1:length(smallest10Indexes)
       
       for j=4:smallest10Indexes(i)
           % if the vertical magnitude of the flow vector is
           % smaller than threshold, than it should not be
           % reference frame. Being lower than the set
           % threshold is an indicator of a idle position in
           % the exercise.
           if( abs(vy_arr(smallest10Indexes(i)+1-j)) < 50)
               reference_arr(smallest10Indexes(i)) = reference_arr(smallest10Indexes(i)) + 1;
           else
               break % reference frame found
           end
       end
       % since reference frame is found, from the current
       % frame down until the referenced frame, if there is
       % such a frame falling in this interval, than it
       % should be a predecessor frame of the current frame
       % which was also detected in the top 10 lowest
       % magnitudes list. That is why it should not be taken
       % as a candidate to avoid duplicates since its 
       % successor frame is already being considered.
       % The values are marked as -1 to indicate
       % preceeding frames
       
       for k=1:reference_arr(smallest10Indexes(i))
           if( ismember( (smallest10Indexes(i) - k),smallest10Indexes(:) ) )
               sortedVals( find(smallest10Indexes==(smallest10Indexes(i) - k)) )= -1;
           end
       end
    end

    vidReader = VideoReader(vname);
    
    opticFlow = opticalFlowHS;
    %frame counter
    counter = 0;
    % frames which satisfy conditions are counted here
    detected = 0;
    % extracted images are appended to this matrix
    images_extract =[];
    while hasFrame(vidReader)
        counter = counter+1;
        colorframe = readFrame(vidReader);
        grayframe = im2gray(colorframe);  
        flow = estimateFlow(opticFlow,grayframe);
        % the magnitude measured at the bottom 60% of the
        % video
        lower_mag=sum(sum(flow.Magnitude(round(r*0.4):r,:)));
        
        % the magnitude measured at the top 40% of the video
        upper_mag =sum(sum(flow.Magnitude(1:round(r*0.4),:)));
        
        % reference frame is determined
        reference_counter = counter - reference_arr(counter);
        
        if( reference_counter <= 1)
            reference_counter = 2;
        end

        if( ismember(counter,smallest10Indexes(:)))
            % to be classified, a frame should be:
            % in the smallest top 10 magnitude list,
            % should not be a preceeding frame,
            % referenced frame should have downward motion
            % magnitude higher than 50,
            % lower 60% of the frame should have higher
            % motion magnitude than the top 40%.
            if( sortedVals(find(smallest10Indexes==counter))~=-1 && vy_arr(reference_counter) > 50 && lower_mag > upper_mag )
                figure;
                imshow(colorframe);
                disp(['frame: ',num2str(counter)]);
                disp(['magnitude value: ',num2str(sortedVals(find(smallest10Indexes==counter)))]);
                disp(['upper magnitude: ',num2str(upper_mag)]);
                disp(['lower magnitude: ',num2str(lower_mag)]);
                detected = detected +1;
                title("Detected lowest depth frame #"+num2str(detected));
                images_extract = [images_extract ; colorframe];
                %pause();
            end 
        end
    end

    [r_ex, c_ex, ~] = size(images_extract);
    figure;
    for i=0:(r_ex/r)-1
       subplot(1,detected,i+1);
       imshow(images_extract(i*r+1:i*r+r,:,:)); 
       title("Detected image #"+num2str(i+1));
    end
    
    % image is saved to the default MATLAB directory with
    % appropriate name and dimensions
    folder = 'C:\Users\ekinn\OneDrive\Belgeler\MATLAB';
    file_list = dir(fullfile(folder, '*.png'));
    num_files = length(file_list);

    vname=['C:\Users\ekinn\OneDrive\Belgeler\MATLAB\','s',num2str(num_files+1),'.png'];
    K = imresize(images_extract(round(0.3*r):round(0.9*r),:,:),[300 200]);  %resize first
    figure;imshow(K);title('Final extracted image');
    if( 0 ~=r_ex/r )
        imwrite(K, vname); 
    end
    
end



