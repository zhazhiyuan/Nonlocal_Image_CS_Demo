
function [filename,subrate,alpha, beta, mu, c1, c2, jjj, PSN_Result,FSIM_Result, SSIM_Result,Time_s, Err_or]=HSSE_CS_Test(filename,IterNum,subrate,alpha, beta, mu, c1, c2,err_or)

        
        
        Original_Filename = [filename '.tif'];
        
        
        
        Original = imread(Original_Filename);
        
        
        
        [Row, Col,kkk] = size(Original);
        
        if kkk==3
            
            Original_Image  = double(rgb2gray(Original));
            
        else 
            
            Original_Image  = double(Original);
            
        end
        
        % Constructe Measurement Matrix (Gaussian Random)
        patch_size = 32;
        
        NN = patch_size * patch_size;
        
        MM = round(subrate * NN);
        
        randn('seed',0);
        
        PHI = orth(randn(NN, NN))';
        
        PHI = PHI(1:MM, :);
        
        X = im2col(Original_Image, [patch_size patch_size], 'distinct');
        
        Y = PHI * X;  % CS Measurements
        
        fprintf('。。。。。。。。。。。。。。。\n');
        fprintf(filename);
        fprintf('\n');
        fprintf('。。。。。。。。。。。。。。。\n');
        fprintf('rate = %0.2f\n',subrate);
        fprintf('。。。。。。。。。。。。。。。\n');
        
  
        
        [x_MH, ~] = MH_BCS_SPL_Decoder(Y, PHI, subrate, Row, Col);
        
        Inital_psnr   =  csnr (x_MH, Original_Image, 0,0)
        
     
        
        Opts = [];
        
        
         if ~isfield(Opts,'alpha')
            Opts.alpha = alpha;
         end
         
         if ~isfield(Opts,'beta')
            Opts.beta = beta;
         end      
         
         if ~isfield(Opts,'mu')
            Opts.mu = mu;
         end    
         
         if ~isfield(Opts,'c1')
            Opts.c1 = c1;
         end   
         
         if ~isfield(Opts,'c2')
            Opts.c2 = c2;
         end             
        
        if ~isfield(Opts,'PHI')
             Opts.PHI = PHI;
        end
        
       if ~isfield(Opts,'Row')    
             Opts.Row = Row;
       end
       
       if ~isfield(Opts,'Col')           
        Opts.Col = Col;
       end
       
       if ~isfield(Opts,'patch')
            Opts.patch = 7;
       end         
   
       if ~isfield(Opts,'patch_size')
            Opts.patch_size = patch_size;
       end  
       
       if ~isfield(Opts,'nSig')
            Opts.nSig = sqrt(2);
       end
       
        
        if ~isfield(Opts,'Initial')
            Opts.Initial = double(x_MH);
        end
        
        if ~isfield(Opts,'Org')        
        Opts.Org = Original_Image;
        end
        
        if ~isfield(Opts,'IterNum')
            Opts.IterNum = IterNum;
        end

        if ~isfield(Opts,'loop')
            Opts.loop = 200;
        end
        
        if ~isfield(Opts,'step')
            Opts.step = 4;
        end  
         
         if ~isfield(Opts,'Sim')
             Opts.Sim = 60; % 60 or 40
         end
         
         if ~isfield(Opts,'Region')
              Opts.Region = 20;
         end    

         
    %    fprintf('Initial PSNR = %0.2f\n',csnr(par.Org,par.Initial,0,1));

        time0   = clock;
        
        [reconstructed_image, PSN_Result,FSIM_Result,SSIM_Result, jjj, Err_or]= HSSE_CS_Main(Y, Opts,err_or);

        
          Time_s =(etime(clock,time0));  
        
        if subrate==0.1

        Final_Name= strcat(filename,'_HSSE_CS_ratio_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.1_Results/',Final_Name));
        
 
        elseif subrate==0.2
            
        Final_Name= strcat(filename,'_HSSE_CS_ratio_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.2_Results/',Final_Name));
        

        
        elseif subrate==0.3
            
        Final_Name= strcat(filename,'_HSSE_CS_ratio_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.3_Results/',Final_Name));

        
        elseif subrate==0.4
            
        Final_Name= strcat(filename,'_HSSE_CS_ratio_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.4_Results/',Final_Name));
        

       
        else
            
           Final_Name= strcat(filename,'_HSSE_CS_ratio_',num2str(subrate),'_PSNR_',num2str(PSN_Result),'_FSIM_',num2str(FSIM_Result),'_SSIM_',num2str(SSIM_Result),'.png');
            
        imwrite(uint8(reconstructed_image),strcat('./ratio_0.5_Results/',Final_Name));

            
            
                                
       end    



end

