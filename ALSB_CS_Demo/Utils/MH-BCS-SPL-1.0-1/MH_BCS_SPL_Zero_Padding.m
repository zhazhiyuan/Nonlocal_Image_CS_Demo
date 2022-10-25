% function y = MH_BCS_SPL_Zero_Padding(x, a, b, sblk, blk, dim)
%
% zero padding for subblocks, the zero padded subblocks have the same size as
% the blocks in BCS-SPL.
%
% x     : input subblock
% a     : row position of a subblock in a block
% b     : column position of a subblock in a block
% sblk  : subblock size
% blk   : block size
% dim   : number of rows/cols of subblocks in a block (dim = blk/sblk)
%

%
% MH-BCS-SPL: Multihypothesis Block Compressed Sensing -
%    Smooth Projected Landweber
% Copyright (C) 2012  James E. Fowler
% http://www.ece.mstate.edu/~fowler
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
%

%
% Written by C. Chen, April. 2011
% Department of Electical and Computer Engineering,
% Miss State Univ.
%

function y = MH_BCS_SPL_Zero_Padding(x, a, b, sblk, blk, dim)

rows = rem(a,dim);
cols = rem(b,dim);

A = zeros(blk, blk);

if rows == 0
    if cols == 0
        A(end-sblk+1:end,end-sblk+1:end) = x;
    else
        A(end-sblk+1:end,(cols-1)*sblk+1:cols*sblk) = x;
    end
else
    if cols == 0
        A((rows-1)*sblk+1:rows*sblk,end-sblk+1:end) = x;
    else
        A((rows-1)*sblk+1:rows*sblk,(cols-1)*sblk+1:cols*sblk) = x;
    end
end

y = A(:);
