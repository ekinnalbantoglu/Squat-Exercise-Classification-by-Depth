function [c1_fin2,r1_fin2,c2_fin2,r2_fin2] = channel_polling(c41,r41,c42,r42,c31,r31,c32,r32,c21,r21,c22,r22,c11,r11,c12,r12,I,Ge,G1e,G2e,G3e)
    I1 = imread(I);
    [rows,cols,~] = size(I1);
    kneeDet = 0;
    hipDet = 0;
    c1_fin =[];
    c2_fin = [];
    r1_fin=[];
    r2_fin=[];
    % prepare gradient arrays
    g11=kneeGrad(c11,r11,Ge);
    g12=hipGrad(c12,r12,Ge);
    g21=kneeGrad(c21,r21,G1e);
    g22=hipGrad(c22,r22,G1e);
    g31=kneeGrad(c31,r31,G2e);
    g32=hipGrad(c32,r32,G2e);
    g41=kneeGrad(c41,r41,G3e);
    g42=hipGrad(c42,r42,G3e);
    
    figure;imshow(I);hold on;
    
    %decide knee with r11 c11 r21 c21 r31 c31 r41 c41 
    if( length(r11) > 1 ||  length(r21) > 1 || length(r31) > 1 || length(r41) > 1 )
        %decide
        if(length(r11) > 1) % if has multiple detections
            % pick the highest gradient
            index = 1;
            for a=1:length(r11)
                if(g11(a) > g11(index))
                    index = a;
                end
            end
            r11 = [r11(index)];
            g11 = [g11(index)];
            c11 = [c11(index,:)];
            
        end
        if(length(r21) > 1)
            index = 1;
            for a=1:length(r21)
                if(g21(a) > g21(index))
                    index = a;
                end
            end
            r21 = [r21(index)];
            g21 = [g21(index)];
            c21 = [c21(index,:)];            
        end
        if(length(r31) > 1)
            index = 1;
            for a=1:length(r31)
                if(g31(a) > g31(index))
                    index = a;
                end
            end
            r31 = [r31(index)];
            g31 = [g31(index)];
            c31 = [c31(index,:)];            
        end
        if(length(r41) > 1)
            index = 1;
            for a=1:length(r41)
                if(g41(a) > g41(index))
                    index = a;
                end
            end
            r41 = [r41(index)];
            g41 = [g41(index)];
            c41 = [c41(index,:)];            
        end        
    end
    
    
    
    if ( length(r11) == 0 ||  length(r21) == 0 || length(r31) == 0 || length(r41) == 0 )
        % either 1's or 0's, decide & unify
        tempc=[c11;c21;c31;c41];
        tempr=[r11;r21;r31;r41];
        tempgra =[g11;g21;g31;g41];
        if(length(r11)+length(r21)+length(r31)+length(r41)==3) % if there are 3 1's
            
            if(isClose(tempc(1,1),tempc(1,2),tempc(2,1),tempc(2,2)) && isClose(tempc(2,1),tempc(2,2),tempc(3,1),tempc(3,2)) && isClose(tempc(1,1),tempc(1,2),tempc(3,1),tempc(3,2))  ) % they all agree
                % pick largest
                maximum = max(tempr);
                index = find(tempr==maximum);
                r1_fin = maximum;
                c1_fin = tempc(index,:);
                
            elseif(~isClose(tempc(1,1),tempc(1,2),tempc(2,1),tempc(2,2)) && ~isClose(tempc(2,1),tempc(2,2),tempc(3,1),tempc(3,2)) && ~isClose(tempc(1,1),tempc(1,2),tempc(3,1),tempc(3,2))  ) % all different
                 % pick highest gradient  
                maximum = max(tempgra);
                index = find(tempgra==maximum);
                r1_fin = tempr(index);
                c1_fin = tempc(index,:);
                
            else % 2 of them agrees, 1 outlier (tricky)
                if(isClose(tempc(2,1),tempc(2,2),tempc(3,1),tempc(3,2))) % 2 and 3 agrees
                    if(tempgra(1) > (tempgra(2)+tempgra(3))) % outlier's gradient > agreeing 2's total
                        % pick outlier
                        r1_fin = tempr(1);
                        c1_fin = tempc(1,:);
                    else % pick largest agreeing
                    	
                        if(tempr(2) < tempr(3))
                            r1_fin = tempr(3);
                            c1_fin = tempc(3,:);
                        else
                            r1_fin = tempr(2);
                            c1_fin = tempc(2,:);
                        end
                    end
                elseif(isClose(tempc(1,1),tempc(1,2),tempc(3,1),tempc(3,2))) % 1 and 3 agrees
                    if(tempgra(2) > (tempgra(1)+tempgra(3))) % outlier's gradient > agreeing 2's total
                        % pick outlier
                        r1_fin = tempr(2);
                        c1_fin = tempc(2,:);
                    else % pick largest agreeing
                    	
                        if(tempr(1) < tempr(3))
                            r1_fin = tempr(3);
                            c1_fin = tempc(3,:);
                        else
                            r1_fin = tempr(1);
                            c1_fin = tempc(1,:);
                        end
                    end
                elseif(isClose(tempc(1,1),tempc(1,2),tempc(2,1),tempc(2,2))) % 1 and 2 agrees
                    if(tempgra(3) > (tempgra(1)+tempgra(2))) % outlier's gradient > agreeing 2's total
                        % pick outlier
                        r1_fin = tempr(3);
                        c1_fin = tempc(3,:);
                    else % pick largest agreeing
                    	
                        if(tempr(1) < tempr(2))
                            r1_fin = tempr(2);
                            c1_fin = tempc(2,:);
                        else
                            r1_fin = tempr(1);
                            c1_fin = tempc(1,:);
                        end
                    end                
                else
                    disp('error 2-1');
                end
                
            end
        
        elseif(length(r11)+length(r21)+length(r31)+length(r41)==2) % if there are 2 1's
            if(isClose(tempc(1,1),tempc(1,2),tempc(2,1),tempc(2,2))) % they agree
                % pick largest
                if(tempr(1) < tempr(2))
                    r1_fin = tempr(2);
                    c1_fin = tempc(2,:);
                else
                    r1_fin = tempr(1);
                    c1_fin = tempc(1,:);
                end
            else
                % pick highest gradient
                if(tempgra(1) < tempgra(2))
                    r1_fin = tempr(2);
                    c1_fin = tempc(2,:);
                else
                    r1_fin = tempr(1);
                    c1_fin = tempc(1,:);
                end
            end
            
        elseif(length(r11)+length(r21)+length(r31)+length(r41)==1) % if there is 1 1.
            % pick it
            r1_fin = tempr(1);
            c1_fin = tempc(1,:);
        else % there is kno knee detected
            % do nothing, squat is unaccepted regardless
        end
        
    else
        tempr=[r11;r21;r31;r41];
        tempc=[c11;c21;c31;c41];
        tempgra =[g11;g21;g31;g41];
        % all of them are 1's. Check if unity
        if( isClose(c11(1,1),c11(1,2),c21(1,1),c21(1,2)) && isClose(c31(1,1),c31(1,2),c41(1,1),c41(1,2)) && isClose(c11(1,1),c11(1,2),c31(1,1),c31(1,2))  )% all the locations indicate the same 
            %choose largest
            
            maximum = max(tempr);
            index = find(tempr==maximum);
            r1_fin = maximum;
            c1_fin = tempc(index(1,1),:);
            %done
        
        % 3 of them agrees, 1 outlier, pick 3's choice
        elseif ( isClose(tempc(1,1),tempc(1,2),tempc(2,1),tempc(2,2)) && isClose(tempc(2,1),tempc(2,2),tempc(3,1),tempc(3,2)) && isClose(tempc(1,1),tempc(1,2),tempc(3,1),tempc(3,2))) % 1 2 3
            tempr2=[r11;r21;r31];
            tempc2=[c11;c21;c31];
            maximum = max(tempr2);
            index = find(tempr2==maximum);
            r1_fin = maximum;
            c1_fin = tempc2(index(1,1),:);
        elseif ( isClose(tempc(1,1),tempc(1,2),tempc(2,1),tempc(2,2)) && isClose(tempc(2,1),tempc(2,2),tempc(4,1),tempc(4,2)) && isClose(tempc(1,1),tempc(1,2),tempc(4,1),tempc(4,2))) % 1 2 4
            tempr2=[r11;r21;r41];
            tempc2=[c11;c21;c41];
            maximum = max(tempr2);
            index = find(tempr2==maximum);
            r1_fin = maximum;
            c1_fin = tempc2(index(1,1),:);
        elseif (  isClose(tempc(1,1),tempc(1,2),tempc(4,1),tempc(4,2)) && isClose(tempc(4,1),tempc(4,2),tempc(3,1),tempc(3,2)) && isClose(tempc(1,1),tempc(1,2),tempc(3,1),tempc(3,2))) % 1 3 4
            tempr2=[r11;r31;r41];
            tempc2=[c11;c31;c41];
            maximum = max(tempr2);
            index = find(tempr2==maximum);
            r1_fin = maximum;
            c1_fin = tempc2(index(1,1),:);
        elseif (  isClose(tempc(4,1),tempc(4,2),tempc(2,1),tempc(2,2)) && isClose(tempc(2,1),tempc(2,2),tempc(3,1),tempc(3,2)) && isClose(tempc(4,1),tempc(4,2),tempc(3,1),tempc(3,2))) % 2 3 4
            tempr2=[r21;r31;r41];
            tempc2=[c21;c31;c41];
            maximum = max(tempr2);
            index = find(tempr2==maximum);
            r1_fin = maximum;
            c1_fin = tempc2(index(1,1),:);
            
        else % situation is 2-2 or 1-1-2 or 1-1-1-1, pick the highest gradient
            maximum = max(tempgra);
            index = find(tempgra==maximum);
            r1_fin = tempr(index(1,1));
            c1_fin = tempc(index(1,1),:);
        end
    end
    %draw lines
    if ( length(r1_fin) ~= 0)
        kneeDet = 1;
       % plot([1 cols],[c1_fin(1,2)-0.0001 c1_fin(1,2)+0.0001],'b');
        plot([1 cols],[c1_fin(1,2) c1_fin(1,2)],'--b','LineWidth',2); 
        hold on;
        plot([c1_fin(1,1) c1_fin(1,1)],[c1_fin(1,2) c1_fin(1,2)],'.b','MarkerSize', 15); 
        hold on;
    else
        % do nothing
    end
    
    %=======================================================    
    
    %decide hip with r12 c12 r22 c22 r32 c32 r42 c42   
    % mostly same with the knee decision part
    
    if( length(r12) > 1 ||  length(r22) > 1 || length(r32) > 1 || length(r42) > 1 )
        %decide
        if(length(r12) > 1) % if has multiple detections
            % pick the highest gradient
            index = 1;
            for a=1:length(r12)
                if(g12(a) > g12(index))
                    index = a;
                end
            end
            r12 = [r12(index)];
            g12 = [g12(index)];
            c12 = [c12(index,:)];
            
        end
        if(length(r22) > 1)
            index = 1;
            for a=1:length(r22)
                if(g22(a) > g22(index))
                    index = a;
                end
            end
            r22 = [r22(index)];
            g22 = [g22(index)];
            c22 = [c22(index,:)];            
        end
        if(length(r32) > 1)
            index = 1;
            for a=1:length(r32)
                if(g32(a) > g32(index))
                    index = a;
                end
            end
            r32 = [r32(index)];
            g32 = [g32(index)];
            c32 = [c32(index,:)];            
        end
        if(length(r42) > 1)
            index = 1;
            for a=1:length(r42)
                if(g42(a) > g42(index))
                    index = a;
                end
            end
            r42 = [r42(index)];
            g42 = [g42(index)];
            c42 = [c42(index,:)];            
        end        
    end
    
    
    
    if ( length(r12) == 0 ||  length(r22) == 0 || length(r32) == 0 || length(r42) == 0 )
        % either 1's or 0's, decide & unify
        tempc=[c12;c22;c32;c42];
        tempr=[r12;r22;r32;r42];
        tempgra =[g12;g22;g32;g42];
        if(length(r12)+length(r22)+length(r32)+length(r42)==3) % if there are 3 1's
            
            if(isClose(tempc(1,1),tempc(1,2),tempc(2,1),tempc(2,2)) && isClose(tempc(2,1),tempc(2,2),tempc(3,1),tempc(3,2)) && isClose(tempc(1,1),tempc(1,2),tempc(3,1),tempc(3,2))  ) % they all agree
                % pick largest
                maximum = max(tempr);
                index = find(tempr==maximum);
                r2_fin = maximum;
                c2_fin = tempc(index(1,1),:);
                
            elseif(~isClose(tempc(1,1),tempc(1,2),tempc(2,1),tempc(2,2)) && ~isClose(tempc(2,1),tempc(2,2),tempc(3,1),tempc(3,2)) && ~isClose(tempc(1,1),tempc(1,2),tempc(3,1),tempc(3,2))  ) % all different
                 % pick highest gradient  
                maximum = max(tempgra);
                index = find(tempgra==maximum);
                r2_fin = tempr(index(1,1));
                c2_fin = tempc(index(1,1),:);
                
            else % 2 of them agrees, 1 outlier (tricky)
                if(isClose(tempc(2,1),tempc(2,2),tempc(3,1),tempc(3,2))) % 2 and 3 agrees
                    if(tempgra(1) > (tempgra(2)+tempgra(3))) % outlier's gradient > agreeing 2's total
                        % pick outlier
                        r2_fin = tempr(1);
                        c2_fin = tempc(1,:);
                    else % pick largest agreeing
                    	
                        if(tempr(2) < tempr(3))
                            r2_fin = tempr(3);
                            c2_fin = tempc(3,:);
                        else
                            r2_fin = tempr(2);
                            c2_fin = tempc(2,:);
                        end
                    end
                elseif(isClose(tempc(1,1),tempc(1,2),tempc(3,1),tempc(3,2))) % 1 and 3 agrees
                    if(tempgra(2) > (tempgra(1)+tempgra(3))) % outlier's gradient > agreeing 2's total
                        % pick outlier
                        r2_fin = tempr(2);
                        c2_fin = tempc(2,:);
                    else % pick largest agreeing
                    	
                        if(tempr(1) < tempr(3))
                            r2_fin = tempr(3);
                            c2_fin = tempc(3,:);
                        else
                            r2_fin = tempr(1);
                            c2_fin = tempc(1,:);
                        end
                    end
                elseif(isClose(tempc(1,1),tempc(1,2),tempc(2,1),tempc(2,2))) % 1 and 2 agrees
                    if(tempgra(3) > (tempgra(1)+tempgra(2))) % outlier's gradient > agreeing 2's total
                        % pick outlier
                        r2_fin = tempr(3);
                        c2_fin = tempc(3,:);
                    else % pick largest agreeing
                    	
                        if(tempr(1) < tempr(2))
                            r2_fin = tempr(2);
                            c2_fin = tempc(2,:);
                        else
                            r2_fin = tempr(1);
                            c2_fin = tempc(1,:);
                        end
                    end                
                else
                    disp('error 2-1 2');
                end
                
            end
        
        elseif(length(r12)+length(r22)+length(r32)+length(r42)==2) % if there are 2 1's
            if(isClose(tempc(1,1),tempc(1,2),tempc(2,1),tempc(2,2))) % they agree
                % pick largest
                if(tempr(1) < tempr(2))
                    r2_fin = tempr(2);
                    c2_fin = tempc(2,:);
                else
                    r2_fin = tempr(1);
                    c2_fin = tempc(1,:);
                end
            else
                % pick highest gradient
                if(tempgra(1) < tempgra(2))
                    r2_fin = tempr(2);
                    c2_fin = tempc(2,:);
                else
                    r2_fin = tempr(1);
                    c2_fin = tempc(1,:);
                end
            end
            
        elseif(length(r12)+length(r22)+length(r32)+length(r42)==1) % if there is 1 1.
            % pick it
            r2_fin = tempr(1);
            c2_fin = tempc(1,:);
        else % there is kno knee detected
            % do nothing, squat is unaccepted regardless
        end
        
    else
        tempr=[r12;r22;r32;r42];
        tempc=[c12;c22;c32;c42];
        tempgra =[g12;g22;g32;g42];
        % all of them are 1's. Check if unity
        if( isClose(c12(1,1),c12(1,2),c22(1,1),c22(1,2)) && isClose(c32(1,1),c32(1,2),c42(1,1),c42(1,2)) && isClose(c12(1,1),c12(1,2),c32(1,1),c32(1,2))  )% all the locations indicate the same 
            %choose largest
            
            maximum = max(tempr);
            index = find(tempr==maximum);
            r2_fin = maximum;
            c2_fin = tempc(index(1,1),:);
            %done
        
        % 3 of them agrees, 1 outlier, pick 3's choice
        elseif ( isClose(tempc(1,1),tempc(1,2),tempc(2,1),tempc(2,2)) && isClose(tempc(2,1),tempc(2,2),tempc(3,1),tempc(3,2)) && isClose(tempc(1,1),tempc(1,2),tempc(3,1),tempc(3,2))) % 1 2 3
            tempr2=[r12;r22;r32];
            tempc2=[c12;c22;c32];
            maximum = max(tempr2);
            index = find(tempr2==maximum);
            r2_fin = maximum;
            c2_fin = tempc2(index(1,1),:);
        elseif ( isClose(tempc(1,1),tempc(1,2),tempc(2,1),tempc(2,2)) && isClose(tempc(2,1),tempc(2,2),tempc(4,1),tempc(4,2)) && isClose(tempc(1,1),tempc(1,2),tempc(4,1),tempc(4,2))) % 1 2 4
            tempr2=[r12;r22;r42];
            tempc2=[c12;c22;c42];
            maximum = max(tempr2);
            index = find(tempr2==maximum);
            r2_fin = maximum;
            c2_fin = tempc2(index(1,1),:);
        elseif (  isClose(tempc(1,1),tempc(1,2),tempc(4,1),tempc(4,2)) && isClose(tempc(4,1),tempc(4,2),tempc(3,1),tempc(3,2)) && isClose(tempc(1,1),tempc(1,2),tempc(3,1),tempc(3,2))) % 1 3 4
            tempr2=[r12;r32;r42];
            tempc2=[c12;c32;c42];
            maximum = max(tempr2);
            index = find(tempr2==maximum);
            r2_fin = maximum;
            c2_fin = tempc2(index(1,1),:);
        elseif (  isClose(tempc(4,1),tempc(4,2),tempc(2,1),tempc(2,2)) && isClose(tempc(2,1),tempc(2,2),tempc(3,1),tempc(3,2)) && isClose(tempc(4,1),tempc(4,2),tempc(3,1),tempc(3,2))) % 2 3 4
            tempr2=[r22;r32;r42];
            tempc2=[c22;c32;c42];
            maximum = max(tempr2);
            index = find(tempr2==maximum);
            r2_fin = maximum;
            c2_fin = tempc2(index(1,1),:);
            
        else % situation is 2-2 or 1-1-2 or 1-1-1-1, pick the highest gradient
            maximum = max(tempgra);
            index = find(tempgra==maximum);
            r2_fin = tempr(index(1,1));
            c2_fin = tempc(index(1,1),:);
        end
    end
    %draw lines
    if ( length(r2_fin) ~= 0)
        hipDet = 1;
        
    else
        % do nothing
    end
    
    %=======================================================
    
    % Acceptance
    c_fin = [c1_fin;c2_fin];
    r_fin = [r1_fin;r2_fin];
    if(~isempty(r_fin))
       viscircles(c_fin,r_fin);
    end
    
    if( ~kneeDet && hipDet)
        text = "No knee detected. Squat Failed.";
        plot([1 cols],[c2_fin(1,2) c2_fin(1,2)],'r','LineWidth',2); 
        hold on;
        plot([c2_fin(1,1) c2_fin(1,1)],[c2_fin(1,2) c2_fin(1,2)],'.r','MarkerSize', 15); 
        hold on;
        % if no knee, not accepted
    elseif( kneeDet && ~hipDet )
        text = "No hip detected. Squat Failed.";
    elseif(  ~kneeDet && ~hipDet)
        text = "No knee or hip detected. Squat Failed.";
    elseif( kneeDet && hipDet && c1_fin(1,2) > c2_fin(1,2))
        text = "Depth is unsatisfactory. Squat Failed.";
        plot([1 cols],[c2_fin(1,2) c2_fin(1,2)],'r','LineWidth',2); 
        hold on;
        plot([c2_fin(1,1) c2_fin(1,1)],[c2_fin(1,2) c2_fin(1,2)],'r.','MarkerSize', 15); 
        hold on;
    else
        text = "Depth is satisfactory. Squat Successful.";
        plot([1 cols],[c2_fin(1,2) c2_fin(1,2)],'g','LineWidth',2); 
        hold on;
        plot([c2_fin(1,1) c2_fin(1,1)],[c2_fin(1,2) c2_fin(1,2)],'g.','MarkerSize',15); 
        hold on;
    end
    title(text);
    hold off;
    c1_fin2 =1;r1_fin2=1; c2_fin2=1; r2_fin2=1;
    
end

