%% Definizione delle dimensioni
clear all; clc; close all;
f=2.45e9; % [Hz]
lambda=physconst('LightSpeed')/f;
L1 = 0.0289; % Lunghezza della patch inferiore [m]
W1 = 0.0372; % Larghezza della patch inferiore [m]
L2=0.0303;
W2=0.0391;
h1 =0.0016; % Spessore del substrato inferiore [m]
h2 = 0.0025;   % Spessore del substrato superiore [m]
epsr=4.4;
epseff=(epsr+1)/2+((epsr-1)/2)/(sqrt(1+12*h1/W1));
beta=2*pi*(sqrt(epseff)/lambda); % costante di propagazione del substrato
k0=2*pi/lambda;
Rin=50;
Rr=60*lambda*(1-1/24*(k0*h1)^2)/W1;
Lfeed=1/beta*acos(sqrt(Rin/Rr));
r_0 = 0.325 * 1e-3; % Raggio del pin di alimentazione [m]
Lgnd = 0.03849;      % Lunghezza del piano di massa [m]
Wgnd =0.04686 ;      % Larghezza del piano di massa [m]

%% Materiali dei substrati
epsr1 = 4.4; % Costante dielettrica del substrato inferiore
epsr2 = 4.4 ; % Costante dielettrica del substrato superiore

tandelta1 =0.0260; % Tangente di perdita
tandelta2= 0.0260;

% Creazione dei substrati
substrato1 = dielectric('Name','FR4','EpsilonR',epsr1,'LossTangent',tandelta1,'Thickness', h1);
substrato2 = dielectric('Name','FR4','EpsilonR',epsr2,'LossTangent',tandelta2,'Thickness', h2);

%% Creazione delle patch
% Patch inferiore
Micro_PatchInf=antenna.Rectangle();
Micro_PatchInf.Length=L1;
Micro_PatchInf.Width=W1;
% Patch superiore
Micro_PatchSup=antenna.Rectangle();
Micro_PatchSup.Length=L2;
Micro_PatchSup.Width=W2;
% ground
pGnd = antenna.Rectangle(Length=Lgnd,Width=Wgnd);
%% Visualizzazione delle componenti
figure;
show(Micro_PatchInf);
title('Patch Inferiore');
figure;
show(Micro_PatchSup);
title('Patch Superiore');
%% stacked
p = pcbStack;
p.Name = 'Stacked patch';
p.BoardShape = pGnd;
p.BoardThickness = h1+h2;
p.Layers = {Micro_PatchSup, substrato2, Micro_PatchInf, substrato1, pGnd};
p.Conductor = metal('Name', 'Copper'); % Imposta il conduttore come rame
p.FeedLocations = [Lfeed 0 3 5];
p.FeedDiameter = 2*r_0;
p.FeedViaModel='square';
figure
show(p)
%% mesh
mesh(p,MaxEdgeLength=lambda/10);
figure
mesh(p,view='metal')
%% array
d=0.0917; %distanza ottimale tra le patch

Array=conformalArray('Element', p,'ElementPosition',[0,0,0;0,d,0;0,2*d,0;0,3*d,0;0,4*d,0],'AmplitudeTaper',[2.06 4.19 5.26 4.19 2.06]);
show(Array);
%% pattern gain
figure;
pattern(Array,f);
figure;
patternAzimuth(Array,f)
figure;
patternElevation(Array,f)
%% BW in funzione di d
d=0:0.001:lambda;
for i=1:length(d)
    BW(i)=(pi-2*(acos((1.73*lambda)/(2*pi*d(i)))))*180/pi;
end
figure();
plot(d,BW)
%% andamento coefficienti
n=linspace(-2,2,5);
C2=2.06;
C1=4.19;
C0=5.26;
Cn=[C2 C1 C0 C1 C2];
figure();
stem(n,Cn)

%% pattern direttività
figure;
patternAzimuth(Array,f)
figure;
pattern(Array, f, 'Type', 'directivity');