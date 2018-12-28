function maxr = q1s1(mpc, ptdf, p)
%% const
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
%% prepare
branchp = @(x)(x.branch(:, PF) - x.branch(:, PT)) / 2;
org_brp = branchp(mpc);
%% 当位于2号节点的发电机有功出力减小0.1、1与10时
node = 2;
target = find(mpc.gen(:, GEN_BUS) == node); % find the gen
md = mpc;
md.gen(target, PG) = md.gen(target, PG) - p;
mdres = runpf(md, mpoption('pf.alg', 'nr','verbose', 0));
mbrp = branchp(mdres) - org_brp;
cbrp = - p * ptdf(:, node);
r = abs((cbrp - mbrp) ./ branchp(mdres));
r(r == Inf) = 0;
maxr = max(r);
end