%% Definizione delle dimensioni
clear all; clc; close all;
f=2.45e9; % [Hz]
lambda=physconst('LightSpeed')/f;
L1 = 0.0288; % Lunghezza della patch inferiore [m]
W1 = 0.0372; % Larghezza della patch inferiore [m]
L2=0.0274;
W2=0.0354;
h1 =1.6e-3; % Spessore del substrato inferiore [m]
h2 = 0.003;   % Spessore del substrato superiore [m]
epsr=4.4;
epseff=(epsr+1)/2+((epsr-1)/2)/(sqrt(1+12*h1/W1));
beta=2*pi*(sqrt(epseff)/lambda); % costante di propagazione del substrato
k0=2*pi/lambda;
Rin=50;
Rr=60*lambda*(1-1/24*(k0*h1)^2)/W1;
Lfeed=1/beta*acos(sqrt(Rin/Rr));
r_0 = 0.325 * 1e-3; % Raggio del pin di alimentazione [m]
Lgnd = 0.0384;      % Lunghezza del piano di massa [m]
Wgnd =0.0468;      % Larghezza del piano di massa [m]

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
%% correnti figure()
figure
current(p,f)

%% simulazione
freqRange = linspace(1.5e9, 3.5e9, 50);
%freqRange = linspace(2.8e9, 3.2e9, 5);
Zref = 50;
s = sparameters(p,freqRange,Zref);
figure;
rfplot(s);
figure;
impedance(p,freqRange);
title('impedenza in ingresso');
%% guadagno
pattern(p, f, 'Type', 'gain');
title('guadagno');