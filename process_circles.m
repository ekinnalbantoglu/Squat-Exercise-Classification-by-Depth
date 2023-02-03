function [o11,o12,o21,o22] = process_circles(I,sen)

    % knee circle lower and upper boundaries
    rmin_knee=18; 
    rmax_knee=35;
    
    [row,col] = size(I);
    if( row ~= 300 || col ~= 200 )
        I = imresize(I,[300 200]);  %resize first
    end
    
    %circles are detected which are on the left of the image
    % and between 40-80% of rows.
    [c1, r1] = imfindcircles(I(round(row*0.4):round(row*0.8),1:round(col*0.5)),[rmin_knee rmax_knee],'Sensitivity',sen,'EdgeThreshold',0.15);
   
    % if circle detected, conduct circularity check
    if( ~isempty(r1))
        %restoring correct image locations since a partial
        %image was provided to imfindcircles
        c1(:,2) = c1(:,2) + round(row*0.4);
        circularity1 = zeros(length(r1));
        for i=1:length(r1)
            % form the ROI rectangle
            leftc = round(c1(i,1)-r1(i));
            rightc = round(c1(i,1)+r1(i));
            upr = round(c1(i,2)-r1(i));
            downr = round(c1(i,2)+r1(i));
            if(leftc < 1)
                leftc = 1;
            end
            if(rightc > col)
                rightc = col;
            end
            if(upr < 1)
                upr = 1;
            end
            if(downr > row)
                downr = row;
            end
                        
            stats = regionprops(I( upr:downr , leftc:rightc ), 'MajorAxisLength', 'MinorAxisLength','Circularity', 'Area', 'Perimeter');
           
            circularity1(i) = stats.Circularity;
        end        
        for i=1:length(r1)
            % detections higher placed than 55% of the rows
            % are deleted for further accuracy.
            if( c1(i,2) < row*0.55)
                r1(i) = 0;
                c1(i,:) = 0;
            end
        end
        
        for i=1:length(r1)
            for j=1:length(r1)
                if( (r1(j) ~= 0) && (r1(i) ~= 0) )
                    if( ~isequaln(circularity1(i), NaN) && isequaln(circularity1(j), NaN) )
                       
                        r1(j) = 0;
                        c1(i,:) = 0;
                        % in order not to create indexing
                        % issues in the loops, these values
                        % are assigned 0 and deleted after
                        % the loop
                    end
                    
                end
            end
        end
        r1=r1(r1>0);
        del_temp = c1(:,1)==0; 
        c1(del_temp,:) = [];
    end
    
    % hip detection
    % floowing steps are similar to the knee detection
    
    % hip circle lower and upper boundaries
    rmin_hip=20; 
    rmax_hip=50;
    [c2, r2] = imfindcircles(I(round(row*0.4):round(row*0.8),round(col*0.5):col),[rmin_hip rmax_hip],'Sensitivity',sen,'EdgeThreshold',0.1);
    
    if(  ~isempty(r2) )
        %restoring correct image locations since a partial
        %image was provided to imfindcircles
        c2(:,2) = c2(:,2) + round(row*0.4);
        c2(:,1) = c2(:,1) + round(col*0.5);
        
        circularity2 = zeros(length(r2));
        for i=1:length(r2)
            % form the ROI rectangle
            leftc = round(c2(i,1)-r2(i));
            rightc = round(c2(i,1)+r2(i));
            upr = round(c2(i,2)-r2(i));
            downr = round(c2(i,2)+r2(i));
            if(leftc < 1)
                leftc = 1;
            end
            if(rightc > col)
                rightc = col;
            end
            if(upr < 1)
                upr = 1;
            end
            if(downr > row)
                downr = row;
            end
            stats = regionprops(I( upr:downr , leftc:rightc ), 'MajorAxisLength', 'MinorAxisLength','Circularity', 'Area', 'Perimeter');
            
            circularity2(i) = stats.Circularity;
        end
        for i=1:size(r2)
            % detections higher placed than 55% of the rows
            % are deleted for further accuracy.
            if( c2(i,2) < row*0.55)
                r2(i) = 0;
                c2(i,:) = 0;
            end
        end
        for i=1:length(r2)
            for j=1:length(r2)
                if( (r2(j) ~= 0) && (r2(i) ~= 0) )
                    if( ~isequaln(circularity2(i), NaN) && isequaln(circularity2(j), NaN) )
                       
                        r2(j) = 0;
                        c2(i,:) = 0;
                    end
                    % in order not to create indexing
                    % issues in the loops, these values
                    % are assigned 0 and deleted after
                    % the loop
                end
            end
        end
        r2=r2(r2>0);
        del_temp = c2(:,1)==0; 
        c2(del_temp,:) = [];
    end

    all_circ=[c1;c2];
    all_r=[r1;r2];
    %viscircles(all_circ, all_r);

    o11 = c1;
    o12 = r1;
    o21 = c2;
    o22 = r2;
   
end

