[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
mpc = case30();
%% Watch case30
n_pq = sum(mpc.bus(:, BUS_TYPE) == 1);
n_pv = sum(mpc.bus(:, BUS_TYPE) == 2);
n_ref = sum(mpc.bus(:, BUS_TYPE) == 3);

fprintf('Bus Type: PQ: %d, PV: %d, REF: %d\n', n_pq, n_pv, n_ref);
%% pf case30
res = runpf(mpc, mpoption('pf.alg', 'nr'), 'meta/case30pf_nr.log', 'meta/case30pf_nr');