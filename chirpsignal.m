B = 5e6;% bandwidth 70MHz
T = 50e-6;% pulse width 20us
Fs = 10e6;% sampling rate or Nyquist rate
N = T*Fs;
t = -T/2:1/Fs:T/2-1/Fs;
K = B/T;
%%
 St = exp(1i*pi*K*t.^2);% signal
 theta = pi*K*t.^2;% signal radians
 f = K*t;% signal frequency
 
figure
 subplot(2,1,1);plot(real(St));title('chirp signal');
 subplot(2,1,2);plot(f);title('signal frequency Hz');
 
figure;
 plot(abs(fftshift(fft(St))));title('signal spectrum');


s = (stft(St));
plot(abs((s)));
title('short time ft');

hold on;
figure;
        plot_data =abs(s);
        imagesc(t,f,plot_data);
        colorbar;
        xlabel('Time');
        ylabel('Frequency');
        zlabel('Amplitude');
        title('Spectrogram'); 
        
figure;
mf_sig = conj(fliplr(St));
subplot(2,2,1);
plot(real(mf_sig));

subplot(2,2,2)
mf_out = conv(St, mf_sig);
plot(abs(mf_out(N/2+1:N*3/2)));
title('Matched filter');


%time delay
time_delay=zeros(1,length(t));
mf_out1=[time_delay,mf_out];
subplot(2,2,3);
plot(abs(mf_out1),'r');
title('time delay');

% input signal

figure;
%pulse=50;
%n1=size(St,1);
y_m=repmat(St,1,2)
matrix=repmat(y_m,256,9)
yfft=fftshift(fft(y_m));
plot(abs(yfft));
title('input matrix')
imagesc(abs(yfft));
colorbar;
title('image of input matrix')

pc = conj(fliplr(yfft));
subplot(2,2,3)
pc_out = conv2((yfft), (pc));
plot(abs(pc_out(N/2+1:N*3/2)));
title('Matched filter')


H=hamming(256); %Windowing
figure; plot(H)
title('Hamming Window: Time Domain')
xlabel('Samples')
ylabel('Amplitude')

%doppler processing
PRI=0.0002;
PRF=1/PRI;
for j=1:9000
   X(:,j)=matrix(:,j).*H;
    Data(:,j)=fftshift(fft(X(:,j)));
end
figure; mesh(20*log10(abs(Data)))
title('Range/Doppler response')
xlabel('Range Bins')
ylabel('Frequency Bins')
zlabel('Signal power dB')


%velocity
lambda=0.3;
y1=20*log10(abs(y_m(:,700)));
V_min=(-PRF/2)*lambda;
V_max=(PRF/2)*lambda;
Velocity=V_min:(V_max-V_min)/255:V_max;

figure; plot(Velocity,20*log10(abs(Data(:,700))))
title('Doppler response of max. target')
xlabel('Velocity (m/s)')
ylabel('Magnitude');

%Range 
c=3e8;
Pulse_Width=6e-7;
R_min=c*Pulse_Width/2;
R_max=c*PRI/2;
Range=R_min:(R_max-R_min)/8999:R_max;
figure; plot(Range,20*log10(abs(Data(160,:))))
title('Range response of max. target')
xlabel('Range (m)')
ylabel('Magnitude')


%Surface plot
Pt=20*log10(abs(Data))%power

figure; 
imagesc(Range,Velocity,Pt);
colorbar;
title('Range/Doppler Response')
xlabel('Range (m)')
ylabel('Velocity (m/s)')
zlabel('Signal power (dB)')
