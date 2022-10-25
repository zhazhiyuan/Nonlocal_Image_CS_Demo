function OutImg = Solver_PSR(InImg,Thr)

params = [];

if ~isfield(params,'x')
    params.x = InImg; 
end

if ~isfield(params,'blocksize')
    params.blocksize = 8; 
end

if ~isfield(params,'dictsize')
    params.dictsize = 256; 
end

if ~isfield(params,'sigma')
    params.sigma = Thr; 
end

if ~isfield(params,'maxval')
    params.maxval = 255; 
end

if ~isfield(params,'trainnum')
    params.trainnum = 40000; 
end

if ~isfield(params,'iternum')
    params.iternum = 20; 
end

if ~isfield(params,'memusage')
    params.memusage = 'high'; 
end

[ImgNew, Dict] = KSVD_Module(params);

OutImg = ImgNew;