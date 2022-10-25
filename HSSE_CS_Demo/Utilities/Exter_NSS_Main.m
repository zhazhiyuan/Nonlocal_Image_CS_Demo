function [im_out]        =     Exter_NSS_Main  (Out_Put,Opts, nSig)

randn ('seed',0);


[Exte, model]              =           Exter_par_set( nSig );

Exte.nim                   =           double( Out_Put)/255;

im_out                     =           Exter_Denoising( Exte, Opts, model);


end

