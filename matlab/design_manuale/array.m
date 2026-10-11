%% Definizione delle dimensioni
clear all; clc; close all;
L1 = 0.0383; % Lunghezza della patch inferiore [m]
W1 = 0.0429; % Larghezza della patch inferiore [m]
L2 = 0.0451;
W2 = 0.0427;
h1 = 1.3e-3; % Spessore del substrato inferiore [m]
h2 = 0.0081;   % Spessore del substrato superiore [m]
Lfeed = 0.0183;   % Offset del punto di alimentazione [m]
r_0 = 0.325 * 1e-3; % Raggio del pin di alimentazione [m]
Lgnd = 2*L1;      % Lunghezza del piano di massa [m]
Wgnd = 2*W1;      % Larghezza del piano di massa [m]
f=2.45e9; % [Hz]
lambda=physconst('LightSpeed')/f;

%% Materiali dei substrati
epsr1 = 2.2; % Costante dielettrica del substrato inferiore
epsr2 = 1.03; % Costante dielettrica del substrato superiore 
tandelta1 = 9e-4; % Tangente di perdita
tandelta2= 1.5e-4;

% Creazione dei substrati
substrato1 = dielectric('Name','Duroid5880','EpsilonR',epsr1,'LossTangent',tandelta1,'Thickness', h1);
substrato2 = dielectric('Name','foam','EpsilonR',epsr2,'LossTangent',tandelta2,'Thickness', h2);
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

%% stacked
p = pcbStack;
p.Name = 'Stacked patch';
p.BoardShape = pGnd;
p.BoardThickness = h1+h2;
p.Layers = {Micro_PatchSup, substrato2, Micro_PatchInf, substrato1, pGnd};
p.Conductor = metal('Name', 'Copper'); % Imposta il conduttore come rame
p.FeedLocations = [Lfeed 0 3 5];
p.FeedDiameter = 2*r_0;
p.FeedViaModel = 'square';
figure
show(p)

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

%% Fattore di Array
% Modello del singolo elemento (patch stacked)
Elem = phased.CosineAntennaElement('FrequencyRange', [2.3e9 2.8e9], ...
    'CosinePower', [1.5 3]);
% Creazione dell'array ULA con 5 elementi
Array = phased.ULA('NumElements', 5);
lambda = 3e8 / 2.45e9; % Lunghezza d'onda
Array.ElementSpacing = 0.0917; % Spaziatura tra gli elementi
Array.Element = Elem;
% Tapering con Chebyshev
Array.Taper = chebwin(5, 25); % Riduce i lobi laterali a 25 dB
% Diagramma di radiazione totale
f = 2.45e9; % Frequenza operativa
figure;
pattern(Array, f, 'Type', 'directivity', 'PropagationSpeed', 3e8);
% Parametri
f = 2.45e9; % Frequenza operativa (2.5 GHz)
PropagationSpeed = 3e8; % Velocità della luce
w = ones(getNumElements(Array), 1); % Pesi uniformi (nessun tapering)
% Diagramma azimutale (2D - rettangolare)
figure;
pattern(Array, f, -180:180, 0, 'PropagationSpeed', PropagationSpeed, ...
    'CoordinateSystem', 'rectangular', 'weights', w, ...
    'Type', 'Directivity', 'PlotStyle', 'Overlay');
title('Diagramma Azimutale (2D - Rettangolare)');
% Diagramma U-V
figure;
pattern(Array, f, -1:0.01:1, 0, 'PropagationSpeed', PropagationSpeed, ...
    'CoordinateSystem', 'uv', 'weights', w, ...
    'Type', 'Directivity', 'PlotStyle', 'Overlay');
title('Diagramma in Coordinate U-V');

%% pattern direttività
figure;
patternAzimuth(Array,f)
figure;
pattern(Array, f, 'Type', 'directivity');
