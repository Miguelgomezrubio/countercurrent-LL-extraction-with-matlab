function [R,E,n,M,pole,Ro,Eo,P_raffinate,P_extract,desired_separation] = ...
    counterFlow_function(Ro,Eo,ySo,yDo,xSo,xDo,P_degree,yS_eq,xS_eq,yD_eq,xD_eq,xSn)
%COUNTERFLOW_FUNCTION
%   Computes the number of equilibrium stages for a liquid-liquid
%   counter-current extraction operation using polynomial fits for the
%   equilibrium correlations.
%
%   INPUTS:
%       Ro, Eo          : Feed mass flow rates of raffinate and extract phases [kg/h]
%       ySo, yDo        : Solute / solvent mass fractions in the extract feed
%       xSo, xDo        : Solute / solvent mass fractions in the raffinate feed
%       P_degree        : Polynomial degree for equilibrium fitting (e.g. 2)
%       yS_eq, xS_eq    : Experimental equilibrium data (solute): extract vs raffinate
%       yD_eq, xD_eq    : Experimental equilibrium data (solvent): extract vs raffinate
%       xSn             : Target solute mass fraction in the final raffinate stream
%
%   OUTPUTS:
%       R               : Raffinate compositions per stage (n x [xS,xD])
%       E               : Extract compositions per stage (n x [yS,yD])
%       n               : Number of equilibrium stages
%       M               : Global mixing point composition [zSm, zDm]
%       pole            : Pole composition [zS_pole, zD_pole]
%       Ro, Eo          : Returned for convenience
%       P_raffinate     : Polynomial coefficients for raffinate equilibrium curve
%       P_extract       : Polynomial coefficients for extract equilibrium curve
%       desired_separation : Target composition vector [xSn, xDn]

    % ===== Global mixing point =====
    M_flowRate = Ro + Eo; 
    zSm = (Ro*xSo + Eo*ySo) / M_flowRate;
    zDm = (Ro*xDo + Eo*yDo) / M_flowRate;

    % ===== Polynomial equilibrium fitting =====
    P_equilibrium = polyfit(yS_eq, xS_eq, P_degree);
    P_raffinate   = polyfit(xS_eq, xD_eq, P_degree);
    P_extract     = polyfit(yS_eq, yD_eq, P_degree);

    % ===== Target equilibrium for raffinate and extract =====
    xDn = polyval(P_raffinate, xSn);

    % ===== Stage 1 calculation (minimization against operating line) =====
    yS1 = fminbnd(@(yS1)E1_function(yS1,P_extract,zSm,zDm,xSn,xDn),0,1);
    yD1 = polyval(P_extract,yS1);

    xS1 = polyval(P_equilibrium,yS1);
    xD1 = polyval(P_raffinate,xS1);

    % ===== Mass balance to compute stage flows =====
    E1_massFlow = (Ro*(xSo-xSn) + Eo*(ySo-xSn)) / (yS1 - xSn);
    Rn_massFlow = Eo + Ro - E1_massFlow; %#ok<NASGU>

    % ===== Pole point calculation =====
    pole_flow = E1_massFlow - Ro;
    zS_pole = (E1_massFlow*yS1 - Ro*xSo) / pole_flow;
    zD_pole = (E1_massFlow*yD1 - Ro*xDo) / pole_flow;

    % ===== Initialization =====
    n = 1;
    E = [yS1, yD1];
    R = [xS1, xD1];
    xS_loop = 1.1;

    M    = [zSm, zDm];
    pole = [zS_pole, zD_pole];
    desired_separation = [xSn, xDn];

    % ===== Counter-current stepping loop =====
    while xS_loop > xSn
        
        if n > 130
            disp('ERROR: Convergence error or excessive number of stages');
            return
        end

        yS = fminbnd(@(yS)pole_intersection(n,yS,zS_pole,zD_pole,R,P_extract),0,E(n,1));
        yD = polyval(P_extract,yS);
        E = [E; yS, yD];

        xS = polyval(P_equilibrium,yS);
        xD = polyval(P_raffinate,xS);
        R = [R; xS, xD];

        n = n + 1;
        xS_loop = xS;
    end

    Number_of_equilibrium_stages = n; %#ok<NASGU>

end

% =========================================================================
% SUBFUNCTIONS
% =========================================================================

function FO = E1_function(yS1,P_extract,zSm,zDm,xSn,xDn)
%OBJ FOR STAGE 1 COMPUTATION
%   Compares equilibrium curve and operating line for stage 1.

    yD1_equilibrium = polyval(P_extract,yS1);

    m = (zDm - xDn) / (zSm - xSn);
    b = xDn - m*xSn;

    yD1_line = m*yS1 + b;

    FO = (yD1_equilibrium - yD1_line)^2;
end


function FO = pole_intersection(n,yS,zS_pole,zD_pole,R,P_extract)
%OBJ FOR POLE-LINE INTERSECTION
%   Minimizes distance between equilibrium and pole-based operating line.

    m = (zD_pole - R(n,2)) / (zS_pole - R(n,1));
    b = -m*zS_pole + zD_pole;

    yD_equilibrium = polyval(P_extract,yS);
    yD_line = m*yS + b;

    FO = (yD_line - yD_equilibrium)^2;
end
