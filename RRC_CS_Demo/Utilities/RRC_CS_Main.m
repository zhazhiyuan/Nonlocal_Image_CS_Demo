function [filename,  subrate, mu,  c, jj, PSNR_Inital, PSN_Result,  FSIM_Result,  SSIM_Result, Time_s, dif] = RRC_CS_Main(filename, IterNum, subrate,sigma, mu, c, err)

   

        time0                                   =                                      clock;
        
        original_filename                       =                                      [filename '.tif'];
        
        original_filename                       =                                      imread(original_filename);
        
        [Row, Col,kk]                           =                                      size(original_filename);
                
        if kk==3
            
        Original_Image                          =                                     double(rgb2gray((original_filename)));
        
        else
        Original_Image                          =                                     double((original_filename));
        
        end
       
        patch_size                              =                32;
        
         NN                                     =                patch_size * patch_size;

         MM                                     =                round(subrate * NN);
   
        
        
 randn('seed',0);

PHI = orth(randn(NN, NN))';

PHI = PHI(1:MM, :);

X = im2col(Original_Image, [patch_size patch_size], 'distinct');  

Y = PHI * X;  % CS Measurements
% Initial
 

[x_MH, ~] = MH_BCS_SPL_Decoder(Y, PHI, subrate, Row, Col);


PSNR_Inital  = csnr (x_MH,  Original_Image, 0,0 )

 

% Parameter Setting
par = [];

if ~isfield(par,'PHI')
       par.PHI = PHI; % Sampling Matrix
end

if ~isfield(par,'patch_size')        
       par.patch_size = patch_size;
end

if ~isfield(par,'Row')    
       par.Row = Row;
end

if ~isfield(par,'Col')           
       par.Col = Col;
end
   
if ~isfield(par,'patch')
       par.patch = 7; % patch size
end  
       
if ~isfield(par,'mu')
       par.mu = mu;
end

if ~isfield(par,'c1')
       par.c = c;
end

       
if ~isfield(par,'sigma')
par.sigma = sigma;
end
       
if ~isfield(par,'e')
       par.e = 0.4;
end
        
if ~isfield(par,'Initial')
      par.Initial = double(x_MH);
end

if ~isfield(par,'Org')        
      par.Org = Original_Image;
end
        
if ~isfield(par,'IterNum')
      par.IterNum = IterNum;
end

if ~isfield(par,'loop')
       par.loop = 200;
end
        
if ~isfield(par,'step')
       par.step = 4;
end  
         
if ~isfield(par,'Similar_patch')
       par.Similar_patch = 60; % Similar patch numbers
end
         
if ~isfield(par,'Region')
       par.Region = 20;
end   

[reconstructed_image, PSN_Result, FSIM_Result, SSIM_Result, All_PSNR, jj, dif]= RRC_CS(Y, par, err);
       
        
        
        Time_s =(etime(clock,time0));  
        
        if subrate==0.1

        Final_Name= strcat(filename,'_RRC_CS_',num2str(subrate),'_PSNR_',num2str(PSN_Result), '_FSIM_',num2str(FSIM_Result), '_SSIM_',num2str(SSIM_Result),'.png');
     %   PSNR_Final_Name= strcat(filename,'_RRC_CS_',num2str(subrate),'_Iter_',num2str(j),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result), '_SSIM_',num2str(SSIM_Result),'.txt');

        imwrite(uint8(reconstructed_image),strcat('./_RRC_CS_0.1_Results/',Final_Name));
        
        PSNR_Final_Name1= strcat(filename,'_RRC_CS_',num2str(subrate),'.txt');
        dlmwrite(PSNR_Final_Name1,All_PSNR); 
        
        elseif subrate==0.2
            
        Final_Name= strcat(filename,'_RRC_CS_',num2str(subrate),'_PSNR_',num2str(PSN_Result), '_FSIM_',num2str(FSIM_Result), '_SSIM_',num2str(SSIM_Result),'.png');
        
        imwrite(uint8(reconstructed_image),strcat('./_RRC_CS_0.2_Results/',Final_Name));
        
                PSNR_Final_Name1= strcat(filename,'_RRC_CS_',num2str(subrate),'.txt');
        dlmwrite(PSNR_Final_Name1,All_PSNR); 
        
        
        
        elseif subrate==0.3
            
        Final_Name= strcat(filename,'_RRC_CS_',num2str(subrate),'_PSNR_',num2str(PSN_Result), '_FSIM_',num2str(FSIM_Result), '_SSIM_',num2str(SSIM_Result),'.png');
        
        imwrite(uint8(reconstructed_image),strcat('./_RRC_CS_0.3_Results/',Final_Name));
        
                PSNR_Final_Name1= strcat(filename,'_RRC_CS_',num2str(subrate),'.txt');
        dlmwrite(PSNR_Final_Name1,All_PSNR); 
        
        
        elseif subrate==0.4
            
        Final_Name= strcat(filename,'_RRC_CS_',num2str(subrate),'_PSNR_',num2str(PSN_Result), '_FSIM_',num2str(FSIM_Result), '_SSIM_',num2str(SSIM_Result),'.png');
        
        imwrite(uint8(reconstructed_image),strcat('./_RRC_CS_0.4_Results/',Final_Name));
        
                PSNR_Final_Name1= strcat(filename,'_RRC_CS_',num2str(subrate),'.txt');
        dlmwrite(PSNR_Final_Name1,All_PSNR); 
        
        
        
        else
            
        Final_Name= strcat(filename,'_RRC_CS_',num2str(subrate),'_PSNR_',num2str(PSN_Result), '_FSIM_',num2str(FSIM_Result), '_SSIM_',num2str(SSIM_Result),'.png');
        
        
        imwrite(uint8(reconstructed_image),strcat('./_RRC_CS_0.5_Results/',Final_Name));
        
                PSNR_Final_Name1= strcat(filename,'_RRC_CS_',num2str(subrate),'.txt');
        dlmwrite(PSNR_Final_Name1,All_PSNR); 
                                
       end    
        
        
        
        
end