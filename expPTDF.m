function ptdf = expPTDF(mpc)
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
N = size(mpc.bus,1);
b = size(mpc.branch,1);
slack = find(mpc.bus(:, BUS_TYPE) == REF);
slack = slack(1);
noslack = find((1:N)' ~= slack);
[~, ~, ~, ~] = makeBdc(mpc);
%% Build A
A = sparse(mpc.branch(:,[F_BUS,T_BUS]),[1:b,1:b]',[ones(b,1),-ones(b,1)]);
A = A(noslack, :);
%% Calc ptdf
xd = diag(1./mpc.branch(:,BR_X));
B0 = A * xd * A';
Xki = xd * A' / B0;
ptdf = zeros(b, N);
ptdf(:, noslack) = Xki;
end