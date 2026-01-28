%% INTRODUCTION
% This script computes the number of equilibrium stages required for
% liquid–liquid counter-current extraction using the function
% counterFlow_function. The attached process diagram can be used to
% interpret the process variables and notation.


%% INITIALIZATION
close all;
clear;
clc;


%% EQUILIBRIUM DATA (MASS FRACTIONS)

% Raffinate phase equilibrium data (x_S vs x_D)
xS_eq = [0.0596  0.1397  0.1905  0.2300  0.2692  0.2763  0.3088  0.3573  ...
         0.4090  0.4605  0.5178  0.5800];
xD_eq = [0.0052  0.0068  0.0079  0.0100  0.0102  0.0104  0.0117  0.0160  ...
         0.0210  0.0375  0.0652  0.1460];

% Extract phase equilibrium data (y_S vs y_D)
yS_eq = [0.0875  0.2078  0.2766  0.3706  0.3852  0.3939  0.4297  0.4821  ...
         0.5395  0.5740  0.6034  0.5800];
yD_eq = [0.9093  0.7832  0.7101  0.6085  0.5921  0.5821  0.5392  0.4757  ...
         0.4000  0.3370  0.2626  0.1460];


%% PROCESS SPECIFICATIONS

% Target solute mass fraction in final raffinate stream (R_n)
xSn = 0.06;

% Raffinate feed specification
Ro  = 200;   % Raffinate feed mass flow rate [kg/h]
xSo = 0.45;  % Solute mass fraction in raffinate feed (R_o)
xDo = 0.0;   % Solvent mass fraction in raffinate feed (R_o)

% Extract feed specification
Eo  = 400;   % Extract feed mass flow rate [kg/h]
ySo = 0.0;   % Solute mass fraction in extract feed (E_o)
yDo = 1.0;   % Solvent mass fraction in extract feed (E_o)

% Polynomial degree for equilibrium curve fitting (recommended: 2)
P_degree = 2;


%% BASE CASE CALCULATION

% Call to main counter-current extraction function
[R,E,n,M,pole,Ro,Eo,P_raffinate,P_extract,desired_separation] = ...
    counterFlow_function(Ro,Eo,ySo,yDo,xSo,xDo,P_degree, ...
                         yS_eq,xS_eq,yD_eq,xD_eq,xSn);

% Plot operating diagram and stages
figure(1);
counterFlow_plot_function(R,E,n,M,pole,Ro,Eo, ...
                          P_raffinate,P_extract,desired_separation, ...
                          xSo,xDo,ySo,yDo,xS_eq);


%% SENSITIVITY: NUMBER OF STAGES AS A FUNCTION OF Ro

% We can evaluate how the required number of stages (n) varies with the
% raffinate feed flow rate Ro.

Ro_from = 100;
Ro_to   = 1200;

Ro_plot = [];
n_plot  = [];

interval    = Ro_to - Ro_from;
Ro_linspace = linspace(Ro_from,Ro_to,interval);

for i = 1:interval
    [R,E,n,M,pole,Ro,Eo,P_raffinate,P_extract,desired_separation] = ...
        counterFlow_function(Ro_linspace(i),Eo,ySo,yDo,xSo,xDo, ...
                             P_degree,yS_eq,xS_eq,yD_eq,xD_eq,xSn);

    Ro_plot = [Ro_plot; Ro];
    n_plot  = [n_plot;  n];
end

figure(2);
plot(Ro_plot,n_plot);
xlabel('R_o mass flow rate (kg/h)');
ylabel('Number of equilibrium stages required for the desired separation');


%% SENSITIVITY: SEPARATION AND E1 COMPOSITION AS A FUNCTION OF Ro

% We can also evaluate:
%   - The solute fraction in the final raffinate (R_n) as a function of Ro.
%   - The solute fraction in the first extract stage (E_1) as a function of Ro.

Ro_from = 100;
Ro_to   = 1200;

interval    = Ro_to - Ro_from;
Ro_linspace = linspace(Ro_from,Ro_to,interval);

Ro_plot   = [];
xSn_plot  = [];  % x_S in R_n
yS1_plot  = [];  % y_S in E_1

for i = 1:interval
    [R,E,n,M,pole,Ro,Eo,P_raffinate,P_extract,desired_separation] = ...
        counterFlow_function(Ro_linspace(i),Eo,ySo,yDo,xSo,xDo, ...
                             P_degree,yS_eq,xS_eq,yD_eq,xD_eq,xSn);

    Ro_plot  = [Ro_plot;  Ro];
    xSn_plot = [xSn_plot; R(end,1)]; % last raffinate stage solute fraction
    yS1_plot = [yS1_plot; E(1,1)];   % first extract stage solute fraction
end

figure(3);
plot(Ro_plot,xSn_plot);
xlabel('R_o mass flow rate (kg/h)');
ylabel('Solute mass fraction in R_n');

figure(4);
plot(Ro_plot,yS1_plot);
xlabel('R_o mass flow rate (kg/h)');
ylabel('Solute mass fraction in E_1');



