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
p.FeedViaModel = 'square';
figure
show(p)

%% mesh
mesh(p,MaxEdgeLength=lambda/26);


%% stacked patch mesh
figure
mesh(p,view='metal')

%% simulazione
Zref = 50;
freqRange = linspace(2.3e9, 2.9e9, 60);
s = sparameters(p,freqRange,Zref);
figure;
rfplot(s);

figure;
impedance(p,freqRange);
title('Impedenza di Ingresso');

%% Larghezza di banda
freqRange = linspace(2.2e9, 2.8e9, 50); % Frequenze in Hz
S = sparameters(p, freqRange); % Calcolo dei parametri S
% Estrarre il coefficiente S11
s11 = squeeze(S.Parameters(1, 1, :)); % Vettore 1D per S11
% Calcolare il modulo di S11 in dB
s11_dB = 20 * log10(abs(s11));
% Trovare le frequenze in cui S11 è inferiore a -10 dB
bandwidth_indices = find(s11_dB < -10); % Indici delle frequenze valide
freq_band = freqRange(bandwidth_indices); % Frequenze corrispondenti
% Larghezza di banda
bandwidth = (max(freq_band) - min(freq_band)) / 1e6; % in MHz
% Visualizzare il grafico
figure;
plot(freqRange / 1e9, s11_dB, '-b', 'LineWidth', 1.5);
hold on;
yline(-10, '--r', 'Soglia -10 dB', 'LineWidth', 1.2); % Soglia -10 dB
xline(min(freq_band) / 1e9, '--g', 'f_{min}', 'LineWidth', 1.2);
xline(max(freq_band) / 1e9, '--g', 'f_{max}', 'LineWidth', 1.2);
xlabel('Frequenza (GHz)');
ylabel('S_{11} (dB)');
title(['Larghezza di Banda: ', num2str(bandwidth, '%.2f'), ' MHz']);
grid on;
legend('S_{11}', 'Soglia -10 dB', 'Bordi Banda');
hold off;

%% Pattern di radiazione
figure;
pattern(p, f, 'Type', 'directivity');
title('Pattern di Direttività');

% Guadagno
figure;
pattern(p, f, 'Type', 'gain');
title('Pattern di Guadagno');
%% beamwidth
subplot(1,1,2);
beamwidth(p, f,0,0:360);
subplot(2,1,1);
beamwidth(p, f,0:360,0);

%% pattern sul piano E e H
patternElevation(p,f); % il piano di elevazione contiene le linee di forza di E
hold on; 
%figure;
%patternAzimuth(p,f); % il pinao di Azimuth contiene le linee di forza del campo H
%figure;
%pattern(p,f,'type','efield'); % visualizzazione del solo campo elettrico
%figure;
%EHfields(p,f); % rappresentazione vettoriale del campo E e H

%% return loss
freqRange = linspace(2e9,3e9,50);
figure;
returnLoss(p, freqRange);

