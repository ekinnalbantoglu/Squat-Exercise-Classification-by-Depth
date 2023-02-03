function gradArr = hipGrad(cen,rad,G)
    [rows,cols] = size(G);
    gradArr =[];
    if (~isempty(rad) )
        for k=1:length(rad)
            pix_cen=G(round(cen(k,2)),round(cen(k,1)));
            pix_ref=G(round(cen(k,2)) , min(cols,round(cen(k,1))+round(rad(k))+10) );  
            diff = abs(pix_cen - pix_ref);
            gradArr = [gradArr diff];
        end
    end
end