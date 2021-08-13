clear;clc
%LMS filter practice
wavfilename = 'OSR_us_speech_8k.wav';

[sig,fs] = audioread(wavfilename);
sig =sig';

sig = sig(0.3*fs:6.3*fs-1);

sizeFile = size(wavfilename,2);
outFile = strcat(wavfilename(1:sizeFile-4) ,'_cut.wav');
audiowrite(outFile,sig',fs);

t=0:1:length(sig)-1;
t=t/fs; % Convert indices to time instant
%x=randn(1,length(sig)); % Generate random noise
a = -0.2;
b = 0.2;
x= (b-a).*rand(1,length(sig)) + a;

n=filter([ 0 0 0 0 0 0.5 ],1,x); % Generate the corruption noise
tap = 21;
d=sig+n; % Generate signal plus noise
outFile = strcat(wavfilename(1:sizeFile-4) ,'_noiseAdded.wav');
audiowrite(outFile,d',fs);

mu=0.01; % Initialize step size
w=zeros(1,tap); % Initialize adaptive filter coefficients
y=zeros(1,length(t)); % Initialize the adaptive filter output array
e=y; % Initialize the output array (noise-cancelled signal)
% Adaptive filtering using LMS algorithm
for m = tap+1:1:length(t)-1
    sum=0;
    for i = 1:1:tap   % Wiener filter
        sum=sum+w(i)*x(m-i);  % y = w[0]x[n] + ... w[tap-1]x[n-tap+1]
    end
        y(m)=sum;     % output of Wiener filter
        e(m)=d(m)-y(m);  % e: noise-cancelled signal
    for i=1:1:tap     % update each filter coefficient using LMS algorithm
        w(i)=w(i)+2*mu*e(m)*x(m-i);
    end
end

outFile = strcat(wavfilename(1:sizeFile-4) ,'_noiseRemoved.wav');
audiowrite(outFile,e',fs);

len = [16001:18000];
% Calculate the single-sided amplitude spectrum for the original signal
SIG_fft=2*abs(fft(sig(len) ))/length( sig(len) );
SIG_fft(1)=SIG_fft(1)/2;

% Calculate the single-sided amplitude spectrum for the corrupted signal
D=2*abs(fft( d(len) ))/length( d(len) );D(1)=D(1)/2;
f=[0:1:length( sig(len) )/2]*8000/length( sig(len)  );
% Calculate the single-sided amplitude spectrum for the noise-cancelled signal
E=2*abs(fft(e(len)))/length(e(len));E(1)=E(1)/2;
% Plot signals and spectrums
subplot(4,1,1), plot( sig(len) );grid; ylabel('Orig. speech');
subplot(4,1,2),plot( d(len) );grid; ylabel('Corrupt. speech')
subplot(4,1,3),plot( x(len) );grid;ylabel('Ref. noise');
subplot(4,1,4),plot( e(len) );grid; ylabel('Clean speech');
xlabel('Number of samples');
figure
subplot(3,1,1),plot(f,SIG_fft(1:length(f)));grid
ylabel('Orig. spectrum')
subplot(3,1,2),plot(f,D(1:length(f)));grid; ylabel('Corrupt. spectrum')
subplot(3,1,3),plot(f,E(1:length(f)));grid
ylabel('Clean spectrum'); xlabel('Frequency (Hz)');