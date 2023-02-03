function out = process_and_draw(I,sen)
out = 1;
G = imread(I);

% Below is an optional plot of different channels and how
% they display the image
%figure;subplot(131);imshow(G1);title('Red');subplot(132);imshow(G2);title('Green');subplot(133);imshow(G3);title('Blue');sgtitle('Channel variations');

% image is partitioned into RGB channels, which will be
% utilized on top of grayscale
G1 = G(:,:,1);
G2 = G(:,:,2);
G3 = G(:,:,3);

% Part 1: Grayscale

G = rgb2gray(G);
G = double(G);
%smoothing
Ge = imgaussfilt(G);
[rows,cols] = size(G);
%edge detection
[G,~]=edge(Ge,'canny',[0.03 0.21]);
%detect circles on the image 
[c11,r11,c12,r12] = process_circles(G,sen);
%clear overalapping circles
[c11,r11,c12,r12] = clear_overlaps(c11,r11,c12,r12,Ge);
%Concatenate knee and hip indicating circle data
c1=[c11;c12];
r1=[r11;r12];
figure;set(gcf, 'Position', get(0, 'Screensize'));
subplot(221);
imshow(I);
viscircles(c1,r1);
title('Grayscale');

% Below is an optional statistic, visualizing the
% intensity difference that is used to select prevailing 
% circles 
%{
if(  ~isempty(r1) )
   for k=1:length(r1)
       pix_cen=Ge(round(c1(k,2)),round(c1(k,1)));
       if(c1(k,1)<=round(cols/2))
          pix_ref=Ge(round(c1(k,2)), max(1,round(c1(k,1))-round(r1(k))-10) );       
       elseif(c1(k,1)>round(cols/2))
          pix_ref=Ge( round(c1(k,2)) , min(cols,round(c1(k,1))+round(r1(k))+10) );         
       end
       text(c1(k,1)-5,c1(k,2),num2str(abs(pix_ref-pix_cen)),'Color','b',...
               'FontSize',8,'FontWeight','bold')
   end
end
%}


% Part 2: Channels
%Red
G1 = double(G1);
%smoothing
G1e = imgaussfilt(G1);
%edge detection
[G1,~]=edge(G1e,'canny',[0.03 0.21]);
%detect circles on the image 
[c21,r21,c22,r22] = process_circles(G1,sen);
%clear overalapping circles
[c21,r21,c22,r22] = clear_overlaps(c21,r21,c22,r22,G1e);
%Concatenate knee and hip indicating circle data
c2=[c21;c22];
r2=[r21;r22];
subplot(222);
imshow(I); 
viscircles(c2,r2);
title('Red Channel');
% Intensity differences plotted
%{
if(  ~isempty(r2) )
   for k=1:length(r2)
       pix_cen=G1e(round(c2(k,2)),round(c2(k,1)));
       if(c2(k,1)<=round(cols/2))
          pix_ref=G1e( round(c2(k,2)) , max(1,round(c2(k,1))-round(r2(k))-10) );       
       elseif(c2(k,1)>round(cols/2))
          pix_ref=G1e( round(c2(k,2)) , min(cols,round(c2(k,1))+round(r2(k))+10) );         
       end
       text(c2(k,1)-5,c2(k,2),num2str(abs(pix_ref-pix_cen)),'Color','b',...
               'FontSize',8,'FontWeight','bold')
   end
end
%}


%Green
G2 = double(G2);
%smoothing
G2e = imgaussfilt(G2);
%edge detection
[G2,~]=edge(G2e,'canny',[0.03 0.21]);
%detect circles on the image 
[c31,r31,c32,r32] = process_circles(G2,sen);
%clear overalapping circles
[c31,r31,c32,r32] = clear_overlaps(c31,r31,c32,r32,G2e);
%Concatenate knee and hip indicating circle data
c3=[c31;c32];
r3=[r31;r32];
subplot(223);
imshow(I); 
viscircles(c3,r3);
title('Green Channel');
% Intensity differences plotted
%{
if(  ~isempty(r3) )
   for k=1:length(r3)
       pix_cen=G2e(round(c3(k,2)),round(c3(k,1)));
       if(c3(k,1)<=round(cols/2))
          pix_ref=G2e(round(c3(k,2)) , max(1,round(c3(k,1))-round(r3(k))-10) );       
       elseif(c3(k,1)>round(cols/2))
          pix_ref=G2e(round(c3(k,2)) , min(cols,round(c3(k,1))+round(r3(k))+10) );         
       end
       text(c3(k,1)-5,c3(k,2),num2str(abs(pix_ref-pix_cen)),'Color','b',...
               'FontSize',8,'FontWeight','bold')
   end
end
%}

%Blue
G3 = double(G3);
%smoothing
G3e = imgaussfilt(G3);
%edge detection
[G3,~]=edge(G3e,'canny',[0.03 0.21]);
%detect circles on the image 
[c41,r41,c42,r42] = process_circles(G3,sen);
%clear overalapping circles
[c41,r41,c42,r42] = clear_overlaps(c41,r41,c42,r42,G3e);
%Concatenate knee and hip indicating circle data
c4=[c41;c42];
r4=[r41;r42];
subplot(224);
imshow(I); 
viscircles(c4,r4);
title('Blue Channel');
sgtitle('Results of 4 different detections');
% Intensity differences plotted
%{
if(  ~isempty(r4) )
   for k=1:length(r4)
       pix_cen=G3e(round(c4(k,2)),round(c4(k,1)));
       if(c4(k,1)<=round(cols/2))
          pix_ref=G3e(round(c4(k,2)) , max(1,round(c4(k,1))-round(r4(k))-10) );       
       elseif(c4(k,1)>round(cols/2))
          pix_ref=G3e(round(c4(k,2)), min(cols,round(c4(k,1))+round(r4(k))+10) );         
       end
       text(c4(k,1)-5,c4(k,2),num2str(abs(pix_ref-pix_cen)),'Color','b',...
               'FontSize',8,'FontWeight','bold')
   end
end
%}

% Using all the generated knee and hip data, ultimate
% decision is given and depth line is drawn
[c1_fin,r1_fin,c2_fin,r2_fin] = channel_polling(c41,r41,c42,r42,c31,r31,c32,r32,c21,r21,c22,r22,c11,r11,c12,r12,I,Ge,G1e,G2e,G3e);


end


