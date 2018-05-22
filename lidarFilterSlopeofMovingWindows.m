clear all;
clc,

load('x.mat')
load('y.mat')
load('z.mat')

%% belirlenen alani sec (50x50 metre icin 50000x50000 veri noktasi kullandim)
x = x(10001:60000);
y = y(10001:60000);
z = z(10001:60000);

%% Her pencerenin boyuru 1x1 m 1000x1000 data

winsize = 1000;
wininc = winsize;

datawin = ones(winsize,1);
datasize = size(x,1);
Nsignals = size(x,2);

numwin = floor((datasize - winsize)/wininc)+1;

st = 1;
en = winsize;

zemin = zeros(numwin,Nsignals);
%% bu for dongusu veriyi pencere pencere taramayi sagliyor
for indexShift = 1:numwin

indexFilt = 1:1000;
    curwinX = x(st:en,:).*repmat(datawin,1,Nsignals);
    curwinY = y(st:en,:).*repmat(datawin,1,Nsignals);
    curwinZ = z(st:en,:).*repmat(datawin,1,Nsignals);

[Zmin,Indexmin] = min(curwinZ);
distanceXYZFirstPart = zeros(1,length(1:(Indexmin-1)));

slopeZFirstPart = zeros(1,length(1:(Indexmin-1)));
%% veriyi en kucuk z noktasina kadar olan kisim ve en kucuk z noktasindan pencerenin sonuna kadar olan kisim olarak
% ikiye ayirip islemleri o sekilde yaptim

for i = 1:(Indexmin-1)
    
    %% Mesafeye hesabi
   
    distanceXYZFirstPart(i) = sqrt( (curwinX(i)-(curwinX(Indexmin))).^2 +  (curwinY(i)-(curwinY(Indexmin))).^2 +  (z(i)-(curwinZ(Indexmin))).^2);
    
    %% Egim hesabi
   
    slopeZFirstPart(i) = (z(i)-(z(Indexmin))) /...
       sqrt( (curwinX(i)-(curwinX(Indexmin))).^2 +  (curwinY(i)-(curwinY(Indexmin))).^2);
   
end
%% aci hesabi
zenithFirstPart = 180/pi*atan(slopeZFirstPart);


distanceXYZSecondPart = zeros(1,length(Indexmin+1:(length(curwinZ))));

slopeZSecondPart = zeros(1,length(Indexmin+1:(length(curwinZ))));

for i = Indexmin+1:(length(curwinZ))
   distanceXYZSecondPart(i) = sqrt( (curwinX(i)-(curwinX(Indexmin))).^2 +  (curwinY(i)-(curwinY(Indexmin))).^2 +  (curwinZ(i)-(curwinZ(Indexmin))).^2);
   
   slopeZSecondPart(i) = (curwinZ(i)-(curwinZ(Indexmin))) /...
       sqrt( (curwinX(i)-(curwinX(Indexmin))).^2 +  (curwinY(i)-(curwinY(Indexmin))).^2);
   
end

zenithSecondPart = 180/pi*atan(slopeZSecondPart);
%% en kucuk z degerinden oncesi ve sonrasi icin elde edilen degerler tek vektorde birlestirildi

distanceXYZSecondPart(1:Indexmin-1) = distanceXYZFirstPart;
distanceXYZ = distanceXYZSecondPart;

slopeZSecondPart(1:Indexmin-1) = slopeZFirstPart;
slopeZ = slopeZSecondPart;

zenithSecondPart(1:Indexmin-1) = zenithFirstPart;
zenith = zenithSecondPart;

%% Esik degeri egimin standart sapmasinin 0.47 kati secildi
%% 0.15 ile 0.5 arasi bir deger secmek mantikli

thresholdZ = 0.47*std(slopeZ);
%% filtrelenmis deger hesalpandi
zFiltered(indexShift,:) = (curwinZ.*(slopeZ>thresholdZ)');

st = st + wininc;
en = en + wininc;
end
%% filtrelenmis Z degeri vektor haline cevrildi filtre sonucu esigin altinda
%% kalan z degerleri sifir (0) ile degistirildi ve filtrenin sonucu karsilastirma
%% amacli plot3 ile cizdirildi

zFilteredT = zFiltered';
zFilteredN = zFilteredT(:);
plot3(x,y,z)
title('Ham Lidar Verisi')
figure
plot3(x,y,zFilteredN)
title('Egim Filtresi')