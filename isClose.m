function out = isClose(c1,r1,c2,r2)
    out = 0;
    first = [c1,r1];
    second = [c2,r2]; 
    
    dist = norm( first - second );
    
    if (dist < 5)
        out = 1;
    end

end

