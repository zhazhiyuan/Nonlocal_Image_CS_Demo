function [ SigmaX, svp ] = GST_Algo( SigmaY, C, p )

 
p1    =   p;   
Temp  =   SigmaY;
s     =   SigmaY;
s1    =   zeros(size(s));

for i=1:3
   W_Vec    =   C;
   [s1, svp]=   solve_GST(s, W_Vec, p1); %GST
   Temp     =   s1;
end
SigmaX = s1;

end

