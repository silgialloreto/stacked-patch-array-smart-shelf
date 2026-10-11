%% definiamo una patch alla f=2.45GHz
clear all; clc; close all;
f=2.45e9; %[Hz]
lambda=physconst('LightSpeed')/f;
epsr=2.2; 
tandelta=9e-4;
h=1.3e-3; % spessore di un singolo strato di substrato
Rin=50; % espressa in [Ohm]
W=0.0429;
epseff=(epsr+1)/2+((epsr-1)/2)/(sqrt(1+12*h/W)); % costante dielettrica efficace
delta_L=h*0.412*(epseff+0.3)*(W/h+0.264)/((epseff-0.258)*(W/h+0.8)); % deltaL dovuti alla presenza dei fringing fields
Leff=physconst('LightSpeed')/(2*f*sqrt(epseff)); % lunghezza efficacie del patch
L=0.0383;
beta=2*pi*(sqrt(epseff)/lambda); % costante di propagazione del substrato
k0=2*pi/lambda; % costante di propagazione nel vuoto
Rr=60*lambda*(1-1/24*(k0*h)^2)/W;
Lfeed=1/beta*acos(sqrt(Rin/Rr)); % punto di alimentazione

Dmax=Rr*(4/(377*pi))*(2*pi*W/lambda)^2;
DmaxdB=10*log10(Dmax);
BWh=2*acos(sqrt(1/(2+k0*W)));
BWe=2*acos(sqrt((7.03*lambda^2)/(4*pi^2*(3*Leff^2+h^2))));

%% Creazione della patch
Micro_Patch=patchMicrostrip();

Micro_Patch.FeedOffset=[L/2-Lfeed,0];
Micro_Patch.Length=L;
Micro_Patch.Width=W;
Micro_Patch.GroundPlaneLength=2*L; 
Micro_Patch.GroundPlaneWidth=2*W;

show(Micro_Patch);

%% implementazione patch (Creazione del substrato)
Micro_Patch.Conductor=metal("Name",'Copper');
Duroid5880=dielectric('Name','Duroid5880','EpsilonR',epsr,'LossTangent',tandelta);
Micro_Patch.Height=2*h;
Micro_Patch.Substrate=Duroid5880;

show(Micro_Patch);

%% Configurazione della mesh
mesh(Micro_Patch, 'MaxEdgeLength',lambda/26);
mesh(Micro_Patch);
figure
mesh(Micro_Patch,view="metal");
%% ottimizzazione mesh
meshDensities = 10:2:45; % Diversi valori di densità della mesh
s11_values = zeros(size(meshDensities)); % Array per salvare i valori di S11
for i = 1:length(meshDensities)
   % Configura la mesh
   mesh(Micro_Patch, 'MaxEdgeLength', lambda / meshDensities(i));
   % Calcola il coefficiente di riflessione S11
   S = sparameters(Micro_Patch, f); % Calcola S11 a 2.45 GHz
   s11_values(i) = 20 * log10(abs(S.Parameters(1, 1, 1))); % Salva in dB
   disp(['Densità della mesh (n): ', num2str(meshDensities(i))]);
end
% Grafico di S11 al variare della densità della mesh
figure;
plot(meshDensities, s11_values, '-o', 'LineWidth', 1.5);
xlabel('Densità della mesh (n)');
ylabel('Coefficiente di riflessione (S_{11}) [dB]');
title('S_{11} al variare della densità della mesh');
grid on;

%% contour plot
% Definizione dei range di W e L
W_range = 0.041:0.0005:0.045; % Gamma di W
L_range = 0.037:0.0005:0.040; % Gamma di L
% Inizializzazione delle variabili per i risultati
Gamma = zeros(length(L_range), length(W_range));
for i = 1:length(L_range)
    for j = 1:length(W_range)
        % Parametri geometrici
        W = W_range(j);
        L = L_range(i);
        
        % Calcolo della resistenza di radiazione
        Rr = (60 * lambda / W) * (1 - (1 / 24) * (k0 * h)^2)^(-1);
        
       
         % Calcolo del punto di alimentazione Lfeed
        Lfeed = 1 / beta * acos(sqrt(Rin / Rr));
        
        % Controllo di validità di Lfeed
        if isnan(Lfeed) || ~isreal(Lfeed)
            Gamma(i, j) = NaN; % Salta valori non fisici
            continue;
        end
        
       Micro_Patch=patchMicrostrip();
       Micro_Patch.FeedOffset=[L/2-Lfeed,0];
       Micro_Patch.Length=L;
       Micro_Patch.Width=W;
       Micro_Patch.GroundPlaneLength=2*L;
       Micro_Patch.GroundPlaneWidth=2*W;
       % implementazione patch (Creazione del substrato)
       Micro_Patch.Conductor=metal("Name",'Copper');
       Duroid5880=dielectric('Name','Duroid5880','EpsilonR',epsr,'LossTangent',tandelta);
       Micro_Patch.Height=2*h;
       Micro_Patch.Substrate=Duroid5880;
       %configurazione mesh
       mesh(Micro_Patch, 'MaxEdgeLength',lambda/26)
     
        
        % Calcolo di S11
        S = sparameters(Micro_Patch, f);
        Gamma(i, j) = abs(S.Parameters(1, 1, 1)); % Modulo di S11
        
        % Debugging dei valori calcolati
        disp(['W: ', num2str(W), ', L: ', num2str(L), ...
              ', Rr: ', num2str(Rr), ...
              ', Lfeed: ', num2str(Lfeed), ...
              ', S11 (dB): ', num2str(20 * log10(Gamma(i, j)))]);
    end
end
% Creazione del contour plot
figure();
contourf(W_range, L_range, 20 * log10(Gamma)); % Livelli più dettagliati
colorbar;
xlabel('W (m)');
ylabel('L (m)');
title('S11 (dB) Contour Plot');
grid on;
 
%% Simulazione
freqRange = linspace(2.2e9, 2.8e9, 20); % Intervallo di frequenze
S = sparameters(Micro_Patch,freqRange );
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

% Guadagno
figure;
pattern(Micro_Patch, f, 'Type', 'gain');
title('Pattern di Guadagno');

%% Larghezza di banda
freqRange = linspace(2.3e9, 2.6e9, 100); % Frequenze in Hz
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
%% beamwidth
figure(1);
beamwidth(Micro_Patch, f,0,0:360);
figure(2);
beamwidth(Micro_Patch, f,0:360,0);

%% visualize E field
figure()
EHfields(Micro_Patch,f)
%% return loss
freqRange = linspace(2e9,3e9,50);
returnLoss(Micro_Patch, freqRange);
 
%% corrente
figure;
current(Micro_Patch, f); 

% Impostazione del range della barra dei colori
clim([0, 6]); 
colorbar;