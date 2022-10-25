clc
clear
m_1=0; 
m_2=0;    
m_3=0;  
m_4=0;  
m_5=0; 


m_6=0; 
m_7=0;    
m_8=0;  
m_9=0;  
m_10=0; 


m_11=0; 
m_12=0;    
m_13=0;  
m_14=0;  
m_15=0; 
m_16=0;  
m_17=0;  
m_18=0; 

All_data_Results_1 = cell(1,400);
All_data_Results_2 = cell(1,400);
All_data_Results_3 = cell(1,400);
All_data_Results_4 = cell(1,400);
All_data_Results_5 = cell(1,400);


All_data_Results_6 = cell(1,400);
All_data_Results_7 = cell(1,400);
All_data_Results_8 = cell(1,400);
All_data_Results_9 = cell(1,400);
All_data_Results_10 = cell(1,400);


All_data_Results_11 = cell(1,400);
All_data_Results_12 = cell(1,400);
All_data_Results_13 = cell(1,400);
All_data_Results_14 = cell(1,400);
All_data_Results_15 = cell(1,400);

All_data_Results_16 = cell(1,400);
All_data_Results_17 = cell(1,400);
All_data_Results_18 = cell(1,400);

for i = 1:14
    
ImageNum =i;

switch ImageNum
      case 1
                filename = 'airplane';
            case 2
                filename = 'boats';
            case 3
                filename = 'couple';
            case 4
                filename = 'Fence';    
            case 5
                filename = 'fingerprint'; 
                
            case 6
                filename = 'flower';
            case 7
                filename = 'girl';
            case 8
                filename = 'Lake';
            case 9
                filename = 'Leaves';    
            case 10
                filename = 'lena'; 
                
            case 11
                filename = 'lin';
            case 12
                filename = 'man';
            case 13
                filename = 'pentagon';     
                
            case 14
                filename = 'peppers';

end

for j  =   1:5
    


        
    
  
ratio_Num        =     [0.1, 0.2, 0.3, 0.4, 0.5]; % 0.6 represents Inlayed Text Removal




IterNum             =      400;

Subrate             =       ratio_Num(j)



c1                  =      1;

c2                  =      1;    

             

 if  Subrate==0.1
     
     alpha               =      0.09;

beta                =      0.0002;

mu                  =      0.001;
     

 [Ori, Subrate, alpha, beta, mu, c1, c2, jj, PSNR_Final,FSIM_Final,SSIM_Final,Time_s, Err_or]= LR_GSC_CS_Test(filename, IterNum, Subrate, alpha, beta, mu, c1, c2);
 
 m_1= m_1+1;
 
 s=strcat('A',num2str(m_1));
 
 All_data_Results_1{m_1}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s, Err_or};
 
 xlswrite('LR_GSC_CS_0.1_Test_Final_3.xls', All_data_Results_1{m_1},'sheet1',s);
 

 
 
elseif  Subrate==0.2
    
    alpha               =      0.08;

beta                =      0.0003;

mu                  =      0.001;
     

         
[Ori, Subrate, alpha, beta, mu, c1, c2, jj, PSNR_Final,FSIM_Final,SSIM_Final,Time_s, Err_or]= LR_GSC_CS_Test(filename, IterNum, Subrate, alpha, beta, mu, c1, c2);

 m_4= m_4+1;
 
 s=strcat('A',num2str(m_4));
 
 All_data_Results_4{m_4}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s, Err_or};
 
 xlswrite('LR_GSC_CS_0.2_Test_Final_3.xls', All_data_Results_4{m_4},'sheet1',s);


 
 elseif  Subrate==0.3
     
     
     alpha               =      0.08;

beta                =      0.0009;

mu                  =      0.001;
     

[Ori, Subrate, alpha, beta, mu, c1, c2, jj, PSNR_Final,FSIM_Final,SSIM_Final,Time_s, Err_or]= LR_GSC_CS_Test(filename, IterNum, Subrate, alpha, beta, mu, c1, c2);

 m_7= m_7+1;
 
 s=strcat('A',num2str(m_7));
 
 All_data_Results_7{m_7}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s, Err_or};
 
 xlswrite('LR_GSC_CS_0.3_Test_Final_3.xls', All_data_Results_7{m_7},'sheet1',s);
 

 
 
  elseif  Subrate==0.4
      
      
      alpha               =      0.08;

beta                =      0.0009;

mu                  =      0.001;
     

    
[Ori, Subrate, alpha, beta, mu, c1, c2, jj, PSNR_Final,FSIM_Final,SSIM_Final,Time_s, Err_or]= LR_GSC_CS_Test(filename, IterNum, Subrate, alpha, beta, mu, c1, c2);

 m_10=  m_10+1;
 
 s=strcat('A',num2str( m_10));
 
 All_data_Results_10{ m_10}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s, Err_or};
 
 xlswrite('LR_GSC_CS_0.4_Test_Final_3.xls', All_data_Results_10{ m_10},'sheet1',s);
 

 
 
 elseif Subrate==0.5
     
     alpha               =      0.08;

beta                =      0.0009;

mu                  =      0.001;
     
[Ori, Subrate, alpha, beta, mu, c1, c2, jj, PSNR_Final,FSIM_Final,SSIM_Final,Time_s, Err_or]= LR_GSC_CS_Test(filename, IterNum, Subrate, alpha, beta, mu, c1, c2);

 m_13=  m_13+1;
 
 s=strcat('A',num2str( m_13));
 
 All_data_Results_13{ m_13}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s, Err_or};
 
 xlswrite('LR_GSC_CS_0.5_Test_Final_3.xls', All_data_Results_13{ m_13},'sheet1',s);


 
 
 else
     
  
[Ori, Subrate, alpha, beta, mu, c1, c2, jj, PSNR_Final,FSIM_Final,SSIM_Final,Time_s, Err_or]= LR_GSC_CS_Test(filename, IterNum, Subrate, alpha, beta, mu, c1, c2);

 m_16=  m_16+1;
 
 s=strcat('A',num2str( m_16));
 
 All_data_Results_16{ m_16}={Ori, Subrate, PSNR_Final,FSIM_Final,SSIM_Final,Time_s, Err_or};
 
 xlswrite('LR_GSC_CS_text_miss_Test_Final_3.xls', All_data_Results_16{ m_16},'sheet1',s);        
         
 save LR_GSC_CS_text_miss_Test_para  All_data_Results_16 
 

 
 end
 


clearvars -except filename i m_1 All_data_Results_1 m_2 All_data_Results_2 m_3 All_data_Results_3 m_4 All_data_Results_4 m_5 All_data_Results_5 ...
m_6 All_data_Results_6 m_7 All_data_Results_7 m_8 All_data_Results_8 m_9 All_data_Results_9 m_10 All_data_Results_10 m_11 All_data_Results_11 ...
m_12 All_data_Results_12 m_13 All_data_Results_13 m_14 All_data_Results_14 m_15 All_data_Results_15 m_16 All_data_Results_16 ...
m_17 All_data_Results_17 m_18 All_data_Results_18
end
clearvars -except filename  m_1 All_data_Results_1 m_2 All_data_Results_2 m_3 All_data_Results_3 m_4 All_data_Results_4 m_5 All_data_Results_5 ...
m_6 All_data_Results_6 m_7 All_data_Results_7 m_8 All_data_Results_8 m_9 All_data_Results_9 m_10 All_data_Results_10 m_11 All_data_Results_11 ...
m_12 All_data_Results_12 m_13 All_data_Results_13 m_14 All_data_Results_14 m_15 All_data_Results_15 m_16 All_data_Results_16 ...
m_17 All_data_Results_17 m_18 All_data_Results_18
end






         