function [V, converged, i] = newtonpf(Ybus, Sbus, V0, ref, pv, pq, mpopt)
%NEWTONPF  Solves the power flow using a full Newton's method.
%   [V, CONVERGED, I] = NEWTONPF(YBUS, SBUS, V0, REF, PV, PQ, MPOPT)
%   solves for bus voltages given the full system admittance matrix (for
%   all buses), the complex bus power injection vector (for all buses),
%   the initial vector of complex bus voltages, and column vectors with
%   the lists of bus indices for the swing bus, PV buses, and PQ buses,
%   respectively. The bus voltage vector contains the set point for
%   generator (including ref bus) buses, and the reference angle of the
%   swing bus, as well as an initial guess for remaining magnitudes and
%   angles. MPOPT is a MATPOWER options struct which can be used to 
%   set the termination tolerance, maximum number of iterations, and 
%   output options (see MPOPTION for details). Uses default options if
%   this parameter is not given. Returns the final complex voltages, a
%   flag which indicates whether it converged or not, and the number of
%   iterations performed.
%
%   See also RUNPF.

%   MATPOWER
%   Copyright (c) 1996-2016, Power Systems Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%
%   This file is part of MATPOWER.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See http://www.pserc.cornell.edu/matpower/ for more info.

%% default arguments
if nargin < 7
    mpopt = mpoption;
end

%% options
tol     = mpopt.pf.tol;
max_it  = mpopt.pf.nr.max_it;

%% initialize
converged = 0;
i = 0;
V = V0;
Va = angle(V);
Vm = abs(V);

%% set up indexing for updating V
npv = length(pv);
npq = length(pq);
j1 = 1;         j2 = npv;           %% j1:j2 - V angle of pv buses
j3 = j2 + 1;    j4 = j2 + npq;      %% j3:j4 - V angle of pq buses
j5 = j4 + 1;    j6 = j4 + npq;      %% j5:j6 - V mag of pq buses

%% evaluate F(x0)
mis = V .* conj(Ybus * V) - Sbus(Vm);
F = [   real(mis([pv; pq]));
        imag(mis(pq))   ];

%% check tolerance
normF = norm(F, inf);
if mpopt.verbose > 1
    fprintf('\n it    max P & Q mismatch (p.u.)');
    fprintf('\n----  ---------------------------');
    fprintf('\n%3d        %10.3e', i, normF);
end
if normF < tol
    converged = 1;
    if mpopt.verbose > 1
        fprintf('\nConverged!\n');
    end
end

%% do Newton iterations
while (~converged && i < max_it)
    %% update iteration counter
    i = i + 1;
    
    %% evaluate Jacobian
    [dSbus_dVm, dSbus_dVa] = dSbus_dV(Ybus, V);
    [dummy, neg_dSd_dVm] = Sbus(Vm);
    dSbus_dVm = dSbus_dVm - neg_dSd_dVm;
    
    j11 = real(dSbus_dVa([pv; pq], [pv; pq]));
    j12 = real(dSbus_dVm([pv; pq], pq));
    j21 = imag(dSbus_dVa(pq, [pv; pq]));
    j22 = imag(dSbus_dVm(pq, pq));
    
    J = [   j11 j12;
            j21 j22;    ];

    %% compute update step
    dx = -(J \ F);

    %% update voltage
    if npv
        Va(pv) = Va(pv) + dx(j1:j2);
    end
    if npq
        Va(pq) = Va(pq) + dx(j3:j4);
        Vm(pq) = Vm(pq) + dx(j5:j6);
    end
    V = Vm .* exp(1j * Va);
    Vm = abs(V);            %% update Vm and Va again in case
    Va = angle(V);          %% we wrapped around with a negative Vm

    %% evalute F(x)
    mis = V .* conj(Ybus * V) - Sbus(Vm);
    F = [   real(mis([pv;pq]));
            imag(mis(pq))   ];

    %% check for convergence
    normF = norm(F, inf);
    if mpopt.verbose > 1
        fprintf('\n%3d        %10.3e', i, normF);
    end
    if normF < tol
        converged = 1;
        if mpopt.verbose
            fprintf('\nNewton''s method power flow converged in %d iterations.\n', i);
        end
    end
end

if mpopt.verbose
    if ~converged
        fprintf('\nNewton''s method power flow did not converge in %d iterations.\n', i);
    end
end
