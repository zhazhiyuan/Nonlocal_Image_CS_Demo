
function       [nDCnlX,blk_arr,DC,par] = CalNonLocal( im, par)
% record the non-local patch set and the index of each patch in
% of seed patches in image
im = single(im);
X   = zeros(par.ps2, par.maxrc);
k   = 0;
for i = 1:par.ps
    for j = 1:par.ps
        k = k+1;
        blk = im(i:end-par.ps+i,j:end-par.ps+j);
        X(k,:) = blk(:)';
    end
end
% index of each patch in image
Index    =   (1:par.maxrc);
Index    =   reshape(Index,par.maxr,par.maxc);
% record the indexs of patches similar to the seed patch
blk_arr  =  zeros(par.nlsp, par.lenrc );
% Patch Group Means
DC = zeros(par.ps2,par.lenrc);
% non-local patch groups
nDCnlX = zeros(par.ps2,par.lenrc*par.nlsp);
for  i  =  1 :par.lenr
    for  j  =  1 : par.lenc
        row = par.r(i);
        col = par.c(j);
        off = (col-1)*par.maxr + row;
        off1 = (j-1)*par.lenr + i;
        % the range indexes of the window for searching the similar patches
        rmin = max( row - par.Win, 1 );
        rmax = min( row + par.Win, par.maxr );
        cmin = max( col - par.Win, 1 );
        cmax = min( col + par.Win, par.maxc );
        idx     =   Index(rmin:rmax, cmin:cmax);
        idx     =   idx(:);
        neighbor = X(:,idx); % the patches around the seed in X
        seed  = X(:,off);
        dis = sum(bsxfun(@minus,neighbor, seed).^2,1);
        [~,ind] = sort(dis);
        indc = idx( ind( 1:par.nlsp ) );
        blk_arr(:,off1) = indc;
        temp = X( : , indc );
        DC(:,off1) = mean(temp,2);
        nDCnlX(:,(off1-1)*par.nlsp+1:off1*par.nlsp) = bsxfun(@minus,temp,DC(:,off1));
    end
end