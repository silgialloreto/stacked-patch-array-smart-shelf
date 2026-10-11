%% definiamo una patch alla f=2.45GHz
clear all; clc; close all;
f=2.45e9; % [Hz]
lambda=physconst('LightSpeed')/f;
epsr=4.4;
tandelta=0.0260;
h=1.6e-3; % spessore di un singolo strato di substrato
Rin=50; % espressa in [Ohm]
W=0.0372;
epseff=(epsr+1)/2+((epsr-1)/2)/(sqrt(1+12*h/W)); % costante dielettrica efficace

delta_L=h*0.412*(epseff+0.3)*(W/h+0.264)/((epseff-0.258)*(W/h+0.8)); % deltaL dovuti alla presenza dei fringing fields
Leff=physconst('LightSpeed')/(2*f*sqrt(epseff)); % lunghezza efficacie del patch
L=0.0288;
beta=2*pi*(sqrt(epseff)/lambda); % costante di propagazione del substrato
k0=2*pi/lambda; % costante di propagazione nel vuoto
Rr=60*lambda*(1-1/24*(k0*h)^2)/W;
Lfeed=1/beta*acos(sqrt(Rin/Rr));
Dmax=Rr*(4/(377*pi))*(2*pi*W/lambda)^2;
DmaxdB=10*log10(Dmax);
BWh=2*acos(sqrt(1/(2+k0*W)));
BWe=2*acos(sqrt((7.03*lambda^2)/(4*pi^2*(3*Leff^2+h^2))));
%% Creazione della patch
Micro_Patch=patchMicrostrip();
Micro_Patch.FeedOffset=[L/2-Lfeed,0];
Micro_Patch.Length=L;
Micro_Patch.Width=W;
Micro_Patch.GroundPlaneLength=0.0384;
Micro_Patch.GroundPlaneWidth=0.0468;
show(Micro_Patch);
%% implementazione patch (Creazione del substrato)
Micro_Patch.Conductor=metal("Name",'Copper');
Duroid5880=dielectric('Name','Duroid5880','EpsilonR',epsr,'LossTangent',tandelta);
Micro_Patch.Height=2*h;
Micro_Patch.Substrate=Duroid5880;
show(Micro_Patch);
%% Configurazione della mesh
mesh(Micro_Patch,MaxEdgeLength=lambda/10)
mesh(Micro_Patch);
figure
mesh(Micro_Patch,View="metal")

%% Calcolo correnti
figure()
current(Micro_Patch,f) %Correnti
%% Simulazione
% Parametri S
freqRange = linspace(2.2e9, 2.4e9, 50); % Intervallo di frequenze
S = sparameters(Micro_Patch, freqRange);
figure;
rfplot(S); % Grafico del coefficiente di riflessione S11
% Impedenza di ingresso
figure;
impedance(Micro_Patch, freqRange);
title('Impedenza di Ingresso');
% Pattern di radiazione
figure;
pattern(Micro_Patch, f, 'Type', 'directivity');
title('Pattern di Direttività');
figure;
pattern(Micro_Patch,f,'Type','gain');
title('guadagno');
%% Larghezza di banda
% Definizione dell'intervallo di frequenze per l'analisi
freqRange = linspace(2e9, 3e9, 50); % Frequenze in Hz
S = sparameters(Micro_Patch, freqRange); % Calcolo dei parametri S
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
