clear all;
close all;
clc;
SNR = 0.09;                     %Signal to noise ratio
w=2*pi*5;                       %Frequency
t=0.01:0.01:0.2;                %Time Vector
N=20;                           %Number of Bits
E_s=1;
No = E_s^2/SNR;                 %Noise Power
sig_n = sqrt(No/2);             %Noise standard deviation
data=floor(2*rand(1,N));
data_p=2*data-1;
disp("Polar NRZ-level Encoder");
disp(data_p)
data_dem=reshape(data_p,2,N/2);
disp("Odd and Even dibits")
disp(data_dem)
y_in=[];
y_qd=[];
for i=1:N/2
    y1=data_dem(1,i)*E_s*cos(w*t); % inphase component
    y2=data_dem(2,i)*E_s*sin(w*t) ;% Quadrature component
    y_in=[y_in y1];                % inphase signal vector
    y_qd=[y_qd y2];                %quadrature signal vector
end
tt=0.01:0.01:(0.2*N/2)+0.1;
y_in1=[y_in zeros(1,10)];
y_qd1=[zeros(1,10) y_qd];
y=[];
y=y_in1+y_qd1; % modulated signal vector
figure(1)
subplot(3,1,1);
plot(tt,y_in1), grid on;
title(' waveform for inphase component in OQPSK modulation ');
xlabel('time(sec)');
ylabel(' amplitude(volt)');
subplot(3,1,2);
plot(tt,y_qd1), grid on;
title(' waveform for Quadrature component in OQPSK modulation ');
xlabel('time(sec)');
ylabel(' amplitude(volt)');
subplot(3,1,3);
plot(tt,y), grid on;
title('OQPSK modulated signal (sum of inphase and Quadrature phase signal)');
xlabel('time(sec)');
ylabel(' amplitude(volt)');
n=sig_n*randn(1, length(y));
Rx_sig=[];
Rx_sig=y+n;
figure(2)
plot(tt, y);
hold on;
plot(tt, Rx_sig);
grid on;
title('Transmitted and recieved signals');
legend('Transmitted waveform','Recieved waveform');
sigma1 = E_s*cos(w*t);          %Create basis functions
sigma2 = E_s*sin(w*t);
index = 1:length(t);
for ii=0:N/2-1                    %detect the signal
    X(ii+1) = sum(sigma1.*Rx_sig(ii*length(t) + index));    
    Y(ii+1) = sum(sigma2.*Rx_sig(ii*length(t) + index+10));
end       
currFig = figure;                   %double buffer so window
set(currFig,'DoubleBuffer','on');   %does not flash
title('Detections and decision regions for OQPSK') ; %Plot the detections
hold on;
axlim = 30;
axis([-axlim axlim -axlim axlim]);
plot([0 0],[-axlim axlim],[-axlim axlim],[0 0]);
 rx=[];ry=[];
for ii=1:N/2  %Make decisions on received bits
    if(X(ii) < 0&& Y(ii)<0)
        rx(ii)=-1;ry(ii)=-1;
    elseif (X(ii) < 0&& Y(ii)>0)
        rx(ii)=-1;ry(ii)=1;
    elseif (X(ii) > 0&& Y(ii)<0) 
        rx(ii)=1;ry(ii)=-1;
    else
       rx(ii)=1;ry(ii)=1;
    end
    figure(currFig);%Constellation diagram
    if (and((rx(ii)-data_dem(1,ii)),1)||and((ry(ii)-data_dem(2,ii)),1))
        plot(X(ii),Y(ii),'ro');
    else
        plot(X(ii),Y(ii),'bx');
    end
    hold on
    pause(0.1);
end
xe=rx-data_dem(1,:);
ye=ry-data_dem(2,:);
q=0;
for i=1:N/2
    a=and(xe(i),1);
    b=and(ye(i),1);
    if(a||b)
        q=q+1;
    end
end
disp('Number of Errors');
disp(q);
%Calculate the percentage error
p_error =( 2*q / N )*100; 
disp('Probability of error in %')
disp(p_error);

