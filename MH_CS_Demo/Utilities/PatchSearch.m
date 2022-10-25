function  indc  =  PatchSearch(X, row, col, off, nv, S, I)

[N M]   =   size(I);
f2      =   size(X,2);

rmin    =   max( row-S, 1 );
rmax    =   min( row+S, N );
cmin    =   max( col-S, 1 );
cmax    =   min( col+S, M );
         
idx     =   I(rmin:rmax, cmin:cmax);
idx     =   idx(:);
B       =   X(idx, :);        
v       =   X(off, :);
        
        
dis     =   (B(:,1) - v(1)).^2;
for k = 2:f2
    dis   =  dis + (B(:,k) - v(k)).^2;
end
dis   =  dis./f2;
[val,ind]   =  sort(dis); 
indc        =  idx( ind(1:nv) );
%indc = idx(dis<250);

