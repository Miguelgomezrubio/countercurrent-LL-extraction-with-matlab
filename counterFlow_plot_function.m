function [] = counterFlow_plot_function( ...
    R,E,n,M,pole,Ro,Eo,P_raffinate,P_extract,desired_separation, ...
    xSo,xDo,ySo,yDo,xS_eq)
%COUNTERFLOW_PLOT_FUNCTION
%   Produces a graphical representation of the counter-current
%   liquid–liquid extraction stage calculation.
%
%   INPUTS:
%       R                 : [n x 2] raffinate compositions per stage (xS, xD)
%       E                 : [n x 2] extract compositions per stage (yS, yD)
%       n                 : Number of equilibrium stages
%       M                 : Global mixing point composition [zS_M, zD_M]
%       pole              : Pole composition [zS_pole, zD_pole]
%       Ro, Eo            : Raffinate and extract feed flow rates [kg/h]
%       P_raffinate       : Polynomial coefficients for raffinate equilibrium
%       P_extract         : Polynomial coefficients for extract equilibrium
%       desired_separation: Target raffinate composition [xSn, xDn]
%       xSo, xDo          : Raffinate feed composition (xS, xD)
%       ySo, yDo          : Extract feed composition (yS, yD)
%       xS_eq             : Raffinate solute equilibrium data (for x-range)
%
%   The function assumes an active figure and overlays curves and markers.

    % ---------------------------------------------------------------------
    % Plot style settings
    % ---------------------------------------------------------------------
    markerSize = 5;

    % Label offsets for marker text
    hOffsetExtract   = 0.00;   % Horizontal offset for extract stage labels
    vOffsetExtract   = 0.045;  % Vertical offset for extract stage labels

    hOffsetRaffinate = 0.003;  % Horizontal offset for raffinate stage labels
    vOffsetRaffinate = -0.04;  % Vertical offset for raffinate stage labels

    hOffsetMixing    = 0.005;  % Horizontal offset for mixing point label
    vOffsetMixing    = 0.01;   % Vertical offset for mixing point label


    % ---------------------------------------------------------------------
    % Equilibrium curves (raffinate and extract)
    % ---------------------------------------------------------------------
    X = linspace(0, xS_eq(end), 30);

    D_plot_ref_eq  = polyval(P_raffinate, X);
    D_plot_extr_eq = polyval(P_extract,   X);

    hold on;

    % Plot raffinate and extract equilibrium curves
    plot(X, D_plot_ref_eq,  'Color', 'k');
    plot(X, D_plot_extr_eq, 'Color', 'k');

    xlabel('y_S , x_S');
    ylabel('y_D , x_D');
    title( ...
        ['Graphical view of stage calculation, R_o = ', num2str(Ro), ...
         '  E_o = ', num2str(Eo), ' [kg/h]'] ...
    );


    % ---------------------------------------------------------------------
    % Stage operating lines (from extract to raffinate)
    % ---------------------------------------------------------------------
    for i = 1:n
        plot([E(i,1), R(i,1)], [E(i,2), R(i,2)], ...
             'Color', [0.8500, 0.3250, 0.0980]);
    end


    % ---------------------------------------------------------------------
    % Pole-based lines
    % ---------------------------------------------------------------------
    if pole(2) <= 1
        % Pole inside diagram region
        for i = 1:n
            plot([pole(1), E(i,1)], [pole(2), E(i,2)], ...
                 'Color', [0, 0.4470, 0.7410]);
        end
    else
        % Pole outside diagram region; draw lines toward feed and stages
        for i = 1:n
            plot([pole(1), xSo], [pole(2), xDo], ...
                 'Color', [0, 0.4470, 0.7410]);
            plot([pole(1), R(i,1)], [pole(2), R(i,2)], ...
                 'Color', [0, 0.4470, 0.7410]);
        end
    end


    % ---------------------------------------------------------------------
    % Global mixing lines and feed lines
    % ---------------------------------------------------------------------
    % Line from desired separation to first extract stage
    plot([desired_separation(1), E(1,1)], ...
         [desired_separation(2), E(1,2)], 'Color', 'r');

    % Line between extract and raffinate feeds
    plot([ySo, xSo], [yDo, xDo], 'Color', 'r');

    % Feed and mixing points
    plot(M(1),   M(2),   'o', 'MarkerSize', markerSize, ...
         'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    plot(xSo,    xDo,    'o', 'MarkerSize', markerSize, ...
         'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    plot(ySo,    yDo,    'o', 'MarkerSize', markerSize, ...
         'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');


    % ---------------------------------------------------------------------
    % Markers and annotations
    % ---------------------------------------------------------------------
    stageIndex = 1:130;   % Maximum allowed number of stages (consistent with solver)

    % Pole marker
    plot(pole(1), pole(2), 'o', 'MarkerSize', markerSize, ...
         'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    text(pole(1) + 0.01, pole(2) + 0.01, '\Delta (POLE)');

    % Mixing point marker
    plot(M(1), M(2), 'o', 'MarkerSize', markerSize, ...
         'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    text(M(1) + hOffsetMixing, M(2) + vOffsetMixing, 'M');

    % Feed markers: R_o and E_o
    plot(xSo, xDo, 'o', 'MarkerSize', markerSize, ...
         'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    text(xSo, xDo - 0.08, 'R_o');

    plot(ySo, yDo, 'o', 'MarkerSize', markerSize, ...
         'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    text(ySo, yDo + 0.08, 'E_o');

    % Raffinate stage markers
    for i = 1:n
        plot(R(i,1), R(i,2), 'o', 'MarkerSize', markerSize, ...
             'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');

        labelR = ['R', num2str(stageIndex(i))];
        text(R(i,1) + hOffsetRaffinate, ...
             R(i,2) + vOffsetRaffinate, {labelR});
    end

    % Extract stage markers
    for i = 1:n
        plot(E(i,1), E(i,2), 'o', 'MarkerSize', markerSize, ...
             'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');

        labelE = ['E', num2str(stageIndex(i))];
        text(E(i,1) + hOffsetExtract, ...
             E(i,2) + vOffsetExtract, {labelE});
    end

    % Desired separation marker
    plot(desired_separation(1), desired_separation(2), '^', ...
         'MarkerSize', 5, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');

end
