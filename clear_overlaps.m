function [cknee,rknee,chip,rhip] = clear_overlaps(c1,r1,c2,r2,Ge)
    
    cknee = c1;
    rknee = r1;
    chip = c2;
    rhip = r2;
    [~,cols]=size(Ge);
    
    if( length(rknee) <=1 && length(rhip) <=1)
        % do nothing, no overlaps
    end
    if( length(rknee) >1)
        for i=1:length(rknee)
            if(rknee(i) ~= 0)
                pix_ref=Ge(round(cknee(i,2)), max(1,round(cknee(i,1))-round(rknee(i))-10) );       
                pix_cen=Ge(round(cknee(i,2)),round(cknee(i,1)));
                %calculate scalar value 1
                gradient1 = abs(pix_ref-pix_cen);
                for j=1:length(rknee)
                    if(rknee(j) ~= 0)
                        pix_ref=Ge(round(cknee(j,2)), max(1,round(cknee(j,1))-round(rknee(j))-10) );       
                        pix_cen=Ge(round(cknee(j,2)),round(cknee(j,1)));
                        %calculate scalar value 2
                        gradient2 = abs(pix_ref-pix_cen);
                        if(i~=j)
                            dist_bw = norm(cknee(i,:) - cknee(j,:));
                            expected_dist_bw = rknee(i)+rknee(j)-1;
                            if( dist_bw && expected_dist_bw >= dist_bw)
                                if(gradient1 < gradient2)
                                    if(gradient1 > gradient2*0.9)
                                        %delete smaller radius
                                        if(rknee(i) >= rknee(j))
                                            rknee(j) = 0;
                                            cknee(j,:) = 0;
                                        else
                                            rknee(i) = 0;
                                            cknee(i,:) = 0;
                                        end
                                    else
                                        %delete i
                                        rknee(i) = 0;
                                        cknee(i,:) = 0;
                                    end
                                elseif( gradient1 > gradient2)
                                    if(gradient1*0.9 < gradient2)
                                        %delete smaller radius
                                        if(rknee(i) >= rknee(j))
                                            rknee(j) = 0;
                                            cknee(j,:) = 0;
                                        else
                                            rknee(i) = 0;
                                            cknee(i,:) = 0;
                                        end
                                    else
                                        %delete j
                                        rknee(j) = 0;
                                        cknee(j,:) = 0;
                                    end
                                else
                                    %delete smaller radius
                                        if(rknee(i) >= rknee(j))
                                            rknee(j) = 0;
                                            cknee(j,:) = 0;
                                        else
                                            rknee(i) = 0;
                                            cknee(i,:) = 0;
                                        end
                                end
                            end
                        end
                    end
                end
            end
        end
        rknee = rknee(rknee>0);
        del_temp = cknee(:,1)==0; 
        cknee(del_temp,:) = [];
    end
    if(length(rhip) >1)
        for i=1:length(rhip)
            if(rhip(i) ~= 0)
                pix_ref=Ge(round(chip(i,2)), min(cols,round(chip(i,1))+round(rhip(i))+10) );       
                pix_cen=Ge(round(chip(i,2)),round(chip(i,1)));
                gradient1 = abs(pix_ref-pix_cen);
                for j=1:length(rhip)
                    if(rhip(j) ~= 0)
                        pix_ref=Ge(round(chip(j,2)), min(cols,round(chip(j,1))+round(rhip(j))+10) );       
                        pix_cen=Ge(round(chip(j,2)),round(chip(j,1)));
                        gradient2 = abs(pix_ref-pix_cen);
                        if(i~=j)
                            dist_bw = norm(chip(i,:) - chip(j,:));
                            expected_dist_bw = rhip(i)+rhip(j)-1;
                            if( dist_bw && expected_dist_bw >= dist_bw)
                                if(gradient1 < gradient2)
                                    if(gradient1 > gradient2*0.9)
                                        %delete smaller radius
                                        if(rhip(i) >= rhip(j))
                                            rhip(j) = 0;
                                            chip(j,:) = 0;
                                        else
                                            rhip(i) = 0;
                                            chip(i,:) = 0;
                                        end
                                    else
                                        %delete i
                                        rhip(i) = 0;
                                        chip(i,:) = 0;
                                    end
                                elseif( gradient1 > gradient2)
                                    if(gradient1*0.9 < gradient2)
                                        %delete smaller radius
                                        if(rhip(i) >= rhip(j))
                                            rhip(j) = 0;
                                            chip(j,:) = 0;
                                        else
                                            rhip(i) = 0;
                                            chip(i,:) = 0;
                                        end
                                    else
                                        %delete j
                                        rhip(j) = 0;
                                        chip(j,:) = 0;
                                    end
                                else
                                    %delete smaller radius
                                        if(rhip(i) >= rhip(j))
                                            rhip(j) = 0;
                                            chip(j,:) = 0;
                                        else
                                            rhip(i) = 0;
                                            chip(i,:) = 0;
                                        end
                                end
                            end
                        end
                    end
                end
            end
        end
        rhip = rhip(rhip>0);
        del_temp = chip(:,1)==0; 
        chip(del_temp,:) = [];
    end
    % completely deleted zeros from r and corresponding c
end

